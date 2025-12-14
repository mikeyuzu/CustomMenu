local texts = require('texts')
local messages = require('message')
local ui = {}

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

-- フレーム更新
function ui.update()
    -- 必要に応じてアニメーション等を実装
end

return ui
