# CustomMenu - FF11 Windower アドオン

カスタマイズ可能なメニューシステムを提供するWindowerアドオンです。

## ファイル構成

```
CustomMenu/
├── CustomMenu.lua          # メインファイル
├── ui.lua                  # UI表示管理
├── menu_manager.lua        # メニュー状態管理
├── input_handler.lua       # キー入力処理
├── http_handler.lua        # HTTP通信処理
├── settings.lua            # 設定管理
└── README.md              # このファイル
```

## インストール

1. `Windower4/addons/CustomMenu/` フォルダを作成
2. すべてのファイルをそのフォルダに配置
3. ゲーム内で `//lua load CustomMenu` を実行

## 使い方

### 基本コマンド

- `//cmenu open` - メニューを開く
- `//cmenu close` - メニューを閉じる
- `//cmenu notify` - 通知表示を切り替え(デバッグ用)

### キー操作

メニューが開いている時:

- **↑/↓キー** - カーソル移動(1つずつ、ループ)
- **←/→キー** - ページスクロール or 先頭/末尾へジャンプ
- **Enter** - 決定(サブメニューへ遷移)
- **Escape** - キャンセル(前のメニューに戻る)
- **Alt** - メニューを閉じる

### メニュー構造

初期メニュー:
1. エミネンス・レコード
2. 合成
3. 図鑑
4. クエスト
5. ミッション

各項目を選択すると、HTTPリクエストでサブメニューデータを取得します。

## カスタマイズ

### HTTP APIエンドポイント

`http_handler.lua` の `config.base_url` を実際のAPIサーバーURLに変更してください。

```lua
local config = {
    base_url = 'http://your-api-server.com/api',
    timeout = 5
}
```

### APIレスポンス形式

各メニューIDに対して、以下の形式のJSONを返す必要があります:

```json
{
  "title": "サブメニュータイトル",
  "items": [
    { "id": "item1", "label": "項目1" },
    { "id": "item2", "label": "項目2" }
  ]
}
```

### メニュー処理の拡張

サブメニューで特定の処理を実行したい場合は、`CustomMenu.lua` の `handle_confirm()` 関数を拡張してください。

例:
```lua
function handle_confirm()
    local selected = menu_manager.get_selected_item()
    
    -- カスタム処理の例
    if selected.id == 'special_action' then
        -- 特別な処理を実行
        do_special_action()
        return
    end
    
    -- 通常のHTTP通信処理
    http_handler.fetch_menu_data(selected.id, function(success, data)
        -- ...
    end)
end
```

### UI位置調整

`settings.lua` の設定を変更することで、表示位置を調整できます:

```lua
ui = {
    indicator_x = -200,  -- 初期メニュー表示のX位置(右端からの相対)
    indicator_y = -100,  -- 初期メニュー表示のY位置(下端からの相対)
    menu_x = -400,       -- メニューリストのX位置(右端からの相対)
    menu_y = 100,        -- メニューリストのY位置(上端からの)
    page_size = 10,      -- 1ページあたりの表示項目数
}
```

## 開発者向け

### デバッグモード

現在は `http_handler.lua` でダミーデータを返すようになっています。
実際のHTTP通信を実装する場合は、`request_menu()` 関数を書き換えてください。

### 入力ブロック機能

メニューを開いている間、ゲーム側への入力は完全にブロックされます。
初期カスタムメニュー(カスタムメニューインジケーター)のみが表示されている状態では、
コマンド入力のみを受け付け、ゲーム操作は通常通り可能です。

## トラブルシューティング

- メニューが表示されない → `/echo` コマンドでログを確認
- キー入力が効かない → Windowerのキーバインドと競合していないか確認
- HTTP通信エラー → `http_handler.lua` のURLとタイムアウト設定を確認

## ライセンス

このアドオンは自由に改変・再配布可能です。