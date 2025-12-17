local messages = {
    menu_title = 'カスタムメニュー',
    notification_text = 'カスタムメニュー',
    notification_with_icon = 'カスタムメニュー ${icon|!}',

    main_menu = {
        title = 'カスタムメニュー',
        items = {
            eminence = 'エミネンス・レコード',
            synthesis = '合成',
            collection = '図鑑',
            quest = 'クエスト',
            mission = 'ミッション',
        }
    },

    synthesis_menu = {
        title = '合成',
        items = {
            storage = {
                label = '合成倉庫',
                description = '合成倉庫はモンスターやショップから合成素材を入手した時に自動的に格納される倉庫です\n格納した素材が合成に可能な数になった時、合成レシピが開放されます\n開放された合成レシピから合成が可能になります\n\n合成に失敗はありません\nHQ合成にはその合成アイテムに必要なスキル+10が必要になります\nHQ2には+20、HQ3には+30が必要になります\n\n合成したアイテムはポストに届きます\n\n合成倉庫からマイバックに取り出したい時は、その項目を選んで取り出してください\n取り出したアイテムはポストに届きます\n\n取り出した素材を再び合成倉庫に移動させたい場合は\nポスト以外からマイバックへ移動する操作で自動判別されて合成倉庫に移動します\n例えばモグケースからマイバックへ移動など',
            },
            item_list = {
                label = 'アイテム別リスト',
                description = 'アイテムの種別（武器、防具など）からレシピを検索します。',
            },
            guild_list = {
                label = 'ギルド別リスト',
                description = 'ギルドを選んでレシピを検索します。',
            }
        },
        empty_storage_message = '合成倉庫にアイテムはありません',
        category_description = '%sカテゴリの合成素材を表示します。',
    },

    command_help = {
        header = 'CustomMenu Commands:',
        open = '  //cmenu open  - メニューを開く',
        close = '  //cmenu close - メニューを閉じる',
        notify = '  //cmenu notify - 通知を切り替え(デバッグ用)',
    },

    retrieval_success = '%sを取り出しました。\nポストから受け取ってください。',
    ok_button = 'OK',
}

return messages
