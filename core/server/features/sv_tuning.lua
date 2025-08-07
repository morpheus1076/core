
RegisterNetEvent('tuning:SetVehicleData', function(source, netid, data)
    local player = Ox.GetPlayer(source)
    local vehicle = Ox.GetVehicleFromNetId(netid)
    Wait(200)
    if not vehicle then return end
    vehicle.set('vehicledata', data)
end)

RegisterNetEvent('tuning:SaveVehicleData', function(source, netid, setproperties)
    local player = Ox.GetPlayer(source)
    local vehicle = Ox.GetVehicleFromNetId(netid)
    Wait(200)
    if not vehicle then return end
    vehicle.setProperties(setproperties, false)
    vehicle.save()
end)