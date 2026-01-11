_addon.name = 'CustomMenu'
_addon.author = 'Developer'
_addon.version = '1.0.0'
_addon.commands = {'cmenu'}

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
local synergy_category_generator = require('synergy_category_generator')

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
    ui.show_indicator() -- インジケーターを再表示
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

-- 決定ボタン処理
function Handle_Confirm()
    local selected = menu_manager.get_selected_item()
    if not selected then return end

    -- ヘルパー関数: IDがAuctionHouseId（数値）かどうかをチェック
    local function is_auction_house_id(id)
        return type(id) == 'number'
    end

    -- 新しい合成メニュー処理の分岐
    if selected.id == 'guild_list' then
        handle_guild_list_selection()
        return
    elseif string.find(tostring(selected.id), 'GUILD_SELECTED_') then
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
        -- レシピアイテムが選択されたら合成を実行する（将来のタスク）
        -- 今回はエンターキーで何もしない
        return
    elseif selected.id == 'synthesis' then
        local synthesis_menu_data = menu_manager.get_synthesis_menu_data()
        param.set_current_menu(menu_manager.create_submenu(synthesis_menu_data))
        ui.show_menu_list(param.get_current_menu())
    elseif selected.id == 'synthesis_storage' then
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
    elseif string.find(tostring(selected.id), '_MENU') or is_auction_house_id(selected.id) or string.find(tostring(selected.id), 'ITEM_SELECTED_') then
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

        elseif string.find(tostring(selected.id), 'ITEM_SELECTED_') then
            -- アイテムリストから個別のアイテムが選択された場合
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
    else
        http_handler.fetch_menu_data(selected.id, function(success, data)
            if success then
                param.set_current_menu(menu_manager.create_submenu(data))
                ui.show_menu_list(param.get_current_menu())
            else
                print('Failed to load menu data')
            end
        end)
    end
end

--キャンセルボタン処理
function Handle_Cancel()
    if param.get_dialog_open() then
        Close_Dialog()
    elseif menu_manager.can_go_back() then
        param.set_current_menu(menu_manager.go_back())
        ui.hide_synthesis_details() -- 先に非表示にする
        ui.show_menu_list(param.get_current_menu())
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

    -- アイテムリストかどうかの判定を強化
    local is_item_list = false
    if current_menu_data.id == "ITEM_LIST_MENU" then
        is_item_list = true
    elseif current_menu_data.items and #current_menu_data.items > 0 and current_menu_data.items[1].id and string.find(current_menu_data.items[1].id, 'ITEM_SELECTED_') then
        -- メニュー項目の中身を見て、アイテムリストであるかを判断する
        is_item_list = true
    end

    if is_item_list then
        -- アイテムリストの親ID（カテゴリID）を使って、そのカテゴリのアイテムを再生成
        local category_id = current_menu_data.parent_id
        if category_id then
            -- カテゴリ内の全アイテムをフィルタリング
            local filtered_items = {}
            for _, item in ipairs(updated_cache) do
                -- 親IDがauctionHouseIdに該当する場合のフィルタリング
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
            -- ただし、ITEM_LIST_MENUは必ず親カテゴリを持つはずなので、このパスは基本的には通らない想定
            if menu_manager.can_go_back() then
                local prev_menu = menu_manager.go_back()
                local regenerated_menu = synergy_category_generator.generate_menu_data(updated_cache, prev_menu.id)
                param.set_current_menu(menu_manager.create_submenu(regenerated_menu))
                ui.show_menu_list(param.get_current_menu())
            else
                Close_Menu()
            end
        end
    else
        -- 通常のカテゴリメニューの再生成
        local generated_menu = synergy_category_generator.generate_menu_data(updated_cache, current_menu_data.id)
        param.set_current_menu(menu_manager.create_submenu(generated_menu))
        ui.show_menu_list(param.get_current_menu())
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

    http_handler.remove_synergy_inventory_item(chara_id, item.id, item.subId, usenum, item.quantity, function(success, message)
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

-- コマンド処理
windower.register_event('addon command', function(command, ...) 
    command = command and command:lower() or 'help'

    if command == 'open' then
        param.set_menu_open(true)
        param.set_input_delay_frames(2)
        param.set_current_menu(menu_manager.get_main_menu())
        ui.hide_indicator() -- インジケーターを非表示
        ui.show_menu_list(param.get_current_menu())
        input_handler.block_game_input()
        param.set_input_blocked(true)

        -- 一時的にキーを無効化（ゲームのデフォルト動作を止める）
        windower.send_command('keyboard_blockinput 1')
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

    -- 完了ダイアログが開いている場合の処理
    if param.get_success_dialog_open() then
        if action == 'confirm' then
            ui.destroy_success_dialog()
            param.set_success_dialog_open(false)

            -- 在庫を再フェッチしてメニューを更新
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
            else
                Close_Menu() -- chara_idがなければメニューを閉じる
            end
        end
        return true -- 他の入力をブロック
    end

    -- ダイアログが開いている場合の処理
    if param.get_dialog_open() then
        local item = param.get_dialog_item()
        local current_quantity = param.get_dialog_withdraw_quantity()
        local max_quantity = item.quantity
        local stack_size = item.stackSize
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

    -- メニューが開いていない、または入力がブロックされていない場合は、以降の処理を行わない
    if not param.get_menu_open() or not param.get_input_blocked() then
        return false
    end

    if action == 'up' then
        menu_manager.move_cursor(-1)
        ui.hide_synthesis_details() -- 先に非表示にする
        ui.update_menu_display(param.get_current_menu())
        local current_menu = param.get_current_menu()
        if current_menu and current_menu.items and #current_menu.items > 0 and current_menu.items[1].id and string.find(current_menu.items[1].id, 'RECIPE_ITEM_') then
            local selected = menu_manager.get_selected_item()
            if selected and selected.data then
                ui.show_synthesis_details(selected.data)
            end
        end
    elseif action == 'down' then
        menu_manager.move_cursor(1)
        ui.hide_synthesis_details() -- 先に非表示にする
        ui.update_menu_display(param.get_current_menu())
        local current_menu = param.get_current_menu()
        if current_menu and current_menu.items and #current_menu.items > 0 and current_menu.items[1].id and string.find(current_menu.items[1].id, 'RECIPE_ITEM_') then
            local selected = menu_manager.get_selected_item()
            if selected and selected.data then
                ui.show_synthesis_details(selected.data)
            end
        end
    elseif action == 'left' then
        menu_manager.page_up()
        ui.hide_synthesis_details() -- 先に非表示にする
        ui.update_menu_display(param.get_current_menu())
        local current_menu = param.get_current_menu()
        if current_menu and current_menu.items and #current_menu.items > 0 and current_menu.items[1].id and string.find(current_menu.items[1].id, 'RECIPE_ITEM_') then
            local selected = menu_manager.get_selected_item()
            if selected and selected.data then
                ui.show_synthesis_details(selected.data)
            end
        end
    elseif action == 'right' then
        menu_manager.page_down()
        ui.hide_synthesis_details() -- 先に非表示にする
        ui.update_menu_display(param.get_current_menu())
        local current_menu = param.get_current_menu()
        if current_menu and current_menu.items and #current_menu.items > 0 and current_menu.items[1].id and string.find(current_menu.items[1].id, 'RECIPE_ITEM_') then
            local selected = menu_manager.get_selected_item()
            if selected and selected.data then
                ui.show_synthesis_details(selected.data)
            end
        end
    elseif action == 'confirm' then
        Handle_Confirm()
    elseif action == 'cancel' then
        Handle_Cancel()
    elseif action == 'menu' then
        Close_Menu()
    end

    return false
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
    if player.status == 4 then
        -- イベント中/カットシーン中
        return
    end
end)