
function Notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

RegisterCommand("tuning", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle then
        local properties = lib.getVehicleProperties(vehicle)
    else
        Notify("Kein Fahrzeug")
    end
end, false)

function VehColor()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    Wait(50)
    local properties = lib.getVehicleProperties(vehicle)
    Wait(100)
    for i=1, #properties do
        pc = properties[i].color1
        sc = properties[i].color2
        print(json.encode(pc))
        print(json.encode(sc))
        print(json.encode(properties))
    end
    if not pc or not sc then
        local input = lib.inputDialog('Farbauswahl - bitte notieren, wenn wichtige Farben.', {
            {type = 'color', label = 'Primärfarbe', default = '#000000'},
            {type = 'checkbox', label = 'Matt', checked = true},{type = 'checkbox', label = 'Metallic'},
            {type = 'color', label = 'Secundärfarbe', default = '#000000'},
            {type = 'checkbox', label = 'Matt', checked = true},{type = 'checkbox', label = 'Metallic'},
        })
        print(json.encode(input))
        if input == nil then
            return
        end

        -- Checkboxen für met, matt etc.
        if input[2] == true then SetVehicleModColor_1(vehicle, 3,_,_) end
        if input[3] == true then SetVehicleModColor_1(vehicle, 1,_,_) end
        if input[5] == true then SetVehicleModColor_2(vehicle, 3,_,_) end
        if input[6] == true then SetVehicleModColor_2(vehicle, 1,_,_) end

        local r, g, b = Hextorgb(input[1])
        SetVehicleCustomPrimaryColour(vehicle, r, g, b)
        Wait(500)
        local r, g, b = Hextorgb(input[4])
        SetVehicleCustomSecondaryColour(vehicle, r, g, b)
        return
    end
    local primhexColor = RgbToHex(pc[1], pc[2], pc[3]) or properties[i].color1
    local sechexColor = RgbToHex(sc[1], sc[2], sc[3])

    local input = lib.inputDialog('Farbauswahl', {
        {type = 'color', label = 'Primärfarbe', default = '#000000', description = 'Derzeitige Farbe: '..primhexColor..''},
        {type = 'color', label = 'Secundärfarbe', default = '#000000', description = 'Derzeitige Farbe: '..sechexColor..''},
    })
    print(json.encode(input))
    print(input[1])
    print(input[2])
    if input == nil then
        return
    end
    local r, g, b = Hextorgb(input[1])
    SetVehicleCustomPrimaryColour(vehicle, r, g, b)
    Wait(500)
    local r, g, b = Hextorgb(input[2])
    SetVehicleCustomSecondaryColour(vehicle, r, g, b)
end

function Hextorgb(hex)
    -- Entferne das führende `#`, falls vorhanden
    hex = hex
    hex = hex:gsub("#", "")

    -- Überprüfen, ob die Länge korrekt ist (6 Zeichen)
    if #hex ~= 6 then
        print("Ungültiger Hex-Farbcode!")
        return nil
    end

    -- Wandle die Hex-Werte in RGB-Werte um
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    return r, g, b
end

function RgbToHex(r, g, b)
    -- Stelle sicher, dass die Werte im Bereich 0-255 liegen
    if not (r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255) then
        print("Ungültige RGB-Werte! (Werte müssen zwischen 0 und 255 liegen)")
        return nil
    end

    -- Wandle die RGB-Werte in einen Hex-String um
    local hex = string.format("#%02X%02X%02X", r, g, b)

    return hex
end

RegisterCommand('tuning', function()
    Auswahlmenu()
end)

function GetNumModTypes(vehicle, type)
    local modCount = GetNumVehicleMods(vehicle, type)
    if modCount == nil then
        return 0
    end
    return modCount
end

function Auswahlmenu()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local motordefault = GetVehicleMod(vehicle, 11)
    local bremsedefault = GetVehicleMod(vehicle, 12)
    local getriebedefault = GetVehicleMod(vehicle, 13)
    local federungdefault = GetVehicleMod(vehicle, 15)
    local windowstintdefault = GetVehicleWindowTint(vehicle)
    local platetype = GetVehicleNumberPlateTextIndex(vehicle)

    -- Array mit Menüpunkten für die Fahrzeugtuning
    local menuItems = {
        {label = 'Motor', max = GetNumModTypes(vehicle, 11), description = 'Aktuell Verbaut Stufe: '..motordefault..''},
        {label = 'Bremse', max = GetNumModTypes(vehicle, 12), description = 'Aktuell Verbaut Stufe: '..bremsedefault..''},
        {label = 'Getriebe', max = GetNumModTypes(vehicle, 13), description = 'Aktuell Verbaut Stufe: '..getriebedefault..''},
        {label = 'Federung', max = GetNumModTypes(vehicle, 15), description = 'Aktuell Verbaut Stufe: '..federungdefault..''},
        {label = 'Scheibentönung', max = GetNumVehicleWindowTints(), description = 'Aktuell Verbaut Stufe: '..windowstintdefault..''},
        {label = 'Kennzeichen Typ', max = GetNumberOfVehicleNumberPlates(), description = 'Aktuell Verbaut Stufe: '..platetype..''},
        -- Weitere Einträge kannst du hier hinzufügen
    }

    local menuOptions = {}
    table.insert(menuOptions, {label = 'Farbauswahl', description = 'Primär- und Sekundärfarben'})
    for _, item in ipairs(menuItems) do
        -- Dynamisches Werte-Array für jeden Menüpunkt erstellen
        local startindex = -1
        local values = {}
        for i = 1, item.max do
            table.insert(values, tostring(startindex + i)) -- Zahlen als Strings einfügen
        end

        table.insert(menuOptions, {
            label = item.label,
            values = values,
            description = item.description, -- Beschreibung hinzufügen
            defaultIndex = startindex, -- Standardindex festlegen
        })
    end

    lib.registerMenu({
        id = 'tuningmenu',
        title = 'Tuning Menü',
        position = 'top-left',
        onSideScroll = function(selected, scrollIndex, args)
            if selected == 5 then
                --print("Scroll: ", selected, scrollIndex, args)
                SetVehicleMod(vehicle, 15, scrollIndex-1, false)
                Wait(50)
            end
            if selected == 6 then
                --print("Scroll: ", selected, scrollIndex, args)
                SetVehicleWindowTint(vehicle, scrollIndex)
                Wait(50)
            end
            if selected == 7 then
                print("Scroll: ", selected, scrollIndex, args)
                SetVehicleNumberPlateTextIndex(vehicle, scrollIndex)
                Wait(50)
            end
        end,
        options = menuOptions
    }, function(selected, scrollIndex, args)
        --print(selected, scrollIndex, args)
        if selected == 1 then
            VehColor()
        elseif selected == 2 then
            SetVehicleMod(vehicle, 11, scrollIndex-1, false)
            local wert = scrollIndex -1
            local txt = '~y~Motor ~w~auf Stufe ~g~'..wert..' ~w~gesetzt'
            Notify(txt)
        elseif selected == 3 then
            SetVehicleMod(vehicle, 12, scrollIndex-1, false)
            local wert = scrollIndex -1
            local txt = '~y~Bremse ~w~auf Stufe ~g~'..wert..' ~w~gesetzt'
            Notify(txt)
        elseif selected == 4 then
            SetVehicleMod(vehicle, 13, scrollIndex-1, false)
            local wert = scrollIndex -1
            local txt = '~y~Getriebe ~w~auf Stufe ~g~'..wert..' ~w~gesetzt'
            Notify(txt)
        elseif selected == 5 then
            SetVehicleMod(vehicle, 15, scrollIndex-1, false)
            local wert = scrollIndex -1
            local txt = '~y~Federung ~w~auf Stufe ~g~'..wert..' ~w~gesetzt'
            Notify(txt)
        elseif selected == 6 then
            SetVehicleWindowTint(vehicle, scrollIndex)
            local wert = scrollIndex
            local txt = '~y~Scheibentönung ~w~auf Stufe ~g~'..wert..' ~w~gesetzt'
            Notify(txt)
        elseif selected == 7 then
            SetVehicleNumberPlateTextIndex(vehicle, scrollIndex)
            local wert = scrollIndex
            local txt = '~y~Kennzeichen Typ ~w~auf Stufe ~g~'..wert..' ~w~gesetzt'
            Notify(txt)
        end
    end)
    Wait(200)
    lib.showMenu('tuningmenu')
end


--[[
Mod-Types
0 Spoiler
1 Stossstange Vorne
2 Stossstange Hinten
3 Skirt ???
4 Auspuff
5 Chassis
6 Grill
7 Motorhaube
8 Kotflügel L
9 Kotflügel R
10 Dach
11 Motor
12 Bremsen
13 Getriebe
14 Hupe
15 Federung
16 Panzerung
]]