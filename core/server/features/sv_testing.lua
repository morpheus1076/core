
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

--local testEntities = {}


AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    --[[if #testEntities > 0 then
        for i=1, #testEntities do
            DeleteEntity(testEntities[i])
        end
    end]]
end)

