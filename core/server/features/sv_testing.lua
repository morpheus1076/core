
RegisterNetEvent('testing:Werte', function(wert1)
    local player = Ox.GetPlayer(source)
    Wait(50)
    print(player)
    player.set('fullname', wert1, true)
    print('set server')
    local name = player.get('fullname')
    print(name)
end)

lib.callback.register('testing:GetBucket', function()
    local bucket = GetPlayerRoutingBucket(source)
    print(bucket)
    return bucket
end)