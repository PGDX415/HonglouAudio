//
//  GlossaryData.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/3.
//

import Foundation

struct GlossaryItem: Identifiable {
    let id = UUID()
    let term: String
    let pinyin: String
    let explanation: String
    let category: GlossaryCategory
}

enum GlossaryCategory: String, CaseIterable {
    case 典故 = "典故"
    case 词语 = "词语"
    case 人物 = "人物称谓"
    case 器物 = "器物"
    case 礼俗 = "礼俗"
    case 地名 = "地名"
}

struct GlossaryStore {
    static let items: [GlossaryItem] = [
        // MARK: 典故
        GlossaryItem(term: "金玉良缘", pinyin: "jīn yù liáng yuán", explanation: "指贾宝玉（含玉而生）与薛宝钗（有金锁）的婚姻。与'木石前盟'（宝玉黛玉）相对。", category: .典故),
        GlossaryItem(term: "木石前盟", pinyin: "mù shí qián méng", explanation: "指贾宝玉（神瑛侍者，石）与林黛玉（绛珠仙草，木）的前世情缘。黛玉为报灌溉之恩，以一生眼泪偿还。", category: .典故),
        GlossaryItem(term: "太虚幻境", pinyin: "tài xū huàn jìng", explanation: "警幻仙子所居的仙界。第一回和第五回出现，宝玉在此翻阅金陵十二钗判词，是全书的预言框架。", category: .典故),
        GlossaryItem(term: "绛珠仙草", pinyin: "jiàng zhū xiān cǎo", explanation: "林黛玉的前世。生长在西方灵河岸上三生石畔，受神瑛侍者（宝玉前世）甘露灌溉，后下凡以泪还恩。", category: .典故),
        GlossaryItem(term: "神瑛侍者", pinyin: "shén yīng shì zhě", explanation: "贾宝玉的前世。在太虚幻境以甘露灌溉绛珠仙草，下凡历劫。", category: .典故),
        GlossaryItem(term: "通灵宝玉", pinyin: "tōng líng bǎo yù", explanation: "贾宝玉出生时口中衔着的玉石，正面刻'莫失莫忘，仙寿恒昌'。原为女娲补天所剩的一块顽石。", category: .典故),
        GlossaryItem(term: "风月宝鉴", pinyin: "fēng yuè bǎo jiàn", explanation: "跛足道人给贾瑞的镜子，正面照见美人（幻象），反面照见骷髅（真相）。寓意色即是空。", category: .典故),
        GlossaryItem(term: "大观园", pinyin: "dà guān yuán", explanation: "为元春省亲而建的园林，后成为宝玉和众姐妹的居所。是全书最重要的空间场景，象征青春与理想世界。", category: .地名),
        GlossaryItem(term: "海棠诗社", pinyin: "hǎi táng shī shè", explanation: "第三十七回由探春发起，大观园中众人结成的诗社。以咏白海棠起社，是大观园中最美好的文化生活。", category: .典故),
        GlossaryItem(term: "补天遗石", pinyin: "bǔ tiān yí shí", explanation: "女娲炼石补天时，炼成顽石三万六千五百零一块，只用了三万六千五百块，剩下一块弃在青埂峰下。此石即为通灵宝玉的前身。", category: .典故),
        GlossaryItem(term: "三生石", pinyin: "sān shēng shí", explanation: "传说中记录人前世今生的石头，在杭州灵隐寺。绛珠仙草生在三生石畔，暗示宝黛情缘超越今生。", category: .典故),

        // MARK: 词语
        GlossaryItem(term: "齑盐布帛", pinyin: "jī yán bù bó", explanation: "齑（jī）：切碎的腌菜。指粗茶淡饭、布衣粗服的清贫生活。典出元春省亲时所言。", category: .词语),
        GlossaryItem(term: "纨绔", pinyin: "wán kù", explanation: "纨（wán）：细绢。绔（kù）：裤子。古代富贵人家子弟穿的细绢裤，代指不务正业的富家子弟。", category: .词语),
        GlossaryItem(term: "膏粱", pinyin: "gāo liáng", explanation: "膏：肥肉。粱：细粮。代指富贵人家。'择膏粱'指为女儿选择富贵人家的夫婿。", category: .词语),
        GlossaryItem(term: "笏满床", pinyin: "hù mǎn chuáng", explanation: "笏（hù）：古代大臣上朝时手持的板子。形容家族世代为官、权位显赫。出自《好了歌注》。", category: .词语),
        GlossaryItem(term: "兰桂齐芳", pinyin: "lán guì qí fāng", explanation: "兰和桂都是香草，比喻子孙优秀。暗示贾府最终有后代（贾兰）科举中第、重振家声。", category: .词语),
        GlossaryItem(term: "举案齐眉", pinyin: "jǔ àn qí méi", explanation: "东汉梁鸿妻孟光给丈夫送饭时把托盘举到眉毛高，表示恭敬。形容夫妻相敬如宾。", category: .典故),
        GlossaryItem(term: "破镜重圆", pinyin: "pò jìng chóng yuán", explanation: "南朝陈国灭亡时，徐德言与妻子乐昌公主各执半镜为信物，后凭半镜重逢。比喻夫妻失散后重新团聚。", category: .典故),
        GlossaryItem(term: "斑衣戏彩", pinyin: "bān yī xì cǎi", explanation: "春秋时老莱子七十岁穿彩衣学婴儿啼哭以逗父母开心。二十四孝之一，指孝养父母。", category: .典故),
        GlossaryItem(term: "荆钗布裙", pinyin: "jīng chāi bù qún", explanation: "荆枝作钗、粗布为裙，形容女子朴素不事打扮。与'金钗'（富贵）相对。", category: .词语),
        GlossaryItem(term: "东床", pinyin: "dōng chuáng", explanation: "王羲之的故事。郗鉴选婿时，王氏子弟都矜持，只有王羲之在东床上坦腹而卧。代指女婿。", category: .典故),
        GlossaryItem(term: "诰命", pinyin: "gào mìng", explanation: "皇帝封赠官员及其妻室的文书。诰命夫人是命妇的最高等级，贾母、王夫人等都是诰命。", category: .词语),
        GlossaryItem(term: "仕途经济", pinyin: "shì tú jīng jì", explanation: "仕途：做官的道路。经济：经世济民。指科举做官、治理国家的儒家人生道路。宝玉最厌恶此道。", category: .词语),

        // MARK: 人物称谓
        GlossaryItem(term: "令郎", pinyin: "lìng láng", explanation: "对对方儿子的敬称。如冷子兴称贾宝玉为贾政的'令郎'。", category: .人物),
        GlossaryItem(term: "家严", pinyin: "jiā yán", explanation: "对自己父亲的谦称。也称'家父'。", category: .人物),
        GlossaryItem(term: "世翁", pinyin: "shì wēng", explanation: "对世交长辈的尊称。贾雨村称贾政为'世翁'。", category: .人物),
        GlossaryItem(term: "奴才", pinyin: "nú cái", explanation: "明清官场中旗人官员对皇帝的自称，也用于奴仆自称。贾府中下人自称'奴才'。", category: .人物),
        GlossaryItem(term: "老祖宗", pinyin: "lǎo zǔ zōng", explanation: "贾府上下对贾母的尊称，体现其在家族中至高无上的地位。", category: .人物),
        GlossaryItem(term: "千岁", pinyin: "qiān suì", explanation: "对亲王、郡王等皇族成员的尊称。元春被封为贤德妃后，贾府人便是皇亲。", category: .人物),

        // MARK: 器物
        GlossaryItem(term: "拂尘", pinyin: "fú chén", explanation: "用马尾或鬃毛制成的掸尘工具，道士常持。跛足道人、妙玉等都使用拂尘。", category: .器物),
        GlossaryItem(term: "唾壶", pinyin: "tuò hú", explanation: "古代用来承接痰液的小壶，富贵人家日常用品。", category: .器物),
        GlossaryItem(term: "麈尾", pinyin: "zhǔ wěi", explanation: "麈（zhǔ）：一种鹿。用麈尾制成的拂尘状器物，魏晋名士清谈时手持，后成为文人雅士的象征。", category: .器物),
        GlossaryItem(term: "鸾绦", pinyin: "luán tāo", explanation: "鸾（luán）：凤凰的一种。绦（tāo）：丝带。绣有鸾鸟图案的丝带，用作腰带或装饰。", category: .器物),
        GlossaryItem(term: "束发冠", pinyin: "shù fà guān", explanation: "古代男子束发用的冠帽。宝玉常戴束发银冠，是贵族少年身份的象征。", category: .器物),
        GlossaryItem(term: "抹额", pinyin: "mò é", explanation: "束在额头上的装饰带，宝玉常戴'二龙抢珠金抹额'，是明代贵公子的典型装扮。", category: .器物),

        // MARK: 礼俗
        GlossaryItem(term: "省亲", pinyin: "xǐng qīn", explanation: "出嫁的女子回家探望父母。元春省亲是全书最隆重的场面，为迎接她建造了大观园。", category: .礼俗),
        GlossaryItem(term: "打醮", pinyin: "dǎ jiào", explanation: "醮（jiào）：道士设坛祈祷。第二十九回贾母率众去清虚观打醮，是书中重要的宗教活动场景。", category: .礼俗),
        GlossaryItem(term: "抓周", pinyin: "zhuā zhōu", explanation: "婴儿周岁时摆放各种物品任其抓取，以预测未来志趣。宝玉抓了脂粉钗环，贾政大怒。", category: .礼俗),
        GlossaryItem(term: "拜把子", pinyin: "bài bǎ zi", explanation: "结拜为异姓兄弟。书中柳湘莲等人物的社交方式。", category: .礼俗),
        GlossaryItem(term: "入殓", pinyin: "rù liàn", explanation: "将死者放入棺材。秦可卿死后停灵多日，丧礼极尽奢华。", category: .礼俗),
        GlossaryItem(term: "社火", pinyin: "shè huǒ", explanation: "民间节日庆典的表演活动。元春省亲时贾府安排了盛大的社火表演。", category: .礼俗),

        // MARK: 地名
        GlossaryItem(term: "金陵", pinyin: "jīn líng", explanation: "即今天的南京。贾、史、王、薛四大家族原籍金陵，故有'金陵十二钗'之说。", category: .地名),
        GlossaryItem(term: "姑苏", pinyin: "gū sū", explanation: "即今天的苏州。甄士隐家住姑苏阊门外，林黛玉也是苏州人。", category: .地名),
        GlossaryItem(term: "潇湘馆", pinyin: "xiāo xiāng guǎn", explanation: "大观园中林黛玉的住处，以竹子著称，暗合娥皇女英泪洒竹斑的典故。'潇湘妃子'是黛玉的诗号。", category: .地名),
        GlossaryItem(term: "蘅芜苑", pinyin: "héng wú yuàn", explanation: "大观园中薛宝钗的住处，以奇草异石著称。'蘅芜君'是宝钗的诗号。", category: .地名),
        GlossaryItem(term: "怡红院", pinyin: "yí hóng yuàn", explanation: "大观园中贾宝玉的住处，以海棠花和芭蕉著称。'怡红公子'是宝玉的诗号。", category: .地名),
        GlossaryItem(term: "稻香村", pinyin: "dào xiāng cūn", explanation: "大观园中李纨的住处，田园风格，与李纨寡居身份相符。", category: .地名),
        GlossaryItem(term: "栊翠庵", pinyin: "lóng cuì ān", explanation: "大观园中的尼姑庵，妙玉在此修行。第四十一回贾母带刘姥姥来这里品茶。", category: .地名),
        GlossaryItem(term: "荣国府", pinyin: "róng guó fǔ", explanation: "贾家的主宅，贾母、贾政、宝玉等人居住。荣国公贾源的后代，代表了贾府的正支。", category: .地名),
        GlossaryItem(term: "宁国府", pinyin: "nìng guó fǔ", explanation: "贾家的另一宅，贾珍、贾蓉等人居住。宁国公贾演的后代。'造衅开端实在宁'暗示宁国府是贾府衰败的源头。", category: .地名),
    ]

    /// Find glossary items that match text. Returns matches with their ranges.
    static func findMatches(in text: String) -> [(GlossaryItem, Range<String.Index>)] {
        var results: [(GlossaryItem, Range<String.Index>)] = []
        for item in items {
            if let range = text.range(of: item.term) {
                results.append((item, range))
            }
        }
        return results
    }
}
