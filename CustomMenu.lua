_addon.name = 'CustomMenu'
_addon.author = 'Developer'
_addon.version = '1.0.0'
_addon.commands = {'cmenu'}

require('logger')
require('strings')

-- 各モジュールの読み込み
local settings = require('settings')
local ui = require('ui')
local menu_manager = require('menu_manager')
local input_handler = require('input_handler')
local http_handler = require('http_handler')
local param = require('param')

-- 初期化
windower.register_event('load', function()
    print('CustomMenu loaded')
    ui.initialize()
    menu_manager.initialize()
end)

-- アンロード時
windower.register_event('unload', function()
    ui.cleanup()
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

    if selected.id == 'synthesis' then
        local synthesis_menu_data = menu_manager.get_synthesis_menu_data()
        param.set_current_menu(menu_manager.create_submenu(synthesis_menu_data))
        ui.show_menu_list(param.get_current_menu())
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

-- キャンセルボタン処理
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
        print('CustomMenu Commands:')
        print('  //cmenu open  - メニューを開く')
        print('  //cmenu close - メニューを閉じる')
        print('  //cmenu notify - 通知を切り替え(デバッグ用)')
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
