local function create_condition(setting_key, feedback, condition_check)
    local setting_value

    return {
        load_setting = function()
            setting_value = ModSettingGet("fungal_skip_mod." .. setting_key) or false
        end,
        
        setting_is_enabled = function()
            return setting_value
        end,

        feedback = feedback,

        condition_met = condition_check,
    }
end

local conditions = {
    battle_ents = {},
    Conditions = {},
    disallow_list = {
        ["animal_scavenger_heal"] = true
    }
}

if true then
    conditions.Conditions.allow_anywhere = create_condition(
        "allow_anywhere", 
        "",
        function()
            return true
        end
    )
end

if true then
    conditions.Conditions.is_in_holy_mountain = create_condition(
        "allow_in_holy_mountain", 
        "inside a holy mountain",
        function()
            local player_entity = EntityGetWithTag("player_unit")[1]
            if not player_entity then
                return false
            end

            local player_x, player_y = EntityGetTransform(player_entity)
            local workshop_entities = EntityGetWithTag("workshop_aabb")
            if #workshop_entities == 0 then
                return false
            end
            
            for _, entity in ipairs(workshop_entities) do
                local hitbox_component = EntityGetFirstComponentIncludingDisabled(entity, "HitboxComponent")
                if hitbox_component then
                    local ent_x, ent_y, _r, _sx, _sy = EntityGetTransform(entity)
                    local min_x = ComponentGetValue2(hitbox_component, "aabb_min_x") + ent_x
                    local min_y = ComponentGetValue2(hitbox_component, "aabb_min_y") + ent_y
                    local max_x = ComponentGetValue2(hitbox_component, "aabb_max_x") + ent_x
                    local max_y = ComponentGetValue2(hitbox_component, "aabb_max_y") + ent_y

                    if player_x >= min_x and player_x <= max_x and player_y >= min_y and player_y <= max_y then
                        return true
                    end
                end
            end

            return false
        end
    )
end

if true then
    conditions.Conditions.is_in_battle = create_condition(
        "allow_outside_of_battle",
        "outside of battle",
        function()
            local player_entity = EntityGetWithTag("player_unit")[1]
            if not player_entity then
                return false
            end

            local frame_num = GameGetFrameNum()
            local seconds_frames = 60 * 4  -- 4 seconds threshold

            -- Iterate through entities tagged as 'enemy'
            local enemy_entities = EntityGetWithTag("enemy")
            for _, enemy in ipairs(enemy_entities) do
                -- Check if enemy is in the disallow list
                local enemy_name = EntityGetName(enemy)
                if not conditions.disallow_list[enemy_name] then
                    local ai_component = EntityGetFirstComponentIncludingDisabled(enemy, "AnimalAIComponent")
                    if ai_component then
                        local greatest_prey = ComponentGetValue2(ai_component, "mGreatestPrey")
                        if greatest_prey == player_entity then
                            -- Track current frame as the last time this enemy preyed on the player
                            conditions.battle_ents[enemy] = frame_num
                        end
                    end
                end
            end

            -- Clean up old entries from `battle_ents`
            for enemy, last_frame in pairs(conditions.battle_ents) do
                if frame_num - last_frame >= seconds_frames then
                    conditions.battle_ents[enemy] = nil
                end
            end

            -- If the list is empty, the player is not in battle
            return next(conditions.battle_ents) == nil
        end
    )
end

return conditions