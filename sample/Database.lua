local Database = {}

local socket = require('socket')
local http = require('socket.http')
local ltn12 = require('ltn12')
local url = require("socket.url")

local baseURL = "http://localhost:5000/api/database"
local PORT = 80 -- HTTPのデフォルトポート (HTTPSの場合は443と別のライブラリが必要)
local TIMEOUT_SEC = 0.01 -- 各ソケット操作のポーリング間隔 (極めて短く設定)

--- URLのクエリ文字列を組み立てるヘルパー関数
 -- @param params (table) キーと値のペアを持つテーブル
 -- @return (string) "key1=value1&key2=value2" のような形式の文字列
local function build_query_string(params)
    local parts = {}
    for key, value in pairs(params) do
        -- 値をURLエンコードする
        table.insert(parts, key .. "=" .. url.escape(tostring(value)))
    end
    return table.concat(parts, "&")
end

--- ナビゲーションメッセージを取得する
 -- @param params (table) APIが必要とするパラメータを含むテーブル
 -- @return (string, string|nil) 成功時はレスポンスボディ、失敗時はnilとエラーメッセージ
local function get_navi_message(params)
    -- クエリ文字列を組み立てる
    local query_string = build_query_string(params)
    local request_url = baseURL .. "/GetMessage?" .. query_string

    -- APIへGETリクエストを送信
    local response_body = {}
    local res, code, headers, status = http.request({
        url = request_url,
        method = "GET",
        sink = ltn12.sink.table(response_body)
    })

    if code == 200 then
        -- 成功した場合、テーブルに格納されたレスポンスボディを結合して返す
       return table.concat(response_body)
    else
        -- 失敗した場合、ステータスコードとメッセージを返す
        return nil, "Error: " .. (status or "Unknown error") .. " (Code: " .. tostring(code) .. ")"
    end
end

-- 非同期でメッセージを取得する関数
function Database.get_message_async(message_params)
    local message, err = get_navi_message(message_params)

    -- 結果を出力
    if message then
        return message
    else
        return ''
    end
end

return Database
