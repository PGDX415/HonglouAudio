//
//  LanternRiddleData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation

struct LanternRiddle: Identifiable {
    let id: Int
    let character: String     // who created it
    let poem: String          // the riddle verse
    let hint: String          // "打一果名" etc.
    let answer: String
    let wrongOptions: [String]
    let prophecy: String      // hidden meaning — the 谶语
    let jiaZhengReaction: String // 贾政的反应
}

struct LanternRiddleStore {
    static let riddles: [LanternRiddle] = [
        LanternRiddle(
            id: 1,
            character: "贾母",
            poem: "猴子身轻站树梢",
            hint: "打一果名",
            answer: "荔枝",
            wrongOptions: ["桂圆", "红枣", "核桃"],
            prophecy: "「荔枝」谐音「离枝」——树倒猢狲散，贾母去世后贾府分崩离析。",
            jiaZhengReaction: "贾政已知是荔枝，却故意乱猜别的，罚了许多东西，然后方猜着，也得了贾母的东西。"
        ),
        LanternRiddle(
            id: 2,
            character: "贾政",
            poem: "身自端方，体自坚硬。\n虽不能言，有言必应。",
            hint: "打一用物",
            answer: "砚台",
            wrongOptions: ["印章", "镇纸", "戒尺"],
            prophecy: "贾政自喻——端方刚硬如砚，却一言成谶。他出的谜「有言必应」，偏偏每个谜都应验了悲剧。",
            jiaZhengReaction: "（贾政自己出的谜，念与贾母猜）"
        ),
        LanternRiddle(
            id: 3,
            character: "贾元春",
            poem: "能使妖魔胆尽摧，\n身如束帛气如雷。\n一声震得人方恐，\n回首相看已化灰。",
            hint: "打一玩物",
            answer: "爆竹",
            wrongOptions: ["烟花", "炮仗", "灯笼"],
            prophecy: "元春身为贵妃，显赫一时如爆竹般响亮——然「回首相看已化灰」，暗示她盛极而亡，转瞬成灰。",
            jiaZhengReaction: "贾政心内沉思道：娘娘所作爆竹，此乃一响而散之物……今乃上元佳节，如何皆作此不祥之物为戏耶？"
        ),
        LanternRiddle(
            id: 4,
            character: "贾迎春",
            poem: "天运人功理不穷，\n有功无运也难逢。\n因何镇日纷纷乱，\n只为阴阳数不同。",
            hint: "打一用物",
            answer: "算盘",
            wrongOptions: ["秤杆", "历书", "棋盘"],
            prophecy: "算盘拨动由人，却受「数」的支配——迎春一生任人摆布，嫁与中山狼孙绍祖，最终被折磨致死，「阴阳数不同」即是命。",
            jiaZhengReaction: "贾政心内愈觉烦闷：迎春所作算盘，是打动乱如麻……今乃上元佳节，如何皆作此不祥之物为戏耶？"
        ),
        LanternRiddle(
            id: 5,
            character: "贾探春",
            poem: "阶下儿童仰面时，\n清明妆点最堪宜。\n游丝一断浑无力，\n莫向东风怨别离。",
            hint: "打一玩物",
            answer: "风筝",
            wrongOptions: ["纸鸢", "柳絮", "秋千"],
            prophecy: "断线风筝、远嫁异乡——探春清明时节远嫁海外，「千里东风一梦遥」，从此与亲人永隔。",
            jiaZhengReaction: "贾政心内沉思道：探春所作风筝，乃飘飘浮荡之物……今乃上元佳节，如何皆作此不祥之物为戏耶？"
        ),
        LanternRiddle(
            id: 6,
            character: "贾惜春",
            poem: "前身色相总无成，\n不听菱歌听佛经。\n莫道此生沉黑海，\n性中自有大光明。",
            hint: "打一用物",
            answer: "佛前海灯",
            wrongOptions: ["香炉", "木鱼", "念珠"],
            prophecy: "海灯孤悬佛前——惜春最终削发为尼，独卧青灯古佛旁。「性中自有大光明」是解脱，也是寂灭。",
            jiaZhengReaction: "贾政心内愈觉烦闷：惜春所作海灯，一发清净孤独……大有悲戚之状。"
        ),
        LanternRiddle(
            id: 7,
            character: "林黛玉",
            poem: "朝罢谁携两袖烟，\n琴边衾里总无缘。\n晓筹不用鸡人报，\n五夜无烦侍女添。\n焦首朝朝还暮暮，\n煎心日日复年年。\n光阴荏苒须当惜，\n风雨阴晴任变迁。",
            hint: "打一用物",
            answer: "更香",
            wrongOptions: ["蜡烛", "灯芯", "檀香"],
            prophecy: "更香燃尽方休——黛玉一生「焦首朝朝还暮暮，煎心日日复年年」，以泪还债，泪尽而亡。更香即心香，燃尽便是结局。",
            jiaZhengReaction: "贾政看完，心内自忖道：此物还倒有限。只是小小之人作此词句，更觉不祥，皆非永远福寿之辈。想到此处，愈觉烦闷，大有悲戚之状。"
        ),
        LanternRiddle(
            id: 8,
            character: "贾宝玉",
            poem: "南面而坐，北面而朝。\n象忧亦忧，象喜亦喜。",
            hint: "打一用物",
            answer: "镜子",
            wrongOptions: ["屏风", "铜鉴", "画卷"],
            prophecy: "镜子映照万物，却终究是虚空——宝玉一生追求真情，到头来「落了片白茫茫大地真干净」。镜中花、水中月，皆是幻象。",
            jiaZhengReaction: "贾政道：这个莫非是镜子？宝玉回说：是。贾政道：是谁做的？宝玉只得回说：是儿子做的。贾政就不言语。"
        ),
        LanternRiddle(
            id: 9,
            character: "薛宝钗",
            poem: "有眼无珠腹内空，\n荷花出水喜相逢。\n梧桐叶落分离别，\n恩爱夫妻不到冬。",
            hint: "打一用物",
            answer: "竹夫人",
            wrongOptions: ["枕头", "凉席", "团扇"],
            prophecy: "竹夫人夏日相伴，秋后便被弃置——宝钗与宝玉婚后，宝玉「悬崖撒手」出家，她独守空闺，恰如那句「恩爱夫妻不到冬」。",
            jiaZhengReaction: "贾政看完，心内自忖道：此物还倒有限。只是小小之人作此词句，更觉不祥……想到此处，愈觉烦闷，大有悲戚之状，因而回至房中，只是思索，翻来覆去，竟难成寐。"
        )
    ]

    /// Return all riddles shuffled for a game session
    static func gameRound() -> [LanternRiddle] {
        riddles.shuffled()
    }
}
