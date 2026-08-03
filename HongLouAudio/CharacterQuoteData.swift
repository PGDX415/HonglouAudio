//
//  CharacterQuoteData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation

struct CharacterQuote: Identifiable {
    let id = UUID()
    let text: String
    let context: String  // brief context of when/why this was said
    let chapterNumber: Int
}

struct CharacterQuoteStore {
    /// Famous quotes organized by character name
    static let quotes: [String: [CharacterQuote]] = [
        "贾宝玉": [
            CharacterQuote(
                text: "女儿是水做的骨肉，男人是泥做的骨肉。我见了女儿便觉清爽，见了男子便觉浊臭逼人。",
                context: "宝玉论男女之别，表达了他对女性的崇拜和对世俗男子的厌恶",
                chapterNumber: 2
            ),
            CharacterQuote(
                text: "这妹妹我曾见过的。",
                context: "黛玉初进贾府，宝玉一见如故，暗示二人前世因缘",
                chapterNumber: 3
            ),
            CharacterQuote(
                text: "你死了，我做和尚去。",
                context: "宝玉对黛玉的深情告白，多次出现，最终应验",
                chapterNumber: 31
            ),
            CharacterQuote(
                text: "我又不是个国贼禄鬼，什么是功名？",
                context: "宝玉拒绝宝钗、湘云的规劝，表明对科举仕途的厌恶",
                chapterNumber: 36
            ),
            CharacterQuote(
                text: "任他弱水三千，我只取一瓢饮。",
                context: "宝玉向黛玉表明心意——弱水三千，只爱你一人",
                chapterNumber: 91
            )
        ],
        "林黛玉": [
            CharacterQuote(
                text: "花谢花飞花满天，红消香断有谁怜？",
                context: "《葬花吟》开篇，以花喻己，感叹命运的悲凉",
                chapterNumber: 27
            ),
            CharacterQuote(
                text: "一年三百六十日，风刀霜剑严相逼。",
                context: "《葬花吟》中最痛彻的句子，诉寄人篱下之苦",
                chapterNumber: 27
            ),
            CharacterQuote(
                text: "你既为我之知己，我亦为你之知己。",
                context: "黛玉向宝玉坦露心迹，表明彼此是唯一的知己",
                chapterNumber: 32
            ),
            CharacterQuote(
                text: "早知他来，我就不来了。",
                context: "黛玉吃宝钗的醋，率真可爱的撒娇之语",
                chapterNumber: 8
            ),
            CharacterQuote(
                text: "冷月葬花魂。",
                context: "中秋联句中的千古绝唱，预示黛玉的悲剧结局",
                chapterNumber: 76
            )
        ],
        "薛宝钗": [
            CharacterQuote(
                text: "好风凭借力，送我上青云。",
                context: "宝钗咏柳絮词，展现她借势高飞的志向与机心",
                chapterNumber: 70
            ),
            CharacterQuote(
                text: "天下难得的是富贵，又难得的是闲散，这两样再不能兼有。",
                context: "宝钗道出人生矛盾，透露出她通透世俗的一面",
                chapterNumber: 37
            ),
            CharacterQuote(
                text: "淡极始知花更艳，愁多焉得玉无痕。",
                context: "宝钗咏白海棠诗，以淡雅自况，体现了她的审美观和性格",
                chapterNumber: 37
            ),
            CharacterQuote(
                text: "男人们读书明理，辅国治民，这便好了。",
                context: "宝钗劝宝玉读书应考，体现了她恪守传统价值观的一面",
                chapterNumber: 42
            )
        ],
        "王熙凤": [
            CharacterQuote(
                text: "我是从来不信什么阴司地狱报应的，凭是什么事，我说要行就行。",
                context: "凤姐自白，揭示她胆大妄为、不信因果的性格",
                chapterNumber: 15
            ),
            CharacterQuote(
                text: "机关算尽太聪明，反算了卿卿性命。",
                context: "凤姐判词，预言她聪明一世终害己的结局",
                chapterNumber: 5
            ),
            CharacterQuote(
                text: "我又不是那等没见过世面的人，什么好的歹的都见过了。",
                context: "凤姐自负之语，显示她见多识广的管家气派",
                chapterNumber: 16
            ),
            CharacterQuote(
                text: "你打量我是和你们姑娘那么好性儿，由着你们欺负？",
                context: "凤姐训斥下人，展现她治家的威严与狠辣",
                chapterNumber: 14
            )
        ],
        "史湘云": [
            CharacterQuote(
                text: "是真名士自风流。",
                context: "湘云反驳黛玉，表达她对名士洒脱风度的认同",
                chapterNumber: 49
            ),
            CharacterQuote(
                text: "且住为佳耳，何必较真？",
                context: "湘云劝大家不要为小事计较，体现她的豁达",
                chapterNumber: 62
            ),
            CharacterQuote(
                text: "寒塘渡鹤影。",
                context: "中秋联句中的名句，意境清冷，暗示湘云的孤寂",
                chapterNumber: 76
            )
        ],
        "贾探春": [
            CharacterQuote(
                text: "我但凡是个男人，可以出得去，我必早走了，立一番事业。",
                context: "探春感叹身为女子的局限，表达她的抱负与不甘",
                chapterNumber: 55
            ),
            CharacterQuote(
                text: "百足之虫，死而不僵。",
                context: "探春看出贾府衰败的本质，见识超越众人",
                chapterNumber: 74
            ),
            CharacterQuote(
                text: "咱们倒是一家子亲骨肉呢，一个个像乌眼鸡似的，恨不得你吃了我，我吃了你。",
                context: "探春痛斥贾府内部的勾心斗角",
                chapterNumber: 75
            )
        ],
        "晴雯": [
            CharacterQuote(
                text: "只是一件，我死也不甘心的：我虽生得比别人略好些，并没有私情密意勾引你怎样。",
                context: "晴雯临死前对宝玉的剖白，冤屈而悲壮",
                chapterNumber: 77
            ),
            CharacterQuote(
                text: "谁又比谁高贵些？",
                context: "晴雯撕扇时的傲气之言，展现她不愿低头的性格",
                chapterNumber: 31
            )
        ],
        "妙玉": [
            CharacterQuote(
                text: "纵有千年铁门槛，终须一个土馒头。",
                context: "妙玉喜爱的诗句，表达她对富贵如浮云的看透",
                chapterNumber: 63
            )
        ],
        "刘姥姥": [
            CharacterQuote(
                text: "老刘，老刘，食量大如牛，吃个老母猪不抬头！",
                context: "刘姥姥在大观园宴席上的自嘲逗趣，令人捧腹",
                chapterNumber: 40
            ),
            CharacterQuote(
                text: "瘦死的骆驼比马大。",
                context: "刘姥姥说贾府——即使衰败也远比普通人家富裕",
                chapterNumber: 6
            )
        ],
        "贾元春": [
            CharacterQuote(
                text: "田舍之家，虽齑盐布帛，终能聚天伦之乐；今虽富贵已极，骨肉各方，然终无意趣！",
                context: "元春省亲时对贾母的哭诉，道出深宫之苦",
                chapterNumber: 18
            )
        ],
        "鸳鸯": [
            CharacterQuote(
                text: "别说大老爷要我做小老婆，就是太太这会子死了，大老爷要收我做房里人，我也不愿意！",
                context: "鸳鸯誓死抗婚，展现了身为奴婢的尊严与骨气",
                chapterNumber: 46
            )
        ],
        "平儿": [
            CharacterQuote(
                text: "得饶人处且饶人。",
                context: "平儿劝王熙凤的良善之语，全书最具智慧的一句话",
                chapterNumber: 59
            )
        ],
        "秦可卿": [
            CharacterQuote(
                text: "月满则亏，水满则溢。",
                context: "可卿托梦王熙凤，预言贾府盛极必衰的命运",
                chapterNumber: 13
            )
        ]
    ]

    /// Get quotes for a given character name
    static func quotesFor(_ characterName: String) -> [CharacterQuote] {
        quotes[characterName] ?? []
    }
}
