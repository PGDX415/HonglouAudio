//
//  DailyQuoteData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation

struct DailyQuote: Identifiable {
    let id: Int
    let text: String
    let source: String  // character + chapter
}

struct DailyQuoteStore {
    /// Returns the quote for today based on day-of-year
    static func todayQuote() -> DailyQuote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % quotes.count
        return quotes[index]
    }

    static let quotes: [DailyQuote] = [
        DailyQuote(id: 1, text: "满纸荒唐言，一把辛酸泪。都云作者痴，谁解其中味？", source: "第一回 · 开篇诗"),
        DailyQuote(id: 2, text: "女儿是水做的骨肉，男人是泥做的骨肉。我见了女儿便觉清爽，见了男子便觉浊臭逼人。", source: "贾宝玉 · 第二回"),
        DailyQuote(id: 3, text: "世事洞明皆学问，人情练达即文章。", source: "第五回 · 宁国府对联"),
        DailyQuote(id: 4, text: "假作真时真亦假，无为有处有还无。", source: "第一回 · 太虚幻境对联"),
        DailyQuote(id: 5, text: "机关算尽太聪明，反算了卿卿性命。", source: "第五回 · 王熙凤判词"),
        DailyQuote(id: 6, text: "花谢花飞花满天，红消香断有谁怜？", source: "林黛玉 · 第二十七回"),
        DailyQuote(id: 7, text: "好风凭借力，送我上青云。", source: "薛宝钗 · 第七十回"),
        DailyQuote(id: 8, text: "弱水三千，我只取一瓢饮。", source: "贾宝玉 · 第九十一回"),
        DailyQuote(id: 9, text: "月满则亏，水满则溢。", source: "秦可卿 · 第十三回"),
        DailyQuote(id: 10, text: "千里搭长棚，没有不散的筵席。", source: "小红 · 第二十六回"),
        DailyQuote(id: 11, text: "不是东风压了西风，就是西风压了东风。", source: "林黛玉 · 第八十二回"),
        DailyQuote(id: 12, text: "瘦死的骆驼比马大。", source: "刘姥姥 · 第六回"),
        DailyQuote(id: 13, text: "万两黄金容易得，知心一个也难求。", source: "紫鹃 · 第五十七回"),
        DailyQuote(id: 14, text: "大丈夫相时而动。", source: "贾雨村 · 第四回"),
        DailyQuote(id: 15, text: "得饶人处且饶人。", source: "平儿 · 第五十九回"),
        DailyQuote(id: 16, text: "是真名士自风流。", source: "史湘云 · 第四十九回"),
        DailyQuote(id: 17, text: "天下没有不可用的东西，既可用，便值钱。", source: "薛宝钗 · 第五十六回"),
        DailyQuote(id: 18, text: "但凡家庭之事，不是东风压了西风，就是西风压了东风。", source: "林黛玉 · 第八十二回"),
        DailyQuote(id: 19, text: "人有聚就有散，聚时欢喜，到散时岂不清冷？", source: "林黛玉 · 第三十一回"),
        DailyQuote(id: 20, text: "心病终须心药治，解铃还须系铃人。", source: "第八十回"),
        DailyQuote(id: 21, text: "纵有千年铁门槛，终须一个土馒头。", source: "妙玉 · 第六十三回"),
        DailyQuote(id: 22, text: "百足之虫，死而不僵。", source: "贾探春 · 第七十四回"),
        DailyQuote(id: 23, text: "闲时为你死，忙时各逃生。", source: "第六十一回"),
        DailyQuote(id: 24, text: "子系中山狼，得志便猖狂。", source: "第五回 · 迎春判词"),
        DailyQuote(id: 25, text: "赤条条来去无牵挂。", source: "贾宝玉 · 第二十二回"),
        DailyQuote(id: 26, text: "玉在椟中求善价，钗于奁内待时飞。", source: "贾雨村 · 第一回"),
        DailyQuote(id: 27, text: "身后有余忘缩手，眼前无路想回头。", source: "第二回 · 智通寺对联"),
        DailyQuote(id: 28, text: "叹人间美中不足今方信，纵然是齐眉举案，到底意难平。", source: "第五回 · 红楼梦曲"),
        DailyQuote(id: 29, text: "才自精明志自高，生于末世运偏消。", source: "第五回 · 探春判词"),
        DailyQuote(id: 30, text: "一损皆损，一荣皆荣。", source: "第四回 · 门子解说护官符"),
        DailyQuote(id: 31, text: "春恨秋悲皆自惹，花容月貌为谁妍。", source: "第五回 · 太虚幻境薄命司对联"),
    ]
}
