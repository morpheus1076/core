
local Mor = require("client.cl_lib")

RegisterCommand("groupperms", function()
    local player = Ox.GetPlayer(PlayerId())
    Wait(50)
    local permissions = Ox.GetGroupPermissions('staat')
    print(json.encode(permissions))
    print(player)
    local plkey = player.get('fullname')
    print(plkey)
    if not plkey then
        local wert1 = 'Cyrus Bradshaw'
        TriggerServerEvent('testing:Werte', wert1)
        --player.set('fullname', 'Cyrus Bradshaw', false)
    end
end, false)

RegisterCommand("bucket", function()
    local player = Ox.GetPlayer(PlayerId())
    local StateBucket = lib.callback.await('testing:GetBucket')
    Mor.Notify('Aktueller Bucket: '..StateBucket)
end, false)