Config = {}

Config.Framework = 'vrp'

Config.InteractionDistance = 2.0
Config.TransitionTime = 2000
Config.Cooldown = 3000
Config.EnableSounds = true
Config.EnableBlur = true

Config.Marker = {
    RenderDistance = 15.0,
    Alpha = 180,
    GroundOffset = -0.9,
    RingSize = 0.9,
    ArrowHeight = 0.6,
    ArrowSize = 0.18,
    TextHeight = 1.1,
    Color = {
        r = 180,
        g = 195,
        b = 215
    }
}

Config.Animation = {
    dict = 'anim@heists@keycard@',
    name = 'idle',
    flag = 49
}

Config.TargetSystem = 'ox_target'

Config.Elevators = {
    ['hospital'] = {
        label = 'Hospital Central',
        interaction = 'marker',
        icon = 'fa-solid fa-hospital',
        jobs = {},
        floors = {
            {
                label = 'Térreo',
                coords = vector4(340.0, -580.0, 28.8, 70.0)
            },
            {
                label = '1º Andar',
                coords = vector4(338.0, -583.0, 43.2, 70.0)
            },
            {
                label = '2º Andar',
                coords = vector4(330.0, -600.0, 50.0, 180.0)
            }
        }
    },
    ['policia'] = {
        label = 'Delegacia',
        interaction = 'target',
        icon = 'fa-solid fa-building-shield',
        jobs = {'police'},
        floors = {
            {
                label = 'Recepção',
                coords = vector4(441.8, -982.0, 30.7, 90.0)
            },
            {
                label = 'Escritórios',
                coords = vector4(441.8, -982.0, 36.7, 90.0)
            },
            {
                label = 'Cobertura',
                coords = vector4(441.8, -982.0, 42.7, 90.0)
            }
        }
    },
    ['prefeitura'] = {
        label = 'Prefeitura',
        interaction = 'marker',
        icon = 'fa-solid fa-landmark',
        jobs = {},
        floors = {
            {
                label = 'Térreo',
                coords = vector4(-544.0, -204.0, 38.2, 210.0)
            },
            {
                label = '1º Andar',
                coords = vector4(-544.0, -204.0, 45.8, 210.0)
            }
        }
    }
}
