Shared = {}

function Shared.GetCurrentFloor(elevatorId, playerCoords)
    local elevator = Config.Elevators[elevatorId]
    if not elevator then return nil end

    local closestFloor = nil
    local closestDist = math.huge

    for i, floor in ipairs(elevator.floors) do
        local dist = #(playerCoords - vector3(floor.coords.x, floor.coords.y, floor.coords.z))
        if dist < closestDist then
            closestDist = dist
            closestFloor = i
        end
    end

    return closestFloor
end

function Shared.GetFloorDirection(currentZ, targetZ)
    if targetZ > currentZ then
        return 'up'
    else
        return 'down'
    end
end

function Shared.HasJobPermission(playerJobs, requiredJobs)
    if not requiredJobs or #requiredJobs == 0 then
        return true
    end

    for _, required in ipairs(requiredJobs) do
        for _, playerJob in ipairs(playerJobs) do
            if string.lower(playerJob) == string.lower(required) then
                return true
            end
        end
    end

    return false
end
