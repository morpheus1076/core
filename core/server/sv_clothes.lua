
CreateThread(function()
    lib.callback.register('clothes:GiveItems', function(source, data)
        local player = Ox.GetPlayer(source)

        if data.component then
            local imageName = tostring(''..data.gender..'_'..data.component..'_'..data.drawable..'')
            lib.print.info(imageName)
            local setMeta =
            {
                label = data.label,
                description = 'gen:'..data.gender..' draw:'..data.drawable..' text:'..data.texture..' comp:'..data.component..'',
                data = data
            }
            
            exports.ox_inventory:AddItem(player.source, data.item, 1,
            {
                metadata = setMeta,
                label = data.label,
                description = setMeta.description,
                image = imageName,
            })
        end
        return true
    end)
end)
