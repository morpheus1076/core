
local Mor = require("server.sv_lib")
local Config = require("shared.cfg_abschlepphof")

lib.callback.register('AbschleppEinparken', function(source, netVehicle)
    local src = source
    local player = Ox.GetPlayer(src)
    if not player then return end
    local vehicle = Ox.GetVehicleFromNetId(netVehicle)
    local garage = 'abschlepphof'
    if vehicle then
        local owner = MySQL.query.await('SELECT `owner` FROM `vehicles` WHERE `plate` = @plate ;', {['@plate'] = vehicle.plate})
        local account = Ox.GetGroupAccount('lsc')
        local secAccount = Ox.GetCharacterAccount(owner[1].owner)
        if account and secAccount then
            local invoice = account.createInvoice({
                actorId = player.charId or nil,
                toAccount = secAccount.accountId,
                amount = 300,
                message = "Abschleppkosten :"..vehicle.plate.." "
            })
            if invoice[1].success then
                vehicle.save()
                MySQL.update('UPDATE vehicles SET park_coord = @coords WHERE plate = @plate', {['@coords'] = 'null', ['@plate'] = vehicle.plate})
                MySQL.update('UPDATE vehicles SET garage = @garage WHERE plate = @plate', {['@garage'] = garage, ['@plate'] = vehicle.plate})
                vehicle.setStored(garage, false)
                vehicle.despawn(false)
                return true
            else
                print('Rechnungsstellung fehlgeschlagen')
                return false
            end
        else
            print('Konto nicht vorhanden: Rechnungsstellung fehlgeschlagen')
            return false
        end
    else
        print('Fahrzeug ist kein Spielerfahrzeug')
        return false
    end
end)