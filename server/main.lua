local cooldowns = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    print('^4========================================^0')
    print('^4  ELEVATOR SYSTEM v1.0.0^0')
    print('^4  Criado por Lucassx^0')
    print('^4  github.com/lucasribeiroxzz^0')
    print('^4========================================^0')

    local elevatorCount = 0
    local floorCount = 0
    for _, elevator in pairs(Config.Elevators) do
        elevatorCount = elevatorCount + 1
        floorCount = floorCount + #elevator.floors
    end
    print('^2  [OK]^0 ' .. elevatorCount .. ' elevadores carregados (' .. floorCount .. ' andares)')
    print('^4========================================^0')
end)

RegisterNetEvent('elevator:requestTeleport', function(elevatorId, floorIndex)
    local source = source
    local now = GetGameTimer()

    if cooldowns[source] and (now - cooldowns[source]) < Config.Cooldown then
        TriggerClientEvent('elevator:notifyClient', source, 'cooldown')
        return
    end

    local elevator = Config.Elevators[elevatorId]
    if not elevator then return end

    if floorIndex < 1 or floorIndex > #elevator.floors then return end

    if elevator.jobs and #elevator.jobs > 0 then
        local hasPermission = CheckPlayerPermission(source, elevator.jobs)
        if not hasPermission then
            TriggerClientEvent('elevator:notifyClient', source, 'noperm')
            return
        end
    end

    cooldowns[source] = now
    TriggerClientEvent('elevator:doTeleport', source, elevatorId, floorIndex)
end)

function CheckPlayerPermission(source, requiredJobs)
    if not requiredJobs or #requiredJobs == 0 then
        return true
    end

    if Config.Framework == 'vrp' then
        local vRP = nil
        TriggerEvent('getServerFunctions', function(f) vRP = f end)

        if vRP then
            local user_id = vRP.getUserId(source)
            if user_id then
                for _, job in ipairs(requiredJobs) do
                    if vRP.hasPermission and vRP.hasPermission(user_id, job) then
                        return true
                    end
                    if vRP.hasGroup and vRP.hasGroup(user_id, job) then
                        return true
                    end
                end
            end
        end
        return false

    elseif Config.Framework == 'creative' then
        for _, job in ipairs(requiredJobs) do
            local success, hasJob = pcall(function()
                return exports['creative_jobs']:hasJob(source, job)
            end)
            if success and hasJob then
                return true
            end
        end
        return false
    end

    return true
end

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)
