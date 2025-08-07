
if not lib then
    error('ox_lib ist nicht geladen!')
end

local Mor = require("client.cl_lib")

lib.locale()
local setCloth = {}

local json_male_legs = LoadResourceFile("core", "json/male_legs.json")
local json_female_legs = LoadResourceFile("core", "json/female_legs.json")
local json_male_torso = LoadResourceFile("core", "json/male_torsos.json")
local json_female_torso = LoadResourceFile("core", "json/female_torsos.json")
local json_male_shoes = LoadResourceFile("core", "json/male_shoes.json")
local json_female_shoes = LoadResourceFile("core", "json/female_shoes.json")
local json_male_shirt = LoadResourceFile("core", "json/male_undershirts.json")
local json_female_shirt = LoadResourceFile("core", "json/female_undershirts.json")
local json_male_tops = LoadResourceFile("core", "json/male_tops.json")
local json_female_tops = LoadResourceFile("core", "json/female_tops.json")
local json_props_male_hat = LoadResourceFile("core", "json/props_male_hats.json")
local json_props_female_hat = LoadResourceFile("core", "json/props_female_hats.json")

local male_legs = json.decode(json_male_legs)
local female_legs = json.decode(json_female_legs)
local male_torso = json.decode(json_male_torso)
local female_torso = json.decode(json_female_torso)
local male_shoes = json.decode(json_male_shoes)
local female_shoes = json.decode(json_female_shoes)
local male_shirt = json.decode(json_male_shirt)
local female_shirt = json.decode(json_female_shirt)
local male_tops = json.decode(json_male_tops)
local female_tops = json.decode(json_female_tops)
local male_hat = json.decode(json_props_male_hat)
local female_hat = json.decode(json_props_female_hat)

CreateThread(function()
    lib.registerRadial({
        id = 'clothes_menu',
        items = {
            {
                label = locale('Hat'),
                icon = 'helmet-safety',
                onSelect = function()
                    local ped = PlayerPedId()
                    local player = Ox.GetPlayer(PlayerId())
                    local plyData = player.get('playerdata')
                    local getgender = plyData.gender
                    local drawHat = GetPedPropIndex(ped, 0)
                    local textHat = GetPedPropTextureIndex(ped, 0)
                    local drawableKey = tostring(drawHat)
                    local textureKey = tostring(textHat)

                    if getgender == 'male' then
                        if male_hat[drawableKey] and male_hat[drawableKey][textureKey] then
                            local name = male_hat[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='hat', prop=0, drawable=drawHat, texture=textHat}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            else
                                local name = male_hat[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='hat', prop=0, drawable=drawHat, texture=textHat}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            end
                        else
                            return "Unknown Kopfbedeckung"
                        end
                    else
                        if female_hat[drawableKey] and female_hat[drawableKey][textureKey] then
                            local name = female_hat[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='hat', prop=0, drawable=drawHat, texture=textHat}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            else
                                local name = female_hat[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='hat', prop=0, drawable=drawHat, texture=textHat}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            end
                        else
                            return "Unknown Kopfbedeckung"
                        end
                    end
                end
            },
            --[[{
                label = locale('Arms'),
                icon = 'hand',
                onSelect = function()
                    local ped = PlayerPedId()
                    local player = Ox.GetPlayer(PlayerId())
                    local plyData = player.get('playerdata')
                    local getgender = plyData.gender
                    local drawTorso = GetPedDrawableVariation(ped, 3)
                    local textTorso = GetPedTextureVariation(ped, 3)
                    local drawableKey = tostring(drawTorso)
                    local textureKey = tostring(textTorso)
                    if getgender == 'male' then
                        if male_torso[drawableKey] and male_torso[drawableKey][textureKey] then
                            local name = male_torso[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='torso', component=3, drawable=drawTorso, texture=textTorso}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            else
                                local name = male_torso[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='torso', component=3, drawable=drawTorso, texture=textTorso}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            end
                        else
                            return "Unknown Jacke"
                        end
                    else
                        if female_torso[drawableKey] and female_torso[drawableKey][textureKey] then
                            local name = female_torso[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='torso', component=3, drawable=drawTorso, texture=textTorso}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            else
                                local name = female_torso[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='torso', component=3, drawable=drawTorso, texture=textTorso}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            end
                        else
                            return "Unknown Jacke"
                        end
                    end
                end
            },]]
            {
                label = locale('Tops'),
                icon = 'shirt',
                onSelect = function()
                    local ped = PlayerPedId()
                    local player = Ox.GetPlayer(PlayerId())
                    local plyData = player.get('playerdata')
                    local getgender = plyData.gender
                    local drawTops = GetPedDrawableVariation(ped, 11)
                    local textTops = GetPedTextureVariation(ped, 11)
                    local drawTorso = GetPedDrawableVariation(ped, 3)
                    local textTorso = GetPedTextureVariation(ped, 3)
                    local drawableKey = tostring(drawTops)
                    local textureKey = tostring(textTops)
                    lib.print.info(drawableKey, textureKey)
                    if getgender == 'male' then
                        if male_tops[drawableKey] and male_tops[drawableKey][textureKey] then
                            local name = male_tops[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='tops', component=11, drawable=drawTops, texture=textTops, torso={drawTorso, textTorso}}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', source, setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            else
                                local name = male_tops[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='tops', component=11, drawable=drawTops, texture=textTops}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', source, setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            end
                        else
                            return "Unknown Tops"
                        end
                    else
                        if female_tops[drawableKey] and female_tops[drawableKey][textureKey] then
                            local name = female_tops[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='tops', component=11, drawable=drawTops, texture=textTops}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', source, setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            else
                                local name = female_tops[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='tops', component=11, drawable=drawTops, texture=textTops}
                                lib.print.info(setCloth)
                                local callClothes = lib.callback.await('clothes:GiveItems', source, setCloth)
                                if callClothes then
                                    Mor.Notify('~w~Kleidung ins ~y~Inventar ~w~gepackt.')
                                end
                            end
                        else
                            return "Unknown Tops"
                        end
                    end
                end
            },
            {
                label = locale('Shirt'),
                icon = 'shirt',
                onSelect = function()
                    local ped = PlayerPedId()
                    local player = Ox.GetPlayer(PlayerId())
                    local plyData = player.get('playerdata')
                    local getgender = plyData.gender
                    local drawShirt = GetPedDrawableVariation(ped, 8)
                    local textShirt = GetPedTextureVariation(ped, 8)
                    local drawableKey = tostring(drawShirt)
                    local textureKey = tostring(textShirt)

                    if getgender == 'male' then
                        if male_shirt[drawableKey] and male_shirt[drawableKey][textureKey] then
                            local name = male_shirt[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='shirt', component=8, drawable=drawShirt, texture=textShirt}
                                lib.print.info(setCloth)
                            else
                                local name = male_shirt[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='shirt', component=8, drawable=drawShirt, texture=textShirt}
                                lib.print.info(setCloth)
                            end
                        else
                            return "Unknown Shirt"
                        end
                    else
                        if female_shirt[drawableKey] and female_shirt[drawableKey][textureKey] then
                            local name = female_shirt[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='shirt', component=8, drawable=drawShirt, texture=textShirt}
                                lib.print.info(setCloth)
                            else
                                local name = female_shirt[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='shirt', component=8, drawable=drawShirt, texture=textShirt}
                                lib.print.info(setCloth)
                            end
                        else
                            return "Unknown Shirt"
                        end
                    end
                end
            },
            {
                label = locale('Pants'),
                icon = 'pants',
                onSelect = function()
                    local ped = PlayerPedId()
                    local player = Ox.GetPlayer(PlayerId())
                    local plyData = player.get('playerdata')
                    local getgender = plyData.gender
                    local drawLegs = GetPedDrawableVariation(ped, 4)
                    local textLegs = GetPedTextureVariation(ped,4)
                    local drawableKey = tostring(drawLegs)
                    local textureKey = tostring(textLegs)

                    if getgender == 'male' then
                        if male_legs[drawableKey] and male_legs[drawableKey][textureKey] then
                            local name = male_legs[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='pants', component=4, drawable=drawLegs, texture=textLegs}
                                lib.print.info(setCloth)
                            else
                                local name = male_legs[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='pants', component=4, drawable=drawLegs, texture=textLegs}
                                lib.print.info(setCloth)
                            end
                        else
                            return "Unknown Legs"
                        end
                    else
                        if female_legs[drawableKey] and female_legs[drawableKey][textureKey] then
                            local name = female_legs[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='pants', component=4, drawable=drawLegs, texture=textLegs}
                                lib.print.info(setCloth)
                            else
                                local name = female_legs[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='pants', component=4, drawable=drawLegs, texture=textLegs}
                                lib.print.info(setCloth)
                            end
                        else
                            return "Unknown Legs"
                        end
                    end
                end
            },
            {
                label = locale('Shoes'),
                icon = 'shoe-prints',
                onSelect = function()
                    local ped = PlayerPedId()
                    local player = Ox.GetPlayer(PlayerId())
                    local plyData = player.get('playerdata')
                    local getgender = plyData.gender
                    local drawShoes = GetPedDrawableVariation(ped, 6)
                    local textShoes = GetPedTextureVariation(ped,6)
                    local drawableKey = tostring(drawShoes)
                    local textureKey = tostring(textShoes)

                    if getgender == 'male' then
                        if male_shoes[drawableKey] and male_shoes[drawableKey][textureKey] then
                            local name = male_shoes[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='shoes', component=6, drawable=drawShoes, texture=textShoes}
                                lib.print.info(setCloth)
                            else
                                local name = male_shoes[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='shoes', component=6, drawable=drawShoes, texture=textShoes}
                                lib.print.info(setCloth)
                            end
                        else
                            return "Unknown Shoes"
                        end
                    else
                        if female_shoes[drawableKey] and female_shoes[drawableKey][textureKey] then
                            local name = female_shoes[drawableKey][textureKey].Localized
                            if name == 'NULL' then
                                local name='unknown'
                                setCloth = {gender=getgender, label=name, item='shoes', component=6, drawable=drawShoes, texture=textShoes}
                                lib.print.info(setCloth)
                            else
                                local name = female_shoes[drawableKey][textureKey].Localized
                                setCloth = {gender=getgender, label=name, item='shoes', component=6, drawable=drawShoes, texture=textShoes}
                                lib.print.info(setCloth)
                            end
                        else
                            return "Unknown Shoes"
                        end
                    end
                end
            }
        }
    })

    lib.addRadialItem({
        {
            id = 'kleidung',
            label = 'Kleidung ablegen.',
            icon = 'shirt',
            menu = 'clothes_menu'
        }
    })
end)