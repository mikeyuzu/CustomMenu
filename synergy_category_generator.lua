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
                if node.id == target_id and node.children then
                    return node.children, node.label
                elseif node.children then
                    local found_children, found_label = find_menu_node(node.children, target_id)
                    if found_children then
                        return found_children, found_label
                    end
                end
            end
            return nil, nil
        end
        local found_menu, found_label = find_menu_node(category_definitions.main, current_menu_id)
        if found_menu and found_label then
            menu_to_generate = found_menu
            title = found_label
        else
            -- 見つからない場合はメインメニューに戻るか、エラー処理
            print(string.format("Warning: Menu ID '%s' not found, defaulting to main.", current_menu_id))
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

return synergy_category_generator
