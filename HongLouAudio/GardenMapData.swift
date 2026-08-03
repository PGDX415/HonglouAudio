//
//  GardenMapData.swift
//  HongLouAudio
//

import Foundation
import SwiftUI

// MARK: - Garden Location

struct GardenLocation: Identifiable {
    let id = UUID()
    let name: String
    let category: LocationCategory
    let residents: [String]
    let description: String
    let keyEvents: [String]
    let position: CGPoint       // relative position on map canvas (0-1 normalized)
    let landmarkColor: Color
    let iconName: String
}

enum LocationCategory: String, CaseIterable {
    case residence = "居所"
    case pavilion = "亭台楼阁"
    case temple = "寺庙"
    case landscape = "山水景观"
}

// MARK: - Garden Store

struct GardenStore {
    static let locations: [GardenLocation] = [
        // ——— 南面入口 ———
        GardenLocation(
            name: "正门",
            category: .pavilion,
            residents: [],
            description: "大观园的正门，面南而开。门上悬'大观园'匾额，两侧石狮镇守。入门即见一带翠嶂挡在面前，将园中景致尽数遮住，留下无限悬念。",
            keyEvents: [
                "贾政率众清客游园题匾额",
                "元妃省亲时仪仗由此入门"
            ],
            position: CGPoint(x: 0.50, y: 0.92),
            landmarkColor: Color(red: 0.55, green: 0.08, blue: 0.08),
            iconName: "building.columns.fill"
        ),
        GardenLocation(
            name: "翠嶂",
            category: .landscape,
            residents: [],
            description: "入门后迎面的一带假山叠石，白石崚嶒，苔藓斑驳，藤萝掩映。贾政赞其'非此一山，一进来园中所有之景悉入目中，则有何趣'。",
            keyEvents: [
                "贾政评此山为画中'大主山'之脉络"
            ],
            position: CGPoint(x: 0.50, y: 0.84),
            landmarkColor: Color(red: 0.2, green: 0.6, blue: 0.3),
            iconName: "fossil.shell.fill"
        ),

        // ——— 中央水域 ———
        GardenLocation(
            name: "沁芳亭",
            category: .pavilion,
            residents: [],
            description: "建在沁芳溪石桥之上的亭子，四面俱是游廊，曲槛临水。此处是大观园交通要冲，连接园中各处。'沁芳'二字乃宝玉所题，取'绕堤柳借三篙翠，隔岸花分一脉香'之意。",
            keyEvents: [
                "宝玉在此题'沁芳'匾额",
                "黛玉葬花归来在此与宝玉相遇",
                "众人常经此往来各处"
            ],
            position: CGPoint(x: 0.50, y: 0.58),
            landmarkColor: Color(red: 0.7, green: 0.3, blue: 0.15),
            iconName: "tent.fill"
        ),

        // ——— 西侧 ———
        GardenLocation(
            name: "潇湘馆",
            category: .residence,
            residents: ["林黛玉", "紫鹃", "雪雁"],
            description: "林黛玉的居所。院内千百竿翠竹掩映，凤尾森森，龙吟细细。小小三间房舍，一明两暗。后院有梨花兼芭蕉，泉水绕阶缘屋至前院盘旋竹下而出。其幽静清雅的氛围，正合黛玉孤高脱俗的性格。",
            keyEvents: [
                "黛玉初入大观园择居于此",
                "宝黛共读《西厢》",
                "黛玉魁夺菊花诗",
                "黛玉焚稿断痴情"
            ],
            position: CGPoint(x: 0.18, y: 0.40),
            landmarkColor: Color(red: 0.3, green: 0.7, blue: 0.35),
            iconName: "leaf.fill"
        ),
        GardenLocation(
            name: "秋爽斋",
            category: .residence,
            residents: ["贾探春", "侍书"],
            description: "贾探春的住所。院内植有芭蕉与梧桐，三间屋子不曾隔断，显得格外阔朗通透。当地放着一张花梨大理石大案，案上磊着各种名人法帖并数十方宝砚，各色笔筒内插的笔如树林一般。",
            keyEvents: [
                "探春在此发起海棠诗社",
                "抄检大观园时探春怒打王善保家的"
            ],
            position: CGPoint(x: 0.28, y: 0.48),
            landmarkColor: Color(red: 0.75, green: 0.55, blue: 0.2),
            iconName: "paintbrush.fill"
        ),
        GardenLocation(
            name: "紫菱洲",
            category: .residence,
            residents: ["贾迎春", "司棋"],
            description: "贾迎春的居所，临水而建。院内有紫菱花架，轩窗寂寥，别有幽情。迎春性格懦弱，此处的清冷幽静亦如其人。",
            keyEvents: [
                "迎春出嫁后宝玉在此凭吊感怀",
                "菱洲寂寥见迎春命运之悲"
            ],
            position: CGPoint(x: 0.10, y: 0.52),
            landmarkColor: Color(red: 0.5, green: 0.4, blue: 0.7),
            iconName: "drop.fill"
        ),

        // ——— 东侧 ———
        GardenLocation(
            name: "怡红院",
            category: .residence,
            residents: ["贾宝玉", "袭人","晴雯","麝月","秋纹"],
            description: "贾宝玉的居所，大观园中最富丽堂皇的院落。院中点衬几块山石，一边种着数本芭蕉，一边乃是一棵西府海棠。宝玉题匾'红香绿玉'，元妃改为'怡红快绿'，故名怡红院。室内雕空玲珑木板，花团锦簇，玲珑剔透。",
            keyEvents: [
                "宝玉择居于此",
                "晴雯撕扇",
                "刘姥姥醉卧怡红院",
                "晴雯被逐后宝玉作《芙蓉女儿诔》"
            ],
            position: CGPoint(x: 0.82, y: 0.38),
            landmarkColor: Color(red: 0.85, green: 0.25, blue: 0.3),
            iconName: "heart.fill"
        ),
        GardenLocation(
            name: "藕香榭",
            category: .pavilion,
            residents: [],
            description: "建在水中的亭榭，四面有窗，左右有曲廊可通，跨水接岸。盖在池中，四面荷花盛开。此处为贾惜春的居所附近，也是众人赏花观鱼、宴饮作乐的雅处。",
            keyEvents: [
                "史湘云在此设螃蟹宴",
                "众人赏桂花、咏菊花诗",
                "贾母在此宴请刘姥姥"
            ],
            position: CGPoint(x: 0.70, y: 0.62),
            landmarkColor: Color(red: 0.85, green: 0.5, blue: 0.6),
            iconName: "water.waves"
        ),

        // ——— 北侧 ———
        GardenLocation(
            name: "蘅芜苑",
            category: .residence,
            residents: ["薛宝钗", "莺儿"],
            description: "薛宝钗的居所。院中一株花木也无，只见许多异草：或有牵藤的，或有引蔓的，或垂山巅，或穿石隙，甚至垂檐绕柱，萦砌盘阶。贾政初见此院，叹道'有趣！只是不大认得'。其清雅朴素正如宝钗'淡极始知花更艳'的品格。",
            keyEvents: [
                "宝钗初入大观园择居于此",
                "贾母在此为宝钗庆生",
                "众人在此赏异草、品香茗"
            ],
            position: CGPoint(x: 0.55, y: 0.08),
            landmarkColor: Color(red: 0.4, green: 0.55, blue: 0.4),
            iconName: "camera.macro"
        ),
        GardenLocation(
            name: "大观楼",
            category: .pavilion,
            residents: [],
            description: "大观园的正殿，元妃省亲时的主要场所。崇阁巍峨，层楼高起，面面琳宫合抱，迢迢复道萦纡。青松拂檐，玉栏绕砌，金辉兽面，彩焕螭头。正殿匾额题'顾恩思义'。",
            keyEvents: [
                "元妃省亲，在此升座受礼",
                "元妃命诸姐妹题咏大观园"
            ],
            position: CGPoint(x: 0.50, y: 0.20),
            landmarkColor: Color(red: 0.7, green: 0.5, blue: 0.1),
            iconName: "building.2.fill"
        ),
        GardenLocation(
            name: "稻香村",
            category: .residence,
            residents: ["李纨", "贾兰"],
            description: "李纨母子的居所。一带黄泥筑就矮墙，墙头皆用稻茎掩护。有几百株杏花如喷火蒸霞一般。里面数楹茅屋，外面却是桑榆槿柘各色树稚新条随其曲折编就两溜青篱。篱外山坡之下有一土井，旁有辘轳之属。下面分畦列亩，佳蔬菜花，漫然无际。",
            keyEvents: [
                "李纨在此抚育贾兰读书",
                "诗社中李纨自号'稻香老农'"
            ],
            position: CGPoint(x: 0.20, y: 0.22),
            landmarkColor: Color(red: 0.6, green: 0.5, blue: 0.2),
            iconName: "leaf.arrow.circlepath"
        ),
        GardenLocation(
            name: "栊翠庵",
            category: .temple,
            residents: ["妙玉"],
            description: "妙玉的修行之所，位于大观园东北角。院中花木繁盛，红梅映雪最为奇绝。妙玉在此带发修行，虽入空门却难舍红尘。庵中茶具珍玩皆为稀世之品。",
            keyEvents: [
                "妙玉在此接待贾母与刘姥姥品茶",
                "宝玉乞红梅",
                "妙玉送贴贺宝玉生辰"
            ],
            position: CGPoint(x: 0.90, y: 0.15),
            landmarkColor: Color(red: 0.65, green: 0.1, blue: 0.2),
            iconName: "moon.stars.fill"
        ),

        // ——— 其他景观 ———
        GardenLocation(
            name: "凸碧山庄",
            category: .pavilion,
            residents: [],
            description: "建于山脊之上的亭子，地势最高。中秋之夜，贾母率众人在此赏月。因建于高坡上，故以'凸碧'名之。是园中登高望远的最佳处。",
            keyEvents: [
                "贾母在此率众人中秋赏月",
                "黛玉与湘云在此联诗"
            ],
            position: CGPoint(x: 0.68, y: 0.26),
            landmarkColor: Color(red: 0.3, green: 0.5, blue: 0.7),
            iconName: "sun.max.fill"
        ),
        GardenLocation(
            name: "凹晶溪馆",
            category: .pavilion,
            residents: [],
            description: "建于低洼水边的馆舍，与凸碧山庄一上一下呼应，取'凹凸'之意。黛玉与湘云中秋夜在此联诗至深夜，留下了'寒塘渡鹤影，冷月葬花魂'的千古绝唱。",
            keyEvents: [
                "黛玉与湘云联诗'寒塘渡鹤影，冷月葬花魂'",
                "妙玉在此续完联句"
            ],
            position: CGPoint(x: 0.62, y: 0.32),
            landmarkColor: Color(red: 0.3, green: 0.45, blue: 0.65),
            iconName: "moon.fill"
        ),
    ]
}
