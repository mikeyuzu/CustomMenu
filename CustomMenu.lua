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
    if param.get_input_blocked() then
        input_handler.unblock_game_input()
        param.set_input_blocked(false)
    end

    -- bindを解除（元の挙動に戻る）
    windower.send_command('keyboard_blockinput 0')
end

-- 決定ボタン処理
function Handle_Confirm()
    local selected = menu_manager.get_selected_item()
    if not selected then return end

    print(string.format("DEBUG: selected.id = %s (type: %s)", tostring(selected.id), type(selected.id)))

    -- ヘルパー関数: IDがAuctionHouseId（数値）かどうかをチェック
    local function is_auction_house_id(id)
        return type(id) == 'number'
    end

    if selected.id == 'synthesis' then
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
        print(string.format("DEBUG: inventory_cache status: %s", tostring(inventory_cache ~= nil and "Available" or "Nil")))
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
            local original_item_id = selected.original_item_id or string.match(tostring(selected.id), 'ITEM_SELECTED_(%d+)')
            print(string.format('DEBUG: アイテムが選択されました: %s (オリジナルID: %s)', selected.label, tostring(original_item_id)))
            -- ここで選択されたアイテムに対して何らかのアクションを実行できる（例えば、そのアイテムの詳細情報を表示するなど）
            -- 現時点では何もしないが、ログに出力して動作を確認する。
            -- Close_Menu() -- メニューを閉じる場合はここで呼ぶ
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
    if menu_manager.can_go_back() then
        param.set_current_menu(menu_manager.go_back())
        ui.show_menu_list(param.get_current_menu())
    else
        Close_Menu()
    end
end

-- コマンド処理
windower.register_event('addon command', function(command, ...) 
    command = command and command:lower() or 'help'

    if command == 'open' then
        param.set_menu_open(true)
        param.set_input_delay_frames(2)
        param.set_current_menu(menu_manager.get_main_menu())
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

    if not param.get_menu_open() or not param.get_input_blocked() then
        return false
    end

    if not down then
        return true
    end

    local action = input_handler.process_key(dik)

    if action == 'up' then
        menu_manager.move_cursor(-1)
        ui.update_menu_display(param.get_current_menu())
    elseif action == 'down' then
        menu_manager.move_cursor(1)
        ui.update_menu_display(param.get_current_menu())
    elseif action == 'left' then
        menu_manager.page_up()
        ui.update_menu_display(param.get_current_menu())
    elseif action == 'right' then
        menu_manager.page_down()
        ui.update_menu_display(param.get_current_menu())
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

    ui.update()
end)