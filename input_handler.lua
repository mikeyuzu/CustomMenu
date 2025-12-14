local input_handler = {}

-- キーコード定義 (DIK codes)
local keys = {
    UP = 0xC8,
    DOWN = 0xD0,
    LEFT = 0xCB,
    RIGHT = 0xCD,
    ENTER = 0x1C,
    NUMPAD_ENTER = 0x9C,
    ESCAPE = 0x01,
    MENU = 0x4A  -- - キー (メニュー表示用)
}

-- 入力ブロック状態
local input_blocked = false

-- キー処理
function input_handler.process_key(dik)
    if dik == keys.UP then
        return 'up'
    elseif dik == keys.DOWN then
        return 'down'
    elseif dik == keys.LEFT then
        return 'left'
    elseif dik == keys.RIGHT then
        return 'right'
    elseif dik == keys.ENTER or dik == keys.NUMPAD_ENTER then
        return 'confirm'
    elseif dik == keys.ESCAPE then
        return 'cancel'
    elseif dik == keys.MENU then
        return 'menu'
    end

    return nil
end

-- ゲーム入力をブロック
function input_handler.block_game_input()
    input_blocked = true
end

-- ゲーム入力のブロック解除
function input_handler.unblock_game_input()
    input_blocked = false
end

-- ブロック状態取得
function input_handler.is_blocked()
    return input_blocked
end

return input_handler
