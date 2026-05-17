local isUIOpen = false
local isTeleporting = false
local currentElevator = nil
local showingHelpFor = nil

CreateThread(function()
    for elevatorId, elevator in pairs(Config.Elevators) do
        if elevator.interaction == 'target' then
            SetupTargetInteraction(elevatorId, elevator)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local closestId = nil
        local closestElev = nil
        local closestFloors = {}
        local nearestDist = 999.0
        local nearestFloor = nil

        for elevatorId, elevator in pairs(Config.Elevators) do
            if elevator.interaction == 'marker' then
                for i, floor in ipairs(elevator.floors) do
                    local fp = vector3(floor.coords.x, floor.coords.y, floor.coords.z)
                    local dist = #(pCoords - fp)

                    if dist < Config.Marker.RenderDistance then
                        closestFloors[#closestFloors+1] = {
                            pos = fp,
                            dist = dist,
                            idx = i,
                            elevId = elevatorId,
                            elev = elevator
                        }
                    end

                    if dist < nearestDist then
                        nearestDist = dist
                        nearestFloor = {
                            pos = fp,
                            dist = dist,
                            idx = i,
                            elevId = elevatorId,
                            elev = elevator
                        }
                    end
                end
            end
        end

        if #closestFloors > 0 then
            sleep = 0

            for _, mf in ipairs(closestFloors) do
                DrawCustomMarker(mf.pos, mf.dist)
            end

            if nearestFloor and nearestDist <= Config.InteractionDistance then
                DrawHelpText3D(
                    nearestFloor.pos + vector3(0.0, 0.0, Config.Marker.TextHeight),
                    nearestFloor.elev.label
                )

                showingHelpFor = nearestFloor.elevId

                if IsControlJustPressed(0, 38) and not isUIOpen and not isTeleporting then
                    OpenElevatorUI(nearestFloor.elevId)
                end
            else
                showingHelpFor = nil
            end
        else
            showingHelpFor = nil
            if nearestDist < 50.0 then
                sleep = 200
            end
        end

        Wait(sleep)
    end
end)

function DrawCustomMarker(pos, dist)
    local time = GetGameTimer()
    local pulse = (math.sin(time * 0.003) + 1.0) * 0.5

    local distFactor = 1.0 - math.min(dist / Config.Marker.RenderDistance, 1.0)
    local alpha = math.floor(Config.Marker.Alpha * (0.5 + pulse * 0.5) * distFactor)
    if alpha < 5 then return end

    local r = Config.Marker.Color.r
    local g = Config.Marker.Color.g
    local b = Config.Marker.Color.b
    local baseZ = pos.z + Config.Marker.GroundOffset
    local bob = math.sin(time * 0.002) * 0.04
    local ring = Config.Marker.RingSize
    local rot = (time * 0.05) % 360.0

    DrawMarker(25,
        pos.x, pos.y, baseZ - 0.01,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        ring, ring, 0.015,
        r, g, b, math.floor(alpha * 0.35),
        false, false, 2, false, nil, nil, false
    )

    DrawMarker(6,
        pos.x, pos.y, baseZ + bob,
        0.0, 0.0, 0.0, 0.0, 0.0, rot,
        ring * 0.7, ring * 0.7, ring * 0.7,
        r, g, b, math.floor(alpha * 0.12),
        false, false, 2, true, nil, nil, false
    )

    local arrowBob = math.sin(time * 0.004) * 0.08
    local arrowZ = baseZ + Config.Marker.ArrowHeight + arrowBob
    local arrowAlpha = math.floor(alpha * (0.6 + pulse * 0.4))

    DrawMarker(36,
        pos.x, pos.y, arrowZ,
        0.0, 0.0, 0.0, 180.0, 0.0, 0.0,
        Config.Marker.ArrowSize, Config.Marker.ArrowSize, Config.Marker.ArrowSize,
        r, g, b, arrowAlpha,
        false, false, 2, false, nil, nil, false
    )

    if dist < Config.InteractionDistance + 1.0 then
        local iPulse = (math.sin(time * 0.005) + 1.0) * 0.5
        DrawMarker(23,
            pos.x, pos.y, baseZ + 0.005,
            0.0, 0.0, 0.0, 90.0, 0.0, 0.0,
            ring * 0.4, ring * 0.4, 0.25,
            r, g, b, math.floor(20 + iPulse * 25),
            false, false, 2, true, nil, nil, false
        )
    end
end

function DrawHelpText3D(pos, elevatorName)
    local onScreen, sx, sy = World3dToScreen2d(pos.x, pos.y, pos.z)
    if not onScreen then return end

    SetTextFont(4)
    SetTextScale(0.33, 0.33)
    SetTextColour(220, 225, 230, 220)
    SetTextDropshadow(2, 0, 0, 0, 200)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString('~INPUT_CONTEXT~  ' .. elevatorName)
    DrawText(sx, sy)

    SetTextFont(4)
    SetTextScale(0.26, 0.26)
    SetTextColour(170, 180, 195, 130)
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString('Elevador')
    DrawText(sx, sy + 0.022)
end

function SetupTargetInteraction(elevatorId, elevator)
    for i, floor in ipairs(elevator.floors) do
        local floorPos = vector3(floor.coords.x, floor.coords.y, floor.coords.z)

        if Config.TargetSystem == 'ox_target' and GetResourceState('ox_target') == 'started' then
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
                            if not isUIOpen and not isTeleporting then
                                OpenElevatorUI(elevatorId)
                            end
                        end,
                        canInteract = function()
                            return not isUIOpen and not isTeleporting
                        end
                    }
                }
            })

        elseif Config.TargetSystem == 'vrp_target' and GetResourceState('vrp_target') == 'started' then
            exports.vrp_target:addPoint(
                'elevator_' .. elevatorId .. '_' .. i,
                floorPos,
                Config.InteractionDistance,
                {
                    {
                        label = 'Usar Elevador - ' .. elevator.label,
                        icon = elevator.icon or 'fa-solid fa-elevator',
                        action = function()
                            if not isUIOpen and not isTeleporting then
                                OpenElevatorUI(elevatorId)
                            end
                        end
                    }
                }
            )

        elseif Config.TargetSystem == 'creative_target' and GetResourceState('creative_target') == 'started' then
            exports.creative_target:addPoint({
                id = 'elevator_' .. elevatorId .. '_' .. i,
                coords = floorPos,
                distance = Config.InteractionDistance,
                options = {
                    {
                        label = 'Usar Elevador - ' .. elevator.label,
                        icon = elevator.icon or 'fa-solid fa-elevator',
                        event = 'elevator:openFromTarget',
                        args = { elevatorId = elevatorId }
                    }
                }
            })
        end
    end
end

RegisterNetEvent('elevator:openFromTarget', function(data)
    if data and data.elevatorId and not isUIOpen and not isTeleporting then
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
        floorsData[#floorsData + 1] = {
            index = i,
            label = floor.label,
            isCurrent = (i == currentFloor)
        }
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
    SendNUIMessage({ action = 'closeElevator' })
end

RegisterNetEvent('elevator:doTeleport', function(elevatorId, floorIndex)
    if isTeleporting then return end

    local elevator = Config.Elevators[elevatorId]
    if not elevator then return end

    local floor = elevator.floors[floorIndex]
    if not floor then return end

    local ped = PlayerPedId()
    local currentPos = GetEntityCoords(ped)
    local direction = Shared.GetFloorDirection(currentPos.z, floor.coords.z)

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

    SendNUIMessage({ action = 'hideTransition' })

    isTeleporting = false
    currentElevator = nil
end)

RegisterNetEvent('elevator:notifyClient', function(notifyType)
    if notifyType == 'noperm' then
        TriggerEvent('Notify', 'Elevador', 'Você não possui acesso a este elevador.', 'vermelho', 5000)
    elseif notifyType == 'cooldown' then
        TriggerEvent('Notify', 'Elevador', 'Aguarde para usar o elevador novamente.', 'amarelo', 3000)
    elseif notifyType == 'error' then
        TriggerEvent('Notify', 'Elevador', 'Ocorreu um erro. Tente novamente.', 'vermelho', 5000)
    end
end)

RegisterCommand('elevator_debug', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    print(string.format('vector4(%.1f, %.1f, %.1f, %.1f)', pos.x, pos.y, pos.z, heading))
end, false)
