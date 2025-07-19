
lib.callback.register('paycheck', function(source)
    local player = Ox.GetPlayer(source)
    local amount = 0

    if not player then return '0' end

    local xgroup = player.getGroups()
    local group, grade = player.getGroup(xgroup)
    --if group == 'arbeitslos' or nil then group = 'staat' end
    local account = player.getAccount()
    local groupaccount = Ox.GetGroupAccount(group)
    local compgroup = MySQL.query.await('SELECT * FROM ox_group_grades;')
    for i=1, #compgroup do
        if (compgroup[i].group == group) and (compgroup[i].grade == grade) then
            amount = compgroup[i].paycheck
        end
    end

    local remove = groupaccount.removeBalance({amount = amount, message = "Paycheck "..player.username.."", true})
    account.addBalance({amount = amount, message = "Paycheck: "..group.."", true})

    if remove.success == true then
        return 'erhalten'
    else
        return 'keinGeld'
    end
end)