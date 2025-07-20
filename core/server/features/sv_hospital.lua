
local Inv = require("server.sv_lib")
local points = require("shared.cfg_hospital")

lib.callback.register('hospital:GiveInvoice', function()
    local player = Ox.GetPlayer(source)
    local account = Ox.GetCharacterAccount(player.charId)
    local getaccount = Ox.GetGroupAccount('staat')
    if account and getaccount then
        local invoice = getaccount.createInvoice({
            toAccount = account.accountId,
            amount = points.price,
            message = "Behandlung im Krankenhaus"
        })
        if invoice.success then
            return true
        else
            return false
        end
    else
        return false
    end
end)

lib.callback.register('GetPedInfos', function(source, id, plyped)
    local src = source
    local targetPlayer = Ox.GetPlayer(id)
    print(json.encode(targetPlayer))
    local plyName = targetPlayer.get('fullname')
    print(json.encode(plyName))
    local setReturn = {name = plyName, ped = plyped}
    return plyName[1].fullName, plyped
end)
