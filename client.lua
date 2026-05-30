local PlayerJob = nil
local gpsBlips = {}
local gpsTargets = {}

local function DebugPrint(msg)
    if Config.Debug then
        print('[pk_jobgps] ' .. msg)
    end
end

local function LoadPlayerJob()
    if ESX and ESX.PlayerData and ESX.PlayerData.job then
        PlayerJob = ESX.PlayerData.job.name
        DebugPrint('Loaded job: ' .. PlayerJob)
    end
end

CreateThread(function()
    while not ESX do
        Wait(250)
    end

    while not ESX.PlayerData or not ESX.PlayerData.job do
        Wait(500)
        LoadPlayerJob()
    end

    LoadPlayerJob()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer

    if xPlayer and xPlayer.job then
        PlayerJob = xPlayer.job.name
        DebugPrint('Player loaded job: ' .. PlayerJob)
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
    PlayerJob = job.name
    DebugPrint('Job changed: ' .. PlayerJob)
    RemoveAllGpsBlips()
end)

local function IsJobAllowed()
    return PlayerJob and Config.AllowedJobs[PlayerJob] == true
end

local function GetVehicleSprite(vehicle)
    if vehicle == 0 then
        return Config.VehicleSprites.foot
    end

    local class = GetVehicleClass(vehicle)

    if class == 15 then
        return Config.VehicleSprites.heli
    elseif class == 16 then
        return Config.VehicleSprites.plane
    elseif class == 14 then
        return Config.VehicleSprites.boat
    elseif class == 8 or class == 13 then
        return Config.VehicleSprites.motorcycle
    else
        return Config.VehicleSprites.car
    end
end

local function GetOwnGpsData()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local entity = ped

    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        entity = vehicle
    end

    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)

    return {
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        heading = heading,
        sprite = GetVehicleSprite(vehicle)
    }
end

local function SetGpsBlipName(blip, name)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(name or 'GPS')
    EndTextCommandSetBlipName(blip)
end

function RemoveAllGpsBlips()
    for _, blip in pairs(gpsBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end

    gpsBlips = {}
    gpsTargets = {}
end

function UpdateGpsBlips(players)
    local activeIds = {}

    for _, data in pairs(players) do
        activeIds[data.id] = true

        local blipData = Config.Blips[data.job] or {
            sprite = 1,
            color = 0,
            scale = 0.85,
            label = 'GPS'
        }

        if not gpsBlips[data.id] then
            gpsBlips[data.id] = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)

            SetBlipSprite(gpsBlips[data.id], data.sprite or blipData.sprite)
            SetBlipColour(gpsBlips[data.id], blipData.color)
            SetBlipScale(gpsBlips[data.id], blipData.scale)
            SetBlipAsShortRange(gpsBlips[data.id], false)
            ShowHeadingIndicatorOnBlip(gpsBlips[data.id], true)
            SetBlipRotation(gpsBlips[data.id], math.floor(data.heading or 0.0))
            SetGpsBlipName(gpsBlips[data.id], data.name)

            gpsTargets[data.id] = {
                current = vector3(data.coords.x, data.coords.y, data.coords.z),
                target = vector3(data.coords.x, data.coords.y, data.coords.z),
                sprite = data.sprite or blipData.sprite,
                heading = data.heading or 0.0,
                name = data.name
            }
        else
            gpsTargets[data.id] = gpsTargets[data.id] or {}
            gpsTargets[data.id].target = vector3(data.coords.x, data.coords.y, data.coords.z)
            gpsTargets[data.id].sprite = data.sprite or blipData.sprite
            gpsTargets[data.id].heading = data.heading or 0.0
            gpsTargets[data.id].name = data.name

            SetBlipSprite(gpsBlips[data.id], gpsTargets[data.id].sprite)
            SetBlipRotation(gpsBlips[data.id], math.floor(gpsTargets[data.id].heading))
            SetGpsBlipName(gpsBlips[data.id], data.name)
        end
    end

    for id, blip in pairs(gpsBlips) do
        if not activeIds[id] then
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end

            gpsBlips[id] = nil
            gpsTargets[id] = nil
        end
    end
end

CreateThread(function()
    while true do
        Wait(Config.SendUpdateTime)

        if not PlayerJob then
            LoadPlayerJob()
        end

        if IsJobAllowed() then
            TriggerServerEvent('pk_jobgps:updateOwnGps', GetOwnGpsData())
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.ReceiveUpdateTime)

        if not PlayerJob then
            LoadPlayerJob()
        end

        if IsJobAllowed() then
            ESX.TriggerServerCallback('pk_jobgps:getPlayers', function(players)
                UpdateGpsBlips(players)
            end)
        else
            RemoveAllGpsBlips()
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.SmoothUpdateTime)

        for id, data in pairs(gpsTargets) do
            local blip = gpsBlips[id]

            if blip and DoesBlipExist(blip) and data.current and data.target then
                local speed = Config.SmoothSpeed or 0.22
                local distance = #(data.target - data.current)

                if distance > 250.0 then
                    data.current = data.target
                else
                    data.current = vector3(
                        data.current.x + ((data.target.x - data.current.x) * speed),
                        data.current.y + ((data.target.y - data.current.y) * speed),
                        data.current.z + ((data.target.z - data.current.z) * speed)
                    )
                end

                SetBlipCoords(blip, data.current.x, data.current.y, data.current.z)
                SetBlipSprite(blip, data.sprite or 1)
                SetBlipRotation(blip, math.floor(data.heading or 0.0))
                SetGpsBlipName(blip, data.name)
            end
        end
    end
end)
