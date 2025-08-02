
local Mor = require("client.cl_lib")
local Wirt = require("shared.cfg_wirtschaftssystem")
local Shops = require("shared.cfg_shops")

local einkauf = Wirt.zentralLager.einkauf

exports.ox_target:addSphereZone({
    coords = einkauf.coords,
    name = einkauf.label,
    radius = einkauf.distance,
    debug = einkauf.debug,
    options = {
        label = einkauf.label,
        name = einkauf.id,
        distance = einkauf.distance,
        groups = einkauf.groups,
        onSelect = function()
            exports.ox_inventory:openInventory(einkauf.type, einkauf.id)
        end
    }
})
local verteiler = Wirt.zentralLager.verteiler
exports.ox_target:addSphereZone({
    coords = verteiler.coords,
    name = verteiler.label,
    radius = verteiler.distance,
    debug = verteiler.debug,
    options = {
        label = verteiler.label,
        name = verteiler.id,
        distance = verteiler.distance,
        groups = verteiler.groups,
        onSelect = function()
            exports.ox_inventory:openInventory(verteiler.type, verteiler.id)
        end
    }
})
local liquor = Wirt.zentralLager.liquor
exports.ox_target:addSphereZone({
    coords = liquor.coords,
    name = liquor.label,
    radius = liquor.distance,
    debug = liquor.debug,
    options = {
        label = liquor.label,
        name = liquor.id,
        distance = liquor.distance,
        groups = liquor.groups,
        onSelect = function()
            exports.ox_inventory:openInventory(liquor.type, liquor.id)
        end
    }
})
local twenty = Wirt.zentralLager.twenty
exports.ox_target:addSphereZone({
    coords = twenty.coords,
    name = twenty.label,
    radius = twenty.distance,
    debug = twenty.debug,
    options = {
        label = twenty.label,
        name = twenty.id,
        distance = twenty.distance,
        groups = twenty.groups,
        onSelect = function()
            exports.ox_inventory:openInventory(twenty.type, twenty.id)
        end
    }
})

local function GetStashItemCount(stashId, item)
    -- WICHTIG: callback.await synchronisiert den Wert!
    local count = lib.callback.await('GetStashItemCount', source, stashId, item)
    Wait(20)
    return count or 0
end

local einkaufStashId = Wirt.zentralLager.einkauf.id
local maxLevels = Wirt.maxLevels.eating
local production = Wirt.production

--- Hilfsfunktion: MinAmount für ein Item aus maxLevels finden
--- Gibt MinAmount zurück (wie bisher)
local function GetMinAmount(itemName)
    for _, category in pairs(Wirt.maxLevels) do
        if type(category) == "table" then
            for _, entry in pairs(category) do
                if type(entry) == "table" and entry.item == itemName then
                    return entry.minAmount
                elseif type(entry) ~= "table" and _ == itemName then
                    return entry -- einfache Struktur z. B. {wasser = 200}
                end
            end
        end
    end
    return nil
end


--- Gibt true zurück, wenn Produktion möglich (wie zuvor)
local function CanProduce(itemName)
    local minAmount = GetMinAmount(itemName)
    if not minAmount then return false end

    local bestand = GetStashItemCount("verteiler_lager_01", itemName)
    if bestand >= minAmount then return end
    for _, entry in ipairs(production) do
        if entry.item == itemName then
            for zutat, menge in pairs(entry.zutaten) do
                if zutat ~= "amount" then
                    local vorhanden = GetStashItemCount(einkaufStashId, zutat)
                    if vorhanden < menge then return false end
                end
            end
            return true
        end
    end
    return false
end
local function TryProduce(itemName)
    for _, entry in ipairs(production) do
        if entry.item == itemName then
            if not CanProduce(itemName) then
                return false
            end

            -- Zutaten und Ziel vorbereiten
            local zutaten = {}
            for zutat, menge in pairs(entry.zutaten) do
                if zutat ~= "amount" then
                    zutaten[zutat] = menge
                end
            end
            local amount = entry.zutaten.amount or 1

            -- Übergabe an Server (diese Funktion erstellst du)
            TriggerServerEvent("mor:produktion:herstellen", {
                zielStash = "verteiler_lager_01",
                quelleStash = einkaufStashId,
                item = itemName,
                amount = amount,
                zutaten = zutaten
            })
            return true
        end
    end
    return false
end

local productionList = Wirt.production

CreateThread(function()
    Wait(1000) -- Optional: Sicherstellen, dass Stashes etc. geladen sind
    for _, prod in ipairs(productionList) do
        local item = prod.item
        if CanProduce(item) then
            --print("✅ Produktion möglich für: " .. item)
            TryProduce(item)
        else
            --print("❌ Produktion NICHT möglich für: " .. item)
        end
        Wait(500) -- kurze Pause, um Server nicht zu überlasten bei vielen Rezepten
    end
end)
