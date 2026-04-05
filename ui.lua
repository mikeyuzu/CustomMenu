local texts = require('texts')
local messages = require('message')
local param = require('param')
local settings_manager = require('settings')
local mission_definitions = require('mission_definitions')
local magic_definitions = require('magic_definitions')
local ui = {}

local dialog_width = 300
local dialog_height = 160

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
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 }, justify = 'left' },
        bg = { alpha = 200, red = 20, green = 20, blue = 40 },
        flags = { bold = false, draggable = false }
    },
    description_panel = {
        pos = { x = 480, y = 100 },
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
        bg = { alpha = 200, red = 20, green = 20, blue = 40 },
        flags = { bold = false, draggable = false }
    },
    synthesis_result_panel = {
        pos = { x = 500, y = 100 },
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
        bg = { alpha = 200, red = 20, green = 40, blue = 20 },
        flags = { bold = false, draggable = false },
        width = 360,
    },
    synthesis_ingredient_panel = {
        pos = { x = 910, y = 100 },
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
        bg = { alpha = 200, red = 40, green = 20, blue = 20 },
        flags = { bold = false, draggable = false },
        width = 250,
    },
    mission_detail_panel = {
        pos = { x = 500, y = 100 },
        text = { size = 12, font = 'MS Gothic', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
        bg = { alpha = 200, red = 20, green = 20, blue = 60 },
        flags = { bold = false, draggable = false },
        width = 400,
    },
}

-- テキストオブジェクト
local indicator_text = nil
local menu_texts = {}
local menu_quantities = {}
local menu_background = nil
local cursor_highlight_background = nil
local description_text = nil

-- 詳細パネル用
local synthesis_result_panel_texts = {}
local synthesis_result_panel_background = nil
local synthesis_ingredient_panel_texts = {}
local synthesis_ingredient_panel_background = nil
local mission_detail_panel_texts = {}
local mission_detail_panel_background = nil
local cursor_highlight_background_sub = nil

-- ナビゲーションウィンドウ用
local navigation_text = nil

-- 文字列の表示幅（半角換算）を計算するヘルパー関数
local function _get_display_width(text)
    if not text then return 0 end
    -- カラーコード (\cs(r,g,b), \cr) と特殊アイコン (${icon|...}) を完全に除去
    -- \cs... は \cs%b() で括弧のバランスをとって除去
    local clean = text:gsub('\\cs%b()', ''):gsub('\\cr', ''):gsub('%$%b{}', '')
    
    local width = 0
    local i = 1
    while i <= #clean do
        local byte = clean:byte(i)
        if not byte then break end
        if byte > 127 then
            width = width + 2
            if (byte >= 0x81 and byte <= 0x9F) or (byte >= 0xE0 and byte <= 0xFC) then
                i = i + 2
            else
                i = i + 1
            end
        else
            width = width + 1
            i = i + 1
        end
    end
    return width
end

-- 初期化
function ui.initialize()
    indicator_text = texts.new(messages.menu_title, settings.indicator)
    -- indicator_text:show() -- ログイン後に表示を制御するため、ここではshowしない

    -- ナビゲーションウィンドウ初期化
    local nav_settings = settings_manager.get('navigation')
    if nav_settings and nav_settings.enabled then
        navigation_text = texts.new('${content}', nav_settings)
        -- navigation_text:show() -- ログイン後に表示を制御するため、ここではshowしない
    end
end

-- クリーンアップ
function ui.cleanup()
    if indicator_text then indicator_text:destroy() end
    for _, t in ipairs(menu_texts) do t:destroy() end
    menu_texts = {}
    for _, t in ipairs(menu_quantities) do t:destroy() end
    menu_quantities = {}
    if menu_background then menu_background:destroy(); menu_background = nil end
    if cursor_highlight_background then cursor_highlight_background:destroy(); cursor_highlight_background = nil end
    if description_text then description_text:destroy(); description_text = nil end
    if cursor_highlight_background_sub then cursor_highlight_background_sub:destroy(); cursor_highlight_background_sub = nil end
    if navigation_text then navigation_text:destroy(); navigation_text = nil end
    ui.hide_synthesis_details()
    ui.hide_mission_details()
end

function ui.show_indicator() if indicator_text then indicator_text:show() end end
function ui.hide_indicator() if indicator_text then indicator_text:hide() end end

function ui.update_indicator(exclamation_mark)
    if indicator_text then
        local text = messages.menu_title
        if exclamation_mark == 1 then
            text = '\\cs(255,255,0)' .. text .. '!\\cr'
        end
        indicator_text:text(text)
    end
end

function ui.update_notification(has_notification)
    ui.update_indicator(has_notification and 1 or 0)
end

function ui.show_menu_list(menu_data)
    ui.update_menu_display(menu_data)
    if description_text then description_text:show() end
end

function ui.hide_menu_list()
    for _, t in ipairs(menu_texts) do t:hide() end
    for _, t in ipairs(menu_quantities) do t:hide() end
    if menu_background then menu_background:hide() end
    if cursor_highlight_background then cursor_highlight_background:hide() end
    if description_text then description_text:hide() end
end

-- ナビゲーション更新
function ui.update_navigation(content)
    if navigation_text then
        navigation_text.content = content
        navigation_text:show()
    end
end

function ui.show_navigation() if navigation_text then navigation_text:show() end end
function ui.hide_navigation() if navigation_text then navigation_text:hide() end end

-- メニュー表示内容更新
function ui.update_menu_display(menu_data)
    if not menu_data then return end

    -- 1. 既存の破棄
    for _, t in ipairs(menu_texts) do t:destroy() end
    menu_texts = {}
    for _, t in ipairs(menu_quantities) do t:destroy() end
    menu_quantities = {}
    if menu_background then menu_background:destroy(); menu_background = nil end
    if cursor_highlight_background then cursor_highlight_background:destroy(); cursor_highlight_background = nil end
    if description_text then description_text:destroy(); description_text = nil end

    -- 2. 寸法計算
    local lines_data = {}
    local max_label_w = 0
    local max_qty_w = 0
    local line_height = settings.menu.text.size + 4

    local start_idx = menu_data.scroll_pos
    local end_idx = math.min(start_idx + menu_data.page_size - 1, #menu_data.items)

    for i = start_idx, end_idx do
        local item = menu_data.items[i]
        local prefix = (i == menu_data.cursor) and '> ' or '  '
        local recipe_name = (item.isOpen == 0) and (item.allMaterialsPossessed and '\\cs(255,255,0)？？？\\cr' or '？？？') or item.label
        local status_icon = (item.status == 1) and ' ${icon|!}' or ''
        
        -- ステータス1（ビックリマーク）なら行全体を黄色にする
        -- ステータス2（受取済み）なら灰色にする
        local color_pfx = ''
        local color_sfx = ''
        if item.status == 1 then
            color_pfx = '\\cs(255,255,0)'
            color_sfx = '\\cr'
        elseif item.status == 2 then
            color_pfx = '\\cs(128,128,128)'
            color_sfx = '\\cr'
        end
        
        local label_text = prefix .. color_pfx .. recipe_name .. status_icon .. color_sfx
        local quantity_text = tostring(item.quantity or '')

        local lw = _get_display_width(label_text)
        local qw = _get_display_width(quantity_text)
        if lw > max_label_w then max_label_w = lw end
        if qw > max_qty_w then max_qty_w = qw end
        table.insert(lines_data, {text=label_text, quantity=quantity_text, is_item=true, index=i})
    end

    local menu_w = max_label_w + (max_qty_w > 0 and (max_qty_w + 1) or 0)
    local max_len = math.max(_get_display_width(menu_data.title), menu_w, 8)
    max_len = max_len + 1 -- 最小限のパディング

    -- ヘッダー等の追加
    table.insert(lines_data, 1, {text=menu_data.title, is_item=false})
    table.insert(lines_data, 2, {text=string.rep('-', max_len - 1), is_item=false})
    if #menu_data.items > menu_data.page_size then
        table.insert(lines_data, {text=string.rep('-', max_len), is_item=false})
        table.insert(lines_data, {text=string.format('[%d/%d]', menu_data.cursor, #menu_data.items), is_item=false})
    end

    -- 3. 背景描画
    local space_line = string.rep(' ', max_len)
    local bg_text = ""
    for _ = 1, #lines_data do bg_text = bg_text .. space_line .. '\n' end
    menu_background = texts.new(bg_text, { pos={x=settings.menu.pos.x-5, y=settings.menu.pos.y}, bg=settings.menu.bg, text=settings.menu.text, flags=settings.menu.flags })
    menu_background:show()

    -- 4. カーソル描画
    local cy = settings.menu.pos.y
    for _, line in ipairs(lines_data) do
        if line.is_item and line.index == menu_data.cursor then
            cursor_highlight_background = texts.new(space_line, { pos={x=settings.menu.pos.x-5, y=cy}, bg={alpha=255, red=70, green=70, blue=100}, text=settings.menu.text, flags=settings.menu.flags })
            cursor_highlight_background:show()
            break
        end
        cy = cy + line_height
    end

    -- 5. テキスト描画
    local ty = settings.menu.pos.y
    for _, line in ipairs(lines_data) do
        local t_obj = texts.new(line.text, { pos={x=settings.menu.pos.x, y=ty}, text=settings.menu.text, bg={alpha=0}, flags=settings.menu.flags })
        table.insert(menu_texts, t_obj); t_obj:show()

        if line.is_item and line.quantity ~= '' then
            local qx = settings.menu.pos.x + (max_len - 1) * (settings.menu.text.size * 0.6)
            local q_obj = texts.new(line.quantity, { pos={x=qx, y=ty}, text={size=settings.menu.text.size, font=settings.menu.text.font, justify='right'}, bg={alpha=0}, flags=settings.menu.flags })
            table.insert(menu_quantities, q_obj); q_obj:show()
        end
        ty = ty + line_height
    end

    -- 6. 説明パネル
    local sel = menu_data.items[menu_data.cursor]
    if sel and sel.description then
        description_text = texts.new(sel.description, { pos=settings.description_panel.pos, bg=settings.description_panel.bg, text=settings.description_panel.text, flags=settings.description_panel.flags })
        description_text:show()
    end
end

local function _update_panel(ps, pt, pb, lines, justify)
    for i=#pt,1,-1 do pt[i]:destroy(); table.remove(pt, i) end
    if pb then pb:destroy(); pb = nil end
    if not lines or #lines == 0 then return nil end

    local lh = ps.text.size + 4
    local max_w = 0
    for _, l in ipairs(lines) do
        local w = _get_display_width(type(l) == 'table' and l.text or l)
        if w > max_w then max_w = w end
    end

    local bg_w = ps.width or (max_w * (ps.text.size * 0.5) + 15)
    local bg_h = #lines * lh + 10
    local sp_c = math.floor(bg_w / (ps.text.size * 0.6))
    local sp_b = ""
    for _ = 1, math.ceil(bg_h/lh) do sp_b = sp_b .. string.rep(' ', sp_c) .. '\n' end

    local new_pb = texts.new(sp_b, { pos=ps.pos, bg=ps.bg, text=ps.text, flags=ps.flags })
    new_pb:show()

    local cy = ps.pos.y + 5
    for _, l in ipairs(lines) do
        local txt = type(l) == 'table' and l.text or l
        local to = { pos={x=ps.pos.x+10, y=cy}, text=ps.text, bg={alpha=0}, flags=ps.flags }
        if justify == 'center' then to.pos.x = ps.pos.x + bg_w/2; to.text.justify = 'center'
        elseif justify == 'right' then to.pos.x = ps.pos.x + bg_w - 10; to.text.justify = 'right' end
        local t_obj = texts.new(txt, to)
        table.insert(pt, t_obj); t_obj:show()
        cy = cy + lh
    end
    return new_pb
end

function ui.show_synthesis_details(recipe)
    if not recipe then ui.hide_synthesis_details(); return end
    local rl = {}
    local nq_hq_l = {}
    local lh = settings.synthesis_result_panel.text.size + 4
    local cy = {y = settings.synthesis_result_panel.pos.y + 5}

    local sk = ""
    if recipe.craftRank then
        for id, s in ipairs(messages.synergy_skill.items) do
            if recipe.craftRank[id] and recipe.craftRank[id] > 0 then sk = sk .. string.format("%s%d ", s.label, recipe.craftRank[id]) end
        end
    end
    table.insert(rl, sk ~= "" and sk or messages.synthesis_menu.other_skill)
    cy.y = cy.y + lh

    local st = (recipe.isOpen == 1) and messages.synthesis_menu.run_synthesis or (recipe.allMaterialsPossessed and messages.synthesis_menu.recipe_open or messages.synthesis_menu.recipe_not_open)
    table.insert(rl, st)
    cy.y = cy.y + lh
    table.insert(rl, messages.synthesis_menu.synthesis_item)
    cy.y = cy.y + lh

    local function add_nq_hq(item, pfx)
        if not item then return end
        local sy = cy.y
        table.insert(rl, string.format("%s %s(%d)", pfx, item.name, item.quantity or 1))
        cy.y = cy.y + lh
        ---@type any
        local disc = item.description or messages.synthesis_menu.not_infomation
        for _, l in ipairs(disc:split('\n')) do
            table.insert(rl, " " .. l); cy.y = cy.y + lh
        end
        table.insert(nq_hq_l, { y=sy, height=cy.y-sy, item=item, type=pfx })
    end
    if recipe.isOpen == 1 then add_nq_hq(recipe.result, "NQ"); add_nq_hq(recipe.resultHQ1, "HQ1"); add_nq_hq(recipe.resultHQ2, "HQ2"); add_nq_hq(recipe.resultHQ3, "HQ3") end
    synthesis_result_panel_background = _update_panel(settings.synthesis_result_panel, synthesis_result_panel_texts, synthesis_result_panel_background, rl, 'left')

    local il = {}
    local ml = {}
    table.insert(il, messages.synthesis_menu.elemental_item); cy.y = cy.y + lh
    local function add_mat(item, is_c)
        if not item then return end
        local sy = cy.y
        local txt = string.format("%s(%d/%d)", item.name or "?", item.possession or 0, item.quantity or 1)
        if (item.possession or 0) < (item.quantity or 1) then txt = "\\cs(255,100,100)"..txt.."\\cr" end
        table.insert(il, txt); cy.y = cy.y + lh
        table.insert(ml, { y=sy, height=lh, item=item, type=is_c and "crystal" or "ingredient" })
    end
    add_mat(recipe.crystal, true)
    if recipe.ingredient then for _, ing in ipairs(recipe.ingredient) do add_mat(ing, false) end end
    synthesis_ingredient_panel_background = _update_panel(settings.synthesis_ingredient_panel, synthesis_ingredient_panel_texts, synthesis_ingredient_panel_background, il, 'left')

    if cursor_highlight_background_sub then cursor_highlight_background_sub:destroy(); cursor_highlight_background_sub = nil end
    local asw = param.get_active_sub_window()
    if param.get_sub_window_active() and (asw == 'nq_hq' or asw == 'materials') then
        local idx = (asw == 'nq_hq') and param.get_nq_hq_cursor_index() or param.get_materials_cursor_index()
        local lay = (asw == 'nq_hq') and nq_hq_l[idx] or ml[idx]
        local ps = (asw == 'nq_hq') and settings.synthesis_result_panel or settings.synthesis_ingredient_panel
        if lay then
            local spc = math.floor(ps.width / (ps.text.size * 0.6))
            local spb = ""
            for _ = 1, math.ceil(lay.height/lh) do spb = spb .. string.rep(' ', spc) .. '\n' end
            cursor_highlight_background_sub = texts.new(spb, { pos={x=ps.pos.x, y=lay.y}, bg={alpha=100, red=100, green=100, blue=150}, text=ps.text, flags=ps.flags })
            cursor_highlight_background_sub:show()
        end
    end
end

function ui.hide_synthesis_details()
    synthesis_result_panel_background = _update_panel(settings.synthesis_result_panel, synthesis_result_panel_texts, synthesis_result_panel_background, nil)
    synthesis_ingredient_panel_background = _update_panel(settings.synthesis_ingredient_panel, synthesis_ingredient_panel_texts, synthesis_ingredient_panel_background, nil)
    if cursor_highlight_background_sub then cursor_highlight_background_sub:destroy(); cursor_highlight_background_sub = nil end
end

local dialog_texts, dialog_button_bg, dialog_button_texts = {}, {}, {}
local dialog_background, quantity_text_obj = nil, nil

function ui.destroy_withdrawal_dialog()
    for _, t in ipairs(dialog_texts) do t:destroy() end; dialog_texts = {}
    if dialog_background then dialog_background:destroy(); dialog_background = nil end
    for _, b in ipairs(dialog_button_bg) do b:destroy() end; dialog_button_bg = {}
    for _, t in ipairs(dialog_button_texts) do t:destroy() end; dialog_button_texts = {}
    quantity_text_obj = nil
end

local function update_dialog_buttons()
    for _, b in ipairs(dialog_button_bg) do b:destroy() end; dialog_button_bg = {}
    for _, t in ipairs(dialog_button_texts) do t:destroy() end; dialog_button_texts = {}
    local sel = param.get_dialog_selected_button()
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - 80
    local by = dy + 60
    local function btn(x, txt, is_sel)
        local b_bg = texts.new(string.rep(' ', 11)..'\n'..string.rep(' ', 11), { pos={x=x, y=by}, bg={alpha=255, red=is_sel and 100 or 50, green=is_sel and 100 or 50, blue=is_sel and 150 or 50}, text={size=12, font='MS Gothic'}, flags={bold=true} })
        b_bg:show(); table.insert(dialog_button_bg, b_bg)
        local b_t = texts.new(txt, { pos={x=x+6, y=by+8}, text={size=12, font='MS Gothic', color={255,255,255,255}, align='center'}, bg={alpha=0} })
        b_t:show(); table.insert(dialog_button_texts, b_t)
    end
    btn(dx + 70, messages.synthesis_menu.dialog_cancel, sel == 'cancel')
    btn(dx + 170, messages.synthesis_menu.dialog_get_item, sel == 'withdraw')
end

function ui.create_withdrawal_dialog()
    ui.destroy_withdrawal_dialog()
    local item = param.get_dialog_item()
    if not item then return end
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - 80
    dialog_background = texts.new(string.rep(string.rep(' ', 40) .. '\n', 10), { pos={x=dx, y=dy}, bg={alpha=230, red=0, green=0, blue=0}, text={size=12} })
    dialog_background:show()
    local t1 = texts.new(string.format(messages.synthesis_menu.confirm_removal, item.name), { pos={x=dx+15, y=dy+10}, text={size=12, color={255,255,255,255}}, bg={alpha=0} })
    t1:show(); table.insert(dialog_texts, t1)
    local mq = math.min(item.quantity, item.stackSize)
    quantity_text_obj = texts.new(string.format(messages.synthesis_menu.quantity_change, param.get_dialog_withdraw_quantity(), mq), { pos={x=dx+15, y=dy+30}, text={size=12, color={255,255,255,255}}, bg={alpha=0} })
    quantity_text_obj:show(); table.insert(dialog_texts, quantity_text_obj)
    update_dialog_buttons()
end

function ui.update_withdrawal_dialog(ut)
    if not param.get_dialog_open() then return end
    if ut == 'quantity' and quantity_text_obj then
        local item = param.get_dialog_item()
        if item ~= nil then
            local mq = math.min(item.quantity, item.stackSize)
            quantity_text_obj:text(string.format('個数 %d/%d (上下で変更)', param.get_dialog_withdraw_quantity(), mq))
        end
    elseif ut == 'buttons' then update_dialog_buttons() end
end

local ccd_texts, ccd_bg, ccd_btn_bg, ccd_btn_texts = {}, nil, {}, {}
function ui.destroy_craft_confirm_dialog()
    for _, t in ipairs(ccd_texts) do t:destroy() end; ccd_texts = {}
    if ccd_bg then ccd_bg:destroy(); ccd_bg = nil end
    for _, b in ipairs(ccd_btn_bg) do b:destroy() end; ccd_btn_bg = {}
    for _, t in ipairs(ccd_btn_texts) do t:destroy() end; ccd_btn_texts = {}
end

local function update_ccd_buttons()
    for _, b in ipairs(ccd_btn_bg) do b:destroy() end; ccd_btn_bg = {}
    for _, t in ipairs(ccd_btn_texts) do t:destroy() end; ccd_btn_texts = {}
    local sel = param.get_craft_confirm_selected_button()
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - 80
    local by = dy + 60
    local function btn(x, txt, is_sel)
        local b_bg = texts.new(string.rep(' ', 11)..'\n'..string.rep(' ', 11), { pos={x=x, y=by}, bg={alpha=255, red=is_sel and 100 or 50, green=is_sel and 100 or 50, blue=is_sel and 150 or 50}, text={size=12, font='MS Gothic'}, flags={bold=true} })
        b_bg:show(); table.insert(ccd_btn_bg, b_bg)
        local b_t = texts.new(txt, { pos={x=x+15, y=by+8}, text={size=12, font='MS Gothic', color={255,255,255,255}, align='center'}, bg={alpha=0} })
        b_t:show(); table.insert(ccd_btn_texts, b_t)
    end
    btn(dx + 70, messages.no_button, sel == 'no'); btn(dx + 170, messages.yes_button, sel == 'yes')
end

function ui.create_craft_confirm_dialog(name)
    ui.destroy_craft_confirm_dialog()
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - 80
    ccd_bg = texts.new(string.rep(string.rep(' ', 40) .. '\n', 10), { pos={x=dx, y=dy}, bg={alpha=230, red=0, green=0, blue=0}, text={size=12, font='MS Gothic'} })
    ccd_bg:show()
    local t = texts.new(string.format(messages.synthesis_menu.confirm_synthesis, name), { pos={x=dx+15, y=dy+20}, text={size=12, font='MS Gothic', color={255,255,255,255}}, bg={alpha=0} })
    t:show(); table.insert(ccd_texts, t)
    update_ccd_buttons()
end
function ui.update_craft_confirm_dialog(ut) if param.get_craft_confirm_dialog_open() and ut == 'buttons' then update_ccd_buttons() end end

local ecd_texts, ecd_bg, ecd_btn_bg, ecd_btn_texts = {}, nil, {}, {}
function ui.destroy_eminence_confirm_dialog()
    for _, t in ipairs(ecd_texts) do t:destroy() end; ecd_texts = {}
    if ecd_bg then ecd_bg:destroy(); ecd_bg = nil end
    for _, b in ipairs(ecd_btn_bg) do b:destroy() end; ecd_btn_bg = {}
    for _, t in ipairs(ecd_btn_texts) do t:destroy() end; ecd_btn_texts = {}
end

local function update_ecd_buttons()
    for _, b in ipairs(ecd_btn_bg) do b:destroy() end; ecd_btn_bg = {}
    for _, t in ipairs(ecd_btn_texts) do t:destroy() end; ecd_btn_texts = {}
    local sel = param.get_eminence_confirm_selected_button()
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - 80
    local by = dy + 60
    local function btn(x, txt, is_sel)
        local b_bg = texts.new(string.rep(' ', 11)..'\n'..string.rep(' ', 11), { pos={x=x, y=by}, bg={alpha=255, red=is_sel and 100 or 50, green=is_sel and 100 or 50, blue=is_sel and 150 or 50}, text={size=12, font='MS Gothic'}, flags={bold=true} })
        b_bg:show(); table.insert(ecd_btn_bg, b_bg)
        local b_t = texts.new(txt, { pos={x=x+15, y=by+8}, text={size=12, font='MS Gothic', color={255,255,255,255}, align='center'}, bg={alpha=0} })
        b_t:show(); table.insert(ecd_btn_texts, b_t)
    end
    btn(dx + 70, messages.no_button, sel == 'no'); btn(dx + 170, messages.yes_button, sel == 'yes')
end

function ui.create_eminence_confirm_dialog(name)
    ui.destroy_eminence_confirm_dialog()
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - 80
    ecd_bg = texts.new(string.rep(string.rep(' ', 40) .. '\n', 10), { pos={x=dx, y=dy}, bg={alpha=230, red=0, green=0, blue=0}, text={size=12, font='MS Gothic'} })
    ecd_bg:show()
    local t = texts.new(string.format(messages.eminence_menu.confirm_receive, name), { pos={x=dx+15, y=dy+20}, text={size=12, font='MS Gothic', color={255,255,255,255}}, bg={alpha=0} })
    t:show(); table.insert(ecd_texts, t)
    update_ecd_buttons()
end
function ui.update_eminence_confirm_dialog(ut) if param.get_eminence_confirm_dialog_open() and ut == 'buttons' then update_ecd_buttons() end end

local sd_texts, sd_bg, sd_btn_bg, sd_btn_t = {}, nil, nil, nil
function ui.destroy_success_dialog()
    for _, t in ipairs(sd_texts) do t:destroy() end; sd_texts = {}
    if sd_bg then sd_bg:destroy(); sd_bg = nil end
    if sd_btn_bg then sd_btn_bg:destroy(); sd_btn_bg = nil end
    if sd_btn_t then sd_btn_t:destroy(); sd_btn_t = nil end
end

function ui.create_success_dialog(msg)
    ui.destroy_success_dialog()
    local _, lc = string.gsub(msg, "\n", ""); lc = lc + 1
    local h = 80 + lc * 20; if h < 120 then h = 120 end
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - h/2
    sd_bg = texts.new(string.rep(string.rep(' ', 40) .. '\n', math.ceil(h/16)), { pos={x=dx, y=dy}, bg={alpha=230}, text={size=12, font='MS Gothic'} })
    sd_bg:show()
    local t = texts.new(msg, { pos={x=dx+15, y=dy+20}, text={size=12, font='MS Gothic', color={255,255,255,255}}, bg={alpha=0} })
    t:show(); table.insert(sd_texts, t)
    local bx = dx + 120; local by = dy + h - 48
    sd_btn_bg = texts.new(string.rep(' ', 11)..'\n'..string.rep(' ', 11), { pos={x=bx, y=by}, bg={alpha=255, red=100, green=100, blue=150}, text={size=12, font='MS Gothic'} })
    sd_btn_bg:show()
    sd_btn_t = texts.new(messages.ok_button, { pos={x=bx+20, y=by+8}, text={size=12, font='MS Gothic', color={255,255,255,255}, align='center'}, bg={alpha=0} })
    sd_btn_t:show()
end

local ord_texts, ord_bg = {}, nil
function ui.destroy_open_recipe_dialog()
    for _, t in ipairs(ord_texts) do t:destroy() end; ord_texts = {}
    if ord_bg then ord_bg:destroy(); ord_bg = nil end
end
function ui.create_open_recipe_dialog(name)
    ui.destroy_open_recipe_dialog()
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - 80
    ord_bg = texts.new(string.rep(string.rep(' ', 40) .. '\n', 10), { pos={x=dx, y=dy}, bg={alpha=230}, text={size=12, font='MS Gothic'} })
    ord_bg:show()
    local t = texts.new(string.format(messages.synthesis_menu.recipe_opened, name), { pos={x=dx+15, y=dy+20}, text={size=12, font='MS Gothic', color={255,255,255,255}}, bg={alpha=0} })
    t:show(); table.insert(ord_texts, t)
end

local ed_texts, ed_bg, ed_btn_bg, ed_btn_t = {}, nil, nil, nil
function ui.destroy_error_dialog()
    for _, t in ipairs(ed_texts) do t:destroy() end; ed_texts = {}
    if ed_bg then ed_bg:destroy(); ed_bg = nil end
    if ed_btn_bg then ed_btn_bg:destroy(); ed_btn_bg = nil end
    if ed_btn_t then ed_btn_t:destroy(); ed_btn_t = nil end
end
function ui.create_error_dialog(msg)
    ui.destroy_error_dialog()
    local _, lc = string.gsub(msg, "\n", ""); lc = lc + 1
    local h = 80 + lc * 20; if h < 120 then h = 120 end
    local dx = (windower.get_windower_settings().ui_x_res / 2) - 150
    local dy = (windower.get_windower_settings().ui_y_res / 2) - h/2
    ed_bg = texts.new(string.rep(string.rep(' ', 40) .. '\n', math.ceil(h/16)), { pos={x=dx, y=dy}, bg={alpha=230, red=30}, text={size=12, font='MS Gothic'} })
    ed_bg:show()
    local t = texts.new(msg, { pos={x=dx+15, y=dy+20}, text={size=12, font='MS Gothic', color={255,255,255,255}}, bg={alpha=0} })
    t:show(); table.insert(ed_texts, t)
    local bx = dx + 120; local by = dy + h - 48
    ed_btn_bg = texts.new(string.rep(' ', 11)..'\n'..string.rep(' ', 11), { pos={x=bx, y=by}, bg={alpha=255, red=100, green=100, blue=150}, text={size=12, font='MS Gothic'} })
    ed_btn_bg:show()
    ed_btn_t = texts.new(messages.ok_button, { pos={x=bx+20, y=by+8}, text={size=12, font='MS Gothic', color={255,255,255,255}, align='center'}, bg={alpha=0} })
    ed_btn_t:show()
end

function ui.show_mission_details(name, status, category_key)
    if not name then
        ui.hide_mission_details()
        return
    end
    local sl = (status == -1) and messages.mission_status.completed or (status == 0 and messages.mission_status.not_started or messages.mission_status.in_progress)
    local l = { " 状態: " .. sl }
    ---@type any
    local gui = category_key and mission_definitions.mission_guidance[category_key] and mission_definitions.mission_guidance[category_key][name]
    if status ~= -1 and gui then
        table.insert(l, "")
        table.insert(l, "--- ガイダンス ---")
        for _, ln in ipairs(gui:split('\n')) do
            table.insert(l, " " .. ln)
        end
    end
    mission_detail_panel_background = _update_panel(settings.mission_detail_panel, mission_detail_panel_texts, mission_detail_panel_background, l, 'left')
end
function ui.hide_mission_details() mission_detail_panel_background = _update_panel(settings.mission_detail_panel, mission_detail_panel_texts, mission_detail_panel_background, nil) end

function ui.show_eminence_details(item, status)
    if not item then ui.hide_eminence_details(); return end
    local sl = (status == 0) and messages.eminence_status.not_achieved or (status == 1 and messages.eminence_status.achieved or messages.eminence_status.reward_received)
    local l = { " 状態: " .. sl, "", "--- 内容 ---", " " .. (item.message or ""), "", "--- 報酬 ---", " " .. (item.reward or "") }
    mission_detail_panel_background = _update_panel(settings.mission_detail_panel, mission_detail_panel_texts, mission_detail_panel_background, l, 'left')
end
function ui.hide_eminence_details() ui.hide_mission_details() end

function ui.show_magic_details(magic_id, jobs, flag)
    if not magic_id then ui.hide_magic_details(); return end
    
    local def = magic_definitions.magics[magic_id]
    local name = def and def.name or "魔法ID:"..magic_id
    local status = (flag == 1) and "習得済み" or "未習得"
    
    -- ジョブ名リスト (22ジョブ)
    local job_names = {"戦","モ","白","黒","赤","シ","ナ","暗","獣","吟","狩","侍","忍","竜","召","青","コ","か","踊","学","風","剣"}
    local level_strings = {}
    
    if type(jobs) == 'table' then
        -- 詳細デバッグログ: テーブルの内容をすべて出力
        local kv_pairs = {}
        local min_key = 999
        for k, v in pairs(jobs) do
            local nk = tonumber(k)
            if nk then
                if nk < min_key then min_key = nk end
                table.insert(kv_pairs, string.format("%s:%s", tostring(k), tostring(v)))
            end
        end

        -- ジョブ情報の解析
        for i = 0, #job_names do
            -- API側が0開始なら jobs[0..21], 1開始なら jobs[1..22]
            local job_idx = (min_key == 0) and i or (i + 1)
            local val = jobs[job_idx] or jobs[tostring(job_idx)]
            local level = tonumber(val)
            
            if level and level > 0 then
                -- job_names は常に 1..22
                local name_idx = i + 1
                if job_names[name_idx] then
                    table.insert(level_strings, job_names[name_idx] .. "Lv" .. level)
                end
            end
        end
    end
    
    local level_display = #level_strings > 0 and table.concat(level_strings, " ") or "習得不可"
    -- ... (以下、説明や入手方法の表示処理は変更なし)

    local l = {
        " " .. name,
        " 状態: " .. status,
        " 習得レベル: " .. level_display,
        "",
        "--- 概要 ---",
        " " .. (def and def.description or "情報がありません。"),
        ""
    }

    local has_detail = false
    if def then
        local details = {
            { key = "shop", label = "ショップ" },
            { key = "quest", label = "クエスト報酬" },
            { key = "drop", label = "モンスタードロップ" },
            { key = "steal", label = "盗む" },
            { key = "chest", label = "宝箱" },
            { key = "mining", label = "採掘" },
            { key = "content", label = "コンテンツ" },
        }

        for _, detail in ipairs(details) do
            local val = def[detail.key]
            local has_content = false
            if type(val) == 'string' and val ~= "" then
                has_content = true
            elseif type(val) == 'table' and #val > 0 then
                has_content = true
            end

            if has_content then
                table.insert(l, "--- " .. detail.label .. " ---")
                -- 複数行またはテーブルの場合に対応
                if type(val) == 'table' then
                    for _, entry in ipairs(val) do
                        if type(entry) == 'table' then
                            local line = ""
                            if entry.zone then line = line .. "[" .. entry.zone .. "] " end
                            if entry.mob then line = line .. entry.mob end
                            if line ~= "" then table.insert(l, " " .. line) end
                        else
                            table.insert(l, " " .. tostring(entry))
                        end
                    end
                else
                    for line in val:gmatch("([^\n]+)") do
                        table.insert(l, " " .. line)
                    end
                end
                table.insert(l, "")
                has_detail = true
            end
        end
    end

    if not has_detail then
        table.insert(l, "--- 入手方法 ---")
        table.insert(l, " " .. (def and def.acquisition or "情報がありません。"))
    end

    mission_detail_panel_background = _update_panel(settings.mission_detail_panel, mission_detail_panel_texts, mission_detail_panel_background, l, 'left')
end

function ui.hide_magic_details() ui.hide_mission_details() end

-- 全てのUIを非表示にする（イベント中など）
function ui.hide_all()
    ui.hide_indicator()
    ui.hide_menu_list()
    ui.hide_navigation()
    ui.hide_synthesis_details()
    ui.hide_mission_details()
end

-- 現在の状態に基づいてUIを表示する
function ui.refresh_visibility()
    -- インジケーターは設定に関わらず基本表示（メニューが開いていない場合）
    if not param.get_menu_open() then
        ui.show_indicator()
    else
        -- メニューが開いている場合はメニューリストを表示
        ui.show_menu_list(param.get_current_menu())
    end

    -- ナビゲーション
    local nav_settings = settings_manager.get('navigation')
    if nav_settings and nav_settings.enabled then
        ui.show_navigation()
    end
end

return ui
