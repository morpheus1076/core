FREEZE       = 0
DELETE       = 1

Ceeb       = {}
Ceeb.props = {
    -- [`prop_mineshaft_door`]      = {
    --     {
    --         mode = DELETE, -- Delete at specified coords
    --         pos = {
    --             vector3(-596.00, 2088.00, 130.00)
    --         },
    --     },
    --     {
    --         mode = FREEZE, -- Freeze everywhere else
    --     },
    -- },

    [`prop_mineshaft_door`]      = { { mode = DELETE } }, -- Mine doors
    [`prop_sec_barrier_ld_01a`]  = { { mode = DELETE } }, -- Parkings barrier
    [`prop_sec_barier_base_01`]  = { { mode = DELETE } }, -- Parkings barrier
    [`prop_sec_barrier_ld_02a`]  = { { mode = DELETE } }, -- Harbour Schranken barrier
    [`prop_facgate_04_r`]  = { { mode = DELETE, pos = {vector3(769.8307,-2495.927,20.29779)}}}, -- Tor Truckhändler R
    [`prop_facgate_04_l`]  = { { mode = DELETE, pos = {vector3(770.5956,-2485.316,20.57158)}}}, -- Tor Truckhändler L
    [`prop_fnclink_02gate4`]  = { { mode = DELETE, pos = {vector3(1121.3093,-475.9706,65.3238)}}}, -- Tor Lager 04-08
    [`prop_rub_trolley02a`]  = { { mode = DELETE } }, -- Einkaufswagen z.Bsp. bei der Müllabfuhr
    [`prop_weed_01`]  = { { mode = DELETE, pos = {vector3(2223.5974, 5576.9912, 53.8427)}}}, -- Weedpflanzen groß
    [`prop_weed_02`]  = { { mode = DELETE, pos = {vector3(2223.5974, 5576.9912, 53.8427)}}}, -- Weedpflanzen klein
    [`prop_bollard_02a`]  = { { mode = DELETE, pos = {vector3(-1458.456055, -505.260529, 30.616695)}}}, -- Poller, der das Garagen öffnen verhindert
    [`imp_prop_impexp_rack_02a`]  = { { mode = DELETE, pos = {vector3(944.235107, -1458.099243, 29.396357)}}}, -- Fehler beim Warenhaus GWA
    [`ex_prop_crate_closed_sc`]  = { { mode = DELETE, pos = {vec3(944.183777, -1458.094238, 31.182119)}}}, -- Fehler beim Warenhaus GWA
    [`bkr_prop_crate_set_01a`]  = { { mode = DELETE, pos = {vec3(944.272522, -1458.122192, 30.226608)}}}, -- Fehler beim Warenhaus GWA

    -- Gas pumps (Avoid vehicles to desync and break gas pumps, can be destroyed by pistols)
    [`prop_gas_pump_old2`]       = { { mode = FREEZE } },
    [`prop_gas_pump_1a`]         = { { mode = FREEZE } },
    [`prop_vintage_pump`]        = { { mode = FREEZE } },
    [`prop_gas_pump_old3`]       = { { mode = FREEZE } },
    [`prop_gas_pump_1c`]         = { { mode = FREEZE } },
    [`prop_gas_pump_1b`]         = { { mode = FREEZE } },
    [`prop_gas_pump_1d`]         = { { mode = FREEZE } },
    [`prop_traffic_01a`]         = { { mode = FREEZE } }, -- Ampeln
    [`prop_traffic_01b`]         = { { mode = FREEZE } }, -- Ampeln
    [`prop_traffic_01d`]         = { { mode = FREEZE } }, -- Ampeln
    [`prop_traffic_03a`]         = { { mode = FREEZE } }, -- Ampeln
    [`prop_streetlight_01`]      = { { mode = FREEZE } }, -- Straßenlaterne
    [`prop_streetlight_01a`]     = { { mode = FREEZE } }, -- Straßenlaterne
    [`prop_streetlight_03`]      = { { mode = FREEZE } }, -- Straßenlaterne
    [`prop_streetlight_03e`]     = { { mode = FREEZE } }, -- Straßenlaterne
    [`prop_streetlight_05`]      = { { mode = FREEZE } }, -- Straßenlaterne
    [`prop_streetlight_14a`]     = { { mode = FREEZE } }, -- Straßenlaterne
    [`prop_phonebox_01b`]        = { { mode = FREEZE } }, -- Telefonzelle
    [`prop_parknmeter_01`]       = { { mode = FREEZE } }, -- Parkuhr
}
