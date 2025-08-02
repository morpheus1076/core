
RegisterServerEvent('jobcheck')
AddEventHandler('jobcheck', function(source)
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = GetPlayerIdentifierByType(source, 'license')
        local job = MySQL.Sync.fetchAll('SELECT job FROM users WHERE identifier = @identifier;', {['@identifier'] = xPlayer.license})
        for i = 1, #job do
            if job[i].job == "police" then
                TriggerClientEvent('sendHelpMessageToPlayer', playerId, "Achtung ein Überfall findet im Bereich ")
            else
                print('nicht Police')
            end
        end
    end
end)