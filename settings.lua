-- settings.lua

dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "fungal_skip_mod" -- Your mod folder name
mod_settings_version = 1

mod_settings = {
    {
        id = "allow_anywhere",
        ui_name = "Allow Anywhere",
        ui_description = "Allow skipping the fungal-shift cooldown in any location or situation",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME, -- Takes effect on restart
    },
    {
        id = "allow_outside_of_battle",
        ui_name = "Allow Outside of Battle",
        ui_description = "Allow skipping the fungal-shift cooldown as long as you're not being pursued",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
    {
        id = "allow_in_holy_mountain",
        ui_name = "Allow in Holy Mountain",
        ui_description = "Allow skipping the fungal-shift cooldown inside holy mountain areas",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
    {
        id = "ui_offset_x",
        ui_name = "X Offset",
        ui_description = "X Offset of the fungal skip UI",
        value_default = 30,
        value_min = 1,
        value_max = 200,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
    {
        id = "ui_offset_y",
        ui_name = "Y Offset",
        ui_description = "Y Offset of the fungal skip UI",
        value_default = 30,
        value_min = 1,
        value_max = 200,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
}

function ModSettingsUpdate(init_scope)
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
