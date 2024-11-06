--init.lua

-- Load the UI module for the fungal shift skip button
local ui = dofile("mods/noita_fungal_skip/files/scripts/fungal_skip_ui.lua")

function OnWorldPostUpdate()
    ui.UpdateFungalShiftUI()
end

function OnPausedChanged( is_paused, is_inventory_pause )
    ui.OnPauseChanged(is_paused, is_inventory_pause)
end