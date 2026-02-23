local messages = require('message')

local menu_definitions = {}

-- アクションタイプの定義
menu_definitions.types = {
    SUBMENU = 'SUBMENU',   -- 定義済みのサブメニューを表示
    FETCH = 'FETCH',       -- APIからデータを取得して表示
    FUNCTION = 'FUNCTION', -- 特定の関数を実行
}

-- メインメニューの項目定義
menu_definitions.main_menu = {
    title = messages.main_menu.title,
    items = {
        { id = 'collection', label = messages.main_menu.items.collection, type = menu_definitions.types.FETCH },
        { id = 'synthesis', label = messages.main_menu.items.synthesis, type = menu_definitions.types.SUBMENU, submenu_id = 'synthesis_menu' },
        { id = 'eminence', label = messages.main_menu.items.eminence, type = menu_definitions.types.FETCH },
        { id = 'quest_items', label = messages.main_menu.items.quest_items, type = menu_definitions.types.FETCH },
        { id = 'contents', label = messages.main_menu.items.contents, type = menu_definitions.types.FETCH },
        { id = 'notice', label = messages.main_menu.items.notice, type = menu_definitions.types.FETCH },
        { id = 'settings', label = messages.main_menu.items.settings, type = menu_definitions.types.FUNCTION, func_name = 'Handle_Settings_Menu' },
    }
}

-- 合成メニューの項目定義
menu_definitions.synthesis_menu = {
    title = messages.synthesis_menu.title,
    items = {
        { 
            id = 'synthesis_storage', 
            label = messages.synthesis_menu.items.storage.label, 
            description = messages.synthesis_menu.items.storage.description,
            type = menu_definitions.types.FUNCTION,
            func_name = 'Handle_Synthesis_Storage'
        },
        { 
            id = 'item_list', 
            label = messages.synthesis_menu.items.item_list.label, 
            description = messages.synthesis_menu.items.item_list.description,
            type = menu_definitions.types.FUNCTION,
            func_name = 'Handle_Item_List_Recipes' -- 今後実装
        },
        { 
            id = 'guild_list', 
            label = messages.synthesis_menu.items.guild_list.label, 
            description = messages.synthesis_menu.items.guild_list.description,
            type = menu_definitions.types.FUNCTION,
            func_name = 'Handle_Guild_List_Selection'
        },
    }
}

-- メニューIDから定義を取得するヘルパー関数
function menu_definitions.get_menu_by_id(id)
    return menu_definitions[id]
end

return menu_definitions
