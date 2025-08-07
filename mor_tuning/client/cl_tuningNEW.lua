
------------------------------------------------------------------------
local Notify = function(msg) exports['mor_nucleus']:Notify(msg) end
local InfoLog = function(msg) exports['mor_nucleus']:InfoLog(msg) end
local WarnLog = function(msg) exports['mor_nucleus']:WarnLog(msg) end
------------------------------------------------------------------------

local tcolors = colors.base

local properties = nil
local vehicle = nil
local colors = {}
local paintType = 0
local metallicNames = {}
local mateColors = {}
local metalColors = {}

RegisterCommand("tuning2", function()
    vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle then
        properties = lib.getVehicleProperties(vehicle)
        lib.showMenu('tuningauswahlmenu')
    else
        Notify("Kein Fahrzeug")
    end
end, false)

local function MainMenu()

end

lib.registerMenu(
    {
        id = 'tuningauswahlmenu',
        title = 'Auswahl Menü',
        position = 'top-left',

            onSelected = function(selected, secondary, args)
            if not secondary then
                --print("Normal button")
            else
                if args.isCheck then
                    --print("Check button")
                end

                if args.isScroll then
                    --print("Scroll button")
                end
            end
            --print(selected, secondary, json.encode(args, {indent=true}))
        end,
        onCheck = function(selected, checked, args)
            --print("Check: ", selected, checked, args)
        end,
        onClose = function(keyPressed)
            --print('Menu closed')
            if keyPressed then
                --print(('Pressed %s to close the menu'):format(keyPressed))
            end
        end,

        options = {
            {label = 'Farben', description = 'Alle Fahrzeugfarben, außer Felgen und Reifen.'},
            {label = 'Aerodynamik', description = 'AeroDynamk Komponenten.'},
            {label = 'Mechnik', description = 'Motor und Anbau Komponenten.'},
        }
    },
        function(selected, scrollIndex, args)
            --print('Selected: ', selected, '  ScrollIndex: ', scrollIndex,'  Args: ', args)
            if selected == 1 then
                lib.showMenu('farbenmenu')
            end
        end)

lib.registerMenu(
    {
        id = 'farbenmenu',
        title = 'Farben Menü',
        position = 'top-left',

        onSelected = function(selected, secondary, args)
            if not secondary then
                print("Normal button")
            else
                if args.isCheck then
                    print("Check button")
                end

                if args.isScroll then
                    print("Scroll button")
                    --print(json.encode(args))
                end
            end
            --print(selected, secondary, json.encode(args, {indent=true}))
        end,
        onCheck = function(selected, checked, args)
            print("Check: ", selected, checked, args)
        end,
        onClose = function(keyPressed)
            print('Menu closed')
            if keyPressed then
                print(('Pressed %s to close the menu'):format(keyPressed))
            end
        end,
        onSideScroll = function(selected, scrollindex, args)
            print('In der Scroll Function: ', 'selected: ',selected,'Scroll: ', scrollindex,'Args:', args)
            if vehicle and selected == 2 and scrollindex ~= nil then
                local dbColors = tcolors
                if scrollindex == 1 then -- Metallic
                    local type = 1
                    paintType = 1
                    for i=1, #dbColors do
                        print('In Select 2 , dbColors for-Schleife')
                        if type == dbColors[i].paintType then
                            print(dbColors[i].name, dbColors[i].index)
                            table.insert(metallicNames, dbColors[i].name)
                        end
                    end
                    print(json.encode(metallicNames))
                    lib.setMenuOptions('farbenmenu', {label = 'Farben', values = metallicNames}, 3)
                    SetVehicleModColor_1(vehicle, paintType, _, _)
                end
            end
            if vehicle and selected == 3 and paintType ~= nil then
                local numIndex = scrollindex-1
                Wait(500)
                print(vehicle, _, numIndex, _)
                SetVehicleModColor_1(vehicle, _, numIndex, _)
            end
        end,
        options = {
            {label = 'Achtung: Direkte Änderungen.', description = 'Daten weden direkt aufs Fahrzeug angewendet.' },
            {label = 'Lackart', values = {'Metallic', 'Matt',' Metall'}},
            {label = 'Farbe', values = 'none'},
        }
    },
        function(selected, scrollIndex, args)
            print('Function ganz unten: ',' Selected: ', selected, '  ScrollIndex: ', scrollIndex,'  Args: ', args)
        end)