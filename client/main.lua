local isUIOpen = false
local isTeleporting = false
local currentElevator = nil
local nearbyElevator = nil
local nearbyFloor = nil

CreateThread(function()
    for elevatorId, elevator in pairs(Config.Elevators) do
        if elevator.interaction == 'target' then
            SetupTarget(elevatorId, elevator)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local foundElevator = nil
        local foundFloor = nil
        local closestDist = Config.InteractionDistance + 10.0

        for elevatorId, elevator in pairs(Config.Elevators) do
            if elevator.interaction == 'pickup' then
                for i, floor in ipairs(elevator.floors) do
                    local floorPos = vector3(floor.coords.x, floor.coords.y, floor.coords.z)
                    local dist = #(pos - floorPos)

                    if dist < closestDist and dist < Config.InteractionDistance + 5.0 then
                        closestDist = dist
                        foundElevator = elevatorId
                        foundFloor = i
                        sleep = 0
                    end
                end
            end
        end

        if foundElevator and closestDist <= Config.InteractionDistance then
            local elevator = Config.Elevators[foundElevator]
            local floor = elevator.floors[foundFloor]
            local floorPos = vector3(floor.coords.x, floor.coords.y, floor.coords.z)

            DrawMarker(2,
                floorPos.x, floorPos.y, floorPos.z + 0.5,
                0.0, 0.0, 0.0,
                180.0, 0.0, 0.0,
                Config.Marker.scale.x, Config.Marker.scale.y, Config.Marker.scale.z,
                Config.Marker.color.r, Config.Marker.color.g, Config.Marker.color.b, Config.Marker.color.a,
                Config.Marker.bobUpAndDown, Config.Marker.faceCamera, 2, Config.Marker.rotate, nil, nil, false
            )

            ShowHelpText(Config.TextUI.label)

            if IsControlJustPressed(0, Config.TextUI.key) and not isUIOpen and not isTeleporting then
                OpenElevatorUI(foundElevator)
            end

            nearbyElevator = foundElevator
            nearbyFloor = foundFloor
        else
            nearbyElevator = nil
            nearbyFloor = nil

            if closestDist <= Config.InteractionDistance + 5.0 then
                sleep = 100
            end
        end

        Wait(sleep)
    end
end)

function ShowHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function SetupTarget(elevatorId, elevator)
    for i, floor in ipairs(elevator.floors) do
        local floorPos = vector3(floor.coords.x, floor.coords.y, floor.coords.z)

        if Config.TargetSystem == 'ox_target' then
            if GetResourceState('ox_target') == 'started' then
                exports.ox_target:addSphereZone({
                    coords = floorPos,
                    radius = Config.InteractionDistance,
                    debug = false,
                    options = {
                        {
                            name = 'elevator_' .. elevatorId .. '_' .. i,
                            label = 'Usar Elevador - ' .. elevator.label,
                            icon = elevator.icon or 'fa-solid fa-elevator',
                            onSelect = function()
                                OpenElevatorUI(elevatorId)
                            end,
                            canInteract = function()
                                return not isUIOpen and not isTeleporting
                            end
                        }
                    }
                })
            end
        elseif Config.TargetSystem == 'vrp_target' then
            if GetResourceState('vrp_target') == 'started' then
                exports.vrp_target:addPoint(
                    'elevator_' .. elevatorId .. '_' .. i,
                    floorPos,
                    Config.InteractionDistance,
                    {
                        {
                            label = 'Usar Elevador - ' .. elevator.label,
                            icon = elevator.icon or 'fa-solid fa-elevator',
                            action = function()
                                OpenElevatorUI(elevatorId)
                            end
                        }
                    }
                )
            end
        elseif Config.TargetSystem == 'creative_target' then
            if GetResourceState('creative_target') == 'started' then
                exports.creative_target:addPoint({
                    id = 'elevator_' .. elevatorId .. '_' .. i,
                    coords = floorPos,
                    distance = Config.InteractionDistance,
                    options = {
                        {
                            label = 'Usar Elevador - ' .. elevator.label,
                            icon = elevator.icon or 'fa-solid fa-elevator',
                            event = 'elevator:openFromTarget',
                            args = {elevatorId = elevatorId}
                        }
                    }
                })
            end
        end
    end
end

RegisterNetEvent('elevator:openFromTarget', function(data)
    if data and data.elevatorId then
        OpenElevatorUI(data.elevatorId)
    end
end)

function OpenElevatorUI(elevatorId)
    if isUIOpen or isTeleporting then return end

    local elevator = Config.Elevators[elevatorId]
    if not elevator then return end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local currentFloor = Shared.GetCurrentFloor(elevatorId, pos)

    currentElevator = elevatorId
    isUIOpen = true

    SetNuiFocus(true, true)

    local floorsData = {}
    for i, floor in ipairs(elevator.floors) do
        table.insert(floorsData, {
            index = i,
            label = floor.label,
            isCurrent = (i == currentFloor)
        })
    end

    SendNUIMessage({
        action = 'openElevator',
        elevator = {
            id = elevatorId,
            label = elevator.label,
            icon = elevator.icon or 'fa-solid fa-elevator',
            floors = floorsData,
            currentFloor = currentFloor
        },
        enableBlur = Config.EnableBlur,
        enableSounds = Config.EnableSounds
    })
end

RegisterNUICallback('selectFloor', function(data, cb)
    cb('ok')

    if not currentElevator or isTeleporting then return end

    local floorIndex = tonumber(data.floor)
    if not floorIndex then return end

    CloseElevatorUI()
    TriggerServerEvent('elevator:requestTeleport', currentElevator, floorIndex)
end)

RegisterNUICallback('closeElevator', function(_, cb)
    cb('ok')
    CloseElevatorUI()
end)

function CloseElevatorUI()
    isUIOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'closeElevator'
    })
end

RegisterNetEvent('elevator:doTeleport', function(elevatorId, floorIndex)
    if isTeleporting then return end

    local elevator = Config.Elevators[elevatorId]
    if not elevator then return end

    local floor = elevator.floors[floorIndex]
    if not floor then return end

    local ped = PlayerPedId()
    local currentPos = GetEntityCoords(ped)
    local targetZ = floor.coords.z
    local direction = Shared.GetFloorDirection(currentPos.z, targetZ)

    isTeleporting = true

    SendNUIMessage({
        action = 'showTransition',
        direction = direction,
        floorLabel = floor.label,
        enableSounds = Config.EnableSounds
    })

    RequestAnimDict(Config.Animation.dict)
    local timeout = 0
    while not HasAnimDictLoaded(Config.Animation.dict) and timeout < 50 do
        Wait(100)
        timeout = timeout + 1
    end

    if HasAnimDictLoaded(Config.Animation.dict) then
        TaskPlayAnim(ped, Config.Animation.dict, Config.Animation.name, 8.0, -8.0, -1, Config.Animation.flag, 0, false, false, false)
    end

    DoScreenFadeOut(500)
    Wait(600)

    SetEntityCoords(ped, floor.coords.x, floor.coords.y, floor.coords.z, false, false, false, false)
    SetEntityHeading(ped, floor.coords.w)

    Wait(Config.TransitionTime)

    ClearPedTasks(ped)
    DoScreenFadeIn(500)

    Wait(600)

    SendNUIMessage({
        action = 'hideTransition'
    })

    isTeleporting = false
    currentElevator = nil
end)

RegisterNetEvent('elevator:notify', function(msg, cor)
    TriggerEvent('Notify', 'Elevador', msg, cor or 'vermelho', 5000)
end)

RegisterCommand('elevator_debug', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    print(string.format('vector4(%.1f, %.1f, %.1f, %.1f)', pos.x, pos.y, pos.z, heading))
end, false)
