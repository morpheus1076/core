
local Mor = require("server.sv_lib")
local Wirt = require("shared.cfg_wirtschaftssystem")
local Shops = require("shared.cfg_shops")

local ox_inventory = exports.ox_inventory
local einkauf = Wirt.zentralLager.einkauf
local verteiler = Wirt.zentralLager.verteiler
local liquor = Wirt.zentralLager.liquor
local twenty = Wirt.zentralLager.twenty
local liquorShops = Shops.liquor
local twentyShops = Shops.twentyfourseven

ox_inventory:RegisterStash(Wirt.zentralLager.verteiler.id, Wirt.zentralLager.verteiler.label, Wirt.zentralLager.verteiler.slots, Wirt.zentralLager.verteiler.weight, Wirt.zentralLager.verteiler.owner)
ox_inventory:RegisterStash(einkauf.id, einkauf.label, einkauf.slots, einkauf.weight, einkauf.owner, einkauf.groups, einkauf.coords)
ox_inventory:RegisterStash(verteiler.id, verteiler.label, verteiler.slots, verteiler.weight, verteiler.owner, verteiler.groups, verteiler.coords)
ox_inventory:RegisterStash(liquor.id, liquor.label, liquor.slots, liquor.weight, liquor.owner, liquor.groups, liquor.coords)
ox_inventory:RegisterStash(twenty.id, twenty.label, twenty.slots, twenty.weight, twenty.owner, twenty.groups, twenty.coords)

lib.callback.register('GetStashItemCount', function(source, stashId, itemName)
    local src = source
    local count = ox_inventory:GetItemCount(stashId, itemName) or 0
    Wait(50)
    return count
end)

RegisterNetEvent("mor:produktion:herstellen", function(data)
    local src = source
    local zielStash = data.zielStash
    local quelleStash = data.quelleStash
    local item = data.item
    local amount = data.amount
    local zutaten = data.zutaten

    -- ✅ Zutaten entfernen (z. B. aus Lager)
    for zutat, menge in pairs(zutaten) do
        local success = Mor.Inv:remove(quelleStash, zutat, menge)

        if not success then
            print(("❌ [Produktion] Fehler beim Entfernen von %s (%d) aus %s"):format(zutat, menge, quelleStash))
            return
        end
    end


    -- ✅ Produkt hinzufügen
    local added = Mor.Inv:add(zielStash, item, amount)

    if added then
        print(("✅ [Produktion] %dx %s erfolgreich produziert und eingelagert in %s (von %s)"):format(amount, item, zielStash, GetPlayerName(src)))
    else
        print(("❌ [Produktion] Konnte %s (%d) nicht einlagern in %s"):format(item, amount, zielStash))
    end
end)

local productionList = Wirt.production

-- MinAmount prüfen – kategorieübergreifend
local function GetMinAmount(itemName)
    for _, category in pairs(Wirt.maxLevels) do
        if type(category) == "table" then
            for _, entry in pairs(category) do
                if type(entry) == "table" and entry.item == itemName then
                    return entry.minAmount
                elseif type(entry) ~= "table" and _ == itemName then
                    return entry
                end
            end
        end
    end
    return nil
end

-- Check ob genug Zutaten vorhanden + ob im Ziel-Stash noch produziert werden darf
local function CanProduceServer(itemName)
    local minAmount = GetMinAmount(itemName)
    if not minAmount then return false end

    local bestand = exports.ox_inventory:GetItemCount(verteiler.id, itemName)
    if bestand >= minAmount then return false end

    for _, entry in ipairs(productionList) do
        if entry.item == itemName then
            for zutat, menge in pairs(entry.zutaten) do
                if zutat ~= "amount" then
                    local vorhanden = exports.ox_inventory:GetItemCount(einkauf.id, zutat)
                    if vorhanden < menge then
                        return false
                    end
                end
            end
            return true
        end
    end
    return false
end

-- Produziere den Artikel
local function TryProduceServer(itemName)
    for _, entry in ipairs(productionList) do
        if entry.item == itemName then
            if not CanProduceServer(itemName) then return false end

            local zutaten = {}
            for zutat, menge in pairs(entry.zutaten) do
                if zutat ~= "amount" then
                    zutaten[zutat] = menge
                end
            end
            local amount = entry.zutaten.amount or 1

            -- Remove Zutaten
            for zutat, menge in pairs(zutaten) do
                local removed = Mor.Inv:remove(einkauf.id, zutat, menge)
                if not removed then
                    print("❌ [Server-Produktion] Fehler beim Entfernen von", zutat)
                    return false
                end
            end

            -- Add Produkt
            local added = Mor.Inv:add(verteiler.id, itemName, amount)
            if added then
                --print(("✅ [Produktion] %dx %s erfolgreich produziert und eingelagert"):format(amount, itemName))
                local message = (("%dx %s erfolgreich produziert und eingelagert"):format(amount, itemName))
                Mor.Log:add('produktion', message)
            else
                print(("❌ [Produktion] Fehler beim Einlagern von %s (%d)"):format(itemName, amount))
            end
            return true
        end
    end
    return false
end

local function VerteilerControl()
    for lagerName, lagerData in pairs(Wirt.zentralLager) do
        -- Jeder Lagername muss auch in Shops definiert sein
        local shopData = Shops[lagerName]
        if shopData and shopData.inventory then
            for _, v in pairs(shopData.inventory) do
                local itemName = v.name
                local minAmount = GetMinAmount(itemName)
                if minAmount then
                    local lagerBestand = exports.ox_inventory:GetItemCount(lagerData.id, itemName)
                    if lagerBestand < minAmount then
                        local vertBestand = exports.ox_inventory:GetItemCount(Wirt.zentralLager.verteiler.id, itemName)
                        if vertBestand >= 1 then
                            local removed = Mor.Inv:remove(Wirt.zentralLager.verteiler.id, itemName, vertBestand)
                            if removed then
                                local added = Mor.Inv:add(lagerData.id, itemName, vertBestand)
                                if added then
                                    --print(("✅ [Verteiler] %dx %s erfolgreich umgelagert nach %s"):format(vertBestand, itemName, lagerData.label))
                                    local message = (("%dx %s erfolgreich umgelagert nach %s"):format(vertBestand, itemName, lagerData.label))
                                    Mor.Log:add('verteiler', message)
                                else
                                    print(("❌ [Verteiler] Fehler beim Einlagern von %s (%d) in %s"):format(itemName, vertBestand, lagerData.label))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Wiederholende Produktionsschleife alle 30 Minuten
CreateThread(function()
    while true do
        Wait(120000)
        local message = "Automatischer Produktionsdurchlauf gestartet"
        Mor.Log:add('produktion', message)
        --print(json.encode(message))
        for _, prod in ipairs(productionList) do
            local item = prod.item
            if CanProduceServer(item) then
                TryProduceServer(item)
            else
                message = "Bedingungen nicht erfüllt für: "..item..""
            end
            Wait(500)
        end
        Wait(1800000)
    end
end)

CreateThread(function()
    while true do
        Wait(120000)
        print("🔁 [Verteiler] Automatische Lagerbefüllung gestartet.")
        local message = 'Automatische Lagerbefüllung gestartet'
        Mor.Log:add('verteiler', message)
        VerteilerControl()
        Wait(3600000)
    end
end)
