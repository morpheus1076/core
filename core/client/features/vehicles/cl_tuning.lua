
local Mor = require("client.cl_lib")
local cfg = require("shared.cfg_tuning")
local mods = {}
local VehicleData = {}
lib.locale()

function OpenRestlichesMenu()

end

function OpenRaederMenu()

end
-- Lackierung Submenü
function OpenLackierungMenu()
    lib.registerMenu({
        id = 'tuning_lackierung_menu',
        title = 'Lackierung',
        position = 'top-right',
        options = {
            {label = 'Primärfarbe', description = 'Primäre Fahrzeugfarbe ändern'},
            {label = 'Sekundärfarbe', description = 'Sekundäre Fahrzeugfarbe ändern'},
            {label = 'Perlfarbe', description = 'Perleffekt-Farbe ändern'},
            {label = 'Verchromte Teile', description = 'Verchromte Elemente anpassen'},
            {label = 'Aufkleber & Design', description = 'Custom Designs und Aufkleber'},
            {label = 'Zurück', description = 'Zum Hauptmenü zurück'}
        }
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            -- Primärfarbe Logik
        elseif selected == 2 then
            -- Sekundärfarbe Logik
        -- ... weitere Optionen
        elseif selected == 6 then
            OpenTuningMenu() -- Zurück zum Hauptmenü
        end
    end)

    lib.showMenu('tuning_lackierung_menu')
end

-- Karosserie Submenü
function OpenKarosserieMenu()
    lib.registerMenu({
        id = 'tuning_karosserie_menu',
        title = 'Karosserie',
        position = 'top-right',
        options = {
            {label = 'Frontschürze', description = 'Frontschürzen anpassen'},
            {label = 'Heckschürze', description = 'Heckschürzen anpassen'},
            {label = 'Seitenschweller', description = 'Seitenschweller anpassen'},
            {label = 'Spoiler', description = 'Spoiler anpassen'},
            {label = 'Motorhaube', description = 'Motorhauben anpassen'},
            {label = 'Dach', description = 'Dachoptionen anpassen'},
            {label = 'Zurück', description = 'Zum Hauptmenü zurück'}
        }
    }, function(selected, scrollIndex, args)
        -- Implementierung der Karosserie-Mods
        if selected == 7 then
            OpenTuningMenu()
        end
    end)

    lib.showMenu('tuning_karosserie_menu')
end

-- Leistung Submenü (mit Untermenüs)
function OpenLeistungMenu()
    local bremsenValues, federungValues, getriebeValues = {}, {}, {}
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    Wait(200)
    local data = GetVehicleData(vehicle)
    local testdata = data.mods
    local bremsenData = testdata["12"]
    local federungData = testdata["15"]
    local getriebeData = testdata["13"]
    if bremsenData.max ~= 0 then
        for i = 1, bremsenData.max do
            table.insert(bremsenValues, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(bremsenData.is +2), args = i-2} )
        end
    else
        table.insert(bremsenValues, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(bremsenData.is +2), args = bremsenData.is} )
    end
    if federungData.max ~= 0 then
        for i = 1, federungData.max do
            table.insert(federungValues, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(federungData.is +2), args = i-2} )
        end
    else
        table.insert(federungValues, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(federungData.is +2), args = federungData.is} )
    end
    if getriebeData.max ~= 0 then
        for i = 1, getriebeData.max do
            table.insert(getriebeValues, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(getriebeData.is +2), args = i-2} )
        end
    else
        table.insert(getriebeValues, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(getriebeData.is +2), args = getriebeData.is} )
    end

    local bremsenOptions = {label = 'Bremsen Ausbaustufen', values = bremsenValues, args = {mod = "12"}}
    local federungOptionen = {label = 'Federungsstufen', values = federungValues, args = {mod = "15"}}
    local getriebeOptionen = {label = 'Getriebestufen', values = getriebeValues, args = {mod = "13"}}

    lib.registerMenu({
        id = 'tuning_leistung_menu',
        title = 'Leistung',
        position = 'top-right',
        options = {
            {label = 'Motor', description = 'Motorleistung etc. Menü'},
            bremsenOptions,
            federungOptionen,
            getriebeOptionen,
            {label = 'Zurück', description = 'Zum Hauptmenü zurück'}
        }
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            OpenMotorMenu()
        elseif selected >= 2 or selected <= 4 and scrollIndex then
            local setIndex = tonumber(scrollIndex - 2)
            local modIndex = tonumber(args.mod)
            SetVehicleMod(vehicle, modIndex, setIndex, false)
            Wait(500) --entfernen oder reduzieren???
            local checkMod = GetVehicleMod(vehicle, modIndex) --entfernen
            lib.print.info(checkMod) --entfernen
            SaveTuning(vehicle)
            OpenLeistungMenu()
        end
        if selected == 5 then
            OpenTuningMenu()
        end
    end)

    lib.showMenu('tuning_leistung_menu')
end

-- Motor Untermenü (innerhalb von Leistung)
function OpenMotorMenu()
    local motorValues = {}
    local turboValues = {}
    local engineBay1Values, engineBay2Values, engineBay3Values = {},{},{}
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    Wait(200)
    local data = GetVehicleData(vehicle)
    local testdata = data.mods
    local motorData = testdata["11"]
    local turboData = testdata["18"]
    local engineBay1Data = testdata["39"]
    local engineBay2Data = testdata["40"]
    local engineBay3Data = testdata["41"]

    if motorData.max ~= 0 then
        for i = 1, motorData.max do
            table.insert(motorValues, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(motorData.is +2), args = i-2} )
        end
    else
        table.insert(motorValues, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(motorData.is +2), args = motorData.is} )
    end

    if turboData.max ~= 0 then
        for i = 1, turboData.max do
            table.insert(turboValues, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(turboData.is +2), args = i-2} )
        end
    else
        table.insert(turboValues, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(turboData.is +2), args = turboData.is} )
    end

    if engineBay1Data.max ~= 0 then
        for i = 1, engineBay1Data.max do
            table.insert(engineBay1Values, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(engineBay1Data.is +2), args = i-2} )
        end
    else
        table.insert(engineBay1Values, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(engineBay1Data.is +2), args = engineBay1Data.is} )
    end
    if engineBay2Data.max ~= 0 then
        for i = 1, engineBay2Data.max do
            table.insert(engineBay2Values, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(engineBay2Data.is +2), args = i-2} )
        end
    else
        table.insert(engineBay2Values, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(engineBay2Data.is +2), args = engineBay2Data.is} )
    end
    if engineBay3Data.max ~= 0 then
        for i = 1, engineBay3Data.max do
            table.insert(engineBay3Values, {label = 'Stufe '..i..'', description = 'Aktuelle Stufe: '..(engineBay3Data.is +2), args = i-2} )
        end
    else
        table.insert(engineBay3Values, {label = 'Kein Tuning möglich', description = 'Aktuelle Stufe: '..(engineBay3Data.is +2), args = engineBay3Data.is} )
    end

    local motorOptions = {label = 'Motor Ausbaustufen', values = motorValues, args = {mod = "11"}}
    local turboOptions = {label = 'Turbo Ausbaustufen', values = turboValues, args = {mod = "18"}}
    local engineBay1Options = {label = 'Motorraum 1', values = engineBay1Values, args = {mod = "39"}}
    local engineBay2Options = {label = 'Motorraum 2', values = engineBay2Values, args = {mod = "40"}}
    local engineBay3Options = {label = 'Motorraum 3', values = engineBay3Values, args = {mod = "41"}}

    lib.registerMenu({
        id = 'tuning_motor_menu',
        title = 'Motor Tuning',
        position = 'top-right',
        onSideScroll = function(selected, scrollIndex, args) lib.print.info("Scroll: ", selected, scrollIndex, args) end,
        options = {
            motorOptions,
            turboOptions,
            engineBay1Options,
            engineBay2Options,
            engineBay3Options,
            {label = 'Zurück', description = 'Zurück zum Leistungsmenü'}
        }
    }, function(selected, scrollIndex, args)
        --lib.print.info(selected, scrollIndex, args) --entfernen
        if (selected >= 1) and (selected <= 5)  then
            if selected and scrollIndex then
                local setIndex = tonumber(scrollIndex - 2)
                local modIndex = tonumber(args.mod)
                SetVehicleMod(vehicle, modIndex, setIndex, false)
                Wait(500) --entfernen oder reduzieren???
                local checkMod = GetVehicleMod(vehicle, modIndex) --entfernen
                lib.print.info(checkMod) --entfernen
                SaveTuning(vehicle)
            end
        end
        if selected == 6 then
            OpenLeistungMenu()
        else
            OpenMotorMenu()
        end
    end)
    lib.showMenu('tuning_motor_menu')
end


function SaveTuning(vehicle)
    Mor.Notify('Tuning wurde ~g~gespeichert~w~.')
    local properties = lib.getVehicleProperties(vehicle)
    Wait(100)
    TriggerServerEvent('tuning:SaveVehicleData', source, VehToNet(vehicle), properties)
end


function OpenTuningMenu()
    -- Prüfen ob Spieler in einem Fahrzeug sitzt
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    if vehicle == 0 then
        return lib.notify({type = 'error', description = 'Du musst in einem Fahrzeug sitzen!'})
    end

    -- Hauptmenü
    lib.registerMenu({
        id = 'tuning_main_menu',
        title = 'Fahrzeug Tuning',
        position = 'top-right',
        options = {
            {label = 'Lackierung', description = 'Farben und Lackierungen anpassen'},
            {label = 'Karosserie', description = 'Karosserie-Mods anpassen'},
            {label = 'Räder', description = 'Räder und Reifen anpassen'},
            {label = 'Leistung', description = 'Motor, Bremsen, Federung, Getriebe'},
            {label = 'Restliches Tuning', description = 'Andere Tuning-Optionen'},
            {label = 'Speichern', description = 'Tuning speichern'},
            {label = 'Schließen', description = 'Menü schließen'}
        }
    }, function(selected, scrollIndex, args)
        -- Hier kommen die Submenüs
        if selected == 1 then
            OpenLackierungMenu()
        elseif selected == 2 then
            OpenKarosserieMenu()
        elseif selected == 3 then
            OpenRaederMenu()
        elseif selected == 4 then
            OpenLeistungMenu()
        elseif selected == 5 then
            OpenRestlichesMenu()
        elseif selected == 6 then
            SaveTuning(vehicle)
        end
    end)

    lib.showMenu('tuning_main_menu')
end

function GetVehicleMods(vehicle)
    veh = {
        entity = vehicle,
        isSpoiler = GetVehicleMod(vehicle, 0),
        maxSpoiler = GetNumVehicleMods(vehicle, 0),
        isBumperF = GetVehicleMod(vehicle, 1),
        maxBumberF = GetNumVehicleMods(vehicle, 1),
        isBumperR = GetVehicleMod(vehicle, 2),
        maxBumperR = GetNumVehicleMods(vehicle, 2),
        isSkirt = GetVehicleMod(vehicle, 3),
        maxSkirt = GetNumVehicleMods(vehicle, 3),
        isExhaust = GetVehicleMod(vehicle, 4),
        maxExhaust = GetNumVehicleMods(vehicle, 4),
        isChassis = GetVehicleMod(vehicle, 5),
        maxChassis = GetNumVehicleMods(vehicle, 5),
        isGrill = GetVehicleMod(vehicle, 6),
        maxGrill = GetNumVehicleMods(vehicle, 6),
        isBonnet = GetVehicleMod(vehicle, 7),
        maxBonnet = GetNumVehicleMods(vehicle, 7),
        isWingL = GetVehicleMod(vehicle, 8),
        maxWingL = GetNumVehicleMods(vehicle, 8),
        isWingR = GetVehicleMod(vehicle, 9),
        maxWingR = GetNumVehicleMods(vehicle, 9),
        isRoof = GetVehicleMod(vehicle, 10),
        maxRoof = GetNumVehicleMods(vehicle, 10),
        isEngine = GetVehicleMod(vehicle, 11),
        maxEngine = GetNumVehicleMods(vehicle, 11),
        ---isBrakes = ,
        --maxBrakes = ,
        --isGearbox = ,
        --maxGearbox = ,
       -- isHorn = ,
        --maxHorn = ,
        --isSuspention = ,
        --maxSuspention = ,
        --isArmour
    }
    local isvehicle = {
        [0] = veh.isSpoiler,
        [1] = veh.isBumperF,
        [2] = veh.isBumperR,
        [3] = veh.isSkirt,
        [4] = veh.isExhaust,
        [5] = veh.isChassis,
        [6] = veh.isGrill,
        [7] = veh.isBonnet,
        [8] = veh.isWingL,
        [9] = veh.isWingR,
        [10] = veh.isRoof,
        [11] = veh.isEngine,
        --[12] = ,
        --[12] = ,

    }
    return veh
end

CreateThread(function()
    for _,i in pairs(cfg) do
        Mor.Blip:new({
            coords = vec3(i.coords.x,i.coords.y,i.coords.z),
            name = i.label,
            sprite = 72, --643 --72 --777
            color = 17,
            hidden = false,
        })
    end
end)

for _,k in pairs(cfg) do
    for i=1, #k.workcoords do
        point = lib.points.new({
            coords = vec3(k.workcoords[i].x, k.workcoords[i].y, k.workcoords[i].z),
            distance = 5,
        })
    end
    function point:onEnter()
        local player = Ox.GetPlayer(PlayerId())
        local plyData = player.get('playerdata')
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if plyData.group == k.group and veh ~= 0 then
            lib.showTextUI(locale('[E] - Car Tuning'), {
            position = "left-center",
            icon = 'hand'
            })
        end
        local keybind = lib.addKeybind({
            name = 'tuningmenueenter',
            description = locale('press E to open tuning menu'),
            defaultKey = 'E',
            onPressed = function(self)
                local vehmods =  GetVehicleMods(vehicle)
                Wait(2000)
                OpenTuningMenu()
                --print(('pressed %s (%s)'):format(self.currentKey, self.name))
            end
        })
        print('Enter Tuning Point')
    end

    function point:onExit()
        veh = {}
        lib.hideTextUI()
        lib.hideMenu(onExit)
        print('left range of point', self.id)
    end
end

lib.onCache('vehicle', function(vehicle, oldfalue)
    if not vehicle then return end
    GetVehicleData(vehicle)
end)

function GetVehicleData(vehicle)
    VehicleData[vehicle] = VehicleData[vehicle] or {}

    VehicleData[vehicle].mods = {
        ["0"]= {
            name = locale('spoiler'),
            is = GetVehicleMod(vehicle, 0),
            max = GetNumVehicleMods(vehicle, 0),
            label = GetModTextLabel(vehicle, 0 , is)
        },
        ["1"]= {
            name = locale('bumper Front'),
            is = GetVehicleMod(vehicle, 1),
            max = GetNumVehicleMods(vehicle, 1),
            label = GetModTextLabel(vehicle, 1 , is)
        },
        ["2"]= {
            name = locale('bumper Rear'),
            is = GetVehicleMod(vehicle, 2),
            max = GetNumVehicleMods(vehicle, 2),
            label = GetModTextLabel(vehicle, 2 , is)
        },
        ["3"]= {
            name = locale('skirt'),
            is = GetVehicleMod(vehicle, 3),
            max = GetNumVehicleMods(vehicle, 3),
            label = GetModTextLabel(vehicle, 3 , is)
        },
        ["4"]= {
            name = locale('exhaust'),
            is = GetVehicleMod(vehicle, 4),
            max = GetNumVehicleMods(vehicle, 4),
            label = GetModTextLabel(vehicle, 4 , is)
        },
        ["5"]= {
            name = locale('chassis'),
            is = GetVehicleMod(vehicle, 5),
            max = GetNumVehicleMods(vehicle, 5),
            label = GetModTextLabel(vehicle, 5 , is)
        },
        ["6"]= {
            name = locale('grill'),
            is = GetVehicleMod(vehicle, 6),
            max = GetNumVehicleMods(vehicle, 6),
            label = GetModTextLabel(vehicle, 6 , is)
        },
        ["7"]= {
            name = locale('bonnet'),
            is = GetVehicleMod(vehicle, 7),
            max = GetNumVehicleMods(vehicle, 7),
            label = GetModTextLabel(vehicle, 7, is)
        },
        ["8"]= {
            name = locale('wingL'),
            is = GetVehicleMod(vehicle, 8),
            max = GetNumVehicleMods(vehicle, 8),
            label = GetModTextLabel(vehicle, 8, is)
        },
        ["9"]= {
            name = locale('wingR'),
            is = GetVehicleMod(vehicle, 9),
            max = GetNumVehicleMods(vehicle, 9),
            label = GetModTextLabel(vehicle, 9, is)
        },
        ["10"]= {
            name = locale('roof'),
            is = GetVehicleMod(vehicle, 10),
            max = GetNumVehicleMods(vehicle, 10),
            label = GetModTextLabel(vehicle, 10, is)
        },
        ["11"]= {
            name = locale('engine'),
            is = GetVehicleMod(vehicle, 11),
            max = GetNumVehicleMods(vehicle, 11),
            label = GetModTextLabel(vehicle, 11, is)
        },
        ["12"]= {
            name = locale('brakes'),
            is = GetVehicleMod(vehicle, 12),
            max = GetNumVehicleMods(vehicle, 12),
            label = GetModTextLabel(vehicle, 12, is)
        },
        ["13"]= {
            name = locale('gearbox'),
            is = GetVehicleMod(vehicle, 13),
            max = GetNumVehicleMods(vehicle, 13),
            label = GetModTextLabel(vehicle, 13, is)
        },
        ["14"]= {
            name = locale('horn'),
            is = GetVehicleMod(vehicle, 14),
            max = GetNumVehicleMods(vehicle, 14),
            label = GetModTextLabel(vehicle, 14, is)
        },
        ["15"]= {
            name = locale('suspension'),
            is = GetVehicleMod(vehicle, 15),
            max = GetNumVehicleMods(vehicle, 15),
            label = GetModTextLabel(vehicle, 15, is)
        },
        ["16"]= {
            name = locale('armour'),
            is = GetVehicleMod(vehicle, 16),
            max = GetNumVehicleMods(vehicle, 16),
            label = GetModTextLabel(vehicle, 16, is)
        },
        ["17"]= {
            name = locale('nitrous'),
            is = GetVehicleMod(vehicle, 17),
            max = GetNumVehicleMods(vehicle, 17),
            label = GetModTextLabel(vehicle, 17, is)
        },
        ["18"]= {
            name = locale('turbo'),
            is = GetVehicleMod(vehicle, 18),
            max = GetNumVehicleMods(vehicle, 18),
            label = GetModTextLabel(vehicle, 18, is)
        },
        ["19"]= {
            name = locale('subwoofer'),
            is = GetVehicleMod(vehicle, 19),
            max = GetNumVehicleMods(vehicle, 19),
            label = GetModTextLabel(vehicle, 19, is)
        },
        ["20"]= {
            name = locale('tyre_smoke'),
            is = GetVehicleMod(vehicle, 20),
            max = GetNumVehicleMods(vehicle, 20),
            label = GetModTextLabel(vehicle, 20, is)
        },
        ["21"]= {
            name = locale('hydraulics'),
            is = GetVehicleMod(vehicle, 21),
            max = GetNumVehicleMods(vehicle, 21),
            label = GetModTextLabel(vehicle, 21, is)
        },
        ["22"]= {
            name = locale('xenon_lights'),
            is = GetVehicleMod(vehicle, 22),
            max = GetNumVehicleMods(vehicle, 22),
            label = GetModTextLabel(vehicle, 22, is)
        },
        ["23"]= {
            name = locale('wheels'),
            is = GetVehicleMod(vehicle, 23),
            max = GetNumVehicleMods(vehicle, 23),
            label = GetModTextLabel(vehicle, 23, is)
        },
        ["24"]= {
            name = locale('WHEELS_REAR_OR_HYDRAULICS'),
            is = GetVehicleMod(vehicle, 24),
            max = GetNumVehicleMods(vehicle, 24),
            label = GetModTextLabel(vehicle, 24, is)
        },
        ["25"]= {
            name = locale('pltholder'),
            is = GetVehicleMod(vehicle, 25),
            max = GetNumVehicleMods(vehicle, 25),
            label = GetModTextLabel(vehicle, 25, is)
        },
        ["26"]= {
            name = locale('pltvanity'),
            is = GetVehicleMod(vehicle, 26),
            max = GetNumVehicleMods(vehicle, 26),
            label = GetModTextLabel(vehicle, 26, is)
        },
        ["27"]= {
            name = locale('interiors1'),
            is = GetVehicleMod(vehicle, 27),
            max = GetNumVehicleMods(vehicle, 27),
            label = GetModTextLabel(vehicle, 27, is)
        },
        ["28"]= {
            name = locale('interiors2'),
            is = GetVehicleMod(vehicle, 28),
            max = GetNumVehicleMods(vehicle, 28),
            label = GetModTextLabel(vehicle, 28, is)
        },
        ["29"]= {
            name = locale('interiors3'),
            is = GetVehicleMod(vehicle, 29),
            max = GetNumVehicleMods(vehicle, 29),
            label = GetModTextLabel(vehicle, 29, is)
        },
        ["30"]= {
            name = locale('interiors4'),
            is = GetVehicleMod(vehicle, 30),
            max = GetNumVehicleMods(vehicle, 30),
            label = GetModTextLabel(vehicle, 30, is)
        },
        ["31"]= {
            name = locale('interiors5'),
            is = GetVehicleMod(vehicle, 31),
            max = GetNumVehicleMods(vehicle, 31),
            label = GetModTextLabel(vehicle, 31, is)
        },
        ["32"]= {
            name = locale('seats'),
            is = GetVehicleMod(vehicle, 31),
            max = GetNumVehicleMods(vehicle, 31),
            label = GetModTextLabel(vehicle, 31, is)
        },
        ["33"]= {
            name = locale('steering'),
            is = GetVehicleMod(vehicle, 31),
            max = GetNumVehicleMods(vehicle, 31),
            label = GetModTextLabel(vehicle, 31, is)
        },
        ["34"]= {
            name = locale('knob'),
            is = GetVehicleMod(vehicle, 34),
            max = GetNumVehicleMods(vehicle, 34),
            label = GetModTextLabel(vehicle, 34, is)
        },
        ["35"]= {
            name = locale('plaque'),
            is = GetVehicleMod(vehicle, 35),
            max = GetNumVehicleMods(vehicle, 35),
            label = GetModTextLabel(vehicle, 35, is)
        },
        ["36"]= {
            name = locale('ice'),
            is = GetVehicleMod(vehicle, 36),
            max = GetNumVehicleMods(vehicle, 36),
            label = GetModTextLabel(vehicle, 36, is)
        },
        ["37"]= {
            name = locale('trunk'),
            is = GetVehicleMod(vehicle, 37),
            max = GetNumVehicleMods(vehicle, 37),
            label = GetModTextLabel(vehicle, 37, is)
        },
        ["38"]= {
            name = locale('hydro'),
            is = GetVehicleMod(vehicle, 38),
            max = GetNumVehicleMods(vehicle, 38),
            label = GetModTextLabel(vehicle, 38, is)
        },
        ["39"]= {
            name = locale('enginebay1'),
            is = GetVehicleMod(vehicle, 39),
            max = GetNumVehicleMods(vehicle, 39),
            label = GetModTextLabel(vehicle, 39, is)
        },
        ["40"]= {
            name = locale('enginebay2'),
            is = GetVehicleMod(vehicle, 40),
            max = GetNumVehicleMods(vehicle, 40),
            label = GetModTextLabel(vehicle, 40, is)
        },
        ["41"]= {
            name = locale('enginebay3'),
            is = GetVehicleMod(vehicle, 41),
            max = GetNumVehicleMods(vehicle, 41),
            label = GetModTextLabel(vehicle, 41, is)
        },
        ["42"]= {
            name = locale('chassis2'),
            is = GetVehicleMod(vehicle, 42),
            max = GetNumVehicleMods(vehicle, 42),
            label = GetModTextLabel(vehicle, 42, is)
        },
        ["43"]= {
            name = locale('chassis3'),
            is = GetVehicleMod(vehicle, 43),
            max = GetNumVehicleMods(vehicle, 43),
            label = GetModTextLabel(vehicle, 43, is)
        },
        ["44"]= {
            name = locale('chassis4'),
            is = GetVehicleMod(vehicle, 44),
            max = GetNumVehicleMods(vehicle, 44),
            label = GetModTextLabel(vehicle, 44, is)
        },
        ["45"]= {
            name = locale('chassis5'),
            is = GetVehicleMod(vehicle, 45),
            max = GetNumVehicleMods(vehicle, 45),
            label = GetModTextLabel(vehicle, 45, is)
        },
        ["46"]= {
            name = locale('door_l'),
            is = GetVehicleMod(vehicle, 46),
            max = GetNumVehicleMods(vehicle, 46),
            label = GetModTextLabel(vehicle, 46, is)
        },
        ["47"]= {
            name = locale('door_r'),
            is = GetVehicleMod(vehicle, 47),
            max = GetNumVehicleMods(vehicle, 47),
            label = GetModTextLabel(vehicle, 47, is)
        },
        ["48"]= {
            name = locale('livery'),
            is = GetVehicleMod(vehicle, 48),
            max = GetNumVehicleMods(vehicle, 48),
            label = GetModTextLabel(vehicle, 48, is)
        },
        ["49"]= {
            name = locale('lightbar'),
            is = GetVehicleMod(vehicle, 49),
            max = GetNumVehicleMods(vehicle, 49),
            label = GetModTextLabel(vehicle, 49, is)
        },
    }
    lib.print.info(VehicleData[vehicle])
    TriggerServerEvent('tuning:SetVehicleData', source, VehToNet(vehicle), VehicleData[vehicle])
    return VehicleData[vehicle]
end