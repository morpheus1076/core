

--[[
lib.addCommand('giveitem', {
    help = 'Gives an item to a player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'item',
            type = 'string',
            help = 'Name of the item to give',
        },
        {
            name = 'count',
            type = 'number',
            help = 'Amount of the item to give, or blank to give 1',
            optional = true,
        },
        {
            name = 'metatype',
            help = 'Sets the item\'s "metadata.type"',
            optional = true,
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local item = Items(args.item)

    if item then
        Inventory.AddItem(args.target, item.name, args.count or 1, args.metatype)
    end
end)
]]