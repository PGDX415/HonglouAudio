//
//  FlyingFlowerData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation

struct Couplet: Identifiable {
    let id: Int
    let firstHalf: String
    let secondHalf: String
    let poemTitle: String
    let author: String
    let chapterNumber: Int
}

struct FlyingFlowerStore {
    static let couplets: [Couplet] = [
        Couplet(id: 1, firstHalf: "花谢花飞花满天", secondHalf: "红消香断有谁怜", poemTitle: "葬花吟", author: "林黛玉", chapterNumber: 27),
        Couplet(id: 2, firstHalf: "一年三百六十日", secondHalf: "风刀霜剑严相逼", poemTitle: "葬花吟", author: "林黛玉", chapterNumber: 27),
        Couplet(id: 3, firstHalf: "质本洁来还洁去", secondHalf: "强于污淖陷渠沟", poemTitle: "葬花吟", author: "林黛玉", chapterNumber: 27),
        Couplet(id: 4, firstHalf: "侬今葬花人笑痴", secondHalf: "他年葬侬知是谁", poemTitle: "葬花吟", author: "林黛玉", chapterNumber: 27),
        Couplet(id: 5, firstHalf: "一朝春尽红颜老", secondHalf: "花落人亡两不知", poemTitle: "葬花吟", author: "林黛玉", chapterNumber: 27),
        Couplet(id: 6, firstHalf: "好风凭借力", secondHalf: "送我上青云", poemTitle: "临江仙·柳絮", author: "薛宝钗", chapterNumber: 70),
        Couplet(id: 7, firstHalf: "眼前道路无经纬", secondHalf: "皮里春秋空黑黄", poemTitle: "螃蟹咏", author: "薛宝钗", chapterNumber: 38),
        Couplet(id: 8, firstHalf: "淡极始知花更艳", secondHalf: "愁多焉得玉无痕", poemTitle: "咏白海棠", author: "薛宝钗", chapterNumber: 37),
        Couplet(id: 9, firstHalf: "偷来梨蕊三分白", secondHalf: "借得梅花一缕魂", poemTitle: "咏白海棠", author: "林黛玉", chapterNumber: 37),
        Couplet(id: 10, firstHalf: "月窟仙人缝缟袂", secondHalf: "秋闺怨女拭啼痕", poemTitle: "咏白海棠", author: "林黛玉", chapterNumber: 37),
        Couplet(id: 11, firstHalf: "玉是精神难比洁", secondHalf: "雪为肌骨易销魂", poemTitle: "咏白海棠", author: "贾探春", chapterNumber: 37),
        Couplet(id: 12, firstHalf: "芳心一点娇无力", secondHalf: "倩影三更月有痕", poemTitle: "白海棠和韵", author: "史湘云", chapterNumber: 37),
        Couplet(id: 13, firstHalf: "孤标傲世偕谁隐", secondHalf: "一样花开为底迟", poemTitle: "问菊", author: "林黛玉", chapterNumber: 38),
        Couplet(id: 14, firstHalf: "满纸自怜题素怨", secondHalf: "片言谁解诉秋心", poemTitle: "咏菊", author: "林黛玉", chapterNumber: 38),
        Couplet(id: 15, firstHalf: "一从陶令平章后", secondHalf: "千古高风说到今", poemTitle: "咏菊", author: "林黛玉", chapterNumber: 38),
        Couplet(id: 16, firstHalf: "毫端蕴秀临霜写", secondHalf: "口齿噙香对月吟", poemTitle: "咏菊", author: "林黛玉", chapterNumber: 38),
        Couplet(id: 17, firstHalf: "寒塘渡鹤影", secondHalf: "冷月葬花魂", poemTitle: "中秋联句", author: "林黛玉", chapterNumber: 76),
        Couplet(id: 18, firstHalf: "萧疏篱畔科头坐", secondHalf: "清冷香中抱膝吟", poemTitle: "对菊", author: "史湘云", chapterNumber: 38),
        Couplet(id: 19, firstHalf: "隔座香分三径露", secondHalf: "抛书人对一枝秋", poemTitle: "供菊", author: "史湘云", chapterNumber: 38),
        Couplet(id: 20, firstHalf: "珍重芳姿昼掩门", secondHalf: "自携手瓮灌苔盆", poemTitle: "咏白海棠", author: "薛宝钗", chapterNumber: 37),
        Couplet(id: 21, firstHalf: "半卷湘帘半掩门", secondHalf: "碾冰为土玉为盆", poemTitle: "咏白海棠", author: "林黛玉", chapterNumber: 37),
        Couplet(id: 22, firstHalf: "秋阴捧出何方雪", secondHalf: "雨渍添来隔宿痕", poemTitle: "白海棠和韵", author: "史湘云", chapterNumber: 37),
        Couplet(id: 23, firstHalf: "无赖诗魔昏晓侵", secondHalf: "绕篱欹石自沉音", poemTitle: "咏菊", author: "史湘云", chapterNumber: 38),
        Couplet(id: 24, firstHalf: "欲讯秋情众莫知", secondHalf: "喃喃负手叩东篱", poemTitle: "问菊", author: "林黛玉", chapterNumber: 38),
        Couplet(id: 25, firstHalf: "聚叶泼成千点墨", secondHalf: "攒花染出几痕霜", poemTitle: "画菊", author: "薛宝钗", chapterNumber: 38),
        Couplet(id: 26, firstHalf: "蒂有余香金淡泊", secondHalf: "枝无全叶翠离披", poemTitle: "残菊", author: "贾探春", chapterNumber: 38),
        Couplet(id: 27, firstHalf: "桃花帘外东风软", secondHalf: "桃花帘内晨妆懒", poemTitle: "桃花行", author: "林黛玉", chapterNumber: 70),
        Couplet(id: 28, firstHalf: "粉堕百花洲", secondHalf: "香残燕子楼", poemTitle: "唐多令·柳絮", author: "林黛玉", chapterNumber: 70),
        Couplet(id: 29, firstHalf: "岂是绣绒残吐", secondHalf: "卷起半帘香雾", poemTitle: "如梦令·柳絮", author: "史湘云", chapterNumber: 70),
        Couplet(id: 30, firstHalf: "汉苑零星有限", secondHalf: "隋堤点缀无穷", poemTitle: "西江月·柳絮", author: "薛宝琴", chapterNumber: 70),
    ]

    /// Get 10 random couplets for a game round, plus 3 wrong options each
    static func gameRound(count: Int = 10) -> [(couplet: Couplet, options: [String])] {
        let selected = couplets.shuffled().prefix(count)
        return selected.map { couplet in
            let wrongs = couplets
                .filter { $0.id != couplet.id }
                .shuffled()
                .prefix(3)
                .map { $0.secondHalf }
            let options = ([couplet.secondHalf] + wrongs).shuffled()
            return (couplet, options)
        }
    }
}
