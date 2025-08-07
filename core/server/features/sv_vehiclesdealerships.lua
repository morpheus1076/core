
lib.callback.register('dealerships:BuyVehicle', function(source, price, vehModel, group, coords, heading, garage)
    local player = Ox.GetPlayer(source)
    local plyData = player.get('playerdata')
    local buyAccount = Ox.GetGroupAccount(plyData.group)
    local sellAccount = Ox.GetGroupAccount('staat')
    local buyBalance = buyAccount.get('balance')

    if (group == plyData.group) and (buyBalance >= price) then
        local spawndata = {model = vehModel, owner = player.charId, group = group, stored = garage}
        local vehicle = Ox.CreateVehicle(spawndata, coords, heading)
        Wait(500)
        SetVehicleColours(vehicle.entity, 111, 111)
        SetVehicleDirtLevel(vehicle.entity, 0.0)
        vehicle.save()
        vehicle.setStored(garage, false)
        local vehData = Ox.GetVehicleData(vehicle.model)
        buyAccount.removeBalance({amount = price, message = "Fahrzeugkauf :: VIN: "..vehicle.vin.."", true})
        sellAccount.addBalance({amount = price, message = "Fahrzeugkauf :: VIN: "..vehicle.vin.."", true})
        exports.ox_inventory:AddItem(player.source, 'keys', 1, {label = vehData.name, Kennzeichen = vehicle.plate, type = 'Master '..vehicle.plate..'', description = 'VIN: '..vehicle.vin..'', name = "Model: "..vehicle.model})
        Wait(50)
        return true
    else
        return false
    end
end)