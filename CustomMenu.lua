_addon.name = 'CustomMenu'
_addon.author = 'Developer'
_addon.version = '1.0.0'
_addon.commands = {'cmenu'}

local socket = require("socket")

-- ================================================================
-- ログファイルへの出力設定 (ここから追加)
-- ================================================================
local LOG_FILE_PATH = windower.addon_path .. 'CustomMenu.log'
local original_print = print
local log_file = nil

local function log_to_file(message)
    if not log_file then
        -- ファイルがまだ開かれていない場合、ここで開く試みをする
        log_file = io.open(LOG_FILE_PATH, "a")
        if not log_file then
            original_print("ERROR: Failed to open log file: " .. LOG_FILE_PATH)
            return
        end
    end
    -- タイムスタンプを追加
    log_file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(message) .. "\n")
    log_file:flush() -- すぐにファイルに書き込む
end

-- print関数をフック
function print(...)
    -- 元のprint関数でコンソールに出力
    original_print(...)
    -- 全ての引数を連結してファイルにログを記録
    local args = {...}
    local message_parts = {}
    for i, v in ipairs(args) do
        table.insert(message_parts, tostring(v))
    end
    log_to_file(table.concat(message_parts, "\t")) -- タブ区切りで連結
end
-- ================================================================
-- ログファイルへの出力設定 (ここまで追加)
-- ================================================================

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

-- キャラクター情報取得 (MissionNavを踏襲)
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
    return zone and zone ~= "N/A" and
           map_id and map_id ~= "N/A" and
           coordinates and coordinates ~= "N/A"
end

-- ナビゲーション情報変更チェック
local function hasNavInfoChanged(zone, map_id)
    local last_info = param.get_navigation_last_info()
    return last_info.zone ~= zone or
           last_info.map_id ~= map_id
end

local function hasNavInfoChangedFull(zone, map_id, coordinates)
    local last_info = param.get_navigation_last_info()
    return last_info.zone ~= zone or
           last_info.map_id ~= map_id or
           last_info.coordinates ~= coordinates
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

    local message_params = {
        charaId = last_info.id,
        zoneId = last_info.zone,
        mapId = last_info.map_id,
        coordinates = last_info.coordinates,
        preZoneId = previous_info.zone,
        preMapId = previous_info.map_id,
        preCoordinates = previous_info.coordinates
    }

    http_handler.fetch_navigation_message(message_params, function(success, message)
        if success and message ~= param.get_navigation_last_message() then
            ui.update_navigation(message)
            param.set_navigation_last_message(message)
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

    -- 階層構造（章立て）がある場合
    if type(missions[1]) == 'table' then
        for i, chapter in ipairs(missions) do
            local chapter_completed = 0
            local chapter_total = #chapter.missions
            
            for _, m_name in ipairs(chapter.missions) do
                total_count = total_count + 1
                local status = mission_results[total_count] or 0
                if status == -1 then
                    completed_count = completed_count + 1
                    chapter_completed = chapter_completed + 1
                end
            end
            
            local percentage = (chapter_completed / chapter_total) * 100
            table.insert(menu_items, {
                id = 'MISSION_CHAPTER_' .. i,
                label = string.format("%s %d%%", chapter.title, percentage),
                missions = chapter.missions,
                mission_offset = total_count - chapter_total,
                mission_results = mission_results,
                category_key = category_key
            })
        end
    else
        -- 通常のミッションリスト
        for i, m_name in ipairs(missions) do
            total_count = total_count + 1
            local status = mission_results[i] or 0
            local label = m_name
            
            -- 未クリア（未受託：0 または 進行中：1以上）は？？？
            if status >= 0 then
                label = messages.mission_status.unknown
            end
            
            if status == -1 then
                completed_count = completed_count + 1
            end

            table.insert(menu_items, {
                id = 'MISSION_ITEM_' .. i,
                label = label,
                mission_name = m_name,
                status = status,
                category_key = category_key
            })
        end
    end

    local percentage = total_count > 0 and (completed_count / total_count) * 100 or 0
    local menu_data = {
        title = string.format("%s %d%%", category_label, percentage),
        items = menu_items
    }
    param.set_current_menu(menu_manager.create_submenu(menu_data))
    ui.show_menu_list(param.get_current_menu())
end

-- ミッション図鑑表示
local function Handle_Mission_Encyclopedia()
    local player = windower.ffxi.get_player()
    if not player or not player.id then
        print('エラー: キャラクターIDが取得できません。')
        return
    end
    local chara_id = player.id

    http_handler.fetch_mission_list(chara_id, function(success, data, error_message)
        if success and data then
            -- デバッグ用: キーの一覧をコンソールに出力して、PascalCaseかcamelCaseかを確認
            for k, v in pairs(data) do
                -- print('API Key found: ' .. tostring(k))
            end

            local menu_items = {}
            for _, cat in ipairs(mission_definitions.categories) do
                local m_list = mission_definitions.missions[cat.key]
                -- 大文字・小文字両方のキーを試行し、取得できたデータを保持
                local m_results = data[cat.key] or data[cat.key:lower()] or {}
                
                local completed_count = 0
                local total_count = 0
                
                -- クリア率計算
                if type(m_list[1]) == 'table' then
                    -- 章立てがある場合
                    for _, chapter in ipairs(m_list) do
                        for _, _ in ipairs(chapter.missions) do
                            total_count = total_count + 1
                            if m_results[total_count] == -1 then
                                completed_count = completed_count + 1
                            end
                        end
                    end
                else
                    -- 通常リスト
                    total_count = #m_list
                    for i = 1, total_count do
                        if m_results[i] == -1 then
                            completed_count = completed_count + 1
                        end
                    end
                end

                local percentage = total_count > 0 and (completed_count / total_count) * 100 or 0
                table.insert(menu_items, {
                    id = 'MISSION_CAT_' .. cat.id,
                    label = string.format("%s %d%%", cat.label, percentage),
                    category_key = cat.key,
                    category_label = cat.label,
                    mission_results = m_results
                })
            end

            local menu_data = {
                title = messages.collection_menu.items.mission,
                items = menu_items
            }
            param.set_current_menu(menu_manager.create_submenu(menu_data))
            ui.show_menu_list(param.get_current_menu())
        else
            print('Failed to load mission list: ' .. (error_message or 'Unknown error'))
        end
    end)
end

-- 合成メニュー表示
local function Handle_Synthesis_Menu()
    local synthesis_menu_data = menu_manager.get_synthesis_menu_data()
    param.set_current_menu(menu_manager.create_submenu(synthesis_menu_data))
    ui.show_menu_list(param.get_current_menu())
end

-- 合成倉庫表示
local function Handle_Synthesis_Storage()
    local player = windower.ffxi.get_player()
    if not player or not player.id then
        print('エラー: キャラクターIDが取得できません。')
        return
    end
    local chara_id = player.id
    param.set_chara_id(chara_id) -- chara_idをparamに保存

    http_handler.fetch_synergy_inventory(chara_id, function(success, data, error_message)
        if success and data then
            param.set_synergy_inventory_cache(data) -- データをキャッシュ

            -- メインのシナジーカテゴリメニューを生成
            local generated_menu = synergy_category_generator.generate_menu_data(data, 'main')

            if #generated_menu.items == 0 and generated_menu.empty_message then
                local empty_menu_data = {
                    title = generated_menu.title,
                    items = {{ id = 'empty_message', label = generated_menu.empty_message, description = ""}},
                    cursor = 1,
                    scroll_pos = 1,
                    page_size = 1
                }
                param.set_current_menu(menu_manager.create_submenu(empty_menu_data))
                ui.show_menu_list(param.get_current_menu())
                print(generated_menu.empty_message)
            else
                param.set_current_menu(menu_manager.create_submenu(generated_menu))
                ui.show_menu_list(param.get_current_menu())
            end
        else
            print('Failed to load synergy inventory data: ' .. (error_message or 'Unknown error'))
        end
    end)
end

-- 図鑑メニュー表示
local function Handle_Collection_Menu()
    local player = windower.ffxi.get_player()
    if not player or not player.id then
        print('エラー: キャラクターIDが取得できません。')
        return
    end
    local chara_id = player.id

    http_handler.fetch_collection_list(chara_id, function(success, data, error_message)
        if success and data then
            -- C# Enum 順: Mission, Quest, Item, Monster, Magic, WeaponSkill
            local labels = {
                messages.collection_menu.items.mission,
                messages.collection_menu.items.quest,
                messages.collection_menu.items.item,
                messages.collection_menu.items.monster,
                messages.collection_menu.items.magic,
                messages.collection_menu.items.ws
            }
            
            local menu_items = {}
            for i, val in ipairs(data) do
                local percentage = tonumber(val) / 100
                local label_base = labels[i] or "不明な項目"
                local full_label = string.format("%s %0.2f%%", label_base, percentage)
                
                table.insert(menu_items, {
                    id = 'collection_item_' .. i,
                    label = full_label,
                    description = ""
                })
            end

            local collection_menu_data = {
                title = messages.collection_menu.title,
                items = menu_items
            }
            param.set_current_menu(menu_manager.create_submenu(collection_menu_data))
            ui.show_menu_list(param.get_current_menu())
        else
            print('Failed to load collection list: ' .. (error_message or 'Unknown error'))
        end
    end)
end

-- エミネンス・レコード：カテゴリ別項目を表示
local function Handle_Eminence_Category_Selection(category_label, items_def, eminence_results, category_id)
    local menu_items = {}
    
    -- キーを数値順にソートして取得
    local keys = {}
    for i in pairs(items_def) do
        table.insert(keys, i)
    end
    table.sort(keys)

    for _, i in ipairs(keys) do
        local item_def = items_def[i]
        local status = eminence_results[i + 1] or 0 -- APIは0始まりの配列
        
        table.insert(menu_items, {
            id = 'EMINENCE_ITEM_' .. i,
            label = item_def.label,
            status = status,
            data = item_def,
            is_eminence = true,
            category_id = category_id,
            item_index = i,
            results = eminence_results -- キャッシュ更新用
        })
    end

    local menu_data = {
        title = category_label,
        items = menu_items
    }
    param.set_current_menu(menu_manager.create_submenu(menu_data))
    ui.show_menu_list(param.get_current_menu())
    Refresh_Sub_Window()
end

-- 達成済み（status=1）の項目があるかチェックするヘルパー
local function has_achieved(results)
    if not results then return false end
    for _, status in pairs(results) do
        if status == 1 then return true end
    end
    return false
end

-- エミネンス報酬受取ダイアログを閉じる
function Close_Eminence_Confirm_Dialog()
    param.set_eminence_confirm_dialog_open(false)
    param.set_eminence_confirm_selected_item(nil)
    param.set_eminence_confirm_selected_button('no')
    ui.destroy_eminence_confirm_dialog()
end

-- エミネンス報酬受取実行
function Handle_Eminence_Reward_Receive()
    local item = param.get_eminence_confirm_selected_item()
    local chara_id = windower.ffxi.get_player().id

    if not item or not chara_id then
        print('ERROR: 報酬受取に必要な情報が不足しています。')
        Close_Eminence_Confirm_Dialog()
        return
    end

    http_handler.receive_eminence_reward(chara_id, item.category_id, item.item_index, function(success, data, error_message)
        if success then
            local destination = tonumber(data) or 0
            local msg = messages.eminence_menu.receive_success_delivery
            if destination == 1 then
                msg = messages.eminence_menu.receive_success_key_item
            elseif destination == 2 then
                msg = messages.eminence_menu.receive_success_magic
            end

            -- 1. ローカルキャッシュの更新 (status=2: 受取済み)
            if item.results then
                item.results[item.item_index + 1] = 2
            end

            -- 2. 現在の表示項目を更新
            item.status = 2
            local current_menu = param.get_current_menu()
            if current_menu and current_menu.items then
                for _, m_item in ipairs(current_menu.items) do
                    if m_item.id == item.id then
                        m_item.status = 2
                        break
                    end
                end
            end

            -- 3. 親メニュー（カテゴリ選択メニュー）の達成状態を再計算
            local eminence_cache = param.get_eminence_data_cache()
            if eminence_cache then
                local mission_results = eminence_cache.Mission or eminence_cache.mission or {}
                local face_results = eminence_cache.Face or eminence_cache.face or {}
                local area_results = eminence_cache.Area or eminence_cache.area or {}

                -- menu_managerの履歴からカテゴリメニューを探して更新
                local history = menu_manager.get_history()
                for _, menu in ipairs(history) do
                    if menu.items then
                        for _, m_item in ipairs(menu.items) do
                            if m_item.id == 'EMINENCE_CAT_MISSION' then
                                m_item.status = has_achieved(mission_results) and 1 or 0
                            elseif m_item.id == 'EMINENCE_CAT_AREA' then
                                m_item.status = has_achieved(area_results) and 1 or 0
                            elseif m_item.id == 'EMINENCE_CAT_FACE' then
                                m_item.status = has_achieved(face_results) and 1 or 0
                            end
                        end
                    end
                end

                -- 4. メインメニューの通知状態も更新
                local any_achieved = has_achieved(mission_results) or has_achieved(face_results) or has_achieved(area_results)
                local main_menu = menu_manager.get_main_menu()
                for _, m_item in ipairs(main_menu.items) do
                    if m_item.id == 'eminence' then
                        m_item.status = any_achieved and 1 or 0
                        break
                    end
                end
                ui.update_notification(any_achieved)
            end

            ui.create_success_dialog(msg)
            param.set_success_dialog_open(true)
            
            -- UI更新（メニュー項目と詳細パネル）
            ui.update_menu_display(param.get_current_menu())
            ui.show_eminence_details(item.data, item.status)
        else
            print('ERROR: 報酬の受取に失敗しました: ' .. (error_message or '不明なエラー'))
            param.set_error_dialog_open(true)
            param.set_error_dialog_message("報酬の受取に失敗しました: " .. (error_message or "不明なエラー"))
            ui.create_error_dialog(param.get_error_dialog_message())
        end
        Close_Eminence_Confirm_Dialog()
    end)
end

-- エミネンス・レコード表示
local function Handle_Eminence_Menu()
    local player = windower.ffxi.get_player()
    if not player or not player.id then
        print('エラー: キャラクターIDが取得できません。')
        return
    end
    local chara_id = player.id

    http_handler.fetch_eminence_list(chara_id, function(success, data, error_message)
        if success and data then
            param.set_eminence_data_cache(data) -- キャッシュに保存

            local mission_results = data.Mission or data.mission or {}
            local face_results = data.Face or data.face or {}
            local area_results = data.Area or data.area or {}

            local menu_items = {
                { 
                    id = 'EMINENCE_CAT_MISSION', 
                    label = messages.eminence_menu.categories.mission,
                    category_label = messages.eminence_menu.categories.mission,
                    category_id = 0,
                    items_def = eminence_definitions.missions,
                    results = mission_results,
                    status = has_achieved(mission_results) and 1 or 0
                },
                { 
                    id = 'EMINENCE_CAT_AREA', 
                    label = messages.eminence_menu.categories.area,
                    category_label = messages.eminence_menu.categories.area,
                    category_id = 1,
                    items_def = {}, 
                    results = area_results,
                    status = has_achieved(area_results) and 1 or 0
                },
                { 
                    id = 'EMINENCE_CAT_FACE', 
                    label = messages.eminence_menu.categories.face,
                    category_label = messages.eminence_menu.categories.face,
                    category_id = 2,
                    items_def = eminence_definitions.faces,
                    results = face_results,
                    status = has_achieved(face_results) and 1 or 0
                }
            }

            local menu_data = {
                title = messages.eminence_menu.title,
                items = menu_items
            }
            param.set_current_menu(menu_manager.create_submenu(menu_data))
            ui.show_menu_list(param.get_current_menu())
        else
            print('Failed to load eminence list: ' .. (error_message or 'Unknown error'))
        end
    end)
end

-- 階層を辿ってレシピリストを取得・表示する (アイテム別)
local function Fetch_And_Display_Item_Recipes(ah_id, min_lvl, max_lvl, title)
    local chara_id = param.get_chara_id() or windower.ffxi.get_player().id
    param.set_chara_id(chara_id)

    http_handler.fetch_synthesis_recipes_by_item(chara_id, ah_id, min_lvl, max_lvl, function(success, recipe_data, error_message)
        if success and recipe_data then
            -- 既存のインベントリキャッシュを利用して所持状況を反映
            local inventory_cache = param.get_synergy_inventory_cache()
            local inventory_map = {}
            if inventory_cache then
                for _, item in ipairs(inventory_cache) do
                    local key = tostring(item.id) .. "_" .. tostring(item.subId)
                    inventory_map[key] = item.quantity
                end
            end

            local recipe_items = {}
            for _, recipe in ipairs(recipe_data) do
                -- 素材の所持数補完
                if recipe.crystal then
                    recipe.crystal.possession = inventory_map[tostring(recipe.crystal.itemId) .. "_" .. tostring(recipe.crystal.subId)] or 0
                end
                if recipe.ingredient then
                    for _, ing in ipairs(recipe.ingredient) do
                        ing.possession = inventory_map[tostring(ing.itemId) .. "_" .. tostring(ing.subId)] or 0
                    end
                end

                -- 所持判定
                local all_possessed = true
                if recipe.crystal and (recipe.crystal.possession or 0) < (recipe.crystal.quantity or 1) then all_possessed = false end
                if all_possessed and recipe.ingredient then
                    for _, ing in ipairs(recipe.ingredient) do
                        if (ing.possession or 0) < (ing.quantity or 1) then all_possessed = false break end
                    end
                end

                table.insert(recipe_items, {
                    id = 'RECIPE_ITEM_' .. tostring(recipe.id),
                    label = recipe.result and recipe.result.name or "不明なレシピ",
                    data = recipe,
                    isOpen = recipe.isOpen,
                    allMaterialsPossessed = all_possessed
                })
            end

            local recipe_list_menu_data = {
                title = title or "レシピリスト",
                items = #recipe_items > 0 and recipe_items or {{ id = 'empty', label = "レシピは見つかりませんでした。" }}
            }
            param.set_current_menu(menu_manager.create_submenu(recipe_list_menu_data))
            ui.hide_synthesis_details()
            ui.show_menu_list(param.get_current_menu())
            if #recipe_items > 0 then ui.show_synthesis_details(recipe_data[1]) end
        else
            print('Failed to load item recipes: ' .. (error_message or 'Unknown error'))
        end
    end)
end

-- アイテム別レシピ表示
local function Handle_Item_List_Recipes(menu_id)
    local generated_menu = synergy_category_generator.generate_item_recipe_menu(menu_id or 'ITEM_LIST_RECIPES_ROOT')
    
    -- 項目が1つだけで、自動実行フラグがある場合は即座にAPIを叩く (レベル選択がないカテゴリ用)
    if #generated_menu.items == 1 and generated_menu.items[1].is_auto_trigger then
        ---@type any
        local id = generated_menu.items[1].id
        local parts = id:split('_')
        local ah_id = tonumber(parts[4])
        local min_lvl = tonumber(parts[5])
        local max_lvl = tonumber(parts[6])
        if ah_id and min_lvl and max_lvl then
            Fetch_And_Display_Item_Recipes(ah_id, min_lvl, max_lvl, generated_menu.title)
            return
        end
    end

    param.set_current_menu(menu_manager.create_submenu(generated_menu))
    ui.show_menu_list(param.get_current_menu())
end

-- 汎用APIデータ取得
local function Handle_Generic_Fetch(menu_id)
    http_handler.fetch_menu_data(menu_id, function(success, data)
        if success then
            param.set_current_menu(menu_manager.create_submenu(data))
            ui.show_menu_list(param.get_current_menu())
        else
            print('Failed to load menu data for: ' .. tostring(menu_id))
        end
    end)
end

-- テーブルダンプ用のデバッグ関数
local function table_dump(t, indent, visited)
    indent = indent or ""
    visited = visited or {}
    local str = ""
    if type(t) ~= 'table' then
        return tostring(t)
    end
    if visited[t] then
        return "<recursive table>\n"
    end
    visited[t] = true

    for k, v in pairs(t) do
        str = str .. indent .. tostring(k) .. " = "
        if type(v) == 'table' then
            str = str .. "{\n" .. table_dump(v, indent .. "  ", visited) .. indent .. "}\n"
        else
            str = str .. tostring(v) .. "\n"
        end
    end
    return str
end

-- 初期化
windower.register_event('load', function()
    print('CustomMenu loaded')
    ui.initialize()
    menu_manager.initialize()

    -- ログファイルへの書き込みを確実に開始
    log_to_file("CustomMenu アドオンがロードされました。ログ記録を開始します。")
end)

-- アンロード時
windower.register_event('unload', function()
    ui.cleanup()
    if log_file then
        log_file:close()
        log_file = nil
        original_print("CustomMenu.log を閉じました。")
    end
end)

-- メニューを閉じる
function Close_Menu()
    param.set_menu_open(false)
    param.set_current_menu(nil)
    ui.hide_menu_list()
    ui.hide_synthesis_details() -- サブウィンドウを非表示にする
    ui.hide_mission_details()    -- ミッションサブウィンドウも非表示
    ui.hide_eminence_details()   -- エミネンスサブウィンドウも非表示
    ui.show_indicator() -- インジケーターを再表示
    menu_manager.exit_synthesis_sub_window_mode() -- サブウィンドウモードを終了
    if param.get_input_blocked() then
        input_handler.unblock_game_input()
        param.set_input_blocked(false)
    end

    -- bindを解除（元の挙動に戻る）
    windower.send_command('keyboard_blockinput 0')
end

-- ダイアログを閉じる
function Close_Dialog()
    param.set_dialog_open(false)
    param.set_dialog_item(nil)
    param.set_dialog_withdraw_quantity(0)
    param.set_dialog_selected_button('cancel')
    ui.destroy_withdrawal_dialog() -- UI要素を破棄
end

-- 合成確認ダイアログを閉じる
function Close_Craft_Confirm_Dialog()
    param.set_craft_confirm_dialog_open(false)
    param.set_craft_confirm_item_name(nil)
    param.set_craft_confirm_selected_button('no')
    param.set_craft_confirm_recipe_data(nil)
    param.set_craft_confirm_nq_hq_index(0)
    ui.destroy_craft_confirm_dialog()
end

-- エラーダイアログを閉じる
function Close_Error_Dialog()
    param.set_error_dialog_open(false)
    param.set_error_dialog_message(nil)
    ui.destroy_error_dialog()
end

-- 合成スキル名のマッピング (スキルID -> 日本語名)
local synth_skills_map_jp = {
    [48] = '錬金術', [49] = '調理', [51] = '彫金', [52] = '裁縫',
    [53] = '革細工', [54] = '木工', [55] = '鍛冶', [56] = '骨細工'
}

-- ギルドIDからスキルIDへのマッピングを逆引き
local guild_id_to_skill_id_map = {
    [param.guild_ids.WOODWORKING] = 54,
    [param.guild_ids.SMITHING] = 55,
    [param.guild_ids.GOLDSMITHING] = 51,
    [param.guild_ids.WEAVING] = 52, -- WEAVINGは裁縫
    [param.guild_ids.LEATHERCRAFT] = 53,
    [param.guild_ids.BONECRAFT] = 56,
    [param.guild_ids.ALCHEMY] = 48,
    [param.guild_ids.COOKING] = 49,
}

-- 合成を実行する
function Handle_Craft_Synthesis()
    local chara_id = param.get_chara_id()
    local recipe_data = param.get_craft_confirm_recipe_data()
    local nq_hq_index = param.get_craft_confirm_nq_hq_index()

    if not chara_id or not recipe_data or not nq_hq_index then
        param.set_error_dialog_open(true)
        param.set_error_dialog_message("エラー: 合成に必要な情報が不足しています。")
        ui.create_error_dialog(param.get_error_dialog_message())
        return
    end

    local result_item = nil
    if nq_hq_index == 1 then
        result_item = recipe_data.result
    elseif nq_hq_index == 2 then
        result_item = recipe_data.resultHQ1
    elseif nq_hq_index == 3 then
        result_item = recipe_data.resultHQ2
    elseif nq_hq_index == 4 then
        result_item = recipe_data.resultHQ3
    end

    if not result_item then
        param.set_error_dialog_open(true)
        param.set_error_dialog_message("エラー: 合成するアイテムが見つかりません。")
        ui.create_error_dialog(param.get_error_dialog_message())
        return
    end

    local item_id = result_item.itemId or result_item.id
    local sub_id = result_item.subId
    local item_name = result_item.name

    local primary_guild_id = recipe_data.guildId
    local skill_id_for_api = guild_id_to_skill_id_map[primary_guild_id]

    if not skill_id_for_api then
        param.set_error_dialog_open(true)
        param.set_error_dialog_message("エラー: 合成スキルのIDを特定できません。")
        ui.create_error_dialog(param.get_error_dialog_message())
        return
    end

    http_handler.synthesize_item(chara_id, skill_id_for_api, recipe_data.id, item_id, sub_id, 1, function(success, data, error_message)
        if success and data then
            local storage_type = data.StorageType or data.storageType or 1 -- デフォルトはポスト
            local updated_skill_id = data.SkillId or data.skillId or skill_id_for_api
            local updated_skill_level = data.SkillLevel or data.skillLevel or 0
            local skill_name_jp = synth_skills_map_jp[updated_skill_id] or "不明なスキル"

            local success_message = ""
            if storage_type == 0 then
                success_message = string.format(messages.synthesis_menu.synthesis_success_material_storage, item_name, skill_name_jp, updated_skill_level)
            elseif storage_type == 1 then
                success_message = string.format(messages.synthesis_menu.synthesis_success_post, item_name, skill_name_jp, updated_skill_level)
            else
                success_message = string.format("合成に成功しました: %s\n%s Lv%dになりました。", item_name, skill_name_jp, updated_skill_level)
            end
            
            ui.create_success_dialog(success_message)
            param.set_success_dialog_open(true)

            -- 合成成功後、メニューを更新するためにインベントリを再フェッチする
            http_handler.fetch_synergy_inventory(chara_id, function(fetch_success, inv_data, inv_error)
                if fetch_success and inv_data then
                    Refresh_Menu_After_Inventory_Update(inv_data)
                else
                    print('ERROR: シナジーインベントリの再フェッチに失敗しました: ' .. (inv_error or '不明なエラー'))
                end
            end)

        else
            param.set_error_dialog_open(true)
            param.set_error_dialog_message("合成に失敗しました: " .. (error_message or "不明なエラー"))
            ui.create_error_dialog(param.get_error_dialog_message())
        end
    end)
end

-- 「ギルド別リスト」が選択された後の処理（ギルドリスト表示）
local function handle_guild_list_selection()
    local guild_menu_items = {}
    local guild_definitions = messages.synthesis_menu.guild_recipes.items


    for _, guild in ipairs(guild_definitions) do
        table.insert(guild_menu_items, {id = 'GUILD_SELECTED_' .. guild.id, label = guild.label})
    end

    local guild_list_menu_data = {
        title = messages.synthesis_menu.guild_recipes.title,
        items = guild_menu_items
    }
    param.set_current_menu(menu_manager.create_submenu(guild_list_menu_data))
    ui.show_menu_list(param.get_current_menu())
end

-- ギルドが選択された後の処理（ランクリスト表示）
local function handle_rank_list_selection(selected_guild_id_str)
    local rank_menu_items = {}
    local rank_definitions = messages.synthesis_menu.rank_list.items

    for _, rank in ipairs(rank_definitions) do
        -- IDは 'RANK_SELECTED_GUILDID_RANKNAME' の形式にする
        table.insert(rank_menu_items, {id = 'RANK_SELECTED_' .. selected_guild_id_str .. '_' .. rank.id, label = rank.label})
    end

    local rank_list_menu_data = {
        title = messages.synthesis_menu.rank_list.title,
        items = rank_menu_items
    }
    param.set_current_menu(menu_manager.create_submenu(rank_list_menu_data))
    ui.show_menu_list(param.get_current_menu())
end

-- ランクが選択された後の処理（API呼び出しとレシピリスト表示）
local function fetch_and_display_synthesis_recipes(guild_id, rank)
    local player = windower.ffxi.get_player()
    if not player or not player.id then
        print('エラー: キャラクターIDが取得できません。')
        return
    end
    local chara_id = player.id
    param.set_chara_id(chara_id) -- chara_idをparamに保存

    -- 1. レシピリストを取得
    http_handler.fetch_synthesis_recipes(chara_id, guild_id, rank, function(recipe_success, recipe_data, recipe_error)
        if recipe_success and recipe_data then
            -- 2. 素材倉庫のインベントリを取得
            http_handler.fetch_synergy_inventory(chara_id, function(inv_success, inv_data, inv_error)
                if inv_success and inv_data then
                    -- インベントリデータを使ってレシピデータの所持数を更新する
                    local inventory_map = {}
                    for _, item in ipairs(inv_data) do
                        local key = tostring(item.id) .. "_" .. tostring(item.subId)
                        inventory_map[key] = item.quantity
                    end

                    -- レシピデータの素材に所持数を付与する
                    for _, recipe in ipairs(recipe_data) do
                        recipe.guildId = recipe.guildId or guild_id -- ギルドIDを補完
                        if recipe.crystal then
                            local key = tostring(recipe.crystal.itemId) .. "_" .. tostring(recipe.crystal.subId)
                            recipe.crystal.possession = inventory_map[key] or 0
                        end
                        if recipe.ingredient then
                            for _, ing in ipairs(recipe.ingredient) do
                                local key = tostring(ing.itemId) .. "_" .. tostring(ing.subId)
                                ing.possession = inventory_map[key] or 0
                            end
                        end
                    end
                end

                -- レシピリストのメニューを作成・表示（インベントリ取得の成否に関わらず実行）
                local recipe_items = {}
                if #recipe_data > 0 then
                    for _, recipe in ipairs(recipe_data) do
                        if recipe.result and recipe.result.name then
                            -- 素材が全て揃っているか判定
                            local all_materials_possessed = true
                            if recipe.crystal and (recipe.crystal.possession or 0) < (recipe.crystal.quantity or 1) then
                                all_materials_possessed = false
                            end
                            if all_materials_possessed and recipe.ingredient then
                                for _, ing in ipairs(recipe.ingredient) do
                                    if (ing.possession or 0) < (ing.quantity or 1) then
                                        all_materials_possessed = false
                                        break
                                    end
                                end
                            end

                            table.insert(recipe_items, {id = 'RECIPE_ITEM_' .. tostring(recipe.id), label = recipe.result.name, data = recipe, isOpen = recipe.isOpen, allMaterialsPossessed = all_materials_possessed})
                        end
                    end
                end

                local recipe_list_menu_data = {
                    title = messages.synthesis_menu.guild_recipes.title .. ' - ' .. messages.synthesis_menu.rank_list.title, -- 仮のタイトル
                    items = recipe_items
                }

                if #recipe_items == 0 then
                    -- レシピが見つからなかった場合のメッセージ
                    recipe_list_menu_data.items = {{ id = 'empty_recipes', label = "レシピは見つかりませんでした。", description = ""}}
                end

                param.set_current_menu(menu_manager.create_submenu(recipe_list_menu_data))
                ui.hide_synthesis_details() -- 先に非表示にしておく
                ui.show_menu_list(param.get_current_menu())

                -- 最初のアイテムの詳細をデフォルトで表示
                if recipe_data and #recipe_data > 0 then
                    ui.show_synthesis_details(recipe_data[1]) -- 更新されたレシピデータを渡す
                end
            end)
        else
            print('Failed to load synthesis recipes: ' .. (recipe_error or 'Unknown error'))
        end
    end)
end


-- プレイヤーの合成スキルレベルを取得するヘルパー関数
local function get_player_synth_skills()
    local player = windower.ffxi.get_player()
    if not player or not player.skills then
        return nil
    end

    local skills = player.skills
    local player_synth_skills = {}

    -- `param.guild_ids` を使って、ギルドIDからスキル名、そしてプレイヤーのスキルレベルを取得する
    -- ギルドIDとスキル名のマッピングを保持
    local guild_id_to_skill_name_map = {
        [param.guild_ids.WOODWORKING] = 'woodworking',
        [param.guild_ids.SMITHING] = 'smithing',
        [param.guild_ids.GOLDSMITHING] = 'goldsmithing',
        [param.guild_ids.WEAVING] = 'clothcraft', -- param.guild_ids.WEAVING は clothcraftに対応
        [param.guild_ids.LEATHERCRAFT] = 'leathercraft',
        [param.guild_ids.BONECRAFT] = 'bonecraft',
        [param.guild_ids.ALCHEMY] = 'alchemy',
        [param.guild_ids.COOKING] = 'cooking',
    }

    for guild_id, skill_name_en in pairs(guild_id_to_skill_name_map) do
        player_synth_skills[guild_id] = skills[skill_name_en] or 0
    end
    return player_synth_skills
end

-- 合成確定処理
function Handle_Craft_Confirmation()
    local selected_recipe_item = menu_manager.get_selected_item()

    if not selected_recipe_item or not selected_recipe_item.data then
        print("ERROR: レシピ情報が見つかりません。")
        windower.add_to_chat(123, "エラー: レシピ情報が見つかりません。")
        menu_manager.exit_synthesis_sub_window_mode()
        ui.update_menu_display(param.get_current_menu())
        return
    end

    local recipe_data = selected_recipe_item.data
    local selected_nq_hq_index = param.get_nq_hq_cursor_index()
    
    -- NQ結果、または代わりとなるアイテム情報の存在確認
    local result_item = recipe_data.result or recipe_data.resultHQ1 or recipe_data.resultHQ2 or recipe_data.resultHQ3
    if not result_item then
        print("ERROR: 結果アイテム情報がありません。")
        param.set_error_dialog_open(true)
        param.set_error_dialog_message("エラー: アイテムデータがありません。")
        ui.create_error_dialog(param.get_error_dialog_message())
        menu_manager.exit_synthesis_sub_window_mode()
        ui.update_menu_display(param.get_current_menu())
        return
    end

    local item_name = result_item.name -- 合成アイテム名

    -- 1. 材料チェック
    local has_all_materials = true
    local missing_material_name = ""

    if recipe_data.crystal then
        if (recipe_data.crystal.possession or 0) < (recipe_data.crystal.quantity or 1) then
            has_all_materials = false
            missing_material_name = recipe_data.crystal.name or "不明なクリスタル"
        end
    end
    if has_all_materials and recipe_data.ingredient then
        for _, ing in ipairs(recipe_data.ingredient) do
            if (ing.possession or 0) < (ing.quantity or 1) then
                has_all_materials = false
                missing_material_name = ing.name or "不明な素材"
                break
            end
        end
    end

    if not has_all_materials then
        param.set_error_dialog_open(true)
        param.set_error_dialog_message(string.format("素材が足りません: %s", missing_material_name))
        ui.create_error_dialog(param.get_error_dialog_message())
        menu_manager.exit_synthesis_sub_window_mode()
        ui.update_menu_display(param.get_current_menu())
        return
    end

    -- 2. スキルレベルチェック
    local player_skills = get_player_synth_skills()
    if not player_skills then
        param.set_error_dialog_open(true)
        param.set_error_dialog_message("エラー: スキル情報を取得できません。ログインし直してください。")
        ui.create_error_dialog(param.get_error_dialog_message())
        menu_manager.exit_synthesis_sub_window_mode()
        ui.update_menu_display(param.get_current_menu())
        return
    end

    local primary_guild_id = recipe_data.guildId -- レシピデータからギルドIDを取得
    local craft_ranks = recipe_data.craftRank -- レシピの要求スキルレベル (テーブルまたは数値)

    -- primary_guild_idに対応するランクを取得 (数値キーと文字列キーの両方を考慮、存在しなければ0)
    local required_craft_rank = 0
    if craft_ranks then
        if type(craft_ranks) == 'table' then
            required_craft_rank = craft_ranks[primary_guild_id] or craft_ranks[tostring(primary_guild_id)] or 0
        else
            required_craft_rank = tonumber(craft_ranks) or 0
        end
    end

    local player_skill_level = (primary_guild_id and player_skills[primary_guild_id]) or 0
    local required_level_modifier = 0
    local skill_check_message = "合成レベルが足りません。"

    if selected_nq_hq_index == 2 then -- HQ1
        item_name = (recipe_data.resultHQ1 and recipe_data.resultHQ1.name) or (item_name .. "(HQ1)")
    elseif selected_nq_hq_index == 3 then -- HQ2
        if required_craft_rank > 0 then
            required_level_modifier = 5
        end
        skill_check_message = "合成レベルが足りません。\nHQ2は合成レベル＋５が必要です。"
        item_name = (recipe_data.resultHQ2 and recipe_data.resultHQ2.name) or (item_name .. "(HQ2)")
    elseif selected_nq_hq_index == 4 then -- HQ3
        if required_craft_rank > 0 then
            required_level_modifier = 10
        end
        skill_check_message = "合成レベルが足りません。\nHQ3は合成レベル＋１０が必要です。"
        item_name = (recipe_data.resultHQ3 and recipe_data.resultHQ3.name) or (item_name .. "(HQ3)")
    end
    
    local final_required_level = required_craft_rank + required_level_modifier

    -- スキルレベルチェック (HQ1, HQ2, HQ3 の場合のみ実行。NQは無条件)
    if selected_nq_hq_index > 1 and player_skill_level < final_required_level then
        param.set_error_dialog_open(true)
        param.set_error_dialog_message(skill_check_message)
        ui.create_error_dialog(param.get_error_dialog_message())
        menu_manager.exit_synthesis_sub_window_mode()
        ui.update_menu_display(param.get_current_menu())
        return
    end

    -- 全てのチェックをパスした場合、合成確認ダイアログを表示
    param.set_craft_confirm_dialog_open(true)
    param.set_craft_confirm_item_name(item_name)
    param.set_craft_confirm_selected_button('no') 
    param.set_craft_confirm_recipe_data(recipe_data) 
    param.set_craft_confirm_nq_hq_index(selected_nq_hq_index) 

    ui.create_craft_confirm_dialog(item_name)
    menu_manager.exit_synthesis_sub_window_mode()
end

-- 決定ボタン処理
function Handle_Confirm()
    local selected = menu_manager.get_selected_item()
    if not selected then return end

    -- 1. menu_definitions に基づくアクション処理
    if selected.type then
        if selected.type == menu_definitions.types.SUBMENU then
            local submenu_def = menu_definitions.get_menu_by_id(selected.submenu_id)
            if submenu_def then
                param.set_current_menu(menu_manager.create_submenu(submenu_def))
                ui.show_menu_list(param.get_current_menu())
            end
            return
        elseif selected.type == menu_definitions.types.FUNCTION then
            if selected.func_name == 'Handle_Synthesis_Storage' then
                Handle_Synthesis_Storage()
            elseif selected.func_name == 'Handle_Guild_List_Selection' then
                handle_guild_list_selection()
            elseif selected.func_name == 'Handle_Item_List_Recipes' then
                Handle_Item_List_Recipes()
            elseif selected.func_name == 'Handle_Synthesis_Menu' then
                Handle_Synthesis_Menu()
            elseif selected.func_name == 'Handle_Collection_Menu' then
                Handle_Collection_Menu()
            elseif selected.func_name == 'Handle_Eminence_Menu' then
                Handle_Eminence_Menu()
            end
            return
        elseif selected.type == menu_definitions.types.FETCH then
            Handle_Generic_Fetch(selected.id)
            return
        end
    end

    -- 2. 動的なIDパターンに基づく処理
    local function is_auction_house_id(id)
        return type(id) == 'number'
    end

    -- 図鑑メニュー（ミッション図鑑）のハンドリング
    if selected.id == 'collection_item_1' then
        Handle_Mission_Encyclopedia()
        return
    end

    -- ミッション図鑑：カテゴリ（国・拡張）選択
    if tostring(selected.id):find('MISSION_CAT_') then
        local cat_key = selected.category_key
        local missions = mission_definitions.missions[cat_key]
        Handle_Mission_Category_Selection(selected.category_label, missions, selected.mission_results, cat_key)
        Refresh_Sub_Window() -- 最初の項目の詳細を表示
        return
    end

    -- ミッション図鑑：章（プロマシア等）選択
    if tostring(selected.id):find('MISSION_CHAPTER_') then
        local menu_items = {}
        local missions = selected.missions
        local offset = selected.mission_offset
        local mission_results = selected.mission_results or {}
        local cat_key = selected.category_key
        
        for i, m_name in ipairs(missions) do
            local status = mission_results[offset + i] or 0
            local label = m_name
            if status >= 0 then
                label = messages.mission_status.unknown
            end
            
            table.insert(menu_items, {
                id = 'MISSION_ITEM_' .. (offset + i),
                label = label,
                mission_name = m_name,
                status = status,
                category_key = cat_key
            })
        end

        local menu_data = {
            title = selected.label,
            items = menu_items
        }
        param.set_current_menu(menu_manager.create_submenu(menu_data))
        ui.show_menu_list(param.get_current_menu())
        Refresh_Sub_Window() -- 最初の項目の詳細を表示
        return
    end

    -- ミッション図鑑：個別ミッション（詳細表示）
    if tostring(selected.id):find('MISSION_ITEM_') then
        ui.show_mission_details(selected.mission_name, selected.status, selected.category_key)
        return
    end

    -- エミネンス・レコード：カテゴリ選択
    if tostring(selected.id):find('EMINENCE_CAT_') then
        if selected.id == 'EMINENCE_CAT_AREA' then
            -- エリアは未定義のため無視
            return
        end
        Handle_Eminence_Category_Selection(selected.category_label, selected.items_def, selected.results)
        return
    end

    -- エミネンス・レコード：個別項目（詳細表示）
    if tostring(selected.id):find('EMINENCE_ITEM_') then
        if selected.status == 1 then
            -- 達成済み、未受取の場合 -> 確認ダイアログ
            param.set_eminence_confirm_dialog_open(true)
            param.set_eminence_confirm_selected_item(selected)
            param.set_eminence_confirm_selected_button('no')
            ui.create_eminence_confirm_dialog(selected.label)
        else
            ui.show_eminence_details(selected.data, selected.status)
        end
        return
    end

    -- アイテム別レシピのレベル帯選択
    if string.find(tostring(selected.id), 'ITEM_RECIPE_LEVEL_') then
        local parts = selected.id:split('_')
        local ah_id = tonumber(parts[4])
        local min_lvl = tonumber(parts[5])
        local max_lvl = tonumber(parts[6])
        if ah_id and min_lvl and max_lvl then
            Fetch_And_Display_Item_Recipes(ah_id, min_lvl, max_lvl, selected.label)
        end
        return
    end

    if string.find(tostring(selected.id), 'GUILD_SELECTED_') then
        local guild_id_str = string.match(tostring(selected.id), 'GUILD_SELECTED_(%w+)')
        if guild_id_str then
            handle_rank_list_selection(guild_id_str)
        end
        return
    elseif string.find(tostring(selected.id), 'RANK_SELECTED_') then
        local parts = selected.id:split('_')
        local guild_id_str = parts[3] -- RANK_SELECTED_GUILDID_RANKNAME の形式を想定
        local rank_name_str = parts[4]

        if guild_id_str and rank_name_str then
            local guild_id = param.guild_ids[string.upper(guild_id_str)]
            local rank = param.rank_ids[string.upper(rank_name_str)]
            if guild_id and rank ~= nil then
                fetch_and_display_synthesis_recipes(guild_id, rank)
            end
        end
        return
    elseif string.find(tostring(selected.id), 'RECIPE_ITEM_') then
        -- レシピアイテムが選択された場合
        if selected.isOpen == 0 then
            -- 未解放レシピの場合、materials_onlyモードでサブウィンドウに移行
            menu_manager.enter_synthesis_sub_window_mode('materials_only')
            ui.show_synthesis_details(selected.data)
        elseif selected.isOpen == 1 then -- 解放済みレシピの場合
            -- サブウィンドウモードに移行
            menu_manager.enter_synthesis_sub_window_mode('full')
            -- UIを再描画してサブウィンドウのカーソルを表示
            ui.show_synthesis_details(selected.data)
        end
        return
    elseif string.find(tostring(selected.id), '_MENU') or is_auction_house_id(selected.id) or string.find(tostring(selected.id), 'ITEM_SELECTED_') then
        -- アイテムリストから個別のアイテムが選択された場合
        if string.find(tostring(selected.id), 'ITEM_SELECTED_') then
            local inventory_cache = param.get_synergy_inventory_cache()
            if not inventory_cache then
                print('エラー: シナジーインベントリキャッシュがありません。')
                return
            end

            local original_item_id_str = string.match(tostring(selected.id), 'ITEM_SELECTED_(%d+)')
            local original_item_id = tonumber(original_item_id_str)
            local selected_item_data = nil

            -- キャッシュから完全なアイテムデータを見つける
            for _, item_data in ipairs(inventory_cache) do
                if item_data.id == original_item_id and item_data.subId == selected.subId then
                    selected_item_data = item_data
                    break
                end
            end

            if selected_item_data then
                param.set_dialog_open(true)
                param.set_dialog_item(selected_item_data)
                param.set_dialog_withdraw_quantity(1) -- 初期値は1個
                param.set_dialog_selected_button('cancel') -- 初期選択はキャンセル
                ui.create_withdrawal_dialog() -- UIに描画を通知
            else
                print(string.format('ERROR: 選択されたアイテムのデータが見つかりません (ID: %s, SubID: %s)', tostring(original_item_id), tostring(selected.subId)))
            end
            return
        end

        -- カテゴリ選択 (中間階層)
        local current_menu_data = param.get_current_menu()
        local is_item_recipe_mode = false
        if current_menu_data then
            if current_menu_data.id == 'ITEM_LIST_RECIPES_ROOT' or string.find(tostring(current_menu_data.id), '_MENU') or is_auction_house_id(current_menu_data.id) then
                -- 親メニューがレシピ検索ルートまたはカテゴリの場合、レシピ検索モードとみなす
                -- ただし、合成倉庫から遷移してきた場合は除く必要があるため、もう少し厳密な判定が必要な場合もあるが、
                -- 現状は遷移元がレシピ検索開始ならこのフラグを立てる
                is_item_recipe_mode = true
            end
        end

        if is_item_recipe_mode then
            Handle_Item_List_Recipes(selected.id)
        else
            -- 従来の合成倉庫カテゴリ表示 (在庫チェックあり)
            local inventory_cache = param.get_synergy_inventory_cache()
            if not inventory_cache then
                print('エラー: シナジーインベントリキャッシュがありません。')
                return
            end

            if is_auction_house_id(selected.id) then
                local selected_auction_house_id = selected.id
                local filtered_items = {}
                for _, item in ipairs(inventory_cache) do
                    if item.auctionHouseId == selected_auction_house_id then
                        table.insert(filtered_items, item)
                    end
                end

                if #filtered_items > 0 then
                    local menu_title = selected.label and (selected.label .. " リスト") or "アイテムリスト"
                    local item_list_menu_data = menu_manager.create_item_list_menu(filtered_items, menu_title)
                    param.set_current_menu(menu_manager.create_submenu(item_list_menu_data))
                    ui.show_menu_list(param.get_current_menu())
                else
                    local empty_message_data = {
                        title = selected.label and (selected.label .. " リスト") or "アイテムリスト",
                        items = {{ id = 'empty_message', label = "アイテムは見つかりませんでした。", description = ""}},
                        cursor = 1,
                        scroll_pos = 1,
                        page_size = 1
                    }
                    param.set_current_menu(menu_manager.create_submenu(empty_message_data))
                    ui.show_menu_list(param.get_current_menu())
                end
            else -- 'WEAPON_MENU'のようなサブメニューカテゴリの場合
                local generated_menu = synergy_category_generator.generate_menu_data(inventory_cache, selected.id)
                if #generated_menu.items == 0 and generated_menu.empty_message then
                     local empty_menu_data = {
                        title = generated_menu.title,
                        items = {{ id = 'empty_message', label = generated_menu.empty_message, description = ""}},
                        cursor = 1,
                        scroll_pos = 1,
                        page_size = 1
                    }
                    param.set_current_menu(menu_manager.create_submenu(empty_menu_data))
                    ui.show_menu_list(param.get_current_menu())
                    print(generated_menu.empty_message)
                else
                    param.set_current_menu(menu_manager.create_submenu(generated_menu))
                    ui.show_menu_list(param.get_current_menu())
                end
            end
        end
    elseif selected.id == 'synthesis' then
        Handle_Synthesis_Menu()
    elseif selected.id == 'synthesis_storage' then
        Handle_Synthesis_Storage()
    elseif selected.id == 'guild_list' then
        handle_guild_list_selection()
    else
        -- 定義にないものはデフォルトのAPIフェッチを試みる
        Handle_Generic_Fetch(selected.id)
    end
end

--キャンセルボタン処理
function Handle_Cancel()
    if param.get_dialog_open() then
        Close_Dialog()
    elseif menu_manager.can_go_back() then
        param.set_current_menu(menu_manager.go_back())
        ui.hide_synthesis_details()
        ui.hide_mission_details()
        ui.hide_eminence_details()
        ui.show_menu_list(param.get_current_menu())
        Refresh_Sub_Window() -- 戻った後のアイテムに合わせてサブウィンドウを更新
    else
        Close_Menu()
    end
end

-- インベントリ更新後にメニューを再描画する
function Refresh_Menu_After_Inventory_Update(updated_cache)
    param.set_synergy_inventory_cache(updated_cache)
    local current_menu_data = param.get_current_menu()

    if not current_menu_data then
        Close_Menu()
        return
    end

    -- ギルドレシピリストかどうかの判定 (アイテムIDに RECIPE_ITEM_ が含まれる場合)
    local is_recipe_list = false
    if current_menu_data.items and #current_menu_data.items > 0 and current_menu_data.items[1].id and string.find(tostring(current_menu_data.items[1].id), 'RECIPE_ITEM_') then
        is_recipe_list = true
    end

    -- アイテムリスト（合成倉庫の個別アイテム一覧）かどうかの判定
    local is_item_list = (current_menu_data.id == "ITEM_LIST_MENU")

    if is_recipe_list then
        -- レシピリストの場合は、各レシピの所持数を更新する
        local inventory_map = {}
        for _, item in ipairs(updated_cache) do
            local key = tostring(item.id) .. "_" .. tostring(item.subId)
            inventory_map[key] = item.quantity
        end

        for _, item in ipairs(current_menu_data.items) do
            if item.data then
                local recipe = item.data
                if recipe.crystal then
                    local key = tostring(recipe.crystal.itemId) .. "_" .. tostring(recipe.crystal.subId)
                    recipe.crystal.possession = inventory_map[key] or 0
                end
                if recipe.ingredient then
                    for _, ing in ipairs(recipe.ingredient) do
                        local key = tostring(ing.itemId) .. "_" .. tostring(ing.subId)
                        ing.possession = inventory_map[key] or 0
                    end
                end

                -- 素材が全て揃っているか再判定
                local all_materials_possessed = true
                if recipe.crystal and (recipe.crystal.possession or 0) < (recipe.crystal.quantity or 1) then
                    all_materials_possessed = false
                end
                if all_materials_possessed and recipe.ingredient then
                    for _, ing in ipairs(recipe.ingredient) do
                        if (ing.possession or 0) < (ing.quantity or 1) then
                            all_materials_possessed = false
                            break
                        end
                    end
                end
                item.allMaterialsPossessed = all_materials_possessed
            end
        end

        -- メニューを再描画（スタックは操作しない）
        ui.show_menu_list(current_menu_data)
        -- 詳細ウィンドウも更新
        local selected = menu_manager.get_selected_item()
        if selected and selected.data then
            ui.show_synthesis_details(selected.data)
        end

    elseif is_item_list then
        -- 合成倉庫のアイテムリストの場合
        local category_id = current_menu_data.parent_id
        if category_id then
            local filtered_items = {}
            for _, item in ipairs(updated_cache) do
                if item.auctionHouseId == category_id then
                    table.insert(filtered_items, item)
                end
            end

            local menu_title = current_menu_data.title or "アイテムリスト"
            local item_list_menu_data = menu_manager.create_item_list_menu(filtered_items, menu_title)

            -- 現在のメニューを直接更新 (スタック操作はしない)
            param.set_current_menu(menu_manager.create_current_menu_from_data(item_list_menu_data))
            ui.show_menu_list(param.get_current_menu())
        else
            -- parent_idがない場合は、安全のため一つ前のカテゴリに戻る
            if menu_manager.can_go_back() then
                local prev_menu = menu_manager.go_back()
                if prev_menu ~= nil then
                    local regenerated_menu = synergy_category_generator.generate_menu_data(updated_cache, prev_menu.id)
                    param.set_current_menu(menu_manager.create_submenu(regenerated_menu))
                    ui.show_menu_list(param.get_current_menu())
                end
            else
                Close_Menu()
            end
        end
    else
        -- 通常のカテゴリメニューの再生成
        local generated_menu = synergy_category_generator.generate_menu_data(updated_cache, current_menu_data.id)
        -- スタックを積まないように現在メニューを更新
        param.set_current_menu(menu_manager.create_current_menu_from_data(generated_menu))
        ui.show_menu_list(param.get_current_menu())
    end
end

-- サブウィンドウを更新するヘルパー関数
function Refresh_Sub_Window()
    local selected = menu_manager.get_selected_item()
    if not selected then return end

    ui.hide_synthesis_details()
    ui.hide_mission_details()

    local id_str = tostring(selected.id)
    if id_str:find('RECIPE_ITEM_') then
        if selected.data then
            ui.show_synthesis_details(selected.data)
        end
    elseif id_str:find('MISSION_ITEM_') then
        ui.show_mission_details(selected.mission_name, selected.status, selected.category_key)
    elseif id_str:find('EMINENCE_ITEM_') then
        ui.show_eminence_details(selected.data, selected.status)
    end
end


-- 引き出し処理
function Handle_Withdraw()
    local item = param.get_dialog_item()
    local chara_id = param.get_chara_id()
    local usenum = param.get_dialog_withdraw_quantity()

    if not item or not chara_id or usenum <= 0 then
        print('ERROR: 引き出しに必要な情報が不足しています。')
        Close_Dialog()
        return
    end

    http_handler.remove_synergy_inventory_item(chara_id, item.id, item.subId, usenum, function(success, message)
        Close_Dialog() -- まず引き出しダイアログを閉じる

        if success then
            -- 完了ダイアログを表示
            local success_message = string.format(messages.retrieval_success, item.name)
            ui.create_success_dialog(success_message)
            param.set_success_dialog_open(true)
        else
            print('ERROR: アイテム ' .. item.name .. ' の引き出しに失敗しました: ' .. (message or '不明なエラー'))
            -- 必要ならここでエラーダイアログを表示
        end
    end)
end

-- レシピ解放処理
function Handle_Open_Recipe(selected_recipe_item)
    local chara_id = param.get_chara_id()
    if not chara_id then
        print('エラー: キャラクターIDが取得できません。レシピを解放できません。')
        return
    end

    local recipe_id = string.match(tostring(selected_recipe_item.id), 'RECIPE_ITEM_(%d+)')
    if not recipe_id then
        print('エラー: レシピIDが取得できません。')
        return
    end
    recipe_id = tonumber(recipe_id)

    http_handler.open_recipe(chara_id, recipe_id, function(success, message)
        if success then
            -- 解放成功ダイアログを表示
            param.set_opened_recipe_name(selected_recipe_item.label) -- 解放されたレシピ名をparamに保存
            ui.create_open_recipe_dialog(selected_recipe_item.label)
            param.set_open_recipe_dialog_open(true) -- ダイアログが開いている状態に設定

            -- 解放されたレシピのisOpenフラグを更新する必要があるが、
            -- これはUIを再描画する際に反映されるようにする。
            -- current_menuから該当アイテムを見つけてisOpenを更新する。
            local current_menu = param.get_current_menu()
            if current_menu and current_menu.items then
                for i, item in ipairs(current_menu.items) do
                    if item.id == selected_recipe_item.id then
                        item.isOpen = 1 -- APIが成功したのでisOpenをtrue(1)に設定
                        if item.data then
                            item.data.isOpen = 1 -- dataオブジェクトも更新
                        end
                        break
                    end
                end
            end
        else
            print('レシピ解放エラー: ' .. message)
        end
    end)
end

-- エミネンス・レコードの達成状況をチェックして通知フラグを更新
local function Check_Eminence_Notification(callback)
    local player = windower.ffxi.get_player()
    if not player or not player.id then
        if callback then callback(false) end
        return
    end

    http_handler.fetch_eminence_list(player.id, function(success, data)
        local has_any_achieved = false
        if success and data then
            local categories = {'Mission', 'mission', 'Face', 'face', 'Area', 'area'}
            for _, cat in ipairs(categories) do
                if data[cat] then
                    for _, status in pairs(data[cat]) do
                        if status == 1 then
                            has_any_achieved = true
                            break
                        end
                    end
                end
                if has_any_achieved then break end
            end
        end
        if callback then callback(has_any_achieved) end
    end)
end

-- コマンド処理
windower.register_event('addon command', function(command, ...) 
    command = command and command:lower() or 'help'

    if command == 'open' then
        Check_Eminence_Notification(function(has_achieved)
            local main_menu = menu_manager.get_main_menu()
            
            -- メインメニュー内の「エミネンス・レコード」を探してstatusを更新
            for _, item in ipairs(main_menu.items) do
                if item.id == 'eminence' then
                    item.status = has_achieved and 1 or 0
                    break
                end
            end

            param.set_menu_open(true)
            param.set_input_delay_frames(2)
            param.set_current_menu(main_menu)
            ui.hide_indicator() -- インジケーターを非表示
            ui.show_menu_list(param.get_current_menu())
            input_handler.block_game_input()
            param.set_input_blocked(true)

            -- 一時的にキーを無効化（ゲームのデフォルト動作を止める）
            windower.send_command('keyboard_blockinput 1')
        end)
    elseif command == 'close' then
        Close_Menu()
    elseif command == 'notify' then
        -- デバッグ用: 通知を切り替え
        param.set_has_notification(not param.get_has_notification())
        ui.update_notification(param.get_has_notification())
    elseif command == 'help' then
        print(messages.command_help.header)
        print(messages.command_help.open)
        print(messages.command_help.close)
        print(messages.command_help.notify)
    end
end)

-- キー入力処理
windower.register_event('keyboard', function(dik, down, flags, blocked)
    if param.get_input_delay_frames() > 0 then
        return true
    end

    if not down then
        return true
    end

    local action = input_handler.process_key(dik)

    -- サブウィンドウモード中の入力処理
    if menu_manager.is_in_synthesis_sub_window_mode() then
        local current_recipe = menu_manager.get_selected_item() -- 現在選択中のレシピアイテム
        if not current_recipe or not current_recipe.data then return true end
        local current_recipe_data = current_recipe.data

        local max_nq_hq_index = 0
        if current_recipe_data.result then max_nq_hq_index = max_nq_hq_index + 1 end
        if current_recipe_data.resultHQ1 then max_nq_hq_index = max_nq_hq_index + 1 end
        if current_recipe_data.resultHQ2 then max_nq_hq_index = max_nq_hq_index + 1 end
        if current_recipe_data.resultHQ3 then max_nq_hq_index = max_nq_hq_index + 1 end

        local max_materials_index = 0
        if current_recipe_data.crystal then max_materials_index = max_materials_index + 1 end
        if current_recipe_data.ingredient then max_materials_index = max_materials_index + #current_recipe_data.ingredient end

        if action == 'up' then
            menu_manager.move_sub_window_cursor('up', param.get_active_sub_window() == 'nq_hq' and max_nq_hq_index or max_materials_index)
            ui.show_synthesis_details(current_recipe_data)
        elseif action == 'down' then
            menu_manager.move_sub_window_cursor('down', param.get_active_sub_window() == 'nq_hq' and max_nq_hq_index or max_materials_index)
            ui.show_synthesis_details(current_recipe_data)
        elseif (action == 'left' or action == 'right') and param.get_sub_window_mode() == 'full' then
            menu_manager.switch_active_sub_window()
            ui.show_synthesis_details(current_recipe_data)
        elseif action == 'confirm' then
            Handle_Craft_Confirmation()
        elseif action == 'cancel' then -- ESC key
            menu_manager.exit_synthesis_sub_window_mode()
            ui.show_synthesis_details(current_recipe_data) -- カーソルを非表示にするために再描画
        end
        return true -- サブウィンドウモード中は他の入力をブロック
    end

    -- 合成確認ダイアログが開いている場合の処理 (追加)
    if param.get_craft_confirm_dialog_open() then
        local selected_button = param.get_craft_confirm_selected_button()
        if action == 'left' or action == 'right' then
            if selected_button == 'no' then
                param.set_craft_confirm_selected_button('yes')
            else
                param.set_craft_confirm_selected_button('no')
            end
            ui.update_craft_confirm_dialog('buttons')
        elseif action == 'confirm' then
            if selected_button == 'yes' then
                Handle_Craft_Synthesis()
            end
            Close_Craft_Confirm_Dialog()
        elseif action == 'cancel' then
            Close_Craft_Confirm_Dialog()
        end
        return true -- 他の入力をブロック
    end

    -- エミネンス報酬受取確認ダイアログが開いている場合の処理
    if param.get_eminence_confirm_dialog_open() then
        local selected_button = param.get_eminence_confirm_selected_button()
        if action == 'left' or action == 'right' then
            if selected_button == 'no' then
                param.set_eminence_confirm_selected_button('yes')
            else
                param.set_eminence_confirm_selected_button('no')
            end
            ui.update_eminence_confirm_dialog('buttons')
        elseif action == 'confirm' then
            if selected_button == 'yes' then
                Handle_Eminence_Reward_Receive()
            else
                Close_Eminence_Confirm_Dialog()
            end
        elseif action == 'cancel' then
            Close_Eminence_Confirm_Dialog()
        end
        return true
    end

    -- エラーダイアログが開いている場合の処理 (追加)
    if param.get_error_dialog_open() then
        if action == 'confirm' or action == 'cancel' then
            Close_Error_Dialog()
        end
        return true -- 他の入力をブロック
    end

    -- 完了ダイアログが開いている場合の処理
    if param.get_success_dialog_open() then
        if action == 'confirm' then
            ui.destroy_success_dialog()
            param.set_success_dialog_open(false)

            -- 在庫を再フェッチしてメニューを更新 (合成または引き出しの場合のみ)
            local current_menu = param.get_current_menu()
            local is_synthesis_related = false
            if current_menu then
                if current_menu.id == "ITEM_LIST_MENU" or 
                   (current_menu.items and #current_menu.items > 0 and 
                    (tostring(current_menu.items[1].id):find('RECIPE_ITEM_') or 
                     tostring(current_menu.items[1].id):find('ITEM_SELECTED_'))) then
                    is_synthesis_related = true
                end
            end

            if is_synthesis_related then
                local chara_id = param.get_chara_id()
                if chara_id then
                    http_handler.fetch_synergy_inventory(chara_id, function(fetch_success, data, error_message)
                        if fetch_success and data then
                            Refresh_Menu_After_Inventory_Update(data)
                        else
                            print('ERROR: シナジーインベントリの再フェッチに失敗しました: ' .. (error_message or '不明なエラー'))
                            Close_Menu()
                        end
                    end)
                end
            end
        end
        return true -- 他の入力をブロック
    end

    -- ダイアログが開いている場合の処理
    if param.get_dialog_open() then
        local item = param.get_dialog_item()
        local current_quantity = param.get_dialog_withdraw_quantity()
        local max_quantity = item and item.quantity or 0
        local stack_size = item and item.stackSize or 0
        local withdraw_limit = math.min(max_quantity, stack_size)

        if action == 'up' then
            if current_quantity == withdraw_limit then
                param.set_dialog_withdraw_quantity(1)
            else
                param.set_dialog_withdraw_quantity(math.min(current_quantity + 1, withdraw_limit))
            end
            ui.update_withdrawal_dialog('quantity')
        elseif action == 'down' then
            if current_quantity == 1 then
                param.set_dialog_withdraw_quantity(withdraw_limit)
            else
                param.set_dialog_withdraw_quantity(math.max(current_quantity - 1, 1))
            end
            ui.update_withdrawal_dialog('quantity')
        elseif action == 'left' or action == 'right' then
            -- ボタンの選択を切り替える
            if param.get_dialog_selected_button() == 'cancel' then
                param.set_dialog_selected_button('withdraw')
            else
                param.set_dialog_selected_button('cancel')
            end
            ui.update_withdrawal_dialog('buttons')
        elseif action == 'confirm' then
            if param.get_dialog_selected_button() == 'cancel' then
                Close_Dialog()
            else
                Handle_Withdraw()
            end
        elseif action == 'cancel' then
            Close_Dialog()
        end
        return true -- ダイアログがアクティブな場合は他の入力処理をブロック
    end

    -- レシピ解放ダイアログが開いている場合の処理 (追加)
    if param.get_open_recipe_dialog_open() then
        if action == 'confirm' or action == 'cancel' then
            -- 解放ダイアログを閉じる
            ui.destroy_open_recipe_dialog()
            param.set_open_recipe_dialog_open(false)
            param.set_opened_recipe_name(nil)

            -- 現在のメニューを再描画して、レシピのisOpen状態の変更を反映
            ui.hide_synthesis_details() -- サブウィンドウを非表示にする
            ui.update_menu_display(param.get_current_menu())

            -- 現在選択中のレシピの詳細を再表示（isOpen状態が更新されたもの）
            local current_menu = param.get_current_menu()
            if current_menu and current_menu.items and #current_menu.items > 0 and current_menu.items[1].id and string.find(current_menu.items[1].id, 'RECIPE_ITEM_') then
                local selected = menu_manager.get_selected_item()
                if selected and selected.data then
                    ui.show_synthesis_details(selected.data)
                end
            end
        end
        return true -- 他の入力をブロック
    end

    -- メニューが開いていない、または入力がブロックされていない場合は、以降の処理を行わない
    if not param.get_menu_open() or not param.get_input_blocked() then
        return false
    end

    if action == 'up' then
        menu_manager.move_cursor(-1)
        ui.update_menu_display(param.get_current_menu())
        Refresh_Sub_Window()
    elseif action == 'down' then
        menu_manager.move_cursor(1)
        ui.update_menu_display(param.get_current_menu())
        Refresh_Sub_Window()
    elseif action == 'left' then
        menu_manager.page_up()
        ui.update_menu_display(param.get_current_menu())
        Refresh_Sub_Window()
    elseif action == 'right' then
        menu_manager.page_down()
        ui.update_menu_display(param.get_current_menu())
        Refresh_Sub_Window()
    elseif action == 'confirm' then
        Handle_Confirm()
    elseif action == 'cancel' then
        Handle_Cancel()
    elseif action == 'menu' then
        Close_Menu()
    end

    return true
end)

-- フレーム更新
windower.register_event('prerender', function()
    if param.get_input_delay_frames() > 0 then
        param.set_input_delay_frames(param.get_input_delay_frames() - 1)
    end

    local player = windower.ffxi.get_player()
    if not player then
        return
    end

    -- 定期更新 (1秒ごと)
    local current_time = os.clock()
    local update_interval = settings.get('navigation.update_interval') or 1
    if current_time - last_nav_update >= update_interval then
        checkNavigationInfoChange()
        updateNavigationDisplay()
        last_nav_update = current_time
    end

    if player.status == 4 then
        -- イベント中/カットシーン中
        return
    end
end)

-- ログイン時
windower.register_event('login', function()
    socket.sleep(2)
    updateNavigationDisplay()
end)

-- ゾーン変更時
windower.register_event('zone change', function()
    socket.sleep(1)
    updateNavigationInfo()
    updateNavigationDisplay()
end)

-- ステータス変更時（カットシーン等での非表示制御）
windower.register_event('status change', function(new_status, old_status)
    if new_status == 4 then
        ui.hide_navigation()
    else
        ui.show_navigation()
    end
end)