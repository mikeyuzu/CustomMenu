local messages = {
    menu_title = 'カスタムメニュー',
    notification_text = 'カスタムメニュー',
    notification_with_icon = 'カスタムメニュー ${icon|!}',

    main_menu = {
        title = 'カスタムメニュー',
        items = {
            collection = '図鑑',
            synthesis = '合成',
            eminence = 'エミネンス・レコード',
            quest_items = 'クエストアイテム',
            contents = 'コンテンツ',
            notice = 'お知らせ',
            settings = '設定',
        }
    },

    collection_menu = {
        title = '図鑑進行度',
        items = {
            mission = 'ミッション図鑑',
            quest = 'クエスト図鑑',
            item = 'アイテム図鑑',
            monster = 'モンスター図鑑',
            magic = '魔法図鑑',
            ws = 'WS図鑑',
        }
    },

    magic_menu = {
        title = '魔法図鑑',
        items = {
            white = '白魔法',
            black = '黒魔法',
            song = '歌',
            ninjutsu = '忍術',
            summoning = '召喚魔法',
            blue = '青魔法',
            geomancy = '風水魔法',
            trust = 'フェイス',
        }
    },

    item_book = {
        category = {
            '武器', '防具', 'その他装備', '魔法スクロール', '薬品', '調度品', '素材', '食品', 'クリスタル', 'その他',
        },
        weapon_list = {
            '格闘', '短剣', '片手剣', '両手剣', '片手斧', '両手斧', '両手鎌', '両手槍', '片手刀', '両手刀',
            '片手棍', '両手棍', '弓術', '射撃', '投擲', '弦楽器', '管楽器', '風水鈴', '矢', '弾',
        },
        defense_list = {
            '盾', '頭', '胴', '両手', '両脚', '両足', '首', '腰', '背', '耳', '指',
        },
        other_equipment_list = {
            'ストリンガー', 'グリップ', '補助装備', '釣り竿', '釣り餌', '獣呼び出しアイテム', 'ペットフード', 'からくり回復アイテム', '撮影機',
        },
        magic_list = {
            '白魔法', '黒魔法', '歌', '忍術', '召喚魔法', 'ダイス', '風水魔法', 'フェイス',
        },
        material_list = {
            '金属材', '貴金属材', '布材', '皮革材', '骨材', '木材', '錬金術材', '錬金術材2',
        },
        food_list = {
            '肉・卵料理', '魚介料理', '野菜料理', 'スープ類', '穀物料理', 'スィーツ', 'ドリンク', '食材', '水産物',
        },
        other_list = {
            '雑貨1', '雑貨2', '雑貨3', '雑貨4', '矢・弾', '獣人製品', 'カード', '忍具', '呪物', 'からくり部品', 'チョコボの餌', '強化アイテム',
        },
        level_list_99 = {
            'レベル1-10', 'レベル11-20', 'レベル21-30', 'レベル31-40', 'レベル41-50', 'レベル51-60', 'レベル61-70', 'レベル71-80', 'レベル81-90', 'レベル91-99',
        },
        level_list_119 = {
            'レベル1-10', 'レベル11-20', 'レベル21-30', 'レベル31-40', 'レベル41-50', 'レベル51-60', 'レベル61-70', 'レベル71-80', 'レベル81-90', 'レベル91-100', 'レベル101-110', 'レベル111-118', 'レベル119',
        }
    },

    guild_recipes_menu = {
        completed = 'クリア済み',
        in_progress = '進行中',
        not_started = '未受託',
        unknown = '？？？',
    },

    eminence_status = {
        not_achieved = '未達成',
        achieved = '達成',
        reward_received = '報酬受取済み',
    },

    eminence_menu = {
        title = 'エミネンス・レコード',
        categories = {
            mission = 'ミッション',
            area = 'エリア',
            face = 'フェイス',
        },
        confirm_receive = '「%s」を受け取りますか？',
        receive_success_delivery = '報酬を受け取りました。\nポストから受け取ってください。',
        receive_success_key_item = '報酬を受け取りました。\nエリア移動後に反映されます。',
        receive_success_magic = '報酬を受け取りました。\nエリア移動後に反映されます。',
    },

    synthesis_menu = {
        title = '合成',
        items = {
            storage = {
                label = '合成倉庫',
                description = '合成倉庫はモンスターやショップから合成素材を入手した時に自動的に格納される倉庫です\n格納した素材が合成に可能な数になった時、合成レシピが開放されます\n開放された合成レシピから合成が可能になります\n\n合成に失敗はありません\nNQ合成は素材があれば可能です\nHQ合成にはその合成アイテムに必要なスキルが必要になります\nHQ2には+5、HQ3には+10が必要になります\n\n合成したアイテムはポストに届きます\n\n合成倉庫からマイバックに取り出したい時は、その項目を選んで取り出してください\n取り出したアイテムはポストに届きます\n\n取り出した素材を再び合成倉庫に移動させたい場合は\nポスト以外からマイバックへ移動する操作で自動判別されて合成倉庫に移動します\n例えばモグケースからマイバックへ移動など',
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
        recipe_open = 'エンターで解放する',
        recipe_opened = '「%s」のレシピを解放しました',
        recipe_not_open = '素材を揃えて解放しよう',
        run_synthesis = 'エンターで合成する',
        not_infomation = '説明無し',
        other_skill = 'スキル不明',
        synthesis_item = '【完成品】',
        elemental_item = '【素材】',
        confirm_removal = '%sを取り出しますか？',
        quantity_change = '個数 %d/%d (上下で変更)',
        dialog_get_item = '取り出す',
        dialog_cancel = 'キャンセル',
        confirm_synthesis = '%sを合成しますか？',
        synthesis_success_material_storage = '%sを合成しました\n素材倉庫に格納されました。\n\n%s Lv%dになりました。',
        synthesis_success_post = '%sを合成しました\nポストから受け取ってください。\n\n%s Lv%dになりました。',
        error = {
            materials_missing = '素材が足りません。',
            skill_insufficient = '合成スキルが足りません。',
            skill_insufficient_hq1 = 'HQ1を合成するにはスキルが足りません。',
            skill_insufficient_hq2 = 'HQ2を合成するにはスキルを満たしてさらに+5以上のスキルが必要です。',
            skill_insufficient_hq3 = 'HQ3を合成するにはスキルを満たしてさらに+10以上のスキルが必要です。',
        },
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
    yes_button = 'はい',
    no_button = 'いいえ',
}

return messages
