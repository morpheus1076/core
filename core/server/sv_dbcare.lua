

local cfg = require('shared.cfg_core')
local classes = cfg.Class
local trunks = cfg.Trunk
local glovebox = cfg.Glovebox

lib.callback.register('vehmodels', function(source, allModels)
    local src = source
    for i=1, #allModels do
        local dbModel = MySQL.query.await("SELECT model FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbModel == nil or (type(dbModel) == "table" and next(dbModel) == nil) then
            local insertModel = MySQL.insert.await("INSERT INTO listvehicles (model) VALUES (?)", {allModels[i]})
            if insertModel then
                print('Model: '..allModels[i]..' hinzugefügt.')
            end
            Wait(100)
        end

        local dbClass = MySQL.query.await("SELECT class FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbClass[1].class == 999 or (type(dbClass[1].class) == "table" and next(dbClass[1].class) == 999) then
            local mmodel = json.encode(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelClass = oxmodel.class
                Wait(50)
                local insertClass = MySQL.update.await('UPDATE listvehicles SET class = ? WHERE model = ?', {modelClass, allModels[i]})
                if insertClass then
                    print('Class: '..modelClass..' für Model: '..allModels[i]..' hinzugefügt.')
                end
            end
            Wait(100)
        end

        local dbSeats = MySQL.query.await("SELECT seats FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbSeats[1].seats == 999 or (type(dbSeats[1].seats) == "table" and next(dbSeats[1].seats) == 999) then
            local mmodel = json.encode(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelSeats = oxmodel.seats
                Wait(50)
                local insertSeats = MySQL.update.await('UPDATE listvehicles SET seats = ? WHERE model = ?', {modelSeats, allModels[i]})
                if insertSeats then
                    print('Seats: '..modelSeats..' für Model: '..allModels[i]..' hinzugefügt.')
                end
            end
            Wait(100)
        end

        local dbDoors = MySQL.query.await("SELECT doors FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbDoors[1].doors == 999 or (type(dbDoors[1].doors) == "table" and next(dbDoors[1].doors) == 999) then
            local mmodel = json.encode(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelDoors = oxmodel.doors
                Wait(50)
                local insertDoors = MySQL.update.await('UPDATE listvehicles SET doors = ? WHERE model = ?', {modelDoors, allModels[i]})
                if insertDoors then
                    print('Doors: '..modelDoors..' für Model: '..allModels[i]..' hinzugefügt.')
                end
            end
            Wait(100)
        end

        local dbType = MySQL.query.await("SELECT type FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbType[1].type == 'unbekannt' or (type(dbType[1].type) == "table" and next(dbType[1].type) == 'unbekannt') then
            local mmodel = json.encode(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelType = oxmodel.type
                Wait(50)
                local insertType = MySQL.update.await('UPDATE listvehicles SET type = ? WHERE model = ?', {modelType, allModels[i]})
                if insertType then
                    print('Type: '..modelType..' für Model: '..allModels[i]..' hinzugefügt.')
                end
            end
            Wait(100)
        end

        local dbPrice = MySQL.query.await("SELECT price FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbPrice[1].price == 0 or (type(dbPrice[1].price) == "table" and next(dbPrice[1].price) == 0) then
            local mmodel = tostring(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelPrice = oxmodel.price
                Wait(50)
                local insertPrice = MySQL.update.await('UPDATE listvehicles SET price = ? WHERE model = ?', {modelPrice, allModels[i]})
                if insertPrice then
                    print('Price: '..modelPrice..' für Model: '..allModels[i]..' hinzugefügt.')
                end
            end
            Wait(100)
        end

        local dbMake = MySQL.query.await("SELECT herst FROM listvehicles WHERE model = ?", {allModels[i]})
        if (dbMake[1].herst == 'unbekannt') or (type(dbMake[1].herst) == "table" and next(dbMake[1].herst) == 'unbekannt') then
            local mmodel = tostring(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelMake = oxmodel.make
                if modelMake == "" then modelMake = 'unbekannt' end
                Wait(50)
                local insertMake = MySQL.update.await('UPDATE listvehicles SET herst = ? WHERE model = ?', {modelMake, allModels[i]})
                if insertMake then
                    print('Hersteller: '..modelMake..' für Model: '..allModels[i]..' hinzugefügt.')
                end
            end
            Wait(100)
        end

        local dbName = MySQL.query.await("SELECT name FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbName[1].name == 'unbekannt' or (type(dbName[1].name) == "table" and next(dbName[1].name) == 'unbekannt') then
            local mmodel = tostring(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelName = oxmodel.name
                Wait(50)
                local insertName = MySQL.update.await('UPDATE listvehicles SET name = ? WHERE model = ?', {modelName, allModels[i]})
                if insertName then
                    print('Name: '..modelName..' für Model: '..allModels[i]..' hinzugefügt.')
                end
            end
            Wait(100)
        end

        local dbTrunk = MySQL.query.await("SELECT trunk FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbTrunk[1].trunk == 0 or (type(dbTrunk[1].trunk) == "table" and next(dbTrunk[1].trunk) == 0) then
            local mmodel = tostring(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local cfgTrunk = DbConfig.Trunk
                local modelClass = oxmodel.class
                Wait(50)
                for j=1, #cfgTrunk do
                    if cfgTrunk[j].category == modelClass then
                        local insertTrunk = MySQL.update.await('UPDATE listvehicles SET trunk = ? WHERE model = ?', {cfgTrunk[j].trunk, allModels[i]})
                        if insertTrunk then
                            print('Trunk: '..cfgTrunk[j].trunk..' für Model: '..allModels[i]..' hinzugefügt.')
                        end
                    end
                end
                Wait(50)
            end
            Wait(100)
        end

        local dbGlove = MySQL.query.await("SELECT glovebox FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbGlove[1].glovebox == 0 or (type(dbGlove[1].glovebox) == "table" and next(dbGlove[1].glovebox) == 0) then
            local mmodel = tostring(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local cfgGlove = DbConfig.Glovebox
                local modelClass = oxmodel.class
                Wait(50)
                for j=1, #cfgGlove do
                    if cfgGlove[j].category == modelClass then
                        local insertGlove = MySQL.update.await('UPDATE listvehicles SET glovebox = ? WHERE model = ?', {cfgGlove[j].glovebox, allModels[i]})
                        if insertGlove then
                            print('Glovebox: '..cfgGlove[j].glovebox..' für Model: '..allModels[i]..' hinzugefügt.')
                        end
                    end
                    Wait(50)
                end
            end
            Wait(100)
        end

        local dbWeapon = MySQL.query.await("SELECT weapons FROM listvehicles WHERE model = ?", {allModels[i]})
        if (dbWeapon[1].weapons == 'unbekannt') or (type(dbWeapon[1].weapons) == "table" and next(dbWeapon[1].weapons) == 'unbekannt') then
            local mmodel = tostring(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local modelWeapon = oxmodel.weapons
                if modelWeapon == true then
                    local dataWeapon = 'true'
                    Wait(50)
                    local insertWeapon = MySQL.update.await('UPDATE listvehicles SET weapons = ? WHERE model = ?', {dataWeapon, allModels[i]})
                    if insertWeapon then
                        print('Weapon: '..dataWeapon..' für Model: '..allModels[i]..' hinzugefügt.')
                    end
                else
                    local dataWeapon = 'false'
                    local insertWeapon = MySQL.update.await('UPDATE listvehicles SET weapons = ? WHERE model = ?', {dataWeapon, allModels[i]})
                    if insertWeapon then
                        print('Weapon: '..dataWeapon..' für Model: '..allModels[i]..' hinzugefügt.')
                    end
                end
            end
            Wait(100)
        end

        local dbCategory = MySQL.query.await("SELECT category FROM listvehicles WHERE model = ?", {allModels[i]})
        if dbCategory[1].category == 'unbekannt' or (type(dbCategory[1].category) == "table" and next(dbCategory[1].category) == 'unbekannt') then
            local mmodel = tostring(allModels[i])
            local oxmodel = Ox.GetVehicleData(mmodel)
            if oxmodel then
                local cfgCategory = DbConfig.Class
                local modelClass = oxmodel.class
                Wait(50)
                for j=1, #cfgCategory do
                    if cfgCategory[j].id == modelClass then
                        local insertCategory = MySQL.update.await('UPDATE listvehicles SET category = ? WHERE model = ?', {cfgCategory[j].name, allModels[i]})
                        if insertCategory then
                            print('Category: '..cfgCategory[j].name..' für Model: '..allModels[i]..' hinzugefügt.')
                        end
                    end
                    Wait(50)
                end
            end
            Wait(100)
        end
    end
    return 'erledigt'
end)
