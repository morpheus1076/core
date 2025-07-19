
local Mor = require("server.sv_lib")
local cfg = require("shared.cfg_core")
local time = cfg.groupProductionTime

---- Afghan ---- Vagos
CreateThread(function()
    if cfg.useGroupProduction then
        while true do
            local count, tcount, icount = 0, 1, 4    -- Aus icount wird tcount produziert.
            local invtrocknung = exports.ox_inventory:GetInventoryItems('vagos_feuchtablage')
            if invtrocknung == nil or (type(invtrocknung) == "table" and next(invtrocknung) == nil) then
                Wait(6000)
            else
                for _,v in pairs (invtrocknung) do
                    if v.name == 'afghanzweig' then
                        count = v.count
                    end
                end
                if (count >= ((icount*time)+10)) then
                    if Mor.Inv:canCarry('vagos_trocken', 'afghandry', tcount * time) then
                        Mor.Inv:remove('vagos_feuchtablage', 'afghanzweig', icount * time)
                        Mor.Inv:add('vagos_trocken', 'afghandry', tcount * time)
                    end
                end
            end
            Wait(time * 60000)
        end
    end
end)

---- Falschgeld ---- Triads
CreateThread(function()
    if cfg.useGroupProduction then
        while true do
            local invdrucker = exports.ox_inventory:GetInventoryItems('fgpresseanfang')
            local papier, plastik, farbe, fasern  = 0, 0, 0, 0
            if invdrucker == nil or (type(invdrucker) == "table" and next(invdrucker) == nil) then
                Wait(6000)
            else
                for _,k in pairs (invdrucker) do
                    if k.name == 'faserpapier' then papier = k.count end
                    if k.name == 'plastik' then plastik = k.count end
                    if k.name == 'farbe' then farbe = k.count end
                    if k.name == 'farbfasern' then fasern = k.count end
                end
            end

            if (papier >= 5*time) and (plastik >= 1*time) and (farbe >= 2*time) and (fasern >= 1*time) then
                if Mor.Inv:canCarry('fgpresseende', 'blatt5dollarnoten', 1*time) then
                    Mor.Inv:remove('fgpresseanfang', 'faserpapier', 5*time)
                    Mor.Inv:remove('fgpresseanfang', 'plastik', 1*time)
                    Mor.Inv:remove('fgpresseanfang', 'farbe', 2*time)
                    Mor.Inv:remove('fgpresseanfang', 'farbfasern', 1*time)
                    Mor.Inv:add('fgpresseende', 'blatt5dollarnoten', 1*time)
                end
            end

            local invwasch = exports.ox_inventory:GetInventoryItems('fgwaschanfang')
            if invwasch == nil or (type(invwasch) == "table" and next(invwasch) == nil) then
                Wait(6000)
            else
                for i=1, #invwasch do
                    if invwasch[i].name == "frische5dollarfalsch" then
                        local count = invwasch[1].count
                        if count >= ((4 * time)+5) then
                            if Mor.Inv:canCarry('fgwaschende', 'black_money', 30*time) then
                                Mor.Inv:remove('fgwaschanfang', 'frische5dollarfalsch', 4*time)
                                Mor.Inv:add('fgwaschende', 'black_money', 30*time)
                            end
                        end
                    end
                end
            end
            Wait(time * 60000)
        end
    end
end)