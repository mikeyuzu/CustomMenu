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
            },
        },
        guild_recipes = {
            title = 'ギルド別リスト',
            items = {
                { id = 'woodworking', label = '木工レシピ' },
                { id = 'smithing', label = '鍛冶レシピ' },
                { id = 'goldsmithing', label = '彫金レシピ' },
                { id = 'weaving', label = '織工レシピ' },
                { id = 'leathercraft', label = '革工レシピ' },
                { id = 'bonecraft', label = '骨工レシピ' },
                { id = 'alchemy', label = '錬金術レシピ' },
                { id = 'cooking', label = '調理レシピ' },
            }
        },
        rank_list = {
            title = 'ランク選択',
            items = {
                { id = 'neophyte', label = '素人' },
                { id = 'apprentice', label = '見習' },
                { id = 'journeyman', label = '徒弟' },
                { id = 'craftsman', label = '下級職人' },
                { id = 'artisan', label = '名取' },
                { id = 'initiatiate', label = '目録' },
                { id = 'disciple', label = '印可' },
                { id = 'veteran', label = '高弟' },
                { id = 'deku', label = '皆伝' },
                { id = 'master', label = '師範' },
                { id = 'grandmaster', label = '高級職人' },
            }
        },
        empty_storage_message = '合成倉庫にアイテムはありません',
        category_description = '%sカテゴリの合成素材を表示します。',
    },

    synergy_skill = {
        items = {
            { id = 'woodworking', label = '木工' },
            { id = 'smithing', label = '鍛冶' },
            { id = 'goldsmithing', label = '彫金' },
            { id = 'clothcraft', label = '裁縫' },
            { id = 'leathercraft', label = '革細工' },
            { id = 'bonecraft', label = '骨細工' },
            { id = 'alchemy', label = '錬金術' },
            { id = 'cooking', label = '調理' },
        }
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
