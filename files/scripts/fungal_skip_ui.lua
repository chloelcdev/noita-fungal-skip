local M = {}

-- Constants and state
M.ICON_PATH = "data/ui_gfx/status_indicators/fungal_shift.png"
M.BUTTON_SIZE = 9
M.COOLDOWN_TIME = 60 * 60 * 5

M.ui_offset_x = 20
M.ui_offset_y = 20

-- GUI context and ID tracking
M.gui = nil
M.starting_gui_id = 11811
M.gui_id = M.starting_gui_id

-- Conditions
M.ConditionModule = dofile_once("mods/noita_fungal_skip/files/scripts/conditions.lua")

M.OnPauseChanged = function(is_paused, is_inventory_paused)
    M.load_settings()
end

-- Initialization function to load all settings
M.load_settings = function()
    M.ui_offset_x = ModSettingGet("fungal_skip_mod.ui_offset_x")
    M.ui_offset_y = ModSettingGet("fungal_skip_mod.ui_offset_y")

    for _, condition in pairs(M.ConditionModule.Conditions) do
        condition.load_setting()
    end
end

M.id = function()
    M.gui_id = M.gui_id + 1
    return M.gui_id
end

-- GUI helper function to reset GUI context
M.StartFrame = function()
    M.gui_id = M.starting_gui_id
    GuiStartFrame(M.gui)
end

M.is_cooldown_active = function()
    local frame = GameGetFrameNum()
    local last_frame = tonumber(GlobalsGetValue("fungal_shift_last_frame", "-1000000"))
    return frame < last_frame + M.COOLDOWN_TIME
end

-- Function to iterate through and check conditions
function M.check_conditions()
    -- Start with the assumption that no conditions are met
    local can_skip = false
    local denied_reasons = {}

    for _, condition in pairs(M.ConditionModule.Conditions) do
        if condition.setting_is_enabled() then
            -- Check if the condition is met
            if condition.condition_met() then
                can_skip = true
            else
                table.insert(denied_reasons, condition.feedback)
            end
        end
    end

    -- If no conditions were met, the denied reasons indicate why
    local reason = table.concat(denied_reasons, " or ")

    return can_skip, reason
end

-- Function to update and display the skip button UI
function M.UpdateFungalShiftUI()
    -- Load settings
    M.load_settings()

    -- Check if cooldown is active
    if not M.is_cooldown_active() then
        if M.gui ~= nil then
            GuiDestroy(M.gui)
            M.gui = nil
        end
        return
    end

    -- Check additional conditions
    local can_skip, fail_reasons = M.check_conditions()

    --print("Can skip: " .. tostring(can_skip))

    -- Create GUI if it doesn't exist
    if M.gui == nil then
        M.gui = GuiCreate()
    end

    M.StartFrame()

    -- Get the resolution
    local res_x, res_y = GuiGetScreenDimensions(M.gui)

    -- Position of the button in the bottom right
    local button_x = res_x - M.BUTTON_SIZE - M.ui_offset_x
    local button_y = res_y - M.BUTTON_SIZE - M.ui_offset_y

    -- Set alpha based on conditions
    local alpha = can_skip and 1 or 0.125

    -- Draw button with the 9-slice function
    GuiImageNinePiece(M.gui, M.id(), button_x, button_y, M.BUTTON_SIZE, M.BUTTON_SIZE, alpha, M.ICON_PATH, M.ICON_PATH)

    -- Capture widget interaction details
    local clicked, _, hovered = GuiGetPreviousWidgetInfo(M.gui)

    -- Tooltip when hovered
    if hovered then
        local msg = can_skip and "Click to skip it." or ("Can only skip: " .. fail_reasons)
        GuiTooltip(M.gui, "You are in fungal-shift cooldown.", msg)
    end

    -- If button is clicked, skip the cooldown
    if clicked and can_skip then
        local frame = GameGetFrameNum()
        GlobalsSetValue("fungal_shift_last_frame", tostring(frame - M.COOLDOWN_TIME))
        GamePrintImportant("Fungal shift cooldown skipped!", "", "data/ui_gfx/decorations/3piece_fungal_shift.png")
    end
end

return M