//
//  QuizData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import Foundation

struct QuizQuestion: Identifiable {
    let id: Int
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct QuizStore {
    static let questions: [QuizQuestion] = [
        QuizQuestion(id: 1,
            question: "《红楼梦》原名是什么？",
            options: ["金陵十二钗", "石头记", "风月宝鉴", "情僧录"],
            correctIndex: 1,
            explanation: "《红楼梦》原名《石头记》，又名《情僧录》《风月宝鉴》《金陵十二钗》。"
        ),
        QuizQuestion(id: 2,
            question: "林黛玉的前世是什么？",
            options: ["芙蓉仙子", "绛珠仙草", "牡丹花神", "海棠仙子"],
            correctIndex: 1,
            explanation: "黛玉前世是灵河岸上三生石畔的绛珠仙草，受神瑛侍者（宝玉前世）甘露灌溉。"
        ),
        QuizQuestion(id: 3,
            question: "贾宝玉的通灵宝玉上刻着什么字？",
            options: ["不离不弃 芳龄永继", "莫失莫忘 仙寿恒昌", "金玉良缘 木石前盟", "富贵长春 福寿绵长"],
            correctIndex: 1,
            explanation: "通灵宝玉正面刻'莫失莫忘，仙寿恒昌'；宝钗金锁上刻'不离不弃，芳龄永继'，恰好成对。"
        ),
        QuizQuestion(id: 4,
            question: "大观园是为谁建造的？",
            options: ["贾母祝寿", "元春省亲", "宝玉大婚", "薛家迁居"],
            correctIndex: 1,
            explanation: "大观园是专为贾元春省亲而建造的园林，后来成为宝玉和众姐妹的住所。"
        ),
        QuizQuestion(id: 5,
            question: "'好了歌'是谁唱的？",
            options: ["贾宝玉", "甄士隐", "跛足道人", "癞头和尚"],
            correctIndex: 2,
            explanation: "跛足道人在第一回唱《好了歌》，甄士隐听后为作《好了歌注》。"
        ),
        QuizQuestion(id: 6,
            question: "贾家四春中，谁是皇妃？",
            options: ["贾迎春", "贾探春", "贾元春", "贾惜春"],
            correctIndex: 2,
            explanation: "贾元春是贾政的长女，被选入宫中，封为贤德妃。"
        ),
        QuizQuestion(id: 7,
            question: "'未见其人，先闻其声'形容的是谁？",
            options: ["林黛玉", "薛宝钗", "王熙凤", "史湘云"],
            correctIndex: 2,
            explanation: "林黛玉初入荣国府时，王熙凤的出场是'未见其人，先闻其声'——从后院传来笑声。"
        ),
        QuizQuestion(id: 8,
            question: "潇湘馆是谁在大观园的住处？",
            options: ["薛宝钗", "史湘云", "贾探春", "林黛玉"],
            correctIndex: 3,
            explanation: "潇湘馆以竹子著称，是林黛玉在大观园中的住处，她的诗号'潇湘妃子'即源于此。"
        ),
        QuizQuestion(id: 9,
            question: "'一损皆损，一荣皆荣'说的是什么？",
            options: ["贾府的命运", "四大家族", "大观园姐妹", "金陵十二钗"],
            correctIndex: 1,
            explanation: "门子给贾雨村的护官符上写着贾、史、王、薛四大家族'一损皆损，一荣皆荣'。"
        ),
        QuizQuestion(id: 10,
            question: "秦可卿托梦给谁，预言贾府将衰？",
            options: ["贾母", "贾宝玉", "王熙凤", "尤氏"],
            correctIndex: 2,
            explanation: "秦可卿死后托梦王熙凤，告诫'月满则亏，水满则溢'，劝她早做后路打算。"
        ),
        QuizQuestion(id: 11,
            question: "蘅芜苑是谁的住处？",
            options: ["林黛玉", "史湘云", "薛宝钗", "李纨"],
            correctIndex: 2,
            explanation: "蘅芜苑以奇草异石著称，是薛宝钗在大观园中的住处，她的诗号'蘅芜君'即源于此。"
        ),
        QuizQuestion(id: 12,
            question: "贾宝玉抓周时抓了什么，使贾政大怒？",
            options: ["毛笔", "书本", "算盘", "脂粉钗环"],
            correctIndex: 3,
            explanation: "宝玉周岁抓周时，专抓脂粉钗环，贾政因此大怒，断定了宝玉将来是个酒色之徒。"
        ),
        QuizQuestion(id: 13,
            question: "'风月宝鉴'的正面和反面分别是什么？",
            options: ["美女与骷髅", "富贵与贫穷", "欢乐与悲伤", "真实与虚幻"],
            correctIndex: 0,
            explanation: "跛足道人给贾瑞的'风月宝鉴'，正面是凤姐的倩影，反面是骷髅——寓意色即是空。"
        ),
        QuizQuestion(id: 14,
            question: "抄检大观园发生在哪一回？",
            options: ["第五十五回", "第六十五回", "第七十四回", "第八十四回"],
            correctIndex: 2,
            explanation: "第七十四回，王夫人命凤姐抄检大观园，是大观园由盛转衰的转折点。"
        ),
        QuizQuestion(id: 15,
            question: "谁提议起了海棠诗社？",
            options: ["林黛玉", "薛宝钗", "贾探春", "史湘云"],
            correctIndex: 2,
            explanation: "第三十七回，探春发起海棠诗社，以咏白海棠起社，是大观园文学生活的高峰。"
        ),
        QuizQuestion(id: 16,
            question: "'冷月葬花魂'是谁的诗句？",
            options: ["薛宝钗", "史湘云", "林黛玉", "妙玉"],
            correctIndex: 2,
            explanation: "第七十六回中秋联句，黛玉对湘云的'寒塘渡鹤影'以'冷月葬花魂'，被妙玉评为过于悲凉。"
        ),
        QuizQuestion(id: 17,
            question: "贾宝玉的丫鬟中，谁的性格最刚烈？",
            options: ["袭人", "麝月", "晴雯", "紫鹃"],
            correctIndex: 2,
            explanation: "晴雯性格刚烈，容貌出众，心直口快。因王夫人嫌其妖媚，被逐出大观园后含冤病死。"
        ),
        QuizQuestion(id: 18,
            question: "'护官符'中排名第一的是哪个家族？",
            options: ["王家", "史家", "薛家", "贾家"],
            correctIndex: 3,
            explanation: "护官符四句：'贾不假，白玉为堂金作马。阿房宫，三百里，住不下金陵一个史。东海缺少白玉床，龙王来请金陵王。丰年好大雪，珍珠如土金如铁。'贾家为首。"
        ),
        QuizQuestion(id: 19,
            question: "黛玉的《葬花吟》写于什么时节？",
            options: ["暮春", "仲夏", "深秋", "寒冬"],
            correctIndex: 0,
            explanation: "第二十七回芒种节（暮春），黛玉在花冢葬花，吟出千古绝唱《葬花吟》。"
        ),
        QuizQuestion(id: 20,
            question: "刘姥姥的名字是什么？",
            options: ["刘氏", "刘婆子", "刘姥姥就是她的名字", "书中未提她的名字"],
            correctIndex: 2,
            explanation: "刘姥姥称呼自己为'刘姥姥'，这其实就是她在书中的名字，书中没有提她的本名。"
        ),
        QuizQuestion(id: 21,
            question: "贾宝玉最终的结局是？",
            options: ["继承家业", "出家为僧", "病死", "远走他乡经商"],
            correctIndex: 1,
            explanation: "宝玉中举后毅然出家，在雪地中向贾政拜了四拜，随一僧一道飘然而去。"
        ),
        QuizQuestion(id: 22,
            question: "'金玉良缘'指的是哪两个人？",
            options: ["宝玉和黛玉", "宝玉和宝钗", "贾琏和凤姐", "贾蓉和秦可卿"],
            correctIndex: 1,
            explanation: "贾宝玉（含玉而生）与薛宝钗（有金锁）的婚姻被称为'金玉良缘'，与'木石前盟'相对。"
        ),
        QuizQuestion(id: 23,
            question: "以下哪句话不是林黛玉说的？",
            options: ["早知他来，我就不来了", "你死了，我做和尚去", "花谢花飞花满天", "一年三百六十日，风刀霜剑严相逼"],
            correctIndex: 1,
            explanation: "'你死了，我做和尚去'是贾宝玉对林黛玉说的，不是黛玉说的。"
        ),
        QuizQuestion(id: 24,
            question: "金陵十二钗正册中排在第一位的是？",
            options: ["薛宝钗", "贾元春", "林黛玉", "贾探春"],
            correctIndex: 2,
            explanation: "金陵十二钗判词中，黛玉和宝钗合用一首判词排在最前：'可叹停机德，堪怜咏絮才。玉带林中挂，金簪雪里埋。'"
        ),
        QuizQuestion(id: 25,
            question: "贾府的家学叫什么？",
            options: ["荣国书院", "贾家族塾", "宁国书院", "贾府学堂"],
            correctIndex: 1,
            explanation: "贾府设有族塾，宝玉和秦钟、贾兰等都在此读书。第九回描写了族塾中闹出的风波。"
        ),
        QuizQuestion(id: 26,
            question: "妙玉在大观园中住在哪里？",
            options: ["稻香村", "藕香榭", "栊翠庵", "蘅芜苑"],
            correctIndex: 2,
            explanation: "妙玉是大观园栊翠庵的尼姑，出身官宦之家，性格孤傲清高。"
        ),
        QuizQuestion(id: 27,
            question: "'天上掉下个林妹妹'出自哪种戏曲对《红楼梦》的改编？",
            options: ["京剧", "昆曲", "越剧", "黄梅戏"],
            correctIndex: 2,
            explanation: "'天上掉下个林妹妹'是越剧《红楼梦》中最著名的唱段，影响深远。"
        ),
        QuizQuestion(id: 28,
            question: "贾宝玉与谁在学堂中最为交好？",
            options: ["贾兰", "贾蓉", "秦钟", "薛蟠"],
            correctIndex: 2,
            explanation: "秦钟与宝玉一见如故，二人相约同入贾府族塾读书，关系极为亲密。"
        ),
        QuizQuestion(id: 29,
            question: "'白玉为堂金作马'是护官符中形容哪个家族的？",
            options: ["史家", "王家", "贾家", "薛家"],
            correctIndex: 2,
            explanation: "护官符第一句'贾不假，白玉为堂金作马'形容贾家之富贵。"
        ),
        QuizQuestion(id: 30,
            question: "李纨在大观园的住处是？",
            options: ["潇湘馆", "蘅芜苑", "稻香村", "秋爽斋"],
            correctIndex: 2,
            explanation: "稻香村是大观园中田园风格的院落，为寡居的李纨所住。"
        ),
    ]

    /// Generate a quiz of `count` random questions
    static func randomQuiz(count: Int = 10) -> [QuizQuestion] {
        Array(questions.shuffled().prefix(count))
    }
}
