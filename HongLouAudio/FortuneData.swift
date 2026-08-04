//
//  FortuneData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation
import SwiftUI

enum FortuneLevel: String {
    case 上上签 = "上上签"
    case 上签 = "上签"
    case 中签 = "中签"
    case 下签 = "下签"

    var color: Color {
        switch self {
        case .上上签: return Color(red: 0.8, green: 0.15, blue: 0.15)
        case .上签: return Color(red: 0.85, green: 0.45, blue: 0.2)
        case .中签: return Color(red: 0.55, green: 0.55, blue: 0.55)
        case .下签: return Color(red: 0.3, green: 0.5, blue: 0.7)
        }
    }

    var icon: String {
        switch self {
        case .上上签: return "sparkles"
        case .上签: return "star.fill"
        case .中签: return "circle.fill"
        case .下签: return "drop.fill"
        }
    }
}

struct FortuneSlip: Identifiable {
    let id: Int
    let verse: String          // original poem line
    let source: String          // 判词出处 / 人物
    let guidance: String        // modern fortune interpretation
    let keyword: String         // one-word theme
    let level: FortuneLevel
}

struct FortuneStore {
    static let slips: [FortuneSlip] = [
        FortuneSlip(id: 1,
            verse: "可叹停机德，堪怜咏絮才。玉带林中挂，金簪雪里埋。",
            source: "金陵十二钗 · 黛玉宝钗判词",
            guidance: "才华与品德皆备，然世事未必如愿。今日宜安守本心，不必强求他人认可。林中玉带自高贵，雪里金簪终放光。等待属于你的时机。",
            keyword: "守心",
            level: .中签
        ),
        FortuneSlip(id: 2,
            verse: "一个是阆苑仙葩，一个是美玉无瑕。若说没奇缘，今生偏又遇着他；若说有奇缘，如何心事终虚化？",
            source: "红楼梦曲 · 枉凝眉",
            guidance: "缘分之事，强求不得。遇见已是难得，何必执念于结果？今日宜放下执念，珍惜眼前人。虚化亦是圆满的一种。",
            keyword: "随缘",
            level: .中签
        ),
        FortuneSlip(id: 3,
            verse: "好风凭借力，送我上青云。",
            source: "薛宝钗 · 柳絮词",
            guidance: "时机将至，贵人助力在侧。今日宜主动出击、借势而上。不要犹豫，东风已起，正是扬帆之时。",
            keyword: "借势",
            level: .上上签
        ),
        FortuneSlip(id: 4,
            verse: "机关算尽太聪明，反算了卿卿性命。",
            source: "红楼梦曲 · 聪明累",
            guidance: "聪明反被聪明误。今日宜拙不宜巧，以诚待人胜过机关算尽。退一步海阔天空，莫让心机困住自己。",
            keyword: "守拙",
            level: .下签
        ),
        FortuneSlip(id: 5,
            verse: "才自精明志自高，生于末世运偏消。",
            source: "金陵十二钗 · 探春判词",
            guidance: "空有才华抱负，却受限于环境。今日宜韬光养晦、积蓄力量，不必急于求成。大环境不利时，保全自身即是胜利。",
            keyword: "蓄力",
            level: .中签
        ),
        FortuneSlip(id: 6,
            verse: "是真名士自风流。",
            source: "史湘云 · 第四十九回",
            guidance: "不必在意世俗眼光，做真实的自己最潇洒。今日宜率性而为，不拘小节。真正的风度不靠装饰，自内心而生。",
            keyword: "率真",
            level: .上上签
        ),
        FortuneSlip(id: 7,
            verse: "月满则亏，水满则溢。",
            source: "秦可卿 · 第十三回",
            guidance: "凡事不可求满。今日宜收敛锋芒、见好就收。满招损、谦受益——留有余地，方能持久。",
            keyword: "知止",
            level: .中签
        ),
        FortuneSlip(id: 8,
            verse: "纵有千年铁门槛，终须一个土馒头。",
            source: "妙玉 · 第六十三回",
            guidance: "富贵荣华皆是过眼云烟。今日宜看淡得失、修身养性。真正的财富是内心的安宁，而非物质的堆砌。",
            keyword: "看淡",
            level: .中签
        ),
        FortuneSlip(id: 9,
            verse: "偶因济刘氏，巧得遇恩人。",
            source: "金陵十二钗 · 巧姐判词",
            guidance: "善有善报，今日的善举将成明日的福报。宜助人为乐、广结善缘。你可能在帮助别人的同时，也为自己种下了幸运的种子。",
            keyword: "行善",
            level: .上签
        ),
        FortuneSlip(id: 10,
            verse: "赤条条来去无牵挂。",
            source: "贾宝玉 · 第二十二回",
            guidance: "放下即是自在。今日宜断舍离——放下不必要的执念、关系、物品。一身轻才能走得更远。",
            keyword: "放下",
            level: .上签
        ),
        FortuneSlip(id: 11,
            verse: "瘦死的骆驼比马大。",
            source: "刘姥姥 · 第六回",
            guidance: "即使身处低谷，底蕴犹在。今日不必妄自菲薄——你的积累和经验是你最大的底气。困境只是暂时的。",
            keyword: "自信",
            level: .上签
        ),
        FortuneSlip(id: 12,
            verse: "寒塘渡鹤影，冷月葬花魂。",
            source: "林黛玉 · 第七十六回",
            guidance: "孤独与悲伤皆有时。今日若感落寞，不必强颜欢笑。允许自己脆弱，泪水之后自有晴空。深夜过后，便是黎明。",
            keyword: "释怀",
            level: .下签
        ),
        FortuneSlip(id: 13,
            verse: "得饶人处且饶人。",
            source: "平儿 · 第五十九回",
            guidance: "宽容是最高级的智慧。今日宜宽以待人、不计较小过。你放过的不是别人，而是自己的心境。",
            keyword: "宽容",
            level: .上上签
        ),
        FortuneSlip(id: 14,
            verse: "千里搭长棚，没有不散的筵席。",
            source: "小红 · 第二十六回",
            guidance: "聚散离合皆有时。今日若面临离别或结束，不必太过伤感。每一段结束都是新开始的序章。",
            keyword: "看开",
            level: .中签
        ),
        FortuneSlip(id: 15,
            verse: "身后有余忘缩手，眼前无路想回头。",
            source: "智通寺对联 · 第二回",
            guidance: "贪念是人性最大的陷阱。今日宜反思：是否在某些事上贪得无厌？及时收手，莫等无路可走才后悔。",
            keyword: "节制",
            level: .下签
        ),
        FortuneSlip(id: 16,
            verse: "淡极始知花更艳，愁多焉得玉无痕。",
            source: "薛宝钗 · 咏白海棠",
            guidance: "平淡中方见真味。今日不必追求轰轰烈烈——安静地做好手头的事，朴素里有最持久的美。",
            keyword: "守静",
            level: .上签
        ),
        FortuneSlip(id: 17,
            verse: "万两黄金容易得，知心一个也难求。",
            source: "紫鹃 · 第五十七回",
            guidance: "真正的知己比黄金更珍贵。今日宜珍惜身边懂你的人，不必把时间浪费在无意义的社交上。",
            keyword: "惜缘",
            level: .上签
        ),
        FortuneSlip(id: 18,
            verse: "假作真时真亦假，无为有处有还无。",
            source: "太虚幻境对联 · 第一回",
            guidance: "真真假假，不必太过较真。今日若遇迷惑之事，不妨先放一放。时间自会揭开一切真相。",
            keyword: "不惑",
            level: .中签
        ),
        FortuneSlip(id: 19,
            verse: "子系中山狼，得志便猖狂。",
            source: "金陵十二钗 · 迎春判词",
            guidance: "提醒你小心身边的小人得志。今日宜低调行事、谨言慎行，不要与小人争锋。君子报仇十年不晚，先保全自己。",
            keyword: "避险",
            level: .下签
        ),
        FortuneSlip(id: 20,
            verse: "满纸荒唐言，一把辛酸泪。都云作者痴，谁解其中味？",
            source: "第一回 · 开篇诗",
            guidance: "你的心思并非人人能懂，但这正是你独特之处。今日不必解释太多，懂你的人自然懂。保持你的'痴'——那是你最珍贵的品质。",
            keyword: "自持",
            level: .上签
        ),
    ]

    /// Draw a random fortune slip
    static func drawSlip() -> FortuneSlip {
        slips.randomElement()!
    }
}
