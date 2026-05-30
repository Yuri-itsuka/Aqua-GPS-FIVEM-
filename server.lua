local gpsData = {}

local function DebugPrint(msg)
    if Config.Debug then
        print('[pk_jobgps] ' .. msg)
    end
end

local function HasGpsItem(xPlayer)
    local item = xPlayer.getInventoryItem(Config.RequiredItem)

    if not item then
        return false
    end

    return (item.count or item.amount or 0) > 0
end

RegisterNetEvent('pk_jobgps:updateOwnGps', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        gpsData[src] = nil
        DebugPrint(('No xPlayer for %s'):format(src))
        return
    end

    local job = xPlayer.getJob().name

    if not Config.AllowedJobs[job] then
        gpsData[src] = nil
        DebugPrint(('Player %s blocked: job %s not allowed'):format(src, job))
        return
    end

    if not HasGpsItem(xPlayer) then
        gpsData[src] = nil
        DebugPrint(('Player %s blocked: no item %s'):format(src, Config.RequiredItem))
        return
    end

    if not data or not data.coords then
        DebugPrint(('Player %s sent invalid gps data'):format(src))
        return
    end

    local name = xPlayer.getName()

    if not name or name == '' then
        name = GetPlayerName(src)
    end

    gpsData[src] = {
        id = src,
        name = name,
        job = job,
        sprite = tonumber(data.sprite) or 1,
        heading = tonumber(data.heading) or 0.0,
        coords = {
            x = tonumber(data.coords.x) or 0.0,
            y = tonumber(data.coords.y) or 0.0,
            z = tonumber(data.coords.z) or 0.0
        },
        lastUpdate = os.time()
    }

    DebugPrint(('Saved GPS: id=%s name=%s job=%s sprite=%s'):format(src, name, job, gpsData[src].sprite))
end)

ESX.RegisterServerCallback('pk_jobgps:getPlayers', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb({})
        return
    end

    local myJob = xPlayer.getJob().name

    if not Config.AllowedJobs[myJob] then
        DebugPrint(('Request denied: player %s job %s not allowed'):format(source, myJob))
        cb({})
        return
    end

    if not HasGpsItem(xPlayer) then
        DebugPrint(('Request denied: player %s has no item %s'):format(source, Config.RequiredItem))
        cb({})
        return
    end

    local players = {}
    local now = os.time()
    local stored = 0

    for playerId, data in pairs(gpsData) do
        stored = stored + 1

        local allowSelf = Config.ShowSelf == true
        local isSelf = playerId == source

        if (allowSelf or not isSelf) and data.job == myJob then
            if now - data.lastUpdate <= 10 then
                table.insert(players, data)
            else
                gpsData[playerId] = nil
                DebugPrint(('Removed stale GPS: %s'):format(playerId))
            end
        end
    end

    DebugPrint(('Send %s GPS blips to player %s | stored=%s | job=%s | showSelf=%s'):format(
        #players,
        source,
        stored,
        myJob,
        tostring(Config.ShowSelf)
    ))

    cb(players)
end)

RegisterCommand('gpsdebug', function(source)
    print('---------- pk_jobgps debug ----------')
    for playerId, data in pairs(gpsData) do
        print(('id=%s name=%s job=%s sprite=%s age=%ss coords=%.2f %.2f %.2f'):format(
            playerId,
            data.name,
            data.job,
            data.sprite,
            os.time() - data.lastUpdate,
            data.coords.x,
            data.coords.y,
            data.coords.z
        ))
    end
    print('-------------------------------------')
end, true)

AddEventHandler('playerDropped', function()
    gpsData[source] = nil
end)
