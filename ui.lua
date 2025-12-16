local texts = require('texts')
local messages = require('message')
local param = require('param')
local ui = {}

local dialog_width = 300
local dialog_height = 120

    -- UI設定
local settings = {
    indicator = {
        pos = { x = windower.get_windower_settings().ui_x_res - 460, y = windower.get_windower_settings().ui_y_res - 40 },
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
        bg = { alpha = 150, red = 0, green = 0, blue = 0 },
        flags = { bold = true, draggable = false }
    },
    menu = {
        pos = { x = 200, y = 100 },
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 }, justify = 'left' }, -- デフォルトは左寄せ
        bg = { alpha = 200, red = 20, green = 20, blue = 40 },
        flags = { bold = false, draggable = false }
    },
    description_panel = {
        pos = { x = 480, y = 100 }, -- メニューの右側に配置
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
        bg = { alpha = 200, red = 20, green = 20, blue = 40 },
        flags = { bold = false, draggable = false }
    }
}

-- アイテム名と数量の間のスペース
local LABEL_QUANTITY_SPACING = 3
-- 数量表示カラムの幅（例: "999" + 前後のスペースを考慮）
local QUANTITY_COLUMN_WIDTH = 5 

-- テキストオブジェクト
local indicator_text = nil
local menu_texts = {}
local menu_quantities = {} -- 数量表示用のテキストオブジェクト
local menu_background = nil
local cursor_highlight_background = nil
local description_text = nil

-- 初期化
function ui.initialize()
    -- インジケーター(カスタムメニュー)の作成
    indicator_text = texts.new(messages.menu_title, settings.indicator)
    indicator_text:show()
end

-- クリーンアップ
function ui.cleanup()
    if indicator_text then
        indicator_text:destroy()
    end
    for _, text_obj in ipairs(menu_texts) do
        text_obj:destroy()
    end
    menu_texts = {}
    for _, text_obj in ipairs(menu_quantities) do
        text_obj:destroy()
    end
    menu_quantities = {}
    if menu_background then
        menu_background:destroy()
        menu_background = nil
    end
    if cursor_highlight_background then
        cursor_highlight_background:destroy()
        cursor_highlight_background = nil
    end
    if description_text then
        description_text:destroy()
        description_text = nil
    end
end

-- 通知表示更新
function ui.update_notification(has_notification)
    if indicator_text then
        if has_notification then
            indicator_text:text(messages.notification_with_icon)
        else
            indicator_text:text(messages.notification_text)
        end
    end
end

-- メニューリスト表示
function ui.show_menu_list(menu_data)
    ui.update_menu_display(menu_data)
    if description_text then description_text:show() end
end

-- メニューリスト非表示
function ui.hide_menu_list()
    for _, text_obj in ipairs(menu_texts) do
        text_obj:hide()
    end
    for _, text_obj in ipairs(menu_quantities) do
        text_obj:hide()
    end
    if menu_background then
        menu_background:hide()
    end
    if cursor_highlight_background then
        cursor_highlight_background:hide()
    end
    if description_text then description_text:hide() end
end

-- メニュー表示内容更新
function ui.update_menu_display(menu_data)
    if not menu_data then return end

    -- 1. 既存のUIオブジェクトをすべて破棄
    for _, text_obj in ipairs(menu_texts) do
        text_obj:destroy()
    end
    menu_texts = {}
    for _, text_obj in ipairs(menu_quantities) do
        text_obj:destroy()
    end
    menu_quantities = {}
    if menu_background then
        menu_background:destroy()
        menu_background = nil
    end
    if cursor_highlight_background then
        cursor_highlight_background:destroy()
        cursor_highlight_background = nil
    end
    if description_text then -- Clear existing description
        description_text:destroy()
        description_text = nil
    end

    -- 2. メニューの寸法と内容を計算
    local lines_data = {}
    local max_label_len = 0 -- アイテム名の最大長
    local max_quantity_len = 0 -- 数量の最大長

    local line_height = settings.menu.text.size + 4

    table.insert(lines_data, {text=menu_data.title, is_item=false, index=0})
    table.insert(lines_data, {text=string.rep('-', 30), is_item=false, index=0})

    local start_idx = menu_data.scroll_pos
    local end_idx = math.min(start_idx + menu_data.page_size - 1, #menu_data.items)

    for i = start_idx, end_idx do
        local item = menu_data.items[i]
        local prefix = (i == menu_data.cursor) and '> ' or '  '
        local label_text = prefix .. item.label
        local quantity_text = tostring(item.quantity or '')

        if string.len(label_text) > max_label_len then
            max_label_len = string.len(label_text)
        end
        if string.len(quantity_text) > max_quantity_len then
            max_quantity_len = string.len(quantity_text)
        end
        
        table.insert(lines_data, {text = label_text, quantity = quantity_text, is_item=true, index=i})
    end
    
    -- 数量カラムの表示を考慮したメニュー全体の最大幅
    local menu_content_width = max_label_len + LABEL_QUANTITY_SPACING + QUANTITY_COLUMN_WIDTH
    local max_len = math.max(string.len(menu_data.title), menu_content_width, 30) -- タイトルや区切り線の長さも考慮
    max_len = max_len + 4 -- パディング

    if #menu_data.items > menu_data.page_size then
        table.insert(lines_data, {text=string.rep('-', max_len - 4), is_item=false, index=0}) -- max_lenからパディングを引く
        table.insert(lines_data, {text=string.format('[%d/%d]', menu_data.cursor, #menu_data.items), is_item=false, index=0})
    end

    -- 3. メインの背景を描画
    local line_of_spaces = string.rep(' ', max_len)
    local block_of_spaces = ''
    for i = 1, #lines_data do
        block_of_spaces = block_of_spaces .. line_of_spaces .. '\n'
    end

    local bg_options = {
        pos = { x = settings.menu.pos.x - 10, y = settings.menu.pos.y },
        bg = settings.menu.bg,
        text = settings.menu.text,
        flags = settings.menu.flags,
    }
    menu_background = texts.new(block_of_spaces, bg_options)
    menu_background:show()

    -- 4. カーソルのハイライト背景を描画する
    local current_y_for_highlight = settings.menu.pos.y
    local line_index = 0
    for _, line in ipairs(lines_data) do
        line_index = line_index + 1
        if line.is_item and line.index == menu_data.cursor then
            local highlight_options = {
                pos = { x = settings.menu.pos.x - 10, y = current_y_for_highlight },
                bg = { alpha = 255, red = 70, green = 70, blue = 100 },
                text = settings.menu.text,
                flags = settings.menu.flags,
            }
            cursor_highlight_background = texts.new(line_of_spaces, highlight_options)
            cursor_highlight_background:show()
            break
        end
        current_y_for_highlight = current_y_for_highlight + line_height
    end

    -- 5. 上にテキストを描く
    local current_y_for_text = settings.menu.pos.y
    for _, line in ipairs(lines_data) do
        local text_options = {
            pos = { x = settings.menu.pos.x, y = current_y_for_text },
            text = settings.menu.text,
            bg = { alpha = 0, red = 0, green = 0, blue = 0 },
            flags = settings.menu.flags,
        }

        local text_obj = texts.new(line.text, text_options)
        table.insert(menu_texts, text_obj)
        text_obj:show()

        -- 数量表示 (アイテム行のみ)
        if line.is_item and line.quantity ~= '' then
            local quantity_x_pos = settings.menu.pos.x + max_len * (settings.menu.text.size * 0.6) - QUANTITY_COLUMN_WIDTH * (settings.menu.text.size * 0.6) - 10 -- 微調整
            local quantity_options = {
                pos = { x = quantity_x_pos, y = current_y_for_text },
                text = { size = settings.menu.text.size, font = settings.menu.text.font, stroke = settings.menu.text.stroke, justify = 'right' },
                bg = { alpha = 0, red = 0, green = 0, blue = 0 },
                flags = settings.menu.flags,
            }
            local padded_quantity = string.format("%" .. QUANTITY_COLUMN_WIDTH .. "s", line.quantity) -- 右寄せのためにパディング
            local quantity_obj = texts.new(padded_quantity, quantity_options)
            table.insert(menu_quantities, quantity_obj)
            quantity_obj:show()
        end

        current_y_for_text = current_y_for_text + line_height
    end

    -- 6. 描画説明パネル
    local selected_item_idx = menu_data.cursor
    local selected_item = menu_data.items[selected_item_idx]

    if selected_item and selected_item.description then
        local description_options = {
            pos = settings.description_panel.pos,
            bg = settings.description_panel.bg,
            text = settings.description_panel.text,
            flags = settings.description_panel.flags,
        }
        description_text = texts.new(selected_item.description, description_options)
        description_text:show()
    end
end

-- 引き出しダイアログ表示
local dialog_texts = {}
local dialog_background = nil
local dialog_button_bg = {}
local dialog_button_texts = {} -- ボタンテキスト専用
local quantity_text_obj = nil -- 数量テキストオブジェクトへの参照を保持

-- ダイアログUI要素を破棄
function ui.destroy_withdrawal_dialog()
    for _, text_obj in ipairs(dialog_texts) do
        text_obj:destroy()
    end
    dialog_texts = {}
    if dialog_background then
        dialog_background:destroy()
        dialog_background = nil
    end
    for _, bg_obj in ipairs(dialog_button_bg) do
        bg_obj:destroy()
    end
    dialog_button_bg = {}
    for _, text_obj in ipairs(dialog_button_texts) do
        text_obj:destroy()
    end
    dialog_button_texts = {}
    quantity_text_obj = nil
end

-- ボタンの背景とテキストを更新する内部関数
local function update_dialog_buttons()
    -- 既存のボタン要素をクリア
    for _, bg_obj in ipairs(dialog_button_bg) do
        bg_obj:destroy()
    end
    dialog_button_bg = {}
    for _, text_obj in ipairs(dialog_button_texts) do
        text_obj:destroy()
    end
    dialog_button_texts = {}

    local selected_button = param.get_dialog_selected_button()
    local item = param.get_dialog_item()
    if not item then return end
    
    local dialog_x = (windower.get_windower_settings().ui_x_res / 2) - (dialog_width / 2)
    local dialog_y = (windower.get_windower_settings().ui_y_res / 2) - (dialog_height / 2)
    local line_y = dialog_y + 10 + 50

    -- ボタンの位置とサイズ
    local button_y = line_y
    local cancel_x = dialog_x + (dialog_width / 2) - 80
    local withdraw_x = dialog_x + (dialog_width / 2) + 20
    local button_width = 60
    
    -- 1. 背景を描画
    local function create_button_bg(x, y, is_selected)
        local button_bg_options = {
            pos = { x = x, y = y },
            bg = { alpha = 255, red = 50, green = 50, blue = 50 },
            text = { size = 12, font = 'MS Gothic' },
            flags = { bold = true, draggable = false }
        }
        if is_selected then
            button_bg_options.bg = { alpha = 255, red = 100, green = 100, blue = 150 }
        end
        local button_bg = texts.new(string.rep(' ', (button_width / 6) + 1) .. '\n' .. string.rep(' ', (button_width / 6) + 1), button_bg_options)
        button_bg:show()
        table.insert(dialog_button_bg, button_bg)
    end
    create_button_bg(cancel_x, button_y, selected_button == 'cancel')
    create_button_bg(withdraw_x, button_y, selected_button == 'withdraw')
    
    -- 2. テキストを描画
    local cancel_text = texts.new('キャンセル', {
        pos = { x = cancel_x + (button_width / 2) - 24, y = button_y + 2 + 6 },
        text = { size = 12, font = 'MS Gothic', color = {255,255,255,255}, align = 'center' },
        bg = { alpha = 0 }
    })
    table.insert(dialog_button_texts, cancel_text)
    cancel_text:show()

    local withdraw_text = texts.new('取り出す', {
        pos = { x = withdraw_x + (button_width / 2) - 24, y = button_y + 2 + 6 },
        text = { size = 12, font = 'MS Gothic', color = {255,255,255,255}, align = 'center' },
        bg = { alpha = 0 }
    })
    table.insert(dialog_button_texts, withdraw_text)
    withdraw_text:show()
end

-- ダイアログを初めて作成する
function ui.create_withdrawal_dialog()
    ui.destroy_withdrawal_dialog() -- 念のため既存のものをクリア

    local item = param.get_dialog_item()
    if not item then return end

    local withdraw_quantity = param.get_dialog_withdraw_quantity()
    local max_quantity = item.quantity

    local dialog_x = (windower.get_windower_settings().ui_x_res / 2) - (dialog_width / 2)
    local dialog_y = (windower.get_windower_settings().ui_y_res / 2) - (dialog_height / 2)

    local bg_options = {
        pos = { x = dialog_x, y = dialog_y },
        bg = { alpha = 230, red = 0, green = 0, blue = 0 },
        text = { size = 12, font = 'MS Gothic' },
        flags = { bold = true, draggable = false }
    }
    dialog_background = texts.new(string.rep(string.rep(' ', 40) .. '\n', 7), bg_options)
    dialog_background:show()

    local line_y = dialog_y + 10
    local text_x_offset = 15

    local item_name_text = texts.new(string.format('%sを取り出しますか？', item.name), {
        pos = { x = dialog_x + text_x_offset, y = line_y },
        text = { size = 12, font = 'MS Gothic', color = {255,255,255,255} },
        bg = { alpha = 0 }
    })
    table.insert(dialog_texts, item_name_text)
    item_name_text:show()
    line_y = line_y + 20

    quantity_text_obj = texts.new(string.format('個数 %d/%d (上下で変更)', withdraw_quantity, max_quantity), {
        pos = { x = dialog_x + text_x_offset, y = line_y },
        text = { size = 12, font = 'MS Gothic', color = {255,255,255,255} },
        bg = { alpha = 0 }
    })
    table.insert(dialog_texts, quantity_text_obj)
    quantity_text_obj:show()
    
    update_dialog_buttons() -- 初回のボタンを描画
end

-- ダイアログの表示内容を部分的に更新
function ui.update_withdrawal_dialog(update_type)
    if not param.get_dialog_open() then return end
    
    if update_type == 'quantity' then
        local item = param.get_dialog_item()
        if not item or not quantity_text_obj then return end
        local withdraw_quantity = param.get_dialog_withdraw_quantity()
        local max_quantity = item.quantity
        quantity_text_obj:text(string.format('個数 %d/%d (上下で変更)', withdraw_quantity, max_quantity))
    elseif update_type == 'buttons' then
        update_dialog_buttons()
    end
end

return ui
