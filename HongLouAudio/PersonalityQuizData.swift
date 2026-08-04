//
//  PersonalityQuizData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation
import SwiftUI

struct PersonalityAnswer: Identifiable {
    let id: Int
    let text: String
    let scores: [String: Int]  // character name -> score increment
}

struct PersonalityQuestion: Identifiable {
    let id: Int
    let question: String
    let answers: [PersonalityAnswer]
}

struct PersonalityResult: Identifiable {
    let id = UUID()
    let character: String
    let emoji: String
    let title: String
    let percentage: Int
    let description: String
    let imageName: String
    let color: Color
}

struct PersonalityQuizStore {
    static let questions: [PersonalityQuestion] = [
        PersonalityQuestion(id: 1, question: "你最喜欢的季节是？", answers: [
            PersonalityAnswer(id: 1, text: "🌸 春天 —— 万物复苏，充满希望", scores: ["林黛玉": 3, "贾宝玉": 2]),
            PersonalityAnswer(id: 2, text: "☀️ 夏天 —— 热烈奔放，尽情绽放", scores: ["史湘云": 3, "王熙凤": 2]),
            PersonalityAnswer(id: 3, text: "🍂 秋天 —— 沉静深邃，思绪万千", scores: ["林黛玉": 2, "薛宝钗": 2, "妙玉": 2]),
            PersonalityAnswer(id: 4, text: "❄️ 冬天 —— 清醒克制，积蓄力量", scores: ["薛宝钗": 3, "贾探春": 2])
        ]),
        PersonalityQuestion(id: 2, question: "面对不公平的事，你会？", answers: [
            PersonalityAnswer(id: 1, text: "直接站出来，据理力争", scores: ["贾探春": 3, "王熙凤": 2]),
            PersonalityAnswer(id: 2, text: "心里难过，但不一定会说", scores: ["林黛玉": 3, "贾宝玉": 2]),
            PersonalityAnswer(id: 3, text: "冷静分析，寻找最佳对策", scores: ["薛宝钗": 3, "贾探春": 2]),
            PersonalityAnswer(id: 4, text: "笑一笑，没什么大不了", scores: ["史湘云": 3, "刘姥姥": 2])
        ]),
        PersonalityQuestion(id: 3, question: "在朋友圈/聚会中，你通常是？", answers: [
            PersonalityAnswer(id: 1, text: "气氛担当，有我在就不会冷场", scores: ["史湘云": 3, "王熙凤": 2]),
            PersonalityAnswer(id: 2, text: "安静倾听，偶尔说几句点睛之语", scores: ["薛宝钗": 2, "妙玉": 2, "林黛玉": 2]),
            PersonalityAnswer(id: 3, text: "观察每个人，心里暗暗分析", scores: ["贾探春": 2, "王熙凤": 2, "薛宝钗": 2]),
            PersonalityAnswer(id: 4, text: "看心情——有时话多有时沉默", scores: ["贾宝玉": 3, "林黛玉": 2])
        ]),
        PersonalityQuestion(id: 4, question: "你理想中的生活是？", answers: [
            PersonalityAnswer(id: 1, text: "诗酒琴棋，与知己共度时光", scores: ["贾宝玉": 3, "林黛玉": 2]),
            PersonalityAnswer(id: 2, text: "事业有成，掌控自己的人生", scores: ["王熙凤": 3, "贾探春": 3]),
            PersonalityAnswer(id: 3, text: "岁月静好，平安喜乐", scores: ["薛宝钗": 3, "刘姥姥": 2]),
            PersonalityAnswer(id: 4, text: "远离尘嚣，独善其身", scores: ["妙玉": 3, "林黛玉": 2])
        ]),
        PersonalityQuestion(id: 5, question: "什么最容易让你动心？", answers: [
            PersonalityAnswer(id: 1, text: "才华横溢的人", scores: ["林黛玉": 3, "贾宝玉": 2]),
            PersonalityAnswer(id: 2, text: "温柔体贴的关怀", scores: ["贾宝玉": 3, "薛宝钗": 2]),
            PersonalityAnswer(id: 3, text: "志同道合的默契", scores: ["史湘云": 3, "贾探春": 2]),
            PersonalityAnswer(id: 4, text: "独一无二的理解", scores: ["林黛玉": 2, "妙玉": 2, "贾宝玉": 2])
        ]),
        PersonalityQuestion(id: 6, question: "遇到困难时，你会？", answers: [
            PersonalityAnswer(id: 1, text: "立刻行动，想办法解决", scores: ["王熙凤": 3, "贾探春": 3]),
            PersonalityAnswer(id: 2, text: "向信任的人倾诉求助", scores: ["贾宝玉": 3, "史湘云": 2]),
            PersonalityAnswer(id: 3, text: "独自消化，不想麻烦别人", scores: ["林黛玉": 3, "妙玉": 2]),
            PersonalityAnswer(id: 4, text: "以柔克刚，慢慢化解", scores: ["薛宝钗": 3, "刘姥姥": 2])
        ]),
        PersonalityQuestion(id: 7, question: "朋友会用什么词形容你？", answers: [
            PersonalityAnswer(id: 1, text: "真性情，活得很真实", scores: ["史湘云": 3, "贾宝玉": 2]),
            PersonalityAnswer(id: 2, text: "聪明，有想法", scores: ["贾探春": 3, "王熙凤": 2]),
            PersonalityAnswer(id: 3, text: "温柔，善解人意", scores: ["薛宝钗": 3, "贾宝玉": 2]),
            PersonalityAnswer(id: 4, text: "独特，有自己的一套", scores: ["林黛玉": 3, "妙玉": 3])
        ]),
        PersonalityQuestion(id: 8, question: "你最看重什么？", answers: [
            PersonalityAnswer(id: 1, text: "情义 —— 人生得一知己足矣", scores: ["贾宝玉": 3, "林黛玉": 3]),
            PersonalityAnswer(id: 2, text: "自由 —— 不被束缚地做自己", scores: ["史湘云": 3, "贾探春": 2]),
            PersonalityAnswer(id: 3, text: "安稳 —— 一家人平平安安", scores: ["薛宝钗": 3, "刘姥姥": 3]),
            PersonalityAnswer(id: 4, text: "成就 —— 做出一番事业", scores: ["王熙凤": 3, "贾探春": 2])
        ])
    ]

    static let characterResults: [String: PersonalityResult] = [
        "贾宝玉": PersonalityResult(
            character: "贾宝玉", emoji: "💎", title: "含玉而生的痴情种",
            percentage: 0, description: "你是贾宝玉式的人物——重情重义、叛逆不羁。你厌恶虚伪的规则和功利的算计，只愿活在真情实感里。世人说你'痴'，你却觉得他们不懂。你相信'女儿是水做的骨肉'——柔软、清澈、容不得半点污浊。\n\n你的关键词：真诚、共情、浪漫。",
            imageName: "jia_baoyu", color: Color(red: 0.55, green: 0.5, blue: 0.45)
        ),
        "林黛玉": PersonalityResult(
            character: "林黛玉", emoji: "🪷", title: "风露清愁的世外仙姝",
            percentage: 0, description: "你是林黛玉式的人物——才情绝世、敏感深情。你对美有极高的感知力，对虚伪零容忍。你有时多愁善感，那是因为你比别人看得更透、感受更深。\n\n你的关键词：才情、敏感、纯粹。",
            imageName: "lin_daiyu", color: Color(red: 0.65, green: 0.55, blue: 0.7)
        ),
        "薛宝钗": PersonalityResult(
            character: "薛宝钗", emoji: "🌸", title: "艳冠群芳的蘅芜君",
            percentage: 0, description: "你是薛宝钗式的人物——端庄贤淑、处事圆融。你有超乎常人的智慧和自制力，懂得什么时候该说、什么时候该沉默。你'好风凭借力，送我上青云'——不急不躁，却总能走到高处。\n\n你的关键词：智慧、克制、从容。",
            imageName: "xue_baochai", color: Color(red: 0.85, green: 0.25, blue: 0.35)
        ),
        "王熙凤": PersonalityResult(
            character: "王熙凤", emoji: "🔥", title: "未见其人先闻其声的凤辣子",
            percentage: 0, description: "你是王熙凤式的人物——精明强干、雷厉风行。你有超强的执行力和组织能力，几百人的事在你手里井井有条。但你也要小心'机关算尽太聪明'——有时不妨柔软一些、信任别人一些。\n\n你的关键词：能干、果断、气场强大。",
            imageName: "wang_xifeng", color: Color(red: 0.75, green: 0.15, blue: 0.2)
        ),
        "史湘云": PersonalityResult(
            character: "史湘云", emoji: "🌺", title: "香梦沉酣的枕霞旧友",
            percentage: 0, description: "你是史湘云式的人物——豪爽率直、不拘小节。你是朋友圈里的开心果，大口吃肉、大口喝酒、大声笑。你的座右铭是'是真名士自风流'——做自己最舒服。\n\n你的关键词：率真、洒脱、乐观。",
            imageName: "shi_xiangyun", color: Color(red: 0.85, green: 0.5, blue: 0.55)
        ),
        "贾探春": PersonalityResult(
            character: "贾探春", emoji: "🌿", title: "才自精明志自高的玫瑰花",
            percentage: 0, description: "你是贾探春式的人物——精明能干、志向高远。你不甘心于现状，总想做出改变、立一番事业。你的清醒和远见让你在人群中脱颖而出。'我但凡是个男人，可以出得去，我必早走了，立一番事业'——这就是你。\n\n你的关键词：抱负、清醒、果断。",
            imageName: "jia_tanchun", color: Color(red: 0.55, green: 0.65, blue: 0.35)
        ),
        "妙玉": PersonalityResult(
            character: "妙玉", emoji: "🍵", title: "气质美如兰的槛外人",
            percentage: 0, description: "你是妙玉式的人物——孤傲清高、洁身自好。你有一套自己的标准和边界，不轻易让人进入你的世界。你对品味和品质有极致的要求，宁可孤独也不将就。\n\n你的关键词：独立、精致、自成一格。",
            imageName: "miao_yu", color: Color(red: 0.4, green: 0.5, blue: 0.5)
        ),
        "刘姥姥": PersonalityResult(
            character: "刘姥姥", emoji: "🌾", title: "大智若愚的乡村智者",
            percentage: 0, description: "你是刘姥姥式的人物——朴实善良、幽默通达。你看似平凡，实则拥有极高的人生智慧。你懂得'瘦死的骆驼比马大'，也知道什么时候该放下身段。生活再难，你也能笑着面对。\n\n你的关键词：乐观、朴实、智慧。",
            imageName: "liu_laolao", color: Color(red: 0.65, green: 0.5, blue: 0.3)
        ),
    ]
}
