local Ox = require '@ox_core/lib/init'

lib.callback.register('kontostandsabfrage', function(source)
    local bank = exports.pefcl:getTotalBankBalance(source)
    return bank
end)

AddEventHandler('ox:setActiveGroup', function(playerId, groupName)
    TriggerClientEvent('OnPlayerChangeAktivGroup', playerId)
end)
