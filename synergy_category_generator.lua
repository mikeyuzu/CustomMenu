local synergy_category_generator = {}
local messages = require('message')

-- C#のAuctionHouseIdとAuctionHouseKindのマッピングを模倣
local auction_house_kind_map = {
    -- 武器
    [1] = 'WEAPON', -- H2H
    [2] = 'WEAPON', -- DAGGER
    [3] = 'WEAPON', -- SWORD
    [4] = 'WEAPON', -- GREATSWORD
    [5] = 'WEAPON', -- AXE
    [6] = 'WEAPON', -- GREATAXE
    [7] = 'WEAPON', -- SCYTHE
    [8] = 'WEAPON', -- POLEARM
    [9] = 'WEAPON', -- KATANA
    [10] = 'WEAPON', -- GREATKATANA
    [11] = 'WEAPON', -- CLUB
    [12] = 'WEAPON', -- STAFF
    [13] = 'WEAPON', -- BOW
    [14] = 'WEAPON', -- INSTRUMENTS
    [15] = 'WEAPON', -- AMMUNITION
    [16] = 'WEAPON', -- FISHING_GEAR
    [17] = 'WEAPON', -- PET_ITEMS
    [18] = 'WEAPON', -- GRIPS
    -- 防具
    [19] = 'DEFENSE', -- SHIELD
    [20] = 'DEFENSE', -- HEAD
    [21] = 'DEFENSE', -- BODY
    [22] = 'DEFENSE', -- HANDS
    [23] = 'DEFENSE', -- LEGS
    [24] = 'DEFENSE', -- FEET
    [25] = 'DEFENSE', -- NECK
    [26] = 'DEFENSE', -- WAIST
    [27] = 'DEFENSE', -- EARRINGS
    [28] = 'DEFENSE', -- RINGS
    [223] = 'DEFENSE', -- BACK (AuctionHouseId 223 for BACK based on common FFXI data)
    -- 魔法
    [29] = 'MAGIC', -- WHITE_MAGIC
    [30] = 'MAGIC', -- BLACK_MAGIC
    [31] = 'MAGIC', -- SUMMONING
    [32] = 'MAGIC', -- NINJUTSU
    [33] = 'MAGIC', -- SONGS
    [34] = 'MAGIC', -- DICE
    [35] = 'MAGIC', -- GEOMANCER
    -- 薬品
    [36] = 'MEDICINES',
    -- 調度品
    [37] = 'FURNISHINGS',
    -- 素材
    [38] = 'MATERIALS', -- SMITHING
    [39] = 'MATERIALS', -- GOLDSMITHING
    [40] = 'MATERIALS', -- CLOTHCRAFT
    [41] = 'MATERIALS', -- LEATHERCRAFT
    [42] = 'MATERIALS', -- BONECRAFT
    [43] = 'MATERIALS', -- WOODWORKING
    [44] = 'MATERIALS', -- ALCHEMY
    [45] = 'MATERIALS', -- ALCHEMY_2
    -- 食品
    [46] = 'FOOD', -- FISH
    [47] = 'FOOD', -- MEAT_EGGS
    [48] = 'FOOD', -- SEAFOOD
    [49] = 'FOOD', -- VEGETABLES
    [50] = 'FOOD', -- SOUPS
    [51] = 'FOOD', -- BREADS_RICE
    [52] = 'FOOD', -- SWEETS
    [53] = 'FOOD', -- DRINKS
    [54] = 'FOOD', -- INGREDIENTS
    -- クリスタル
    [55] = 'CRYSTAL',
    -- その他
    [56] = 'OTHER', -- CARDS
    [57] = 'OTHER', -- CURSED_ITEMS
    [58] = 'OTHER', -- MISC
    [59] = 'OTHER', -- NINJA_TOOLS
    [60] = 'OTHER', -- BEAST_MADE
    [61] = 'OTHER', -- AUTOMATON
    [62] = 'OTHER', -- MISC_2
    [63] = 'OTHER', -- MISC_3
}

-- AuctionHouseKindの日本語ラベルマップ (順序を保証するため配列形式に)
local ordered_auction_house_kinds = {
    {kind = 'WEAPON', label = '武器'},
    {kind = 'DEFENSE', label = '防具'},
    {kind = 'MAGIC', label = '魔法'},
    {kind = 'MEDICINES', label = '薬品'},
    {kind = 'FURNISHINGS', label = '調度品'},
    {kind = 'MATERIALS', label = '素材'},
    {kind = 'FOOD', label = '食品'},
    {kind = 'CRYSTAL', label = 'クリスタル'},
    {kind = 'OTHER', label = 'その他'},
}

function synergy_category_generator.generate_menu_data(synergy_inventory_items)
    local active_categories = {} -- Use a table as a set to track active categories
    local menu_items = {}

    if not synergy_inventory_items or #synergy_inventory_items == 0 then
        return {
            title = messages.synthesis_menu.title,
            items = {},
            empty_message = messages.synthesis_menu.empty_storage_message
        }
    end

    for _, item in ipairs(synergy_inventory_items) do
        local auction_house_kind = auction_house_kind_map[item.auctionHouseId]
        if auction_house_kind then
            active_categories[auction_house_kind] = true
        end
    end

    -- ordered_auction_house_kinds で定義されたカテゴリの順序を維持します
    for _, category_entry in ipairs(ordered_auction_house_kinds) do
        local kind = category_entry.kind
        local label = category_entry.label
        if active_categories[kind] then
            table.insert(menu_items, {
                id = 'synergy_category_' .. string.lower(kind),
                label = label,
                description = string.format(messages.synthesis_menu.category_description, label)
            })
        end
    end

    return {
        title = messages.synthesis_menu.title,
        items = menu_items
    }
end

return synergy_category_generator
