
local Mor = require("client.cl_lib")

local dealerspawn = {
    [1] = { coords = vec3(-356.419, 1260.801, 331.114), heading = 42.113 },
    [2] = { coords = vec3(-2187.917, 4249.284, 48.939), heading = 5.142 },
    [3] = { coords = vec3(122.552, 6406.233, 31.363), heading = 310.891 }
}
local selldrugs = {
    { id = 1, name = 'afghan', label = "Afghan Kush", price = 8, currancy = "black_money" },
    { id = 2 ,name = 'afghan_joint',label = "Afghan Joint", price = 20, currancy = "black_money" },
    { id = 3 ,name = 'opium',label = "Opium", price = 20, currancy = "black_money" },
    { id = 4 ,name = 'kokain',label = "Kokain", price = 20, currancy = "black_money" },
}
local excludedPeds = {
    GetHashKey("S_M_Y_Valet_01"),
    GetHashKey("a_f_y_business_01"),
    GetHashKey("A_M_Y_Business_03"),
    GetHashKey("IG_Car3guy1"),
    GetHashKey("a_m_y_business_02"),
    GetHashKey("mp_m_shopkeep_01"),
    GetHashKey("S_F_Y_Shop_LOW"),
    GetHashKey("S_F_Y_Shop_MID"),
    GetHashKey("S_M_Y_Shop_MASK"),
    GetHashKey("A_M_M_Farmer_01"),
    GetHashKey("a_m_y_juggalo_01"),
    GetHashKey("S_M_Y_Construct_01"),
    GetHashKey("S_M_M_AutoShop_01"),
    GetHashKey("S_M_M_AmmuCountry"),
    GetHashKey("S_M_Y_AmmuCity_01"),
    GetHashKey("CS_Old_Man2"),
    GetHashKey("s_f_m_shop_high"),
    GetHashKey("s_m_m_hairdress_01"),
    GetHashKey("u_m_y_tattoo_01"),
    GetHashKey("s_m_m_doctor_01"),
}

local randomdealer = math.random(1, #dealerspawn)

for i, pos in pairs(dealerspawn) do
    if randomdealer == i then
        local coords = pos.coords
        local heading = pos.heading

        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Drogenhändler entfernen bei Live")
        EndTextCommandSetBlipName(blip)
        SetBlipCategory(blip, 2)

        RequestModel("IG_DrugDealer")
        while not HasModelLoaded("IG_DrugDealer") do
            Wait(0)
        end

        local npc = CreatePed(4, GetHashKey("IG_DrugDealer"), coords.x, coords.y, coords.z - 1, heading, false, true)
        SetEntityAsMissionEntity(npc, true, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)

        dpoint = lib.points.new({
            coords = coords,
            distance = 5
        })
        break
    end
end

local listeRows = {}
function dpoint:onEnter()
    local options = {name = 'dealer', label = "Verkaufen", distance = 5, onSelect = function() DrugSelling() end}
    exports.ox_target:addModel("IG_DrugDealer", options)
end

function dpoint:onExit()
    listeRows = {}
    exports.ox_target:removeModel("IG_DrugDealer", 'dealer')
end

function DrugSelling()
    listeRows = {}
    local options = {allowCancel = true}

    for _, a in pairs(selldrugs) do
        local count = exports.ox_inventory:GetItemCount(a.name)
        local prive = a.price
        local price = math.random(prive-1, prive+1)
        table.insert(listeRows, {type = 'number', label = a.label, description = 'Preis: $'..price..'  --  Bestand: '..count, icon = 'hashtag', min = 0, max = count, default = count})
    end

    local input = lib.inputDialog('Dealer', listeRows, options)
    if not input then return end

    for i=1, #input do
        if input[i] > 0  --[[and #input == #selldrugs]] then
            for _, sd in pairs(selldrugs) do
                if i == sd.id then
                    local amount = math.floor(sd.price * input[i])
                    TriggerServerEvent('drugdealer:AddItem', sd.currancy, amount)
                    TriggerServerEvent('drugdealer:RemoveItem', sd.name, input[i])
                    listeRows = {}
                    Wait(200)
                end
            end
        end
    end
end

function NPCDrugSelling()
    listeRows = {}
    local options = {allowCancel = true}

    for _, a in pairs(selldrugs) do
        local count = exports.ox_inventory:GetItemCount(a.name)
        local prive = a.price
        local price = math.random(prive-3, prive-2)
        local max = math.random(1,5)
        if max > count then
            max = count
        end
        table.insert(listeRows, {type = 'number', label = a.label, description = 'Preis: $'..price..'  --  Bestand: '..count, icon = 'hashtag', min = 0, max = max, default = max})
    end

    local input = lib.inputDialog('Dealer', listeRows, options)

    if not input then return end
    for i=1, #input do
        if input[i] > 0 and #input == #selldrugs then
            for _, sd in pairs(selldrugs) do
                if i == sd.id then
                    local count = exports.ox_inventory:GetItemCount(sd.name)
                    if count >= input[i] then
                        local amount = math.floor(sd.price * input[i])
                        TriggerServerEvent('drugdealer:AddItem', sd.currancy, amount)
                        TriggerServerEvent('drugdealer:RemoveItem', sd.name, input[i])
                        listeRows = {}
                        Wait(200)
                    end
                end
            end
        end
    end
end

--[[
-- Funktion zur Überprüfung, ob ein Ped ein NPC ist
function isNPC(ped)
    return not IsPedAPlayer(ped) -- Überprüft, ob der Ped kein Spieler ist
end

function isExcludedPed(ped)
    local modelHash = GetEntityModel(ped)
    for _, excludedHash in ipairs(excludedPeds) do
        if modelHash == excludedHash then
            return true -- Ped ist in der Ausschlussliste
        end
    end
    return false -- Ped ist nicht in der Ausschlussliste
end

-- Funktion zur Überprüfung der Interaktion mit NPCs
function checkInteraction()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Scanne alle Peds in der Nähe des Spielers
        for ped in EnumeratePeds() do

            if DoesEntityExist(ped) and isNPC(ped) and not isExcludedPed(ped) then -- Überprüfe, ob der Ped ein NPC ist
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)

                if distance < 3.0 then -- Überprüfe, ob der Spieler in der Nähe des NPCs ist
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, "Drücke [E], um Items zu verkaufen") -- Text anzeigen

                    if IsControlJustReleased(0, 38) then -- Überprüfe, ob die Taste [E] gedrückt wurde

                        ClearPedTasks(ped)
                        FreezeAndFacePlayer(ped, playerPed) -- NPC anhalten, Aufgaben stoppen und zum Spieler drehen


                        --openSalesMenu(ped) -- Öffne das Verkaufsmenü für diesen NPC
                    end
                else
                    FreezeEntityPosition(ped, false)
                    SetBlockingOfNonTemporaryEvents(ped, false)
                end
            end
        end
    end
end

-- Funktion zum Anhalten, Stoppen der Aufgaben und Drehen des NPCs in Richtung des Spielers
function FreezeAndFacePlayer(npcPed, playerPed)
    -- NPC anhalten
    ClearPedTasks(npcPed)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    TaskTurnPedToFaceEntity(npcPed, playerPed, 4000)
    FreezeEntityPosition(npcPed, true)
    NPCDrugSelling()
    Wait(10000)
    FreezeEntityPosition(npcPed, false)
    Wait(60000)
end

-- Funktion zur Anzeige von 3D-Text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(6)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

-- Funktion zum Auflisten aller Peds in der Welt
function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        if not IsEntityDead(ped) then
            coroutine.yield(ped)
        end
        local success
        repeat
            success, ped = FindNextPed(handle)
            if not IsEntityDead(ped) then
                coroutine.yield(ped)
            end
        until not success
        EndFindPed(handle)
    end)
end

-- Starte die Interaktionsüberprüfung
CreateThread(function()
    checkInteraction()
end)]]