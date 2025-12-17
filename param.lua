local param = {}

local state = {
    has_notification = false,
    current_menu = nil,
    menu_open = false,
    input_blocked = false,
    input_delay_frames = 0,
    synergy_inventory_cache = nil, -- 新しいキャッシュ用
    chara_id = nil, -- charaId用
    dialog_open = false, -- ダイアログが開いているか
    dialog_item = nil,   -- ダイアログで扱うアイテム情報
    dialog_withdraw_quantity = 0, -- ダイアログで選択されている引き出し数
    dialog_selected_button = 'cancel', -- ダイアログで選択されているボタン ('cancel' or 'withdraw')
    dialog_needs_redraw = false, -- ダイアログの再描画が必要か
    success_dialog_open = false -- 完了ダイアログが開いているか
}

function param.get_has_notification()
    return state.has_notification
end
function param.get_success_dialog_open()
    return state.success_dialog_open
end

function param.set_success_dialog_open(open)
    state.success_dialog_open = open
end

function param.set_has_notification(has_notification)
    state.has_notification = has_notification
end

function param.get_current_menu()
    return state.current_menu
end

function param.set_current_menu(current_menu)
    state.current_menu = current_menu
end

function param.get_menu_open()
    return state.menu_open
end

function param.set_menu_open(menu_open)
    state.menu_open = menu_open
end

function param.get_input_blocked()
    return state.input_blocked
end

function param.set_input_blocked(input_blocked)
    state.input_blocked = input_blocked
end

function param.get_input_delay_frames()
    return state.input_delay_frames
end

function param.set_input_delay_frames(frames)
    state.input_delay_frames = frames
end

-- 新しいGetter/Setter
function param.get_synergy_inventory_cache()
    return state.synergy_inventory_cache
end

function param.set_synergy_inventory_cache(cache)
    state.synergy_inventory_cache = cache
end

function param.get_chara_id()
    return state.chara_id
end

function param.set_chara_id(id)
    state.chara_id = id
end

-- ダイアログ関連のGetter/Setter
function param.get_dialog_open()
    return state.dialog_open
end

function param.set_dialog_open(open)
    state.dialog_open = open
end

function param.get_dialog_item()
    return state.dialog_item
end

function param.set_dialog_item(item)
    state.dialog_item = item
end

function param.get_dialog_withdraw_quantity()
    return state.dialog_withdraw_quantity
end

function param.set_dialog_withdraw_quantity(quantity)
    state.dialog_withdraw_quantity = quantity
end

function param.get_dialog_selected_button()
    return state.dialog_selected_button
end

function param.set_dialog_selected_button(button)
    state.dialog_selected_button = button
end

param.auction_house_ids = {
    NONE = 0,
    H2H = 1,
    DAGGER = 2,
    SWORD = 3,
    GREATSWORD = 4,
    AXE = 5,
    GREATAXE = 6,
    SCYTHE = 7,
    POLEARM = 8,
    KATANA = 9,
    GREATKATANA = 10,
    CLUB = 11,
    STAFF = 12,
    BOW = 13,
    INSTRUMENTS = 14,
    AMMUNITION = 15,
    SHIELD = 16,
    HEAD = 17,
    BODY = 18,
    HANDS = 19,
    LEGS = 20,
    FEET = 21,
    NECK = 22,
    WAIST = 23,
    EARRINGS = 24,
    RINGS = 25,
    BACK = 26,
    UNUSED = 27,
    WHITE_MAGIC = 28,
    BLACK_MAGIC = 29,
    SUMMONING = 30,
    NINJUTSU = 31,
    SONGS = 32,
    MEDICINES = 33,
    FURNISHINGS = 34,
    CRYSTALS = 35,
    CARDS = 36,
    CURSED_ITEMS = 37,
    SMITHING = 38,
    GOLDSMITHING = 39,
    CLOTHCRAFT = 40,
    LEATHERCRAFT = 41,
    BONECRAFT = 42,
    WOODWORKING = 43,
    ALCHEMY = 44,
    GEOMANCER = 45,
    MISC = 46,
    FISHING_GEAR = 47,
    PET_ITEMS = 48,
    NINJA_TOOLS = 49,
    BEAST_MADE = 50,
    FISH = 51,
    MEAT_EGGS = 52,
    SEAFOOD = 53,
    VEGETABLES = 54,
    SOUPS = 55,
    BREADS_RICE = 56,
    SWEETS = 57,
    DRINKS = 58,
    INGREDIENTS = 59,
    DICE = 60,
    AUTOMATON = 61,
    GRIPS = 62,
    ALCHEMY_2 = 63,
    MISC_2 = 64,
    MISC_3 = 65,

    INVALID = 255
}

return param
