
local Mor = require("client.cl_lib")
local minuten = 30*60000
local cfg = require("shared.cfg_core")

CreateThread(function()
    if cfg.PaycheckUse then
        while true do
            Wait(minuten)
            local paycheckamount = lib.callback.await('paycheck', source)
            if paycheckamount ~= 0 then
                local msg = {
                    title = '~w~Gehaltszahlung',
                    subtitle = "~b~Bankeinzahlung.",
                    text = '~w~Dein Gehalt ~y~$'..paycheckamount.. '~w~ wurde ~g~überwiesen.',
                    duration = 0.4,
                    pict = 'CHAR_BANK_FLEECA',
                }
                Mor.PostFeed(msg)
            elseif paycheckamount == 0 then
                local msg = {
                    title = '~w~Gehaltszahlung',
                    subtitle = "~y~Firma hat ~r~KEIN ~y~Geld.",
                    text = '~w~Dein Gehalt wurde ~r~NICHT ~w~überwiesen.',
                    duration = 0.4,
                    pict = 'CHAR_BANK_FLEECA',
                }
                Mor.PostFeed(msg)
            end
        end
    end
end)
