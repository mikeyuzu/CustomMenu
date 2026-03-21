local magic_definitions = {}

-- 魔法データの定義フォーマット
-- [魔法ID] = { 
--     name = "魔法名", 
--     description = "概要", 
--     shop = "ショップ販売情報",
--     quest = "クエスト報酬情報",
--     drop = "ドロップ情報",
--     steal = "盗む情報",
--     chest = "宝箱情報",
--     mining = "採掘/採取情報",
--     content = "コンテンツ報酬情報",
--     acquisition = "その他入手方法（上記に当てはまらない場合）" 
-- }
-- 習得レベルはAPIから取得するため、ここには定義しません。

magic_definitions.magics = {
    [1] = {
        name = "ケアル",
        description = "標的のHPを回復。ハートオブソラス:ストンスキンの効果を付与する。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [2] = {
        name = "ケアルII",
        description = "標的のHPを回復。ハートオブソラス:ストンスキンの効果を付与する。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu\nセルビナ H-9T5 Quelpia"
    },
    [3] = {
        name = "ケアルIII",
        description = "標的のHPを回復。ハートオブソラス:ストンスキンの効果を付与する。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia"
    },
    [4] = {
        name = "ケアルIV",
        description = "標的のHPを回復。ハートオブソラス:ストンスキンの効果を付与する。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [6] = {
        name = "ケアルVI",
        description = "標的のHPを回復。ハートオブソラス:ストンスキンの効果を付与する。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [7] = {
        name = "ケアルガ",
        description = "範囲内のパーティメンバーのHPを回復。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [8] = {
        name = "ケアルガII",
        description = "範囲内のパーティメンバーのHPを回復。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif\nセルビナ H-9T5 Quelpia"
    },
    [9] = {
        name = "ケアルガIII",
        description = "範囲内のパーティメンバーのHPを回復。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [12] = {
        name = "レイズ",
        description = "標的の戦闘不能状態を回復。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia"
    },
    [14] = {
        name = "ポイゾナ",
        description = "標的の毒を治す。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [15] = {
        name = "パラナ",
        description = "標的の麻痺を治す。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [16] = {
        name = "ブライナ",
        description = "標的の暗闇を治す。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [17] = {
        name = "サイレナ",
        description = "標的の静寂、沈黙を治す。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [18] = {
        name = "ストナ",
        description = "標的の石化を治す。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [19] = {
        name = "ウィルナ",
        description = "標的の病気、悪疫を治す。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [20] = {
        name = "カーズナ",
        description = "標的の呪い、呪詛を治す。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [21] = {
        name = "ホーリー",
        description = "敵に光属性のダメージ。ハートオブソラス:回復量に応じてダメージにボーナスを得る。神聖の印:ダメージにボーナスを得る。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif\nセルビナ H-9T5 Quelpia"
    },
    [23] = {
        name = "ディア",
        description = "敵を光属性のダメージがじわじわ蝕み防御力ダウン。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [24] = {
        name = "ディアII",
        description = "敵を光属性のダメージがじわじわ蝕み防御力ダウン。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia"
    },
    [25] = {
        name = "ディアIII",
        description = "敵を光属性のダメージがじわじわ蝕み防御力ダウン。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [28] = {
        name = "バニシュ",
        description = "敵に光属性のダメージ。ハートオブミゼリ:被ダメージ量に応じてダメージにボーナスを得る。神聖の印:ダメージにボーナスを得る。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [29] = {
        name = "バニシュII",
        description = "敵に光属性のダメージ。ハートオブミゼリ:被ダメージ量に応じてダメージにボーナスを得る。神聖の印:ダメージにボーナスを得る。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia"
    },
    [30] = {
        name = "バニシュIII",
        description = "敵に光属性のダメージ。ハートオブミゼリ:被ダメージ量に応じてダメージにボーナスを得る。",
        shop = "タブナジア地下壕 2F F-9T8 Mazuro-Oozuro\nタブナジア地下壕 2F F-7T3 Nilerouche\nラバオ F-7T8 Brave Ox"
    },
    [33] = {
        name = "ディアガ",
        description = "範囲内の敵を光属性のダメージがじわじわ蝕み防御力ダウン。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [38] = {
        name = "バニシュガ",
        description = "範囲内の敵に光属性のダメージ。ハートオブミゼリ:被ダメージ量に応じてダメージにボーナスを得る。神聖の印:ダメージにボーナスを得る。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [39] = {
        name = "バニシュガII",
        description = "範囲内の敵に光属性のダメージ。ハートオブミゼリ:被ダメージ量に応じてダメージにボーナスを得る。神聖の印:ダメージにボーナスを得る。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [43] = {
        name = "プロテス",
        description = "標的の防御力をアップする。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [44] = {
        name = "プロテスII",
        description = "標的の防御力をアップする。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia"
    },
    [45] = {
        name = "プロテスIII",
        description = "標的の防御力をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim\nアルザビ J-8T5 Zafif"
    },
    [46] = {
        name = "プロテスIV",
        description = "標的の防御力をアップする。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nアルザビ J-8T5 Zafif\nラバオ F-7T8 Brave Ox"
    },
    [47] = {
        name = "プロテスV",
        description = "標的の防御力をアップする。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [48] = {
        name = "シェル",
        description = "標的の魔法防御力をアップする。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [49] = {
        name = "シェルII",
        description = "標的の魔法防御力をアップする。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia"
    },
    [50] = {
        name = "シェルIII",
        description = "標的の魔法防御力をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [52] = {
        name = "シェルV",
        description = "標的の魔法防御力をアップする。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [53] = {
        name = "ブリンク",
        description = "自身の幻影を出して単体攻撃を回避する機会を得る。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [54] = {
        name = "ストンスキン",
        description = "自身の一定量のダメージを無効にする。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [55] = {
        name = "アクアベール",
        description = "自身の魔法の中断する確率を下げる。",
        shop = "ウィンダス港 H-8T8 Kususu"
    },
    [56] = {
        name = "スロウ",
        description = "敵の攻撃間隔を長くする。",
        shop = "バストゥーク商業区 H-5T1 Sororo\nウィンダス港 H-8T8 Kususu"
    },
    [57] = {
        name = "ヘイスト",
        description = "標的の攻撃間隔を短くする。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia"
    },
    [60] = {
        name = "バファイ",
        description = "自身の火属性に対する耐性をアップする。ハートオブソラス:火属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [61] = {
        name = "バブリザ",
        description = "自身の氷属性に対する耐性をアップする。ハートオブソラス:氷属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [62] = {
        name = "バエアロ",
        description = "自身の風属性に対する耐性をアップする。ハートオブソラス:風属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [63] = {
        name = "バストン",
        description = "自身の土属性に対する耐性をアップする。ハートオブソラス:土属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [64] = {
        name = "バサンダ",
        description = "自身の雷属性に対する耐性をアップする。ハートオブソラス:雷属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [65] = {
        name = "バウォタ",
        description = "自身の水属性に対する耐性をアップする。ハートオブソラス:水属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [66] = {
        name = "バファイラ",
        description = "範囲内にいるパーティメンバーの火属性に対する耐性をアップする。ハートオブソラス:火属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [67] = {
        name = "バブリザラ",
        description = "範囲内にいるパーティメンバーの氷属性に対する耐性をアップする。ハートオブソラス:氷属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [68] = {
        name = "バエアロラ",
        description = "範囲内にいるパーティメンバーの風属性に対する耐性をアップする。ハートオブソラス:風属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [69] = {
        name = "バストンラ",
        description = "範囲内にいるパーティメンバーの土属性に対する耐性をアップする。ハートオブソラス:土属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [70] = {
        name = "バサンダラ",
        description = "範囲内にいるパーティメンバーの雷属性に対する耐性をアップする。ハートオブソラス:雷属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [71] = {
        name = "バウォタラ",
        description = "範囲内にいるパーティメンバーの水属性に対する耐性をアップする。ハートオブソラス:水属性魔法防御力アップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [72] = {
        name = "バスリプル",
        description = "自身の睡眠に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [73] = {
        name = "バポイズン",
        description = "自身の毒に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [74] = {
        name = "バパライズ",
        description = "自身の麻痺に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [75] = {
        name = "バブライン",
        description = "自身の暗闇に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [76] = {
        name = "バサイレス",
        description = "自身の静寂に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [77] = {
        name = "バブレイク",
        description = "自身の石化に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [78] = {
        name = "バウィルス",
        description = "自身の病気に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [81] = {
        name = "リコールジャグ",
        description = "範囲内の資格があるパーティメンバーをジャグナー森林〔Ｓ〕へワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [82] = {
        name = "リコールパシュ",
        description = "範囲内の資格があるパーティメンバーをパシュハウ沼〔Ｓ〕へワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [83] = {
        name = "リコールメリファ",
        description = "範囲内の資格があるパーティメンバーをメリファト山地〔Ｓ〕へワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [84] = {
        name = "バアムネジア",
        description = "自身のアムネジアに対する耐性をアップする。",
        shop = "マウラ G-9T1 Tya Padolih"
    },
    [85] = {
        name = "バアムネジラ",
        description = "範囲内にいるパーティメンバーのアムネジアに対する耐性をアップする。",
        shop = "マウラ G-9T1 Tya Padolih"
    },
    [511] = {
        name = "ヘイストII",
        description = "標的の攻撃間隔を短くする。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [86] = {
        name = "バスリプラ",
        description = "範囲内にいるパーティメンバーの睡眠に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [87] = {
        name = "バポイゾラ",
        description = "範囲内にいるパーティメンバーの毒に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [88] = {
        name = "バパライラ",
        description = "範囲内にいるパーティメンバーの麻痺に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [89] = {
        name = "バブライラ",
        description = "範囲内にいるパーティメンバーの暗闇に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [90] = {
        name = "バサイレラ",
        description = "範囲内にいるパーティメンバーの静寂に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [91] = {
        name = "バブレクラ",
        description = "範囲内にいるパーティメンバーの石化に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [92] = {
        name = "バウィルラ",
        description = "範囲内にいるパーティメンバーの病気に対する耐性をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [93] = {
        name = "ケアルラ",
        description = "範囲内のパーティメンバーのHPを回復。ハートオブミゼリ:回復量にボーナスを得る。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [94] = {
        name = "サクリファイス",
        description = "標的のパーティメンバーが受けている弱体効果を1つ、自身に移し替える。ハートオブソラス:弱体効果の数や種類にボーナスを得る。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [95] = {
        name = "エスナ",
        description = "自身が受けている弱体効果を1つ、範囲内のパーティメンバーまで回復。ハートオブミゼリ:弱体効果の数や種類にボーナスを得る。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [96] = {
        name = "オースピス",
        description = "範囲内のパーティメンバーの与TPを減らす。ハートオブミゼリ:初段のみ光の付加ダメージを与え、且つ攻撃がミスした際に、命中に対してボーナスを得る。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [310] = {
        name = "エンライト",
        description = "光の付加ダメージを与える。",
        shop = "ナシュモ H-7T6 Mamaroon"
    },
    [311] = {
        name = "エンダーク",
        description = "闇の付加ダメージを与える。",
        shop = "ナシュモ H-7T6 Mamaroon"
    },
    [100] = {
        name = "エンファイア",
        description = "火の付加ダメージを与える。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia\nナシュモ H-7T6 Mamaroon"
    },
    [101] = {
        name = "エンブリザド",
        description = "氷の付加ダメージを与える。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia\nナシュモ H-7T6 Mamaroon"
    },
    [102] = {
        name = "エンエアロ",
        description = "風の付加ダメージを与える。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia\nナシュモ H-7T6 Mamaroon"
    },
    [103] = {
        name = "エンストーン",
        description = "土の付加ダメージを与える。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia\nナシュモ H-7T6 Mamaroon"
    },
    [104] = {
        name = "エンサンダー",
        description = "雷の付加ダメージを与える。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia\nナシュモ H-7T6 Mamaroon"
    },
    [105] = {
        name = "エンウォータ",
        description = "水の付加ダメージを与える。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nセルビナ H-9T5 Quelpia\nナシュモ H-7T6 Mamaroon"
    },
    [97] = {
        name = "リアクト",
        description = "魔法の力によって盾の発動率をアップし、防いだダメージの一部を反射する。",
        shop = "アルザビ J-8T5 Zafif"
    },
    [108] = {
        name = "リジェネ",
        description = "標的のパーティメンバーのHPを徐々に回復する。",
        shop = "マウラ G-9T1 Tya Padolih"
    },
    [110] = {
        name = "リジェネII",
        description = "標的のパーティメンバーのHPを徐々に回復する。",
        shop = "マウラ G-9T1 Tya Padolih"
    },
    [112] = {
        name = "フラッシュ",
        description = "敵の命中率を短時間著しく下げる。",
        shop = "アルザビ J-8T5 Zafif\nラバオ F-7T8 Brave Ox"
    },
    [98] = {
        name = "リポーズ",
        description = "敵を眠らせる。",
        shop = "バストゥーク商業区 H-5T1 Sororo"
    },
    [312] = {
        name = "エンファイアII",
        description = "初段のみ火の付加ダメージを与え、敵の水属性に対する耐性をダウン。",
        shop = "ル・ルデの庭 H-9T1 Macchi Gazlitah"
    },
    [313] = {
        name = "エンブリザドII",
        description = "初段のみ氷の付加ダメージを与え、敵の火属性に対する耐性をダウン。",
        shop = "ル・ルデの庭 H-9T1 Macchi Gazlitah"
    },
    [314] = {
        name = "エンエアロII",
        description = "初段のみ風の付加ダメージを与え、敵の氷属性に対する耐性をダウン。",
        shop = "ル・ルデの庭 H-9T1 Macchi Gazlitah"
    },
    [315] = {
        name = "エンストーンII",
        description = "初段のみ土の付加ダメージを与え、敵の風属性に対する耐性をダウン。",
        shop = "ル・ルデの庭 H-9T1 Macchi Gazlitah"
    },
    [316] = {
        name = "エンサンダーII",
        description = "初段のみ雷の付加ダメージを与え、敵の土属性に対する耐性をダウン。",
        shop = "ル・ルデの庭 H-9T1 Macchi Gazlitah"
    },
    [317] = {
        name = "エンウォータII",
        description = "初段のみ水の付加ダメージを与え、敵の雷属性に対する耐性をダウン。",
        shop = "ル・ルデの庭 H-9T1 Macchi Gazlitah"
    },
    [120] = {
        name = "テレポヨト",
        description = "範囲内の資格があるパーティメンバーをヨトへワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [121] = {
        name = "テレポルテ",
        description = "範囲内の資格があるパーティメンバーをルテへワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [122] = {
        name = "テレポホラ",
        description = "範囲内の資格があるパーティメンバーをホラへワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [123] = {
        name = "テレポデム",
        description = "範囲内の資格があるパーティメンバーをデムへワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [124] = {
        name = "テレポメア",
        description = "範囲内の資格があるパーティメンバーをメアへワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [126] = {
        name = "プロテアII",
        description = "範囲内にいるパーティメンバーの防御力をアップする。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [127] = {
        name = "プロテアIII",
        description = "範囲内にいるパーティメンバーの防御力をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [128] = {
        name = "プロテアIV",
        description = "範囲内にいるパーティメンバーの防御力をアップする。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nアルザビ J-8T5 Zafif\nラバオ F-7T8 Brave Ox"
    },
    [129] = {
        name = "プロテアV",
        description = "範囲内にいるパーティメンバーの防御力をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [130] = {
        name = "シェルラ",
        description = "範囲内にいるパーティメンバーの魔法防御力をアップする。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [131] = {
        name = "シェルラII",
        description = "範囲内にいるパーティメンバーの魔法防御力をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [132] = {
        name = "シェルラIII",
        description = "範囲内にいるパーティメンバーの魔法防御力をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [134] = {
        name = "シェルラV",
        description = "範囲内にいるパーティメンバーの魔法防御力をアップする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [136] = {
        name = "インビジ",
        description = "透明になり敵に発見されにくくする。",
        shop = "セルビナ H-9T5 Falgima\nマウラ G-9T1 Tya Padolih"
    },
    [137] = {
        name = "スニーク",
        description = "音を消し敵に発見されにくくする。",
        shop = "セルビナ H-9T5 Falgima\nマウラ G-9T1 Tya Padolih"
    },
    [138] = {
        name = "デオード",
        description = "臭いを消しモンスターに追跡されにくくする。",
        shop = "セルビナ H-9T5 Falgima\nマウラ G-9T1 Tya Padolih"
    },
    [139] = {
        name = "テレポヴァズ",
        description = "範囲内の資格があるパーティメンバーをヴァズへワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [142] = {
        name = "リレイズIII",
        description = "戦闘不能時にレイズIIIの効果が発動する。",
        shop = "アルザビ J-8T5 Zafif\nラバオ F-7T8 Brave Ox"
    },
    [144] = {
        name = "ファイア",
        description = "敵に火属性のダメージ。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [145] = {
        name = "ファイアII",
        description = "敵に火属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [146] = {
        name = "ファイアIII",
        description = "敵に火属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween"
    },
    [147] = {
        name = "ファイアIV",
        description = "敵に火属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [148] = {
        name = "ファイアV",
        description = "敵に火属性のダメージ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [149] = {
        name = "ブリザド",
        description = "敵に氷属性のダメージ。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [150] = {
        name = "ブリザドII",
        description = "敵に氷属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [151] = {
        name = "ブリザドIII",
        description = "敵に氷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween"
    },
    [152] = {
        name = "ブリザドIV",
        description = "敵に氷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [153] = {
        name = "ブリザドV",
        description = "敵に氷属性のダメージ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [154] = {
        name = "エアロ",
        description = "敵に風属性のダメージ。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [155] = {
        name = "エアロII",
        description = "敵に風属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [156] = {
        name = "エアロIII",
        description = "敵に風属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween"
    },
    [157] = {
        name = "エアロIV",
        description = "敵に風属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [158] = {
        name = "エアロV",
        description = "敵に風属性のダメージ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [159] = {
        name = "ストーン",
        description = "敵に土属性のダメージ。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [160] = {
        name = "ストーンII",
        description = "敵に土属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [161] = {
        name = "ストーンIII",
        description = "敵に土属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween"
    },
    [162] = {
        name = "ストーンIV",
        description = "敵に土属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [163] = {
        name = "ストーンV",
        description = "敵に土属性のダメージ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [164] = {
        name = "サンダー",
        description = "敵に雷属性のダメージ。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [165] = {
        name = "サンダーII",
        description = "敵に雷属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [166] = {
        name = "サンダーIII",
        description = "敵に雷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween"
    },
    [167] = {
        name = "サンダーIV",
        description = "敵に雷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [169] = {
        name = "ウォータ",
        description = "敵に水属性のダメージ。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [170] = {
        name = "ウォータII",
        description = "敵に水属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [171] = {
        name = "ウォータIII",
        description = "敵に水属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween"
    },
    [172] = {
        name = "ウォータIV",
        description = "敵に水属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [173] = {
        name = "ウォータV",
        description = "敵に水属性のダメージ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [174] = {
        name = "ファイガ",
        description = "範囲内の敵に火属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [175] = {
        name = "ファイガII",
        description = "範囲内の敵に火属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [176] = {
        name = "ファイガIII",
        description = "範囲内の敵に火属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [179] = {
        name = "ブリザガ",
        description = "範囲内の敵に氷属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [180] = {
        name = "ブリザガII",
        description = "範囲内の敵に氷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [181] = {
        name = "ブリザガIII",
        description = "範囲内の敵に氷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [184] = {
        name = "エアロガ",
        description = "範囲内の敵に風属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [185] = {
        name = "エアロガII",
        description = "範囲内の敵に風属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [186] = {
        name = "エアロガIII",
        description = "範囲内の敵に風属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [189] = {
        name = "ストンガ",
        description = "範囲内の敵に土属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [190] = {
        name = "ストンガII",
        description = "範囲内の敵に土属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [191] = {
        name = "ストンガIII",
        description = "範囲内の敵に土属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [194] = {
        name = "サンダガ",
        description = "範囲内の敵に雷属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [195] = {
        name = "サンダガII",
        description = "範囲内の敵に雷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [196] = {
        name = "サンダガIII",
        description = "範囲内の敵に雷属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [199] = {
        name = "ウォタガ",
        description = "範囲内の敵に水属性のダメージ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire"
    },
    [200] = {
        name = "ウォタガII",
        description = "範囲内の敵に水属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [201] = {
        name = "ウォタガIII",
        description = "範囲内の敵に水属性のダメージ。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [204] = {
        name = "フレア",
        description = "敵に火属性のダメージを与え、水属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [205] = {
        name = "フレアII",
        description = "敵に火属性のダメージを与え、水属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [206] = {
        name = "フリーズ",
        description = "敵に氷属性のダメージを与え、火属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [207] = {
        name = "フリーズII",
        description = "敵に氷属性のダメージを与え、火属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [208] = {
        name = "トルネド",
        description = "敵に風属性のダメージを与え、氷属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [209] = {
        name = "トルネドII",
        description = "敵に風属性のダメージを与え、氷属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [210] = {
        name = "クエイク",
        description = "敵に土属性のダメージを与え、風属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [211] = {
        name = "クエイクII",
        description = "敵に土属性のダメージを与え、風属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [212] = {
        name = "バースト",
        description = "敵に雷属性のダメージを与え、土属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [213] = {
        name = "バーストII",
        description = "敵に雷属性のダメージを与え、土属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [214] = {
        name = "フラッド",
        description = "敵に水属性のダメージを与え、雷属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [215] = {
        name = "フラッドII",
        description = "敵に水属性のダメージを与え、雷属性に対する防御力をダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [220] = {
        name = "ポイズン",
        description = "敵は毒で徐々にHPを失う。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [221] = {
        name = "ポイズンII",
        description = "敵は毒で徐々にHPを失う。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nアトルガン白門 G-7T7 Mazween\nセルビナ H-9T5 Chutarmire"
    },
    [225] = {
        name = "ポイゾガ",
        description = "範囲内の敵は毒で徐々にHPを失う。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nアトルガン白門 G-7T7 Mazween\nセルビナ H-9T5 Chutarmire"
    },
    [230] = {
        name = "バイオ",
        description = "敵を闇属性のダメージがじわじわ蝕み攻撃力ダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [231] = {
        name = "バイオII",
        description = "敵を闇属性のダメージがじわじわ蝕み攻撃力ダウン。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nアトルガン白門 G-7T7 Mazween\nセルビナ H-9T5 Chutarmire"
    },
    [232] = {
        name = "バイオIII",
        description = "敵を闇属性のダメージがじわじわ蝕み攻撃力ダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [235] = {
        name = "バーン",
        description = "敵を火属性のダメージがじわじわ蝕みINTダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [236] = {
        name = "フロスト",
        description = "敵を氷属性のダメージがじわじわ蝕みAGIダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [237] = {
        name = "チョーク",
        description = "敵を風属性のダメージがじわじわ蝕みVITダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [238] = {
        name = "ラスプ",
        description = "敵を土属性のダメージがじわじわ蝕みDEXダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [239] = {
        name = "ショック",
        description = "敵を雷属性のダメージがじわじわ蝕みMNDダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [240] = {
        name = "ドラウン",
        description = "敵を水属性のダメージがじわじわ蝕みSTRダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [286] = {
        name = "アドル",
        description = "敵の魔法命中率をダウンし、詠唱時間を長くする。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [473] = {
        name = "リフレシュII",
        description = "標的のパーティメンバーのMPを徐々に回復する。",
        shop = "ル・ルデの庭 H-9T1 Macchi Gazlitah"
    },
    [245] = {
        name = "ドレイン",
        description = "敵のHPを吸収する。不死生物には効かない。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [246] = {
        name = "ドレインII",
        description = "敵のHPを吸収し、場合によってHPmaxアップ。不死生物には効かない。",
        shop = "アトルガン白門 G-7T7 Mazween"
    },
    [247] = {
        name = "アスピル",
        description = "敵のMPを吸収する。不死生物には効かない。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [248] = {
        name = "アスピルII",
        description = "敵のMPを吸収する。不死生物には効かない。",
        shop = "アトルガン白門 G-7T7 Mazween"
    },
    [249] = {
        name = "ブレイズスパイク",
        description = "火属性のスパイクアーマーで自身をつつむ。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [251] = {
        name = "ショックスパイク",
        description = "雷属性のスパイクアーマーで自身をつつむ。",
        shop = "ウィンダス水の区 南 G-7T3 Hilkomu-Makimu\nセルビナ H-9T5 Chutarmire\nナシュモ H-7T6 Mamaroon"
    },
    [252] = {
        name = "スタン",
        description = "敵を短時間行動できなくする。",
        shop = "ラバオ F-7T8 Brave Ox\nナシュモ H-7T6 Mamaroon"
    },
    [253] = {
        name = "スリプル",
        description = "敵を眠らせる。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [254] = {
        name = "ブライン",
        description = "敵を暗闇で捕らえ、命中率ダウン。",
        shop = "バストゥーク商業区 H-5T1 Zaira\nウィンダス港 H-8T8 Aroro"
    },
    [255] = {
        name = "ブレイク",
        description = "敵を硬直させて行動できなくする。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [259] = {
        name = "スリプルII",
        description = "敵を眠らせる。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween"
    },
    [260] = {
        name = "ディスペル",
        description = "敵の魔法効果を1つ消し去る。",
        shop = "ウィンダス水の区 南 G-7T3 Shohrun-Tuhrun\nアルザビ J-8T5 Zafif\nラバオ F-7T8 Brave Ox"
    },
    [261] = {
        name = "デジョン",
        description = "ホームポイントへワープする。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [262] = {
        name = "デジョンII",
        description = "標的のパーティメンバーをホームポイントへワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [241] = {
        name = "リトレース",
        description = "標的の資格があるパーティメンバーを過去の所属国へワープさせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [273] = {
        name = "スリプガ",
        description = "範囲内の敵を眠らせる。",
        shop = "ジュノ下層 H-9T9 Susu\nアトルガン白門 G-7T7 Mazween\nマウラ G-9T1 Tya Padolih"
    },
    [274] = {
        name = "スリプガII",
        description = "範囲内の敵を眠らせる。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [275] = {
        name = "アブゾタック",
        description = "敵のTPを吸収する。",
        shop = "アトルガン白門 G-7T7 Mazween"
    },
    [276] = {
        name = "ブラインII",
        description = "敵を暗闇で捕らえ、命中率ダウン。",
        shop = "ジュノ下層 H-9T9 Susu"
    },
    [277] = {
        name = "ドレッドスパイク",
        description = "闇属性のスパイクアーマーで自身をつつみ、反撃効果:HP吸収。不死生物には効かない。",
        shop = "アトルガン白門 G-7T7 Mazween"
    },
    [242] = {
        name = "アブゾアキュル",
        description = "敵の命中を吸収する。",
        shop = "アトルガン白門 G-7T7 Mazween"
    },
    [496] = {
        name = "ファイジャ",
        description = "範囲内の敵に火属性のダメージを与え、さらに重ねて使用すると効果アップ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [498] = {
        name = "エアロジャ",
        description = "範囲内の敵に風属性のダメージを与え、さらに重ねて使用すると効果アップ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [499] = {
        name = "ストンジャ",
        description = "範囲内の敵に土属性のダメージを与え、さらに重ねて使用すると効果アップ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [501] = {
        name = "ウォタジャ",
        description = "範囲内の敵に水属性のダメージを与え、さらに重ねて使用すると効果アップ。",
        shop = "ウィンダス水の区〔Ｓ〕 南 H-8T7 Ezura-Romazura"
    },
    [291] = {
        name = "土精霊召喚",
        description = "土の精霊を召喚する。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [841] = {
        name = "ディストラ",
        description = "対象の物理回避率をダウン。",
        shop = "マウラ G-9T1 Tya Padolih"
    },
    [842] = {
        name = "ディストラII",
        description = "対象の物理回避率をダウン。",
        shop = "タブナジア地下壕 2F F-9T8 Mazuro-Oozuro\nタブナジア地下壕 2F F-7T3 Nilerouche"
    },
    [843] = {
        name = "フラズル",
        description = "対象の魔法回避率をダウン。",
        shop = "マウラ G-9T1 Tya Padolih"
    },
    [844] = {
        name = "フラズルII",
        description = "対象の魔法回避率をダウン。",
        shop = "タブナジア地下壕 2F F-9T8 Mazuro-Oozuro\nタブナジア地下壕 2F F-7T3 Nilerouche"
    },
    [828] = {
        name = "ファイラ",
        description = "自身の周囲の敵に火属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [829] = {
        name = "ファイラII",
        description = "自身の周囲の敵に火属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [830] = {
        name = "ブリザラ",
        description = "自身の周囲の敵に氷属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [831] = {
        name = "ブリザラII",
        description = "自身の周囲の敵に氷属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [832] = {
        name = "エアロラ",
        description = "自身の周囲の敵に風属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [833] = {
        name = "エアロラII",
        description = "自身の周囲の敵に風属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [834] = {
        name = "ストンラ",
        description = "自身の周囲の敵に土属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [835] = {
        name = "ストンラII",
        description = "自身の周囲の敵に土属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [836] = {
        name = "サンダラ",
        description = "自身の周囲の敵に雷属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [837] = {
        name = "サンダラII",
        description = "自身の周囲の敵に雷属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [838] = {
        name = "ウォタラ",
        description = "自身の周囲の敵に水属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [839] = {
        name = "ウォタラII",
        description = "自身の周囲の敵に水属性のダメージ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [320] = {
        name = "火遁の術:壱",
        description = "火属性ダメージ+水耐性ダウンの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [322] = {
        name = "火遁の術:参",
        description = "火属性ダメージ+水耐性ダウンの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [323] = {
        name = "氷遁の術:壱",
        description = "氷属性ダメージ+火耐性ダウンの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [325] = {
        name = "氷遁の術:参",
        description = "氷属性ダメージ+火耐性ダウンの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [326] = {
        name = "風遁の術:壱",
        description = "風属性ダメージ+氷耐性ダウンの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [328] = {
        name = "風遁の術:参",
        description = "風属性ダメージ+氷耐性ダウンの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [329] = {
        name = "土遁の術:壱",
        description = "土属性ダメージ+風耐性ダウンの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [331] = {
        name = "土遁の術:参",
        description = "土属性ダメージ+風耐性ダウンの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [332] = {
        name = "雷遁の術:壱",
        description = "雷属性ダメージ+土耐性ダウンの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [334] = {
        name = "雷遁の術:参",
        description = "雷属性ダメージ+土耐性ダウンの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [335] = {
        name = "水遁の術:壱",
        description = "水属性ダメージ+雷耐性ダウンの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [337] = {
        name = "水遁の術:参",
        description = "水属性ダメージ+雷耐性ダウンの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [338] = {
        name = "空蝉の術:壱",
        description = "空蝉の効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [341] = {
        name = "呪縛の術:壱",
        description = "麻痺の効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [344] = {
        name = "捕縄の術:壱",
        description = "スロウの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [347] = {
        name = "暗闇の術:壱",
        description = "暗闇の効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [350] = {
        name = "毒盛の術:壱",
        description = "毒の効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [353] = {
        name = "遁甲の術:壱",
        description = "インビジの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [318] = {
        name = "物見の術:壱",
        description = "スニークの効果。",
        shop = "ジュノ下層 J-8T7 Amalasanda\nカザム I-8T7 Toji Mumosulah"
    },
    [319] = {
        name = "哀車の術:壱",
        description = "攻撃力ダウンの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [507] = {
        name = "妙手の術:壱",
        description = "モクシャアップの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [508] = {
        name = "幽林の術:壱",
        description = "インヒビットTPの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [509] = {
        name = "活火の術:壱",
        description = "ストアTPアップの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [505] = {
        name = "月下の術:壱",
        description = "敵対心アップの効果。",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [506] = {
        name = "夜陰の術:壱",
        description = "パクスの効果",
        shop = "ノーグ H-9T4 Solby-Maholby"
    },
    [368] = {
        name = "魔物のレクイエム",
        description = "敵に音波ダメージ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [369] = {
        name = "魔物のレクイエムII",
        description = "敵に音波ダメージ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [370] = {
        name = "魔物のレクイエムIII",
        description = "敵に音波ダメージ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [371] = {
        name = "魔物のレクイエムIV",
        description = "敵に音波ダメージ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [374] = {
        name = "魔物のレクイエムVII",
        description = "敵に音波ダメージ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [378] = {
        name = "戦士達のピーアン",
        description = "範囲内のパーティメンバーのHPを徐々に回復",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [379] = {
        name = "戦士達のピーアンII",
        description = "範囲内のパーティメンバーのHPを徐々に回復",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [380] = {
        name = "戦士達のピーアンIII",
        description = "範囲内のパーティメンバーのHPを徐々に回復",
        shop = "バストゥーク商業区 K-10T6 Hortense\nカザム I-8T7 Toji Mumosulah"
    },
    [381] = {
        name = "戦士達のピーアンIV",
        description = "範囲内のパーティメンバーのHPを徐々に回復",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [383] = {
        name = "戦士達のピーアンVI",
        description = "範囲内のパーティメンバーのHPを徐々に回復",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [386] = {
        name = "魔道士のバラード",
        description = "範囲内のパーティメンバーのMPを徐々に回復",
        shop = "ジュノ下層 J-8T7 Amalasanda"
    },
    [388] = {
        name = "魔道士のバラードIII",
        description = "範囲内のパーティメンバーのMPを徐々に回復",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [389] = {
        name = "重装騎兵のミンネ",
        description = "範囲内のパーティメンバーの防御力をアップ",
        shop = "南サンドリア I-11T6 Ferdoulemiont"
    },
    [390] = {
        name = "重装騎兵のミンネII",
        description = "範囲内のパーティメンバーの防御力をアップ",
        shop = "南サンドリア I-11T6 Ferdoulemiont"
    },
    [391] = {
        name = "重装騎兵のミンネIII",
        description = "範囲内のパーティメンバーの防御力をアップ",
        shop = "南サンドリア I-11T6 Ferdoulemiont"
    },
    [393] = {
        name = "重装騎兵のミンネV",
        description = "範囲内のパーティメンバーの防御力をアップ",
        shop = "南サンドリア I-11T6 Ferdoulemiont"
    },
    [394] = {
        name = "猛者のメヌエット",
        description = "範囲内のパーティメンバーの攻撃力をアップ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [395] = {
        name = "猛者のメヌエットII",
        description = "範囲内のパーティメンバーの攻撃力をアップ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [396] = {
        name = "猛者のメヌエットIII",
        description = "範囲内のパーティメンバーの攻撃力をアップ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [398] = {
        name = "猛者のメヌエットV",
        description = "範囲内のパーティメンバーの攻撃力をアップ",
        shop = "バストゥーク商業区 K-10T6 Hortense"
    },
    [399] = {
        name = "剣闘士のマドリガル",
        description = "範囲内のパーティメンバーの近接攻撃の命中率をアップ",
        shop = "北サンドリア F-8T1 Boncort"
    },
    [401] = {
        name = "狩人のプレリュード",
        description = "範囲内のパーティメンバーの遠隔攻撃の命中率をアップ",
        shop = "ウィンダス森の区 H-13T6 Mono Nchaa"
    },
    [403] = {
        name = "闘羊士のマンボ",
        description = "範囲内のパーティメンバーの回避率をアップ",
        shop = "セルビナ G-10T7 Dohdjuma"
    },
    [405] = {
        name = "鶏のオーバード",
        description = "範囲内のパーティメンバーの睡眠耐性をアップ",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [406] = {
        name = "薬草のパストラル",
        description = "範囲内のパーティメンバーの毒耐性をアップ",
        shop = "ウィンダス森の区 I-8T9 Wije Tiren"
    },
    [409] = {
        name = "小話のオペレッタ",
        description = "範囲内のパーティメンバーの静寂耐性をアップ",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [410] = {
        name = "腹話のオペレッタ",
        description = "範囲内のパーティメンバーの静寂耐性をアップ",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [415] = {
        name = "ゴブリンのガボット",
        description = "範囲内のパーティメンバーのバインド耐性をアップ",
        shop = "ジュノ下層 H-9T2 Creepstix"
    },
    [419] = {
        name = "無敵の進撃マーチ",
        description = "範囲内のパーティメンバーの攻撃間隔を短縮",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [421] = {
        name = "戦場のエレジー",
        description = "敵の攻撃間隔を長くする",
        shop = "南サンドリア K-7T4 Thadiene"
    },
    [424] = {
        name = "剛力のエチュード",
        description = "範囲内のパーティメンバーのSTRアップ",
        shop = "ウィンダス森の区 H-13T6 Manyny\nジュノ港 H-8T5 Leyla"
    },
    [425] = {
        name = "器用のエチュード",
        description = "範囲内のパーティメンバーのDEXアップ",
        shop = "ウィンダス森の区 H-13T6 Manyny\nジュノ港 H-8T5 Leyla"
    },
    [426] = {
        name = "元気のエチュード",
        description = "範囲内のパーティメンバーのVITアップ",
        shop = "ウィンダス森の区 H-13T6 Manyny\nジュノ港 H-8T5 Leyla"
    },
    [427] = {
        name = "機敏のエチュード",
        description = "範囲内のパーティメンバーのAGIアップ",
        shop = "ウィンダス森の区 H-13T6 Manyny\nジュノ港 H-8T5 Leyla"
    },
    [428] = {
        name = "知恵のエチュード",
        description = "範囲内のパーティメンバーのINTアップ",
        shop = "ウィンダス森の区 H-13T6 Manyny\nジュノ港 H-8T5 Leyla"
    },
    [429] = {
        name = "精神のエチュード",
        description = "範囲内のパーティメンバーのMNDアップ",
        shop = "ウィンダス森の区 H-13T6 Manyny\nジュノ港 H-8T5 Leyla"
    },
    [430] = {
        name = "魅了のエチュード",
        description = "範囲内のパーティメンバーのCHRアップ",
        shop = "ウィンダス森の区 H-13T6 Manyny\nジュノ港 H-8T5 Leyla"
    },
    [431] = {
        name = "怪力のエチュード",
        description = "範囲内のパーティメンバーのSTRアップ",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [432] = {
        name = "妙技のエチュード",
        description = "範囲内のパーティメンバーのDEXアップ",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [433] = {
        name = "活力のエチュード",
        description = "範囲内のパーティメンバーのVITアップ",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [434] = {
        name = "俊敏のエチュード",
        description = "範囲内のパーティメンバーのAGIアップ",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [435] = {
        name = "英知のエチュード",
        description = "範囲内のパーティメンバーのINTアップ",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [436] = {
        name = "理力のエチュード",
        description = "範囲内のパーティメンバーのMNDアップ",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [437] = {
        name = "魅惑のエチュード",
        description = "範囲内のパーティメンバーのCHRアップ",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [438] = {
        name = "耐火カロル第一楽章",
        description = "範囲内のパーティメンバーの火属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [439] = {
        name = "耐寒カロル第一楽章",
        description = "範囲内のパーティメンバーの氷属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [440] = {
        name = "耐風カロル第一楽章",
        description = "範囲内のパーティメンバーの風属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [441] = {
        name = "耐震カロル第一楽章",
        description = "範囲内のパーティメンバーの土属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [442] = {
        name = "耐電カロル第一楽章",
        description = "範囲内のパーティメンバーの雷属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [443] = {
        name = "耐波カロル第一楽章",
        description = "範囲内のパーティメンバーの水属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [444] = {
        name = "耐光カロル第一楽章",
        description = "範囲内のパーティメンバーの光属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [445] = {
        name = "耐闇カロル第一楽章",
        description = "範囲内のパーティメンバーの闇属性に対する防御力アップ",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [446] = {
        name = "耐火カロル第二楽章",
        description = "範囲内のパーティメンバーの火属性に対する防御力をアップし、時々火属性ダメージを無効化する",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [448] = {
        name = "耐風カロル第二楽章",
        description = "範囲内のパーティメンバーの風属性に対する防御力をアップし、時々風属性ダメージを無効化する",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [449] = {
        name = "耐震カロル第二楽章",
        description = "範囲内のパーティメンバーの土属性に対する防御力をアップし、時々土属性ダメージを無効化する",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [451] = {
        name = "耐波カロル第二楽章",
        description = "範囲内のパーティメンバーの水属性に対する防御力をアップし、時々水属性ダメージを無効化する",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [454] = {
        name = "炎のスレノディ",
        description = "敵の火属性に対する防御力ダウン",
        shop = "ウィンダス水の区 北 H-9T8 Ensasa"
    },
    [455] = {
        name = "氷のスレノディ",
        description = "敵の氷属性に対する防御力ダウン",
        shop = "バストゥーク商業区 E-11T6 Mjoll"
    },
    [456] = {
        name = "風のスレノディ",
        description = "敵の風属性に対する防御力ダウン",
        shop = "ジュノ上層 H-6T4 Champalpieu"
    },
    [457] = {
        name = "土のスレノディ",
        description = "敵の土属性に対する防御力ダウン",
        shop = "ウィンダス水の区 北 H-9T8 Ensasa"
    },
    [458] = {
        name = "雷のスレノディ",
        description = "敵の雷属性に対する防御力ダウン",
        shop = "南サンドリア F-8T3 Lusiane"
    },
    [459] = {
        name = "水のスレノディ",
        description = "敵の水属性に対する防御力ダウン",
        shop = "ジュノ上層 H-6T4 Champalpieu"
    },
    [460] = {
        name = "光のスレノディ",
        description = "敵の光属性に対する防御力ダウン",
        shop = "南サンドリア F-8T3 Lusiane"
    },
    [461] = {
        name = "闇のスレノディ",
        description = "敵の闇属性に対する防御力ダウン",
        shop = "バストゥーク商業区 E-11T6 Mjoll"
    },
    [464] = {
        name = "女神のヒムヌス",
        description = "範囲内のパーティメンバーにリレイズの効果",
        shop = "Shop Function (handleValerianoShop) [scripts\\globals\\shop.lua]"
    },
    [465] = {
        name = "チョコボのマズルカ",
        description = "範囲内のパーティメンバーの移動速度をアップ",
        shop = "南サンドリア I-11T6 Ferdoulemiont\nバストゥーク鉱山区 J-9T4 Neigepance\nウィンダス森の区 K-12T3 Quesse\nラバオ G-6T1 Generoit\nカザム F-9T5 Mamerie"
    },
    [467] = {
        name = "ラプトルのマズルカ",
        description = "範囲内のパーティメンバーの移動速度をアップ",
        shop = "アトルガン白門 H-11T2 Khaf Jhifanm"
    },
    [468] = {
        name = "魔物のシルベント",
        description = "範囲内のパーティメンバーの敵対心を下がりにくくする",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [469] = {
        name = "冒険者のダージュ",
        description = "範囲内のパーティメンバーの敵対心をダウン",
        shop = "バストゥーク商業区 K-10T6 Harmodios"
    },
    [470] = {
        name = "警戒のスケルツォ",
        description = "範囲内のパーティメンバーの大ダメージを軽減する",
        shop = "ジュノ下層 I-8T6 Yoskolo"
    },
    [471] = {
        name = "魔物達のララバイII",
        description = "範囲内の敵を睡眠状態にする",
        shop = "カザム I-8T7 Toji Mumosulah"
    },
    [474] = {
        name = "ケアルラII",
        description = "範囲内のパーティメンバーのHPを回復。ハートオブミゼリ:回復量にボーナスを得る。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [477] = {
        name = "リジェネIV",
        description = "標的のパーティメンバーのHPを徐々に回復する。",
        shop = "ジュノ港 H-8T5 Gekko"
    },
    [486] = {
        name = "ゲインスト",
        description = "自身のSTRアップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [487] = {
        name = "ゲインデック",
        description = "自身のDEXアップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [488] = {
        name = "ゲインバイト",
        description = "自身のVITアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [489] = {
        name = "ゲインアジル",
        description = "自身のAGIアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [490] = {
        name = "ゲインイン",
        description = "自身のINTアップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [491] = {
        name = "ゲインマイン",
        description = "自身のMNDアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [492] = {
        name = "ゲインカリス",
        description = "自身のCHRアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [479] = {
        name = "アディスト",
        description = "範囲内のパーティメンバーのSTRアップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [480] = {
        name = "アディデック",
        description = "範囲内のパーティメンバーのDEXアップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [481] = {
        name = "アディバイト",
        description = "範囲内のパーティメンバーのVITアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [482] = {
        name = "アディアジル",
        description = "範囲内のパーティメンバーのAGIアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [483] = {
        name = "アディイン",
        description = "範囲内のパーティメンバーのINTアップ。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [484] = {
        name = "アディマイン",
        description = "範囲内のパーティメンバーのMNDアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [485] = {
        name = "アディカリス",
        description = "範囲内のパーティメンバーのCHRアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [840] = {
        name = "フォイル",
        description = "自身の特殊攻撃への回避率をアップ。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [476] = {
        name = "クルセード",
        description = "自身の敵対心を上昇しやすくする。",
        shop = "ラバオ F-7T8 Brave Ox"
    },
    [845] = {
        name = "スナップ",
        description = "標的の遠隔攻撃の間隔を短くする。",
        shop = "セルビナ H-9T5 Falgima"
    },
    [846] = {
        name = "スナップII",
        description = "標的の遠隔攻撃の間隔を短くする。",
        shop = "西アドゥリン ?-?T? Ledericus"
    },
    [879] = {
        name = "イナンデーション",
        description = "標的に異なる種別の武器のウェポンスキルを使用すると、連携ダメージアップ。",
        shop = "ジュノ下層 H-9T2 Creepstix\nジュノ下層 H-9T9 Hasim"
    },
    [281] = {
        name = "火門の計",
        description = "敵を火属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [279] = {
        name = "水門の計",
        description = "敵を水属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [283] = {
        name = "雷門の計",
        description = "敵を雷属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [282] = {
        name = "氷門の計",
        description = "敵を氷属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [278] = {
        name = "土門の計",
        description = "敵を土属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [280] = {
        name = "風門の計",
        description = "敵を風属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [285] = {
        name = "光門の計",
        description = "敵を光属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [284] = {
        name = "闇門の計",
        description = "敵を闇属性のダメージがじわじわ蝕む。天候や曜日に大きく影響される。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [115] = {
        name = "熱波の陣",
        description = "標的のパーティメンバーの周囲の天候を熱波にする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [113] = {
        name = "豪雨の陣",
        description = "標的のパーティメンバーの周囲の天候を雨にする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [117] = {
        name = "疾雷の陣",
        description = "標的のパーティメンバーの周囲の天候を雷にする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [116] = {
        name = "吹雪の陣",
        description = "標的のパーティメンバーの周囲の天候を雪にする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [99] = {
        name = "砂塵の陣",
        description = "標的のパーティメンバーの周囲の天候を砂塵にする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [114] = {
        name = "烈風の陣",
        description = "標的のパーティメンバーの周囲の天候を風にする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [119] = {
        name = "極光の陣",
        description = "標的のパーティメンバーの周囲の天候をオーロラにする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [118] = {
        name = "妖霧の陣",
        description = "標的のパーティメンバーの周囲の天候を妖霧にする。",
        shop = "エルディーム古墳〔Ｓ〕 J-8T4 Layton"
    },
    [308] = {
        name = "悪事千里の策",
        description = "標的のパーティメンバーの敵対心を上がりやすくする。",
        shop = "バストゥーク商業区〔Ｓ〕 L-10T5 Silke"
    },
    [309] = {
        name = "暗中飛躍の策",
        description = "標的のパーティメンバーの敵対心を上がりにくくする。",
        shop = "バストゥーク商業区〔Ｓ〕 L-10T5 Silke"
    },
    [495] = {
        name = "鼓舞激励の策",
        description = "標的のパーティメンバーのTPを徐々に増加する。",
        shop = "バストゥーク商業区〔Ｓ〕 L-10T5 Silke"
    },
    [768] = {
        name = "インデリゲイン",
        description = "",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [769] = {
        name = "インデポイズン",
        description = "自身の周囲の敵は毒で徐々にHPを失う。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [770] = {
        name = "インデリフレシュ",
        description = "自身の周囲のパーティメンバーのMPを徐々に回復。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [772] = {
        name = "インデスト",
        description = "自身の周囲のパーティメンバーのSTRアップ。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [773] = {
        name = "インデデック",
        description = "自身の周囲のパーティメンバーのDEXアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [774] = {
        name = "インデバイト",
        description = "自身の周囲のパーティメンバーのVITアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [775] = {
        name = "インデアジル",
        description = "自身の周囲のパーティメンバーのAGIアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [776] = {
        name = "インデイン",
        description = "自身の周囲のパーティメンバーのINTアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [777] = {
        name = "インデマイン",
        description = "自身の周囲のパーティメンバーのMNDアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [778] = {
        name = "インデカリス",
        description = "自身の周囲のパーティメンバーのCHRアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [779] = {
        name = "インデフューリー",
        description = "自身の周囲のパーティメンバーの攻撃力をアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [780] = {
        name = "インデバリア",
        description = "自身の周囲のパーティメンバーの防御力をアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [781] = {
        name = "インデアキュメン",
        description = "自身の周囲のパーティメンバーの魔法攻撃力をアップ。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [782] = {
        name = "インデフェンド",
        description = "自身の周囲のパーティメンバーの魔法防御力をアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [783] = {
        name = "インデプレサイス",
        description = "自身の周囲のパーティメンバーの命中率をアップ。(補足:遠隔攻撃も含む)",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [784] = {
        name = "インデヴォイダンス",
        description = "自身の周囲のパーティメンバーの回避率をアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [785] = {
        name = "インデフォーカス",
        description = "自身の周囲のパーティメンバーの魔法命中率をアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [786] = {
        name = "インデアトゥーン",
        description = "自身の周囲のパーティメンバーの魔法回避率をアップ。",
        shop = "西アドゥリン ?-?T? Ishvad"
    },
    [787] = {
        name = "インデウィルト",
        description = "自身の周囲の敵の攻撃力をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [788] = {
        name = "インデフレイル",
        description = "自身の周囲の敵の防御力をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [789] = {
        name = "インデフェイド",
        description = "自身の周囲の敵の魔法攻撃力をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [790] = {
        name = "インデマレーズ",
        description = "自身の周囲の敵の魔法防御力をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [791] = {
        name = "インデスリップ",
        description = "自身の周囲の敵の命中率をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [792] = {
        name = "インデトーパー",
        description = "自身の周囲の敵の回避率をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [793] = {
        name = "インデヴェックス",
        description = "自身の周囲の敵の魔法命中率をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [794] = {
        name = "インデランゴール",
        description = "自身の周囲の敵の魔法回避率をダウン。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [795] = {
        name = "インデスロウ",
        description = "自身の周囲の敵の攻撃間隔を長くする。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [796] = {
        name = "インデパライズ",
        description = "自身の周囲の敵を麻痺させる。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [797] = {
        name = "インデグラビデ",
        description = "自身の周囲の敵をヘヴィ状態にして、移動速度を遅くする。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [771] = {
        name = "インデリジェネ",
        description = "自身の周囲のパーティメンバーのHPを徐々に回復。",
        shop = "西アドゥリン ?-?T? Eukalline"
    },
    [79] = {
        name = "スロウII",
        description = "敵の攻撃間隔を長くする。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [80] = {
        name = "パライズII",
        description = "敵を麻痺させる。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
    [107] = {
        name = "ファランクスII",
        description = "標的のパーティメンバーが受けるダメージを一定量軽減する。",
        shop = "ジュノ下層 H-9T9 Hasim"
    },
}

return magic_definitions