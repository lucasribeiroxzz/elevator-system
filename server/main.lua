local cooldowns = {}

local _0x4f={'\x45\x4c\x45\x56\x41\x54\x4f\x52\x20\x53\x59\x53\x54\x45\x4d','\x43\x72\x69\x61\x64\x6f\x20\x70\x6f\x72\x20\x4c\x75\x63\x61\x73\x73\x78','\x68\x74\x74\x70\x73\x3a\x2f\x2f\x67\x69\x74\x68\x75\x62\x2e\x63\x6f\x6d\x2f\x6c\x75\x63\x61\x73\x72\x69\x62\x65\x69\x72\x6f\x78\x7a\x7a','\x76\x31\x2e\x30\x2e\x30'}
AddEventHandler('onResourceStart', function(_r) if GetCurrentResourceName()~=_r then return end print('^4========================================^0') print('^4  '.._0x4f[1]..' '.._0x4f[4]..' ^0') print('^4  '.._0x4f[2]..' ^0') print('^4  '.._0x4f[3]..' ^0') print('^4========================================^0') end)

RegisterNetEvent('elevator:requestTeleport', function(elevatorId, floorIndex)
    local source = source
    local now = GetGameTimer()

    if cooldowns[source] and (now - cooldowns[source]) < Config.Cooldown then
        TriggerClientEvent('elevator:notify', source, 'Aguarde para usar o elevador novamente.', 'amarelo')
        return
    end

    local elevator = Config.Elevators[elevatorId]
    if not elevator then return end

    if floorIndex < 1 or floorIndex > #elevator.floors then return end

    if elevator.jobs and #elevator.jobs > 0 then
        local hasPermission = CheckPlayerPermission(source, elevator.jobs)
        if not hasPermission then
            TriggerClientEvent('elevator:notify', source, 'Você não tem permissão para usar este elevador.', 'vermelho')
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
        local vRPReady = false

        TriggerEvent('getServerFunctions', function(f) vRP = f end)

        if vRP then
            local user_id = vRP.getUserId(source)
            if user_id then
                for _, job in ipairs(requiredJobs) do
                    if vRP.hasPermission(user_id, job) or vRP.hasGroup(user_id, job) then
                        return true
                    end
                end
            end
        end

        return false
    elseif Config.Framework == 'creative' then
        for _, job in ipairs(requiredJobs) do
            local hasJob = exports['creative_jobs']:hasJob(source, job)
            if hasJob then
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
