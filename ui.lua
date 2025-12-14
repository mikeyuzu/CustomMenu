local texts = require('texts')
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
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
        bg = { alpha = 200, red = 20, green = 20, blue = 40 },
        flags = { bold = false, draggable = false }
    }
}

-- テキストオブジェクト
local indicator_text = nil
local menu_texts = {}
local menu_background = nil
local cursor_highlight_background = nil

-- 初期化
function ui.initialize()
    -- インジケーター(カスタムメニュー)の作成
    indicator_text = texts.new('カスタムメニュー', settings.indicator)
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
    if menu_background then
        menu_background:destroy()
        menu_background = nil
    end
    if cursor_highlight_background then
        cursor_highlight_background:destroy()
        cursor_highlight_background = nil
    end
end

-- 通知表示更新
function ui.update_notification(has_notification)
    if indicator_text then
        if has_notification then
            indicator_text:text('カスタムメニュー ${icon|!}')
        else
            indicator_text:text('カスタムメニュー')
        end
    end
end

-- メニューリスト表示
function ui.show_menu_list(menu_data)
    ui.update_menu_display(menu_data)
end

-- メニューリスト非表示
function ui.hide_menu_list()
    for _, text_obj in ipairs(menu_texts) do
        text_obj:hide()
    end
    if menu_background then
        menu_background:hide()
    end
    if cursor_highlight_background then
        cursor_highlight_background:hide()
    end
end

-- メニュー表示内容更新
function ui.update_menu_display(menu_data)
    if not menu_data then return end

    -- 1. 既存のUIオブジェクトをすべて破棄
    for _, text_obj in ipairs(menu_texts) do
        text_obj:destroy()
    end
    menu_texts = {}
    if menu_background then
        menu_background:destroy()
        menu_background = nil
    end
    if cursor_highlight_background then
        cursor_highlight_background:destroy()
        cursor_highlight_background = nil
    end

    -- 2. メニューの寸法と内容を計算
    local lines_data = {}
    local max_len = 0
    local line_height = settings.menu.text.size + 4

    table.insert(lines_data, {text=menu_data.title, is_item=false, index=0})
    table.insert(lines_data, {text=string.rep('-', 30), is_item=false, index=0})

    local start_idx = menu_data.scroll_pos
    local end_idx = math.min(start_idx + menu_data.page_size - 1, #menu_data.items)

    for i = start_idx, end_idx do
        local item = menu_data.items[i]
        local prefix = (i == menu_data.cursor) and '> ' or '  '
        table.insert(lines_data, {text = prefix .. item.label, is_item=true, index=i})
    end

    if #menu_data.items > menu_data.page_size then
        table.insert(lines_data, {text=string.rep('-', 30), is_item=false, index=0})
        table.insert(lines_data, {text=string.format('[%d/%d]', menu_data.cursor, #menu_data.items), is_item=false, index=0})
    end

    for _, line in ipairs(lines_data) do
        if string.len(line.text) > max_len then
            max_len = string.len(line.text)
        end
    end

    -- 最大長にパディングを追加
    max_len = max_len + 4

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

    -- 4. Draw the cursor highlight background
    local current_y_for_highlight = settings.menu.pos.y
    local line_index = 0
    for _, line in ipairs(lines_data) do
        line_index = line_index + 1
        if line.is_item and line.index == menu_data.cursor then
            local highlight_options = {
                pos = { x = settings.menu.pos.x - 10, y = current_y_for_highlight },
                bg = { alpha = 255, red = 70, green = 70, blue = 100 }, -- ハイライト色
                text = settings.menu.text,
                flags = settings.menu.flags,
            }
            cursor_highlight_background = texts.new(line_of_spaces, highlight_options)
            cursor_highlight_background:show()
            break
        end
        current_y_for_highlight = current_y_for_highlight + line_height
    end

    -- 5. Draw the text on top
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
        current_y_for_text = current_y_for_text + line_height
    end
end

-- フレーム更新
function ui.update()
    -- 必要に応じてアニメーション等を実装
end

return ui
