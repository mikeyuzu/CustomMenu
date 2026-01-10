local socket = require('socket')
local http = require('socket.http')
local ltn12 = require('ltn12')
local http_handler = {}
local url = require("socket.url")

-- Embedded simple JSON parser starts here
-- Source: https://github.com/rxi/json.lua/blob/master/json.lua (Simplified for decode only)
-- json.lua: A simple JSON parser for Lua.
-- (Removed encode part as it's not needed here)

local json = {}
local pairs = pairs
local tostring = tostring
local type = type
local error = error
local pcall = pcall
local tonumber = tonumber
local string = string
local table = table

local decode

local _M = {}

local parse_value
local parse_object
local parse_array
local parse_string
local parse_number
local parse_literal

local lex

-- Lexer
local escape_map = {
  ['"'] = '"', ['\\'] = '\\', ['/'] = '/', ['b'] = '\b', ['f'] = '\f',
  ['n'] = '\n', ['r'] = '\r', ['t'] = '\t'
}

function lex(str)
  local pos = 1
  local len = #str
  local tokens = {}

  local function advance(n)
    pos = pos + n
  end

  local function consume_whitespace()
    while pos <= len and string.find(" \t\r\n", str:sub(pos, pos), 1, true) do
      advance(1)
    end
  end

  local function next_char()
    return str:sub(pos, pos)
  end

  local function match(pattern)
    local s, e, cap = string.find(str, pattern, pos)
    if s == pos then
      advance(e - s + 1)
      return cap
    end
    return nil
  end

  local function add_token(type, value)
    table.insert(tokens, { type = type, value = value })
  end

  while pos <= len do
    consume_whitespace()
    if pos > len then break end

    local char = next_char()

    if char == '{' then add_token("brace_open", char) advance(1)
    elseif char == '}' then add_token("brace_close", char) advance(1)
    elseif char == '[' then add_token("bracket_open", char) advance(1)
    elseif char == ']' then add_token("bracket_close", char) advance(1)
    elseif char == ':' then add_token("colon", char) advance(1)
    elseif char == ',' then add_token("comma", char) advance(1)
    elseif char == '"' then
      local s = pos
      advance(1) -- consume opening quote
      local str_val = ""
      while pos <= len do
        if next_char() == '\\' then
          advance(1) -- consume backslash
          local esc_char = next_char()
          if escape_map[esc_char] then
            str_val = str_val .. escape_map[esc_char]
            advance(1)
          elseif esc_char == 'u' then
            -- Handle unicode escapes (e.g., \uXXXX)
            local hex = match("u([%x%x%x%x])")
            if hex then
              str_val = str_val .. string.char(tonumber(hex, 16))
            else
              error("Invalid unicode escape sequence")
            end
          else
            error("Invalid escape sequence")
          end
        elseif next_char() == '"' then
          advance(1) -- consume closing quote
          add_token("string", str_val)
          break
        else
          str_val = str_val .. next_char()
          advance(1)
        end
      end
    elseif string.find("+-0123456789", char, 1, true) then
      local num_str = match("(-?%d+%.?%d*[eE]?[+-]?%d*)")
      add_token("number", tonumber(num_str))
    elseif char == 't' and match("true") then add_token("boolean", true)
    elseif char == 'f' and match("false") then add_token("boolean", false)
    elseif char == 'n' and match("nil") then add_token("nil", nil)
    else
      error("Unexpected character: " .. char .. " at position " .. pos)
    end
  end
  return tokens
end

-- Parser
local current_token_index
local tokens

local function peek()
  return tokens[current_token_index]
end

local function consume(type)
  local token = peek()
  if token and token.type == type then
    current_token_index = current_token_index + 1
    return token
  end
  error("Expected " .. type .. ", got " .. (token and token.type or "EOF"))
end

parse_string = function()
  return consume("string").value
end

parse_number = function()
  return consume("number").value
end

parse_literal = function()
  local token = peek()
  if token.type == "boolean" or token.type == "nil" then
    consume(token.type)
    return token.value
  end
  error("Expected boolean or nil literal")
end

parse_array = function()
  local arr = {}
  consume("bracket_open")
  if peek().type ~= "bracket_close" then
    while true do
      table.insert(arr, parse_value())
      if peek().type == "comma" then
        consume("comma")
      else
        break
      end
    end
  end
  consume("bracket_close")
  return arr
end

parse_object = function()
  local obj = {}
  consume("brace_open")
  if peek().type ~= "brace_close" then
    while true do
      local key = parse_string()
      consume("colon")
      obj[key] = parse_value()
      if peek().type == "comma" then
        consume("comma")
      else
        break
      end
    end
  end
  consume("brace_close")
  return obj
end

parse_value = function()
  local token = peek()
  if token.type == "string" then return parse_string()
  elseif token.type == "number" then return parse_number()
  elseif token.type == "boolean" or token.type == "nil" then return parse_literal()
  elseif token.type == "bracket_open" then return parse_array()
  elseif token.type == "brace_open" then return parse_object()
  end
  error("Unexpected token type: " .. token.type)
end

function json.decode(str)
  tokens = lex(str)
  current_token_index = 1
  return parse_value()
end

-- The global json_decode_func will now point to this embedded parser's decode function
local json_decode_func = json.decode

-- HTTP通信設定
local config = {
    base_url = 'http://localhost:5000/api/database', -- すべてのAPIのベースURL
    port = 80,
    timeout = 0.01
}

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

-- メニューデータ取得
function http_handler.fetch_menu_data(menu_id, callback)
    coroutine.wrap(function()
        local success, data, error_message = http_handler.request_menu(menu_id)
        callback(success, data, error_message)
    end)()
end

-- HTTP リクエスト実行 (汎用メニューデータ用)
function http_handler.request_menu(menu_id)
    local request_url = config.base_url .. '/' .. menu_id

    local success, data_string, status_code, error_message = http_handler.custom_request(request_url, 'GET')
    local data = nil

    if success then
        local ok, decoded_data = pcall(json_decode_func, data_string)
        if ok then
            data = decoded_data
        else
            success = false
            error_message = "JSON decode error for menu '" .. menu_id .. "': " .. tostring(decoded_data)
        end
    end
    return success, data, error_message
end

-- ダミーデータ生成 (開発・テスト用) -- request_menuからは呼ばれない
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

-- シナジーインベントリアイテム取得API呼び出し
function http_handler.fetch_synergy_inventory(chara_id, callback)
    local params = { charaId = chara_id }
    local query_string = build_query_string(params)
    local request_url = config.base_url .. '/GetSynergyInventoryItems?' .. query_string

    coroutine.wrap(function()
        local success, data_string, status_code, error_message = http_handler.custom_request(request_url, 'GET')
        local data = nil

        if success then
            local ok, decoded_data = pcall(json_decode_func, data_string)
            if ok then
                data = decoded_data
            else
                success = false
                error_message = "JSON decode error for synergy inventory: " .. tostring(decoded_data)
            end
        end
        callback(success, data, error_message)
    end)()
end

-- シナジーインベントリアイテム削除API呼び出し
function http_handler.remove_synergy_inventory_item(chara_id, item_id, sub_id, usenum, quantity, callback)
    local params = {
        charaId = chara_id,
        itemId = item_id,
        subId = sub_id,
        usenum = usenum,
        quantity = quantity
    }
    local query_string = build_query_string(params)
    local request_url = config.base_url .. '/RemoveSynergyInventoryItem?' .. query_string

    coroutine.wrap(function()
        local success, data_string, status_code, error_message = http_handler.custom_request(request_url, 'GET')
        -- RemoveSynergyInventoryItem APIは成功/失敗のみを返すため、データは期待しない
        -- 成功/失敗メッセージをcallbackに渡す
        local message = nil
        if success then
            message = "アイテムの引き出しに成功しました。"
        else
            message = "アイテムの引き出しに失敗しました: " .. (error_message or "不明なエラー")
        end
        callback(success, message)
    end)()
end

-- 合成レシピ取得API呼び出し
function http_handler.fetch_synthesis_recipes(chara_id, guild_id, rank, callback)
    local params = {
        charaId = chara_id,
        guildId = guild_id,
        rank = rank
    }
    local query_string = build_query_string(params)
    local request_url = config.base_url .. '/GetSynthesisRecipes?' .. query_string

    coroutine.wrap(function()
        local success, data_string, status_code, error_message = http_handler.custom_request(request_url, 'GET')
        local data = nil

        if success then
            local ok, decoded_data = pcall(json_decode_func, data_string)
            if ok then
                data = decoded_data
            else
                success = false
                error_message = "JSON decode error for synthesis recipes: " .. tostring(decoded_data)
            end
        end
        callback(success, data, error_message)
    end)()
end

-- カスタムHTTPリクエスト実装例
-- 実際に使用する場合はこちらを拡張
function http_handler.custom_request(url_str, method, headers, body)
    local http_socket = require('socket.http')
    local ltn12 = require('ltn12')

    local response_body_parts = {}
    local sink = ltn12.sink.table(response_body_parts)

    local res, code, response_headers, status_line = http_socket.request({
        url = url_str,
        method = method or 'GET',
        headers = headers or {},
        source = body and ltn12.source.string(body) or nil,
        sink = sink
    })

    if code == 200 then
        return true, table.concat(response_body_parts), code, nil
    else
        return false, nil, code, status_line or "Unknown error"
    end
end

return http_handler
