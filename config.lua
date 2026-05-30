Config = {}

Config.RequiredItem = 'gps'

Config.SendUpdateTime = 750
Config.ReceiveUpdateTime = 1000
Config.SmoothUpdateTime = 50
Config.SmoothSpeed = 0.22

Config.Debug = false

-- Zum Testen alleine auf true lassen.
-- Wenn mehrere Spieler testen, kannst du es auf false machen.
Config.ShowSelf = true

Config.AllowedJobs = {
    police = true,
    ambulance = true,
    mechanic = true,
    bandolo = true,
    fib = true,
    csm = true,
}

Config.Blips = {
    police = {
        sprite = 1,
        color = 3,
        scale = 0.85,
        label = 'Police GPS'
    },
    ambulance = {
        sprite = 1,
        color = 1,
        scale = 0.85,
        label = 'EMS GPS'
    },
    mechanic = {
        sprite = 1,
        color = 5,
        scale = 0.85,
        label = 'Mechanic GPS'
    },
        bandolo = {
        sprite = 1,
        color = 5,
        scale = 0.85,
        label = 'bandolo GPS'
    },
        fib = {
        sprite = 1,
        color = 5,
        scale = 0.85,
        label = 'bandolo GPS'
    },
        csm = {
        sprite = 1,
        color = 5,
        scale = 0.85,
        label = 'bandolo GPS'
    },
}

Config.VehicleSprites = {
    foot = 1,
    car = 225,
    motorcycle = 226,
    boat = 427,
    heli = 43,
    plane = 423
}
