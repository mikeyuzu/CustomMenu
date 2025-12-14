local menu_manager = {}

-- メニュー履歴スタック
local menu_stack = {}

-- 現在のメニューデータ
local current_menu = nil

-- メインメニューの定義
local main_menu_items = {
    { id = 'eminence', label = 'エミネンス・レコード' },
    { id = 'synthesis', label = '合成' },
    { id = 'collection', label = '図鑑' },
    { id = 'quest', label = 'クエスト' },
    { id = 'mission', label = 'ミッション' }
}

-- 初期化
function menu_manager.initialize()
    menu_stack = {}
    current_menu = nil
end

-- メインメニュー取得
function menu_manager.get_main_menu()
    current_menu = {
        title = 'カスタムメニュー',
        items = main_menu_items,
        cursor = 1,
        scroll_pos = 1,
        page_size = 10
    }
    menu_stack = {}
    return current_menu
end

-- カーソル移動
function menu_manager.move_cursor(delta)
    if not current_menu or #current_menu.items == 0 then return end

    current_menu.cursor = current_menu.cursor + delta

    -- ループ処理
    if current_menu.cursor < 1 then
        current_menu.cursor = #current_menu.items
    elseif current_menu.cursor > #current_menu.items then
        current_menu.cursor = 1
    end

    -- スクロール位置調整
    Adjust_Scroll()
end

-- ページアップ
function menu_manager.page_up()
    if not current_menu or #current_menu.items == 0 then return end

    if #current_menu.items <= current_menu.page_size then
        -- スクロールなし: 一番上へ
        current_menu.cursor = 1
        current_menu.scroll_pos = 1
    else
        -- ページ分上へ
        current_menu.cursor = math.max(1, current_menu.cursor - current_menu.page_size)
        Adjust_Scroll()
    end
end

-- ページダウン
function menu_manager.page_down()
    if not current_menu or #current_menu.items == 0 then return end

    if #current_menu.items <= current_menu.page_size then
        -- スクロールなし: 一番下へ
        current_menu.cursor = #current_menu.items
        current_menu.scroll_pos = 1
    else
        -- ページ分下へ
        current_menu.cursor = math.min(#current_menu.items, current_menu.cursor + current_menu.page_size)
        Adjust_Scroll()
    end
end

-- スクロール位置調整
function Adjust_Scroll()
    if not current_menu then return end

    -- カーソルが表示範囲外なら調整
    if current_menu.cursor < current_menu.scroll_pos then
        current_menu.scroll_pos = current_menu.cursor
    elseif current_menu.cursor > current_menu.scroll_pos + current_menu.page_size - 1 then
        current_menu.scroll_pos = current_menu.cursor - current_menu.page_size + 1
    end

    -- スクロール位置の範囲チェック
    local max_scroll = math.max(1, #current_menu.items - current_menu.page_size + 1)
    current_menu.scroll_pos = math.max(1, math.min(current_menu.scroll_pos, max_scroll))
end

-- 選択中のアイテム取得
function menu_manager.get_selected_item()
    if not current_menu or #current_menu.items == 0 then return nil end
    return current_menu.items[current_menu.cursor]
end

-- サブメニュー作成
function menu_manager.create_submenu(data)
    -- 現在のメニューをスタックに追加
    table.insert(menu_stack, current_menu)
    
    -- 新しいメニューを作成
    current_menu = {
        title = data.title or 'サブメニュー',
        items = data.items or {},
        cursor = 1,
        scroll_pos = 1,
        page_size = 10
    }
    
    return current_menu
end

-- 戻れるか
function menu_manager.can_go_back()
    return #menu_stack > 0
end

-- 一つ前に戻る
function menu_manager.go_back()
    if #menu_stack == 0 then return nil end
    
    current_menu = table.remove(menu_stack)
    return current_menu
end

-- 現在のメニュー取得
function menu_manager.get_current_menu()
    return current_menu
end

return menu_manager
