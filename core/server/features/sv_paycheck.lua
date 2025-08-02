
lib.callback.register('paycheck', function(source)
    local player = Ox.GetPlayer(source)
    local amount

    if not player then return '0' end

    local xgroup = player.getGroups()
    local group, grade = player.getGroup(xgroup)
    local aktGroup = MySQL.query.await('SELECT * FROM character_groups WHERE `charId` = ? AND `isActive` = ?;',{player.charId, true})

    --if group == 'arbeitslos' or nil then group = 'staat' end
    local account = player.getAccount()
    local groupaccount = Ox.GetGroupAccount(group)
    amount = MySQL.query.await('SELECT `paycheck` FROM `ox_group_grades` WHERE `group` = ? AND `grade` = ?;',{aktGroup[1].name, aktGroup[1].grade})

    if amount then
        local plyName = player.get('playerdata')
        local remove = groupaccount.removeBalance({amount = amount[1].paycheck, message = "Paycheck "..plyName.fullname.."", true})
        account.addBalance({amount = amount[1].paycheck, message = "Paycheck: "..group.."", true})
        if remove.success == true then
            return amount[1].paycheck
        else
            return 0
        end
    end
    --[[for i=1, #compgroup do
        if (compgroup[i].group == group) and (compgroup[i].grade == grade) then
            amount = compgroup[i].paycheck
        end
    end]]
end)