_addon.name = 'CustomMenu'
_addon.author = 'Developer'
_addon.version = '1.0.0'
_addon.commands = {'cmenu'}

local socket = require("socket")

-- ================================================================
-- ログファイルへの出力設定
-- ================================================================
local LOG_FILE_PATH = windower.addon_path .. 'CustomMenu.log'
local original_print = print
local log_file = nil

local function log_to_file(message)
    if not log_file then
        log_file = io.open(LOG_FILE_PATH, "a")
        if not log_file then return end
    end
    log_file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(message) .. "\n")
    log_file:flush()
end

function print(...)
    original_print(...)
    local args = {...}
    local message_parts = {}
    for i, v in ipairs(args) do table.insert(message_parts, tostring(v)) end
    log_to_file(table.concat(message_parts, "\t"))
end

require('logger')
require('strings')
local messages = require('message')

-- 各モジュールの読み込み
local settings = require('settings')
local ui = require('ui')
local menu_manager = require('menu_manager')
local input_handler = require('input_handler')
local http_handler = require('http_handler')
local param = require('param')
local menu_definitions = require('menu_definitions')
local synergy_category_generator = require('synergy_category_generator')
local mission_definitions = require('mission_definitions')
local eminence_definitions = require('eminence_definitions')

-- ナビゲーションウィンドウ用の状態
local last_nav_update = os.clock()

-- キャラクター情報取得
local function getCharacterInfo()
    local player = windower.ffxi.get_player()
    local info = windower.ffxi.get_info()
    local map = windower.ffxi.get_map_data()
    local pos = windower.ffxi.get_position()
    if player and info and pos then
        return player.name, player.id, info.zone, map, pos
    else
        return nil, nil, nil, nil, nil
    end
end

-- ナビゲーション情報の有効性チェック
local function isValidNavInfo(zone, map_id, coordinates)
    return zone and zone ~= "N/A" and map_id and map_id ~= "N/A" and coordinates and coordinates ~= "N/A"
end

-- ナビゲーション情報変更チェック
local function hasNavInfoChanged(zone, map_id)
    local last_info = param.get_navigation_last_info()
    return last_info.zone ~= zone or last_info.map_id ~= map_id
end

local function hasNavInfoChangedFull(zone, map_id, coordinates)
    local last_info = param.get_navigation_last_info()
    return last_info.zone ~= zone or last_info.map_id ~= map_id or last_info.coordinates ~= coordinates
end

-- ナビゲーション情報更新
local function updateNavigationInfo()
    local name, id, zone, map_id, coordinates = getCharacterInfo()
    local last_info = param.get_navigation_last_info()
    local previous_info = param.get_navigation_previous_info()

    if name then
        if isValidNavInfo(zone, map_id, coordinates) and hasNavInfoChanged(zone, map_id) then
            if last_info.zone and isValidNavInfo(last_info.zone, last_info.map_id, last_info.coordinates) then
                previous_info.id = last_info.id
                previous_info.zone = last_info.zone
                previous_info.map_id = last_info.map_id
                previous_info.coordinates = last_info.coordinates
            end
        end
        if isValidNavInfo(zone, map_id, coordinates) and hasNavInfoChangedFull(zone, map_id, coordinates) then
            last_info.name = name
            last_info.id = id
            last_info.zone = zone
            last_info.map_id = map_id
            last_info.coordinates = coordinates
        end
    end
end

-- ナビゲーション表示更新
local function updateNavigationDisplay()
    local player = windower.ffxi.get_player()
    if not player then return end
    if player.status == 4 then
        ui.hide_navigation()
        return
    end

    local last_info = param.get_navigation_last_info()
    local previous_info = param.get_navigation_previous_info()

    -- IDが取得できていない場合
    if not last_info.id then
        return
    end

    local message_params = {
        charaId = last_info.id,
        zoneId = last_info.zone or 0,
        mapId = last_info.map_id or 0,
        coordinates = last_info.coordinates or "(?_?)",
        preZoneId = previous_info.zone or 0,
        preMapId = previous_info.map_id or 0,
        preCoordinates = previous_info.coordinates or "(?_?)"
    }

    http_handler.fetch_custom_menu_info(message_params, function(success, data)
        if success and data then
            local msg = data.mainNaviMessage

            if msg ~= param.get_navigation_last_message() then
                ui.update_navigation(msg)
                param.set_navigation_last_message(msg)
            end

            local excl = data.exclamationMark or 0
            if excl ~= param.get_navigation_exclamation() then
                ui.update_indicator(excl)
                param.set_navigation_exclamation(excl)
            end
        end
    end)
end

-- ナビゲーション情報変更チェック(prerender用)
local function checkNavigationInfoChange()
    local name, id, zone, map_id, coordinates = getCharacterInfo()
    if name and isValidNavInfo(zone, map_id, coordinates) and hasNavInfoChangedFull(zone, map_id, coordinates) then
        updateNavigationInfo()
    end
end

-- ミッションカテゴリ内の項目を表示
local function Handle_Mission_Category_Selection(category_label, missions, mission_results, category_key)
    local menu_items = {}
    local completed_count = 0
    local total_count = 0
    if type(missions[1]) == 'table' then
        for i, chapter in ipairs(missions) do
            local chapter_completed = 0
            local chapter_total = #chapter.missions
            for _, m_name in ipairs(chapter.missions) do
                total_count = total_count + 1
                local status = mission_results[total_count] or 0
                if status == -1 then completed_count = completed_count + 1; chapter_completed = chapter_completed + 1 end
            end
            local percentage = (chapter_completed / chapter_total) * 100
            table.insert(menu_items, { id = 'MISSION_CHAPTER_' .. i, label = string.format("%s %d%%", chapter.title, percentage), missions = chapter.missions, mission_offset = total_count - chapter_total, mission_results = mission_results, category_key = category_key })
        end
    else
        for i, m_name in ipairs(missions) do
            total_count = total_count + 1
            local status = mission_results[i] or 0
            local label = (status >= 0) and messages.mission_status.unknown or m_name
            if status == -1 then completed_count = completed_count + 1 end
            table.insert(menu_items, { id = 'MISSION_ITEM_' .. i, label = label, mission_name = m_name, status = status, category_key = category_key })
        end
    end
    local percentage = total_count > 0 and (completed_count / total_count) * 100 or 0
    local menu_data = { title = string.format("%s %d%%", category_label, percentage), items = menu_items }
    param.set_current_menu(menu_manager.create_submenu(menu_data))
    ui.show_menu_list(param.get_current_menu())
end

-- ミッション図鑑表示
local function Handle_Mission_Encyclopedia()
    local player = windower.ffxi.get_player()
    if not player or not player.id then return end
    http_handler.fetch_mission_list(player.id, function(success, data, error_message)
        if success and data then
            local menu_items = {}
            for _, cat in ipairs(mission_definitions.categories) do
                local m_list = mission_definitions.missions[cat.key]
                local m_results = data[cat.key] or data[cat.key:lower()] or {}
                local completed_count = 0
                local total_count = 0
                if type(m_list[1]) == 'table' then
                    for _, chapter in ipairs(m_list) do
                        for _, _ in ipairs(chapter.missions) do
                            total_count = total_count + 1
                            if m_results[total_count] == -1 then completed_count = completed_count + 1 end
                        end
                    end
                else
                    total_count = #m_list
                    for i = 1, total_count do if m_results[i] == -1 then completed_count = completed_count + 1 end end
                end
                local percentage = total_count > 0 and (completed_count / total_count) * 100 or 0
                table.insert(menu_items, { id = 'MISSION_CAT_' .. cat.id, label = string.format("%s %d%%", cat.label, percentage), category_key = cat.key, category_label = cat.label, mission_results = m_results })
            end
            local menu_data = { title = messages.collection_menu.items.mission, items = menu_items }
            param.set_current_menu(menu_manager.create_submenu(menu_data))
            ui.show_menu_list(param.get_current_menu())
        end
    end)
end

function Handle_Synthesis_Menu()
    local synthesis_menu_data = menu_manager.get_synthesis_menu_data()
    param.set_current_menu(menu_manager.create_submenu(synthesis_menu_data))
    ui.show_menu_list(param.get_current_menu())
end

function Handle_Synthesis_Storage()
    local player = windower.ffxi.get_player()
    if not player or not player.id then return end
    param.set_chara_id(player.id)
    http_handler.fetch_synergy_inventory(player.id, function(success, data, error_message)
        if success and data then
            param.set_synergy_inventory_cache(data)
            local generated_menu = synergy_category_generator.generate_menu_data(data, 'main')
            if #generated_menu.items == 0 and generated_menu.empty_message then
                local empty_menu_data = { title = generated_menu.title, items = {{ id = 'empty_message', label = generated_menu.empty_message, description = ""}}, cursor = 1, scroll_pos = 1, page_size = 1 }
                param.set_current_menu(menu_manager.create_submenu(empty_menu_data))
                ui.show_menu_list(param.get_current_menu())
            else
                param.set_current_menu(menu_manager.create_submenu(generated_menu))
                ui.show_menu_list(param.get_current_menu())
            end
        end
    end)
end

function Handle_Collection_Menu()
    local player = windower.ffxi.get_player()
    if not player or not player.id then return end
    http_handler.fetch_collection_list(player.id, function(success, data, error_message)
        if success and data then
            local labels = { messages.collection_menu.items.mission, messages.collection_menu.items.quest, messages.collection_menu.items.item, messages.collection_menu.items.monster, messages.collection_menu.items.magic, messages.collection_menu.items.ws }
            local menu_items = {}
            for i, val in ipairs(data) do
                local percentage = tonumber(val) / 100
                table.insert(menu_items, { id = 'collection_item_' .. i, label = string.format("%s %0.2f%%", labels[i] or "不明", percentage), description = "" })
            end
            local collection_menu_data = { title = messages.collection_menu.title, items = menu_items }
            param.set_current_menu(menu_manager.create_submenu(collection_menu_data))
            ui.show_menu_list(param.get_current_menu())
        end
    end)
end

local function Handle_Eminence_Category_Selection(category_label, items_def, eminence_results, category_id)
    local menu_items = {}
    local keys = {}
    for i in pairs(items_def) do table.insert(keys, i) end
    table.sort(keys)
    for _, i in ipairs(keys) do
        local item_def = items_def[i]
        local status = eminence_results[i + 1] or 0
        table.insert(menu_items, { id = 'EMINENCE_ITEM_' .. i, label = item_def.label, status = status, data = item_def, is_eminence = true, category_id = category_id, item_index = i, results = eminence_results })
    end
    local menu_data = { title = category_label, items = menu_items }
    param.set_current_menu(menu_manager.create_submenu(menu_data))
    ui.show_menu_list(param.get_current_menu())
    Refresh_Sub_Window()
end

local function has_achieved(results)
    if not results then return false end
    for _, status in pairs(results) do if status == 1 then return true end end
    return false
end

function Close_Eminence_Confirm_Dialog()
    param.set_eminence_confirm_dialog_open(false); param.set_eminence_confirm_selected_item(nil); param.set_eminence_confirm_selected_button('no'); ui.destroy_eminence_confirm_dialog()
end

function Handle_Eminence_Reward_Receive()
    local item = param.get_eminence_confirm_selected_item()
    local chara_id = windower.ffxi.get_player().id
    if not item or not chara_id then Close_Eminence_Confirm_Dialog(); return end
    http_handler.receive_eminence_reward(chara_id, item.category_id, item.item_index, function(success, data, error_message)
        if success then
            local destination = tonumber(data) or 0
            local msg = (destination == 1) and messages.eminence_menu.receive_success_key_item or (destination == 2 and messages.eminence_menu.receive_success_magic or messages.eminence_menu.receive_success_delivery)
            if item.results then item.results[item.item_index + 1] = 2 end
            item.status = 2
            local current_menu = param.get_current_menu()
            if current_menu and current_menu.items then for _, m_item in ipairs(current_menu.items) do if m_item.id == item.id then m_item.status = 2; break end end end
            local eminence_cache = param.get_eminence_data_cache()
            if eminence_cache then
                local mission_results = eminence_cache.Mission or eminence_cache.mission or {}
                local face_results = eminence_cache.Face or eminence_cache.face or {}
                local area_results = eminence_cache.Area or eminence_cache.area or {}
                local any_achieved = has_achieved(mission_results) or has_achieved(face_results) or has_achieved(area_results)
                ui.update_notification(any_achieved)
            end
            ui.create_success_dialog(msg); param.set_success_dialog_open(true); ui.update_menu_display(param.get_current_menu()); ui.show_eminence_details(item.data, item.status)
        else
            param.set_error_dialog_open(true); param.set_error_dialog_message("報酬の受取に失敗しました: " .. (error_message or "不明"))
            ui.create_error_dialog(param.get_error_dialog_message())
        end
        Close_Eminence_Confirm_Dialog()
    end)
end

function Handle_Eminence_Menu()
    local player = windower.ffxi.get_player()
    if not player or not player.id then return end
    http_handler.fetch_eminence_list(player.id, function(success, data, error_message)
        if success and data then
            param.set_eminence_data_cache(data)
            local mission_results = data.Mission or data.mission or {}
            local face_results = data.Face or data.face or {}
            local area_results = data.Area or data.area or {}
            local menu_items = {
                { id = 'EMINENCE_CAT_MISSION', label = messages.eminence_menu.categories.mission, category_label = messages.eminence_menu.categories.mission, category_id = 0, items_def = eminence_definitions.missions, results = mission_results, status = has_achieved(mission_results) and 1 or 0 },
                { id = 'EMINENCE_CAT_AREA', label = messages.eminence_menu.categories.area, category_label = messages.eminence_menu.categories.area, category_id = 1, items_def = {}, results = area_results, status = has_achieved(area_results) and 1 or 0 },
                { id = 'EMINENCE_CAT_FACE', label = messages.eminence_menu.categories.face, category_label = messages.eminence_menu.categories.face, category_id = 2, items_def = eminence_definitions.faces, results = face_results, status = has_achieved(face_results) and 1 or 0 }
            }
            local menu_data = { title = messages.eminence_menu.title, items = menu_items }
            param.set_current_menu(menu_manager.create_submenu(menu_data))
            ui.show_menu_list(param.get_current_menu())
        end
    end)
end

local function Fetch_And_Display_Item_Recipes(ah_id, min_lvl, max_lvl, title)
    local chara_id = param.get_chara_id() or windower.ffxi.get_player().id
    http_handler.fetch_synthesis_recipes_by_item(chara_id, ah_id, min_lvl, max_lvl, function(success, recipe_data, error_message)
        if success and recipe_data then
            local inventory_cache = param.get_synergy_inventory_cache()
            local inventory_map = {}
            if inventory_cache then for _, item in ipairs(inventory_cache) do inventory_map[tostring(item.id) .. "_" .. tostring(item.subId)] = item.quantity end end
            local recipe_items = {}
            for _, recipe in ipairs(recipe_data) do
                if recipe.crystal then recipe.crystal.possession = inventory_map[tostring(recipe.crystal.itemId) .. "_" .. tostring(recipe.crystal.subId)] or 0 end
                if recipe.ingredient then for _, ing in ipairs(recipe.ingredient) do ing.possession = inventory_map[tostring(ing.itemId) .. "_" .. tostring(ing.subId)] or 0 end end
                local all_possessed = true
                if recipe.crystal and (recipe.crystal.possession or 0) < (recipe.crystal.quantity or 1) then all_possessed = false end
                if all_possessed and recipe.ingredient then for _, ing in ipairs(recipe.ingredient) do if (ing.possession or 0) < (ing.quantity or 1) then all_possessed = false; break end end end
                table.insert(recipe_items, { id = 'RECIPE_ITEM_' .. tostring(recipe.id), label = recipe.result and recipe.result.name or "不明", data = recipe, isOpen = recipe.isOpen, allMaterialsPossessed = all_possessed })
            end
            local recipe_list_menu_data = { title = title or "レシピリスト", items = #recipe_items > 0 and recipe_items or {{ id = 'empty', label = "なし" }} }
            param.set_current_menu(menu_manager.create_submenu(recipe_list_menu_data)); ui.hide_synthesis_details(); ui.show_menu_list(param.get_current_menu())
            if #recipe_items > 0 then ui.show_synthesis_details(recipe_data[1]) end
        end
    end)
end

local function Handle_Item_List_Recipes(menu_id)
    local generated_menu = synergy_category_generator.generate_item_recipe_menu(menu_id or 'ITEM_LIST_RECIPES_ROOT')
    if #generated_menu.items == 1 and generated_menu.items[1].is_auto_trigger then
        local parts = generated_menu.items[1].id:split('_'); local ah_id = tonumber(parts[4]); local min_lvl = tonumber(parts[5]); local max_lvl = tonumber(parts[6])
        if ah_id and min_lvl and max_lvl then Fetch_And_Display_Item_Recipes(ah_id, min_lvl, max_lvl, generated_menu.title); return end
    end
    param.set_current_menu(menu_manager.create_submenu(generated_menu)); ui.show_menu_list(param.get_current_menu())
end

local function Handle_Generic_Fetch(menu_id)
    http_handler.fetch_menu_data(menu_id, function(success, data)
        if success then param.set_current_menu(menu_manager.create_submenu(data)); ui.show_menu_list(param.get_current_menu()) end
    end)
end

windower.register_event('load', function()
    print('CustomMenu loaded'); ui.initialize(); menu_manager.initialize()
    log_to_file("CustomMenu loaded.")
end)

windower.register_event('unload', function()
    ui.cleanup()
    if log_file then log_file:close(); log_file = nil end
end)

function Close_Menu()
    param.set_menu_open(false); param.set_current_menu(nil); ui.hide_menu_list(); ui.hide_synthesis_details(); ui.hide_mission_details(); ui.hide_eminence_details(); ui.show_indicator(); menu_manager.exit_synthesis_sub_window_mode()
    if param.get_input_blocked() then input_handler.unblock_game_input(); param.set_input_blocked(false) end
    windower.send_command('keyboard_blockinput 0')
end

function Close_Dialog()
    param.set_dialog_open(false); param.set_dialog_item(nil); param.set_dialog_withdraw_quantity(0); param.set_dialog_selected_button('cancel'); ui.destroy_withdrawal_dialog()
end

function Handle_Withdraw()
    local item = param.get_dialog_item(); local chara_id = param.get_chara_id(); local usenum = param.get_dialog_withdraw_quantity()
    if not item or not chara_id or usenum <= 0 then Close_Dialog(); return end
    http_handler.remove_synergy_inventory_item(chara_id, item.id, item.subId, usenum, item.quantity, function(success, message)
        Close_Dialog()
        if success then
            ui.create_success_dialog(string.format(messages.retrieval_success, item.name)); param.set_success_dialog_open(true)
            http_handler.fetch_synergy_inventory(chara_id, function(s, d) if s then Refresh_Menu_After_Inventory_Update(d) end end)
        else
            print('ERROR: ' .. item.name .. ' の引き出しに失敗しました: ' .. (message or '不明'))
        end
    end)
end

function Close_Craft_Confirm_Dialog()
    param.set_craft_confirm_dialog_open(false); param.set_craft_confirm_item_name(nil); param.set_craft_confirm_selected_button('no'); param.set_craft_confirm_recipe_data(nil); param.set_craft_confirm_nq_hq_index(0); ui.destroy_craft_confirm_dialog()
end

function Close_Error_Dialog()
    param.set_error_dialog_open(false); param.set_error_dialog_message(nil); ui.destroy_error_dialog()
end

local guild_id_to_skill_id_map = { [1]=54, [2]=55, [3]=51, [4]=52, [5]=53, [6]=56, [7]=48, [8]=49 }
function Handle_Craft_Synthesis()
    local chara_id = param.get_chara_id(); local recipe_data = param.get_craft_confirm_recipe_data(); local nq_hq_index = param.get_craft_confirm_nq_hq_index()
    if not chara_id or not recipe_data or not nq_hq_index then return end
    local result_item = (nq_hq_index == 1) and recipe_data.result or (nq_hq_index == 2 and recipe_data.resultHQ1 or (nq_hq_index == 3 and recipe_data.resultHQ2 or recipe_data.resultHQ3))
    if not result_item then return end
    local skill_id = guild_id_to_skill_id_map[recipe_data.guildId]
    http_handler.synthesize_item(chara_id, skill_id, recipe_data.id, result_item.itemId or result_item.id, result_item.subId, 1, function(success, data, error_message)
        if success then
            ui.create_success_dialog("合成に成功しました"); param.set_success_dialog_open(true)
            http_handler.fetch_synergy_inventory(chara_id, function(s, d) if s then Refresh_Menu_After_Inventory_Update(d) end end)
        else
            param.set_error_dialog_open(true); param.set_error_dialog_message("失敗: " .. (error_message or "不明")); ui.create_error_dialog(param.get_error_dialog_message())
        end
    end)
end

function Handle_Confirm()
    local selected = menu_manager.get_selected_item(); if not selected then return end
    if selected.type == menu_definitions.types.SUBMENU then
        local def = menu_definitions.get_menu_by_id(selected.submenu_id); if def then param.set_current_menu(menu_manager.create_submenu(def)); ui.show_menu_list(param.get_current_menu()) end; return
    elseif selected.type == menu_definitions.types.FUNCTION then
        local f = _G[selected.func_name]; if f then f() end; return
    elseif selected.type == menu_definitions.types.FETCH then Handle_Generic_Fetch(selected.id); return end
    if selected.id == 'collection_item_1' then Handle_Mission_Encyclopedia(); return end
    if tostring(selected.id):find('MISSION_CAT_') then Handle_Mission_Category_Selection(selected.category_label, mission_definitions.missions[selected.category_key], selected.mission_results, selected.category_key); Refresh_Sub_Window(); return end
    if tostring(selected.id):find('EMINENCE_CAT_') then Handle_Eminence_Category_Selection(selected.category_label, selected.items_def, selected.results, selected.category_id); return end
    if tostring(selected.id):find('EMINENCE_ITEM_') then if selected.status == 1 then param.set_eminence_confirm_dialog_open(true); param.set_eminence_confirm_selected_item(selected); ui.create_eminence_confirm_dialog(selected.label) else ui.show_eminence_details(selected.data, selected.status) end; return end
    if tostring(selected.id):find('RECIPE_ITEM_') then menu_manager.enter_synthesis_sub_window_mode(selected.isOpen == 1 and 'full' or 'materials_only'); ui.show_synthesis_details(selected.data); return end
    if selected.id == 'synthesis' then Handle_Synthesis_Menu() elseif selected.id == 'synthesis_storage' then Handle_Synthesis_Storage() else Handle_Generic_Fetch(selected.id) end
end

function Handle_Cancel()
    if param.get_dialog_open() then Close_Dialog() elseif menu_manager.can_go_back() then param.set_current_menu(menu_manager.go_back()); ui.hide_synthesis_details(); ui.hide_mission_details(); ui.hide_eminence_details(); ui.show_menu_list(param.get_current_menu()); Refresh_Sub_Window() else Close_Menu() end
end

function Refresh_Sub_Window()
    local selected = menu_manager.get_selected_item(); if not selected then return end
    ui.hide_synthesis_details(); ui.hide_mission_details(); local id_str = tostring(selected.id)
    if id_str:find('RECIPE_ITEM_') then if selected.data then ui.show_synthesis_details(selected.data) end
    elseif id_str:find('MISSION_ITEM_') then ui.show_mission_details(selected.mission_name, selected.status, selected.category_key)
    elseif id_str:find('EMINENCE_ITEM_') then ui.show_eminence_details(selected.data, selected.status) end
end

function Refresh_Menu_After_Inventory_Update(updated_cache)
    param.set_synergy_inventory_cache(updated_cache); local current = param.get_current_menu(); if not current then return end
    local generated = synergy_category_generator.generate_menu_data(updated_cache, current.id)
    param.set_current_menu(menu_manager.create_current_menu_from_data(generated)); ui.show_menu_list(param.get_current_menu())
end

windower.register_event('addon command', function(command, ...) 
    command = command and command:lower() or 'help'
    if command == 'open' then
        local main = menu_manager.get_main_menu(); param.set_menu_open(true); param.set_input_delay_frames(2); param.set_current_menu(main); ui.hide_indicator(); ui.show_menu_list(main); input_handler.block_game_input(); param.set_input_blocked(true); windower.send_command('keyboard_blockinput 1')
    elseif command == 'close' then Close_Menu()
    elseif command == 'notify' then param.set_has_notification(not param.get_has_notification()); ui.update_notification(param.get_has_notification())
    end
end)

windower.register_event('keyboard', function(dik, down, flags, blocked)
    if param.get_input_delay_frames() > 0 or not down then return true end
    local action = input_handler.process_key(dik)
    
    if param.get_dialog_open() or param.get_craft_confirm_dialog_open() or param.get_eminence_confirm_dialog_open() or param.get_error_dialog_open() or param.get_success_dialog_open() then
        if action == 'confirm' then
            if param.get_dialog_open() then
                if param.get_dialog_selected_button() == 'withdraw' then Handle_Withdraw() else Close_Dialog() end
            elseif param.get_craft_confirm_dialog_open() then
                if param.get_craft_confirm_selected_button() == 'yes' then Handle_Craft_Synthesis() end
                Close_Craft_Confirm_Dialog()
            elseif param.get_eminence_confirm_dialog_open() then
                if param.get_eminence_confirm_selected_button() == 'yes' then Handle_Eminence_Reward_Receive() else Close_Eminence_Confirm_Dialog() end
            elseif param.get_error_dialog_open() then
                Close_Error_Dialog()
            elseif param.get_success_dialog_open() then
                ui.destroy_success_dialog(); param.set_success_dialog_open(false)
            end
        elseif action == 'cancel' then
            if param.get_dialog_open() then Close_Dialog()
            elseif param.get_craft_confirm_dialog_open() then Close_Craft_Confirm_Dialog()
            elseif param.get_eminence_confirm_dialog_open() then Close_Eminence_Confirm_Dialog()
            elseif param.get_error_dialog_open() then Close_Error_Dialog()
            elseif param.get_success_dialog_open() then ui.destroy_success_dialog(); param.set_success_dialog_open(false) end
        elseif action == 'left' or action == 'right' then
            if param.get_dialog_open() then
                param.set_dialog_selected_button(param.get_dialog_selected_button() == 'cancel' and 'withdraw' or 'cancel')
                ui.update_withdrawal_dialog('buttons')
            elseif param.get_craft_confirm_dialog_open() then
                param.set_craft_confirm_selected_button(param.get_craft_confirm_selected_button() == 'no' and 'yes' or 'no')
                ui.update_craft_confirm_dialog('buttons')
            elseif param.get_eminence_confirm_dialog_open() then
                param.set_eminence_confirm_selected_button(param.get_eminence_confirm_selected_button() == 'no' and 'yes' or 'no')
                ui.update_eminence_confirm_dialog('buttons')
            end
        elseif action == 'up' or action == 'down' then
            if param.get_dialog_open() then
                local item = param.get_dialog_item()
                if item then
                    local current = param.get_dialog_withdraw_quantity()
                    local limit = math.min(item.quantity, item.stackSize or 99)
                    if action == 'up' then
                        param.set_dialog_withdraw_quantity(current < limit and current + 1 or 1)
                    else
                        param.set_dialog_withdraw_quantity(current > 1 and current - 1 or limit)
                    end
                    ui.update_withdrawal_dialog('quantity')
                end
            end
        end
        return true
    end

    if not param.get_menu_open() then return false end
    if action == 'up' then menu_manager.move_cursor(-1); ui.update_menu_display(param.get_current_menu()); Refresh_Sub_Window()
    elseif action == 'down' then menu_manager.move_cursor(1); ui.update_menu_display(param.get_current_menu()); Refresh_Sub_Window()
    elseif action == 'confirm' then Handle_Confirm()
    elseif action == 'cancel' then Handle_Cancel()
    elseif action == 'menu' then Close_Menu() end
    return true
end)

local last_visibility_state = false
windower.register_event('prerender', function()
    if param.get_input_delay_frames() > 0 then param.set_input_delay_frames(param.get_input_delay_frames() - 1) end
    local player = windower.ffxi.get_player(); if not player then return end
    local current_time = os.clock(); local interval = settings.get('navigation.update_interval') or 1
    if current_time - last_nav_update >= interval then
        checkNavigationInfoChange(); updateNavigationDisplay(); last_nav_update = current_time
    end
    local should_be_visible = (player.status ~= 4)
    if should_be_visible ~= last_visibility_state then
        if not should_be_visible then ui.hide_all() else ui.refresh_visibility() end
        last_visibility_state = should_be_visible
    end
end)

windower.register_event('login', function() updateNavigationDisplay() end)
windower.register_event('zone change', function() updateNavigationInfo(); updateNavigationDisplay() end)
windower.register_event('status change', function(new) if new == 4 then ui.hide_all() else ui.refresh_visibility() end end)
