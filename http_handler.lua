local socket = require('socket')
local http_handler = {}

-- HTTP通信設定
local config = {
    base_url = 'http://localhost:8080/api',  -- 実際のAPIサーバーURLに変更
    timeout = 5
}

-- メニューデータ取得
function http_handler.fetch_menu_data(menu_id, callback)
    -- 非同期処理のシミュレーション
    -- 実際の実装では coroutine や socket.http.request を使用

    coroutine.wrap(function()
        local success, data = http_handler.request_menu(menu_id)

        -- コールバックをメインスレッドで実行
        coroutine.schedule(function()
            callback(success, data)
        end, 0.1)
    end)()
end

-- HTTP リクエスト実行
function http_handler.request_menu(menu_id)
    -- ここに実際のHTTP通信を実装
    -- 例: socket.http.request を使用

    -- デバッグ用: ダミーデータを返す
    local dummy_data = http_handler.get_dummy_data(menu_id)

    -- 遅延をシミュレート
    socket.sleep(0.5)

    if dummy_data then
        return true, dummy_data
    else
        return false, nil
    end
end

-- ダミーデータ生成 (開発・テスト用)
function http_handler.get_dummy_data(menu_id)
    local data_map = {
        eminence = {
            title = 'エミネンス・レコード',
            items = {
                { id = 'eminence_daily', label = 'デイリー目標' },
                { id = 'eminence_combat', label = '戦闘目標' },
                { id = 'eminence_crafting', label = '生産目標' },
                { id = 'eminence_gathering', label = '採集目標' }
            }
        },
        synthesis = {
            title = '合成',
            items = {
                { id = 'synth_alchemy', label = '錬金術' },
                { id = 'synth_cooking', label = '調理' },
                { id = 'synth_smithing', label = '鍛冶' },
                { id = 'synth_goldsmithing', label = '彫金' },
                { id = 'synth_clothcraft', label = '裁縫' },
                { id = 'synth_leathercraft', label = '革細工' },
                { id = 'synth_woodworking', label = '木工' },
                { id = 'synth_bonecraft', label = '骨細工' }
            }
        },
        collection = {
            title = '図鑑',
            items = {
                { id = 'collection_monsters', label = 'モンスター図鑑' },
                { id = 'collection_items', label = 'アイテム図鑑' },
                { id = 'collection_equipment', label = '装備図鑑' },
                { id = 'collection_areas', label = 'エリア図鑑' }
            }
        },
        quest = {
            title = 'クエスト',
            items = {
                { id = 'quest_sandoria', label = 'サンドリア' },
                { id = 'quest_bastok', label = 'バストゥーク' },
                { id = 'quest_windurst', label = 'ウィンダス' },
                { id = 'quest_jeuno', label = 'ジュノ' },
                { id = 'quest_other', label = 'その他' }
            }
        },
        mission = {
            title = 'ミッション',
            items = {
                { id = 'mission_sandoria', label = 'サンドリア' },
                { id = 'mission_bastok', label = 'バストゥーク' },
                { id = 'mission_windurst', label = 'ウィンダス' },
                { id = 'mission_zilart', label = 'ジラート' },
                { id = 'mission_promathia', label = 'プロマシア' }
            }
        }
    }

    return data_map[menu_id]
end

-- カスタムHTTPリクエスト実装例
-- 実際に使用する場合はこちらを拡張
function http_handler.custom_request(url, method, headers, body)
    local http = require('socket.http')
    local ltn12 = require('ltn12')

    local response_body = {}

    local res, code, response_headers = http.request({
        url = url,
        method = method or 'GET',
        headers = headers or {},
        source = body and ltn12.source.string(body) or nil,
        sink = ltn12.sink.table(response_body)
    })

    if code == 200 then
        local json = require('json')
        local data = json.decode(table.concat(response_body))
        return true, data
    else
        return false, nil
    end
end

return http_handler
