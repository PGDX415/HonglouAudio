//
//  FlowerLotData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation
import SwiftUI

struct FlowerSlip: Identifiable {
    let id: Int
    let flower: String          // 花名
    let emoji: String           // flower emoji
    let title: String           // 题词 (four-character tag)
    let verse: String           // 签上的诗句
    let verseSource: String     // 诗句出处
    let character: String       // 对应红楼人物
    let characterDesc: String   // 人物简介
    let fortune: String         // 现代解读
    let color: Color            // 花色
    let isOriginal: Bool        // 是否原著第六十三回原签
}

struct FlowerLotStore {
    static let slips: [FlowerSlip] = [
        // MARK: 原著八签（第六十三回）
        FlowerSlip(id: 1,
            flower: "牡丹", emoji: "🌸", title: "艳冠群芳",
            verse: "任是无情也动人", verseSource: "唐·罗隐《牡丹花》",
            character: "薛宝钗", characterDesc: "丰姿美丽、端庄贤淑，博学多才却深藏不露。",
            fortune: "你如牡丹——大气雍容，无需刻意讨好，自有倾城之姿。今日宜从容自信，不必迎合他人。",
            color: Color(red: 0.85, green: 0.25, blue: 0.35), isOriginal: true
        ),
        FlowerSlip(id: 2,
            flower: "杏花", emoji: "🌸", title: "瑶池仙品",
            verse: "日边红杏倚云栽", verseSource: "唐·高蟾《下第后上永崇高侍郎》",
            character: "贾探春", characterDesc: "精明能干、志向高远，有'玫瑰花'之称。",
            fortune: "你如杏花——志存高远，不甘平凡。虽出身受限，终将凭借才华为自己争得一片天。",
            color: Color(red: 0.95, green: 0.7, blue: 0.75), isOriginal: true
        ),
        FlowerSlip(id: 3,
            flower: "老梅", emoji: "🌸", title: "霜晓寒姿",
            verse: "竹篱茅舍自甘心", verseSource: "宋·王琪《梅》",
            character: "李纨", characterDesc: "寡居守节、淡泊自守，将一切希望寄托在儿子贾兰身上。",
            fortune: "你如寒梅——甘于淡泊，不争不抢。看似孤独，实则在静默中积蓄着最深的力量。",
            color: Color(red: 0.85, green: 0.5, blue: 0.6), isOriginal: true
        ),
        FlowerSlip(id: 4,
            flower: "海棠", emoji: "🌺", title: "香梦沉酣",
            verse: "只恐夜深花睡去", verseSource: "宋·苏轼《海棠》",
            character: "史湘云", characterDesc: "豪爽率直、才思敏捷，心直口快无城府。",
            fortune: "你如海棠——天真烂漫，无拘无束。人生苦短，何必处处设防？保持你的赤子之心。",
            color: Color(red: 0.9, green: 0.45, blue: 0.55), isOriginal: true
        ),
        FlowerSlip(id: 5,
            flower: "荼蘼", emoji: "🌼", title: "韶华胜极",
            verse: "开到荼蘼花事了", verseSource: "宋·王淇《春暮游小园》",
            character: "麝月", characterDesc: "宝玉身边最后的丫鬟，安静隐忍，陪宝玉走到最后。",
            fortune: "你如荼蘼——盛开在春末，看过所有繁华，也见过所有凋零。你不喧哗，却走得最远。",
            color: Color(red: 0.95, green: 0.85, blue: 0.55), isOriginal: true
        ),
        FlowerSlip(id: 6,
            flower: "并蒂花", emoji: "💐", title: "联春绕瑞",
            verse: "连理枝头花正开", verseSource: "宋·朱淑真《落花》",
            character: "香菱", characterDesc: "甄士隐之女英莲，自幼被拐，命运多舛却始终纯真善良。",
            fortune: "你如并蒂莲——历经风雨仍保持纯真。命运曾亏待于你，但你从未失去善良的本心。",
            color: Color(red: 0.85, green: 0.65, blue: 0.75), isOriginal: true
        ),
        FlowerSlip(id: 7,
            flower: "芙蓉", emoji: "🌺", title: "风露清愁",
            verse: "莫怨东风当自嗟", verseSource: "宋·欧阳修《明妃曲》",
            character: "林黛玉", characterDesc: "才情绝世、敏感多情，以一生的眼泪偿前世的恩情。",
            fortune: "你如芙蓉——遗世独立，清愁入骨。不必怨天尤人，你的敏感是你最深的才华。",
            color: Color(red: 0.7, green: 0.25, blue: 0.4), isOriginal: true
        ),
        FlowerSlip(id: 8,
            flower: "桃花", emoji: "🌸", title: "武陵别景",
            verse: "桃红又是一年春", verseSource: "宋·谢枋得《庆全庵桃花》",
            character: "袭人", characterDesc: "温柔体贴、尽心尽责，从丫鬟做到宝玉的准姨娘。",
            fortune: "你如桃花——春光易逝，但年年可再。你务实周到，在新的环境中总能重新绽放。",
            color: Color(red: 0.9, green: 0.55, blue: 0.6), isOriginal: true
        ),
        // MARK: 续补四签
        FlowerSlip(id: 9,
            flower: "菊花", emoji: "🏵️", title: "孤标傲世",
            verse: "一从陶令平章后，千古高风说到今", verseSource: "《红楼梦》·黛玉《咏菊》",
            character: "林黛玉", characterDesc: "黛玉以菊花自喻——不与百花争春，独在霜秋绽放。",
            fortune: "你如秋菊——孤高自许，不随流俗。你的骄傲是你最珍贵的铠甲，不必为谁改变。",
            color: Color(red: 0.95, green: 0.8, blue: 0.35), isOriginal: false
        ),
        FlowerSlip(id: 10,
            flower: "兰花", emoji: "🌿", title: "空谷幽兰",
            verse: "气质美如兰，才华馥比仙", verseSource: "《红楼梦曲·世难容》",
            character: "妙玉", characterDesc: "出身不凡的修行之人，孤傲清高，才华横溢却不容于世。",
            fortune: "你如幽兰——遗世独立，不求人知。你的世界自成一格，不必勉强融入喧嚣。",
            color: Color(red: 0.55, green: 0.7, blue: 0.5), isOriginal: false
        ),
        FlowerSlip(id: 11,
            flower: "红梅", emoji: "🌺", title: "琉璃世界",
            verse: "看来岂是寻常色，浓淡由他冰雪中", verseSource: "《红楼梦》·宝玉《咏红梅》",
            character: "贾宝玉", characterDesc: "叛逆不羁、重情重义，厌恶仕途经济，向往纯粹的情与美。",
            fortune: "你如红梅——不媚世俗，冰雪自赏。在冰冷的世界里保持自己的温度，你的'不通世故'恰是你最可贵之处。",
            color: Color(red: 0.75, green: 0.2, blue: 0.25), isOriginal: false
        ),
        FlowerSlip(id: 12,
            flower: "玫瑰", emoji: "🌹", title: "带刺玫瑰",
            verse: "机关算尽太聪明，反算了卿卿性命", verseSource: "《红楼梦曲·聪明累》",
            character: "王熙凤", characterDesc: "精明强干、口齿伶俐，掌管贾府数百人口，却聪明反被聪明误。",
            fortune: "你如玫瑰——美丽而有刺，能干却招嫉。你的锋芒是你的武器，但有时不妨柔软一些。",
            color: Color(red: 0.75, green: 0.15, blue: 0.2), isOriginal: false
        ),
    ]

    static func drawSlip() -> FlowerSlip {
        slips.randomElement()!
    }
}
