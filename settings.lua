-- デフォルト設定
local defaults = {
    -- UI設定
    ui = {
        indicator_x = -200,  -- 右端からの相対位置
        indicator_y = -100,  -- 下端からの相対位置
        menu_x = -400,       -- 右端からの相対位置
        menu_y = 100,        -- 上端からの相対位置
        page_size = 10,
        font_size = 12,
        font_name = 'MS Gothic'
    },

    -- HTTP設定
    http = {
        base_url = 'http://localhost:8080/api',
        timeout = 5
    },

    -- キーバインド設定
    keybinds = {
        up = 0xC8,
        down = 0xD0,
        left = 0xCB,
        right = 0xCD,
        confirm = 0x1C,
        cancel = 0x01,
        menu = 0x38
    }
}

-- Windowerの設定システムを利用
local config = require('config')

-- 設定ファイルの読み込み
local settings = config.load(defaults)

-- 設定保存
local function save_settings()
    settings:save()
end

-- 設定値取得
local function get_setting(key)
    local keys = key:split('.')
    local value = settings
    for _, k in ipairs(keys) do
        value = value[k]
        if not value then return nil end
    end
    return value
end

-- 設定値設定
local function set_setting(key, value)
    local keys = key:split('.')
    local target = settings
    for i = 1, #keys - 1 do
        target = target[keys[i]]
        if not target then return false end
    end
    target[keys[#keys]] = value
    save_settings()
    return true
end

-- エクスポート
return {
    get = get_setting,
    set = set_setting,
    save = save_settings,
    defaults = defaults,
    settings = settings
}