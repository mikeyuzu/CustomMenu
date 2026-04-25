local synergy_category_generator = {}
local messages = require('message')
local param = require('param') -- paramモジュールを読み込む

-- 新しい階層的なカテゴリ定義
local category_definitions = {
    main = {
        {id = 'WEAPON_MENU', label = '武器', children = {
            {id = param.auction_house_ids.H2H, label = '格闘武器'},
            {id = param.auction_house_ids.DAGGER, label = '短剣'},
            {id = param.auction_house_ids.SWORD, label = '片手剣'},
            {id = param.auction_house_ids.GREATSWORD, label = '両手剣'},
            {id = param.auction_house_ids.AXE, label = '片手斧'},
            {id = param.auction_house_ids.GREATAXE, label = '両手斧'},
            {id = param.auction_house_ids.SCYTHE, label = '両手鎌'},
            {id = param.auction_house_ids.POLEARM, label = '両手槍'},
            {id = param.auction_house_ids.KATANA, label = '片手刀'},
            {id = param.auction_house_ids.GREATKATANA, label = '両手刀'},
            {id = param.auction_house_ids.CLUB, label = '片手棍'},
            {id = param.auction_house_ids.STAFF, label = '両手棍'},
            {id = param.auction_house_ids.BOW, label = 'レンジ武器等'},
            {id = param.auction_house_ids.INSTRUMENTS, label = '楽器'},
            {id = 'RANGE_WEAPON_MENU', label = '矢・弾その他', children = {
                {id = param.auction_house_ids.AMMUNITION, label = '矢・弾'},
                {id = param.auction_house_ids.FISHING_GEAR, label = '釣り具'},
                {id = param.auction_house_ids.PET_ITEMS, label = '獣の餌'},
                {id = param.auction_house_ids.GRIPS, label = 'グリップ'},
            }},
        }},
        {id = 'DEFENSE_MENU', label = '防具', children = {
            {id = param.auction_house_ids.SHIELD, label = '盾'},
            {id = param.auction_house_ids.HEAD, label = '頭'},
            {id = param.auction_house_ids.BODY, label = '胴'},
            {id = param.auction_house_ids.HANDS, label = '両手'},
            {id = param.auction_house_ids.LEGS, label = '両脚'},
            {id = param.auction_house_ids.FEET, label = '両足'},
            {id = param.auction_house_ids.NECK, label = '首'},
            {id = param.auction_house_ids.WAIST, label = '腰'},
            {id = param.auction_house_ids.EARRINGS, label = '耳'},
            {id = param.auction_house_ids.RINGS, label = '指'},
            {id = param.auction_house_ids.BACK, label = '背'},
        }},
        {id = 'MAGIC_SCROLL_MENU', label = '魔法スクロール', children = {
            {id = param.auction_house_ids.WHITE_MAGIC, label = '白魔法'},
            {id = param.auction_house_ids.BLACK_MAGIC, label = '黒魔法'},
            {id = param.auction_house_ids.SUMMONING, label = '召喚魔法'},
            {id = param.auction_house_ids.NINJUTSU, label = '忍術'},
            {id = param.auction_house_ids.SONGS, label = '歌'},
            {id = param.auction_house_ids.GEOMANCER, label = '風水魔法'},
            {id = param.auction_house_ids.DICE, label = 'ダイス'},
        }},
        {id = param.auction_house_ids.MEDICINES, label = '薬品'},
        {id = param.auction_house_ids.FURNISHINGS, label = '調度品'},
        {id = 'MATERIAL_MENU', label = '素材', children = {
            {id = param.auction_house_ids.SMITHING, label = '金属材'},
            {id = param.auction_house_ids.GOLDSMITHING, label = '貴金属材'},
            {id = param.auction_house_ids.CLOTHCRAFT, label = '布材'},
            {id = param.auction_house_ids.LEATHERCRAFT, label = '皮革材'},
            {id = param.auction_house_ids.BONECRAFT, label = '骨材'},
            {id = param.auction_house_ids.WOODWORKING, label = '木材'},
            {id = param.auction_house_ids.ALCHEMY, label = '錬金術材'},
            {id = param.auction_house_ids.ALCHEMY_2, label = '錬金術材2'},
        }},
        {id = 'FOOD_MENU', label = '食品', children = {
            {id = 'COOKING_MENU', label = '料理', children = {
                {id = param.auction_house_ids.MEAT_EGGS, label = '肉・卵料理'},
                {id = param.auction_house_ids.SEAFOOD, label = '魚介料理'},
                {id = param.auction_house_ids.VEGETABLES, label = '野菜料理'},
                {id = param.auction_house_ids.SOUPS, label = 'スープ類'},
                {id = param.auction_house_ids.BREADS_RICE, label = '穀物料理'},
                {id = param.auction_house_ids.SWEETS, label = 'スィーツ'},
                {id = param.auction_house_ids.DRINKS, label = 'ドリンク'},
            }},
            {id = param.auction_house_ids.INGREDIENTS, label = '食材'},
            {id = param.auction_house_ids.FISH, label = '水産物'},
        }},
        {id = param.auction_house_ids.CRYSTALS, label = 'クリスタル'},
        {id = 'OTHER_MENU', label = 'その他', children = {
            {id = param.auction_house_ids.MISC, label = '雑貨'},
            {id = param.auction_house_ids.MISC_2, label = '雑貨2'},
            {id = param.auction_house_ids.MISC_3, label = '雑貨3'},
            {id = param.auction_house_ids.BEAST_MADE, label = '獣人製品'},
            {id = param.auction_house_ids.CARDS, label = 'カード'},
            {id = param.auction_house_ids.NINJA_TOOLS, label = '忍具'},
            {id = param.auction_house_ids.CURSED_ITEMS, label = '呪物'},
            {id = param.auction_house_ids.AUTOMATON, label = 'からくり部品'},
        }},
    }
}

-- レベル帯の定義
local level_ranges_full = {
    { label = 'Lv1～10', min = 1, max = 10 },
    { label = 'Lv11～20', min = 11, max = 20 },
    { label = 'Lv21～30', min = 21, max = 30 },
    { label = 'Lv31～40', min = 31, max = 40 },
    { label = 'Lv41～50', min = 41, max = 50 },
    { label = 'Lv51～60', min = 51, max = 60 },
    { label = 'Lv61～70', min = 61, max = 70 },
    { label = 'Lv71～80', min = 71, max = 80 },
    { label = 'Lv81～90', min = 81, max = 90 },
    { label = 'Lv91～99', min = 91, max = 99 },
    { label = 'ILv100～109', min = 100, max = 109 },
    { label = 'ILv110～119', min = 110, max = 119 },
}

local level_ranges_to_99 = {
    { label = 'Lv1～10', min = 1, max = 10 },
    { label = 'Lv11～20', min = 11, max = 20 },
    { label = 'Lv21～30', min = 21, max = 30 },
    { label = 'Lv31～40', min = 31, max = 40 },
    { label = 'Lv41～50', min = 41, max = 50 },
    { label = 'Lv51～60', min = 51, max = 60 },
    { label = 'Lv61～70', min = 61, max = 70 },
    { label = 'Lv71～80', min = 71, max = 80 },
    { label = 'Lv81～90', min = 81, max = 90 },
    { label = 'Lv91～99', min = 91, max = 99 },
}

-- アイテムリストに含まれるAuctionHouseIdのセットを作成
local function get_active_auction_house_ids(synergy_inventory_items)
    local active_ids = {}
    if synergy_inventory_items then
        for _, item in ipairs(synergy_inventory_items) do
            active_ids[item.auctionHouseId] = true
        end
    end
    return active_ids
end

-- 指定されたカテゴリまたはそのサブカテゴリにアクティブなAuctionHouseIdが含まれているか再帰的にチェックする
local function has_active_items_in_category(category_node, active_auction_house_ids)
    if category_node.children then
        -- 子カテゴリがある場合、子を再帰的にチェック
        for _, child in ipairs(category_node.children) do
            if has_active_items_in_category(child, active_auction_house_ids) then
                return true
            end
        end
    elseif type(category_node.id) == 'number' then
        -- AuctionHouseIdが直接指定されている場合（リーフノード）、それがアクティブかチェック
        return active_auction_house_ids[category_node.id]
    end
    return false
end

function synergy_category_generator.generate_menu_data(synergy_inventory_items, current_menu_id)
    local menu_to_generate = category_definitions.main
    local title = messages.synthesis_menu.title

    if current_menu_id and current_menu_id ~= 'main' then
        -- 現在のメニューIDに基づいて、category_definitions内の適切な子メニューを見つける
        local function find_menu_node(nodes, target_id)
            for _, node in ipairs(nodes) do
                if tostring(node.id) == tostring(target_id) then
                    return node
                elseif node.children then
                    local found = find_menu_node(node.children, target_id)
                    if found then
                        return found
                    end
                end
            end
            return nil
        end
        local found_node = find_menu_node(category_definitions.main, current_menu_id)
        if found_node then
            if found_node.children then
                menu_to_generate = found_node.children
                title = found_node.label
            else
                -- 子要素がない（リーフノード）の場合は、空のアイテムリストを返す
                -- これにより、呼び出し元で Handle_Generic_Fetch に移行する
                return {
                    title = found_node.label,
                    items = {},
                    id = current_menu_id,
                    is_leaf = true
                }
            end
        else
            -- 見つからない場合はメインメニューに戻るか、エラー処理
            if not tonumber(current_menu_id) and not tostring(current_menu_id):find('ITEM_RECIPE_LEVEL_') then
                print(string.format("Warning: Menu ID '%s' not found, defaulting to main.", current_menu_id))
            end
            menu_to_generate = category_definitions.main
            title = messages.synthesis_menu.title
        end
    end

    local active_auction_house_ids = get_active_auction_house_ids(synergy_inventory_items)
    local menu_items = {}

    for _, category_node in ipairs(menu_to_generate) do
        if has_active_items_in_category(category_node, active_auction_house_ids) then
            -- menu_managerが期待する形式に変換
            table.insert(menu_items, {
                id = category_node.id, -- string ID for sub-menus, number for leaf AH IDs
                label = category_node.label,
                description = "" -- 説明は必要に応じて追加
            })
        end
    end

    if #menu_items == 0 then
        return {
            title = title,
            items = {},
            empty_message = messages.synthesis_menu.empty_storage_message
        }
    end

    return {
        title = title,
        items = menu_items
    }
end

-- アイテム別レシピ用のメニュー生成
function synergy_category_generator.generate_item_recipe_menu(current_menu_id)
    local menu_to_generate = nil
    local title = messages.synthesis_menu.items.item_list.label

    -- 1. トップレベル (武器、防具など 7項目に限定)
    if not current_menu_id or current_menu_id == 'ITEM_LIST_RECIPES_ROOT' then
        local target_items = {
            { id = 'WEAPON_MENU', label = '武器' },
            { id = 'DEFENSE_MENU', label = '防具' },
            { id = param.auction_house_ids.MEDICINES, label = '薬品' },
            { id = param.auction_house_ids.FURNISHINGS, label = '調度品' },
            { id = 'MATERIAL_MENU', label = '素材' },
            { id = 'FOOD_MENU', label = '料理' },
            { id = 'OTHER_MENU', label = 'その他' }
        }
        
        local menu_items = {}
        for _, item in ipairs(target_items) do
            table.insert(menu_items, { id = item.id, label = item.label, description = "" })
        end
        
        return {
            title = messages.synthesis_menu.items.item_list.label,
            items = menu_items,
            id = 'ITEM_LIST_RECIPES_ROOT'
        }
    else
        -- 2. カテゴリの探索 (再帰的に全カテゴリから探す)
        local function find_menu_node(nodes, target_id)
            for _, node in ipairs(nodes) do
                if node.id == target_id then
                    return node
                elseif node.children then
                    local found = find_menu_node(node.children, target_id)
                    if found then return found end
                end
            end
            return nil
        end

        local node = find_menu_node(category_definitions.main, current_menu_id)
        if node then
            if node.children then
                -- 中間カテゴリ (例: 武器 -> 格闘武器)
                local children = node.children
                
                -- 追加作業.txt の指定に基づく特殊なフラット化・フィルタリング処理
                if current_menu_id == 'WEAPON_MENU' then
                    -- 武器カテゴリをフラット化 (矢・弾その他 の階層を排除)
                    children = {}
                    for _, child in ipairs(node.children) do
                        if child.id == 'RANGE_WEAPON_MENU' then
                            for _, grand_child in ipairs(child.children) do
                                table.insert(children, grand_child)
                            end
                        else
                            table.insert(children, child)
                        end
                    end
                elseif current_menu_id == 'FOOD_MENU' then
                    -- 料理カテゴリは食材などを除外し、COOKING_MENU (肉・卵料理等) の中身だけを表示
                    for _, child in ipairs(node.children) do
                        if child.id == 'COOKING_MENU' then
                            children = child.children
                            break
                        end
                    end
                elseif current_menu_id == 'OTHER_MENU' then
                    -- その他カテゴリは カード、呪物、雑貨、忍具、からくり部品 を表示
                    local target_other_ids = {
                        [param.auction_house_ids.CARDS] = true,
                        [param.auction_house_ids.CURSED_ITEMS] = true,
                        [param.auction_house_ids.MISC] = true,
                        [param.auction_house_ids.NINJA_TOOLS] = true,
                        [param.auction_house_ids.AUTOMATON] = true
                    }
                    children = {}
                    for _, child in ipairs(node.children) do
                        if target_other_ids[child.id] then
                            table.insert(children, child)
                        end
                    end
                end

                menu_to_generate = children
                title = node.label
            elseif type(node.id) == 'number' then
                -- リーフカテゴリ (詳細カテゴリ)
                local ah_id = node.id
                
                -- レベル帯が必要なカテゴリか判定
                local ranges = nil
                -- 防具のアクセサリ枠 (首、腰、耳、指、背)
                local accessories = {
                    [param.auction_house_ids.NECK] = true,
                    [param.auction_house_ids.WAIST] = true,
                    [param.auction_house_ids.EARRINGS] = true,
                    [param.auction_house_ids.RINGS] = true,
                    [param.auction_house_ids.BACK] = true
                }
                
                -- 武器(1-15)と防具(16-21)はフルセット、アクセサリは99まで、それ以外はレベルなし
                if ah_id >= 1 and ah_id <= 21 then
                    ranges = level_ranges_full
                elseif accessories[ah_id] then
                    ranges = level_ranges_to_99
                end

                if ranges then
                    -- レベル帯を表示
                    local menu_items = {}
                    for _, range in ipairs(ranges) do
                        table.insert(menu_items, {
                            id = string.format('ITEM_RECIPE_LEVEL_%d_%d_%d', ah_id, range.min, range.max),
                            label = range.label,
                            auction_house_id = ah_id,
                            min_level = range.min,
                            max_level = range.max
                        })
                    end
                    return {
                        title = node.label,
                        items = menu_items,
                        id = current_menu_id
                    }
                else
                    -- レベル帯なし: 直接レシピを表示するための擬似的なレベル帯を生成 (0-255)
                    local menu_items = {{
                        id = string.format('ITEM_RECIPE_LEVEL_%d_0_255', ah_id),
                        label = "レシピリストを表示",
                        is_auto_trigger = true -- 自動遷移用フラグ
                    }}
                    return {
                        title = node.label,
                        items = menu_items,
                        id = current_menu_id
                    }
                end
            end
        end
    end

    -- カテゴリリストの生成 (在庫に関わらず全表示)
    local menu_items = {}
    if menu_to_generate then
        for _, category_node in ipairs(menu_to_generate) do
            table.insert(menu_items, {
                id = category_node.id,
                label = category_node.label,
                description = ""
            })
        end
    end

    return {
        title = title,
        items = menu_items,
        id = current_menu_id
    }
end

return synergy_category_generator
