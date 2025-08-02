
lib.callback.register('mor_keymaker:getVehicles', function(source)
    local player = Ox.GetPlayer(source)
    local vehs = MySQL.query.await('SELECT * FROM vehicles WHERE owner = @owner ORDER BY plate DESC ;', {['@owner'] = player.charId})
    return vehs
end)

lib.callback.register('mor_keymaker:herstellen', function(source, plate, vin, model, price)
    local player = Ox.GetPlayer(source)
    local removed = exports.ox_inventory:RemoveItem(player.source, 'money', price)
    if not removed then return 'nicht genug Geld' end
    exports.ox_inventory:AddItem(player.source, 'keys', 1, {Kennzeichen = plate, type = 'Kopie '..plate..'', description = 'VIN: '..vin..'\\\n Model: '..model})
    return 'hergestellt'
end)