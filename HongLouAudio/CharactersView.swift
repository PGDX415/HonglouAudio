//
//  CharactersView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct CharactersView: View {
    // Main characters data
    private let mainCharacters = [
        Character(
            name: "贾宝玉",
            description: "贾府的公子，性格叛逆，厌恶功名利禄，喜爱诗词歌赋。他与林黛玉有着深厚的感情，是《红楼梦》的核心人物。",
            imageName: "jia_baoyu"
        ),
        Character(
            name: "林黛玉",
            description: "贾母的外孙女，才情出众但体弱多病。她敏感多疑，与贾宝玉青梅竹马，感情深厚，最终因情而逝。",
            imageName: "lin_daiyu"
        ),
        Character(
            name: "薛宝钗",
            description: "薛家的女儿，端庄贤淑，处事圆滑。她最终与贾宝玉成婚，但婚姻并不幸福。",
            imageName: "xue_baochai"
        ),
        Character(
            name: "王熙凤",
            description: "贾琏之妻，贾府的实际管家。她精明能干，手段狠辣，在贾府中掌握大权。",
            imageName: "wang_xifeng"
        ),
        Character(
            name: "贾母",
            description: "贾府的老祖宗，贾宝玉的祖母。她是贾府的最高权威，慈祥而威严。",
            imageName: "jia_mu"
        ),
        Character(
            name: "贾政",
            description: "贾宝玉的父亲，为人严肃古板，重视礼教和功名，对宝玉要求严格。",
            imageName: "jia_zheng"
        ),
        Character(
            name: "贾元春",
            description: "贾政与王夫人的长女，贾宝玉的姐姐。她被选入宫中，封为贤德妃（后晋升为贵妃）。大观园就是为她省亲而建，她的命运与贾府的兴衰密切相关。",
            imageName: "jia_yuanchun"
        ),
        Character(
            name: "袭人",
            description: "贾宝玉的贴身丫鬟，温柔体贴，对宝玉忠心耿耿，后成为宝玉的妾室。",
            imageName: "xi_ren"
        ),
        Character(
            name: "晴雯",
            description: "贾宝玉的丫鬟，性格刚烈，容貌出众，因被诬陷而遭逐出贾府，含恨而终。",
            imageName: "qing_wen"
        ),
        Character(
            name: "妙玉",
            description: "栊翠庵的尼姑，出身官宦之家，性格孤傲清高。她才华横溢，与宝玉、黛玉等人有交往，最终命运悲惨。",
            imageName: "miao_yu"
        ),
        Character(
            name: "史湘云",
            description: "贾母的侄孙女，性格豪爽直率，才思敏捷。她父母早亡，常住贾府，与宝玉、黛玉等人关系密切。",
            imageName: "shi_xiangyun"
        ),
        Character(
            name: "贾探春",
            description: "贾政的庶女，贾宝玉的妹妹。她精明能干，有远见卓识，曾代理管家，后远嫁他乡。",
            imageName: "jia_tanchun"
        ),
        Character(
            name: "贾迎春",
            description: "贾赦的庶女，贾宝玉的堂妹。她性格懦弱，逆来顺受，最终被父亲嫁给孙绍祖而遭受虐待致死。",
            imageName: "jia_yingchun"
        ),
        Character(
            name: "贾惜春",
            description: "贾珍的妹妹，贾宝玉的堂妹。她性格孤僻，喜好绘画，最终看破红尘出家为尼。",
            imageName: "jia_xichun"
        ),
        Character(
            name: "鸳鸯",
            description: "贾母的贴身大丫鬟，聪明能干，忠心耿耿。她拒绝了贾赦的纳妾要求，誓死不从，展现了坚强的品格。",
            imageName: "yuan_yang"
        ),
        Character(
            name: "秦可卿",
            description: "贾蓉的妻子，贾珍的儿媳。她在第五回引导贾宝玉梦游太虚幻境，预示了金陵十二钗的命运。她的死因成谜，葬礼极尽奢华，是小说前半部分的重要情节。",
            imageName: "qin_keqing"
        ),
        Character(
            name: "平儿",
            description: "王熙凤的贴身丫鬟和心腹，贾琏的通房丫头。她为人善良公正，聪明能干，在王熙凤和贾琏之间起到缓冲作用，多次帮助其他丫鬟，展现了高尚的品格。",
            imageName: "ping_er"
        ),
        Character(
            name: "贾琏",
            description: "王熙凤的丈夫，贾赦的儿子。他好色贪财，经常在外拈花惹草，但在家中惧怕妻子王熙凤。他是贾府中的纨绔子弟代表。",
            imageName: "jia_lian"
        ),
        Character(
            name: "刘姥姥",
            description: "王狗儿的岳母，一个来自乡下的穷苦老妇人。她朴实善良，幽默风趣，两次进入贾府求助，见证了贾府的兴衰。她的出现为《红楼梦》增添了浓厚的生活气息和喜剧色彩。",
            imageName: "liu_laolao"
        )
    ]
    
    var body: some View {
        NavigationView {
            List(mainCharacters, id: \.name) { character in
                NavigationLink(destination: CharacterDetailView(character: character)) {
                    HStack(spacing: 16) {
                        // Character image with tap gesture for enlargement
                        CharacterImageView(imageName: character.imageName, name: character.name)
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                // Only show enlarged image if actual image exists (not placeholder)
                                if UIImage(named: character.imageName) != nil {
                                    EnlargedImageView(imageName: character.imageName, characterName: character.name)
                                        .transition(.opacity)
                                }
                            }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(character.name)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            
                            Text(character.description)
                                .font(.caption)
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color(red: 0.96, green: 0.94, blue: 0.90))
            }
            .navigationTitle("人物")
            .listStyle(PlainListStyle())
            .background(
                Color(red: 0.98, green: 0.96, blue: 0.92)
                    .ignoresSafeArea()
            )
        }
        .accentColor(Color(red: 0.6, green: 0.2, blue: 0.2))
    }
}

struct Character: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
}

struct CharacterImageView: View {
    let imageName: String
    let name: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.96, green: 0.94, blue: 0.90))
            
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else {
                // Fallback to text placeholder if image not found
                Text(String(name.first ?? " "))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
            }
        }
    }
}

struct EnlargedImageView: View {
    let imageName: String
    let characterName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Rectangle()
                .fill(Color.black.opacity(0.8))
                .ignoresSafeArea()
            
            // Enlarged image with 3:4 aspect ratio, rounded corners and border
            if let uiImage = UIImage(named: imageName) {
                ZStack {
                    // Background with rounded rectangle and border
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .frame(width: 300, height: 400) // 3:4 ratio (300:400) - increased size
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(red: 0.6, green: 0.2, blue: 0.2), lineWidth: 3)
                        )
                    
                    // Actual image with 3:4 aspect ratio and rounded corners
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
                        .frame(width: 294, height: 394) // Slightly smaller to fit inside border
                        .clipShape(RoundedRectangle(cornerRadius: 22)) // Slightly less corner radius to fit inside
                }
                .padding(.bottom, 100) // Increased padding to accommodate larger image and name text
            } else {
                // Fallback for when image doesn't exist - show rounded rectangle placeholder with border
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(red: 0.96, green: 0.94, blue: 0.90))
                        .frame(width: 300, height: 400) // 3:4 ratio - increased size
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(red: 0.6, green: 0.2, blue: 0.2), lineWidth: 3)
                        )
                    
                    Text(String(characterName.first ?? " "))
                        .font(.system(size: 70, weight: .bold)) // Increased font size for larger placeholder
                        .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                }
                .padding(.bottom, 100)
            }
            
            // Character name overlay
            VStack {
                Spacer()
                Text(characterName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
            }
        }
        .onTapGesture {
            dismiss()
        }
        .ignoresSafeArea()
    }
}

struct CharacterDetailView: View {
    let character: Character
    @State private var showingEnlargedImage = false
    
    var body: some View {
        ZStack {
            // Consistent background for entire view
            Color(red: 0.98, green: 0.96, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    // Character image with tap gesture for enlargement (in detail view too)
                    Button(action: {
                        if UIImage(named: character.imageName) != nil {
                            showingEnlargedImage = true
                        }
                    }) {
                        CharacterImageView(imageName: character.imageName, name: character.name)
                            .frame(width: 120, height: 120)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(character.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                    
                    Text(character.description)
                        .font(.body)
                        .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Additional character info section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("人物特点")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                        
                        createCharacterTraitsText(for: character.name)
                            .font(.body)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    
                    // Famous quotes section
                    if let quote = getFamousQuote(for: character.name) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("经典语录")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            
                            Text("「\(quote)」")
                                .font(.body)
                                .italic()
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                                .padding(.horizontal, 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                }
                .padding(.top, 32)
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEnlargedImage) {
            EnlargedImageView(imageName: character.imageName, characterName: character.name)
        }
    }
    
    private func createCharacterTraitsText(for characterName: String) -> Text {
        switch characterName {
        case "贾宝玉":
            return Text("• 叛逆不羁")
                + Text("\n• 厌恶科举")
                + Text("\n• 重情重义")
                + Text("\n• 才华横溢")
        case "林黛玉":
            return Text("• 才情出众")
                + Text("\n• 敏感多疑")
                + Text("\n• 体弱多病")
                + Text("\n• 情深意重")
        case "薛宝钗":
            return Text("• 端庄贤淑")
                + Text("\n• 处事圆滑")
                + Text("\n• 温柔体贴")
                + Text("\n• 知书达理")
        case "王熙凤":
            return Text("• 精明能干")
                + Text("\n• 手段狠辣")
                + Text("\n• 掌管贾府")
                + Text("\n• 心机深沉")
        case "贾母":
            return Text("• 慈祥威严")
                + Text("\n• 贾府权威")
                + Text("\n• 疼爱宝玉")
                + Text("\n• 家族核心")
        case "贾政":
            return Text("• 严肃古板")
                + Text("\n• 重视礼教")
                + Text("\n• 望子成龙")
                + Text("\n• 传统家长")
        case "贾元春":
            return Text("• 贵为皇妃")
                + Text("\n• 才德兼备")
                + Text("\n• 忧国忧家")
                + Text("\n• 命运悲凉")
        case "袭人":
            return Text("• 温柔体贴")
                + Text("\n• 忠心耿耿")
                + Text("\n• 细心周到")
                + Text("\n• 善解人意")
        case "晴雯":
            return Text("• 性格刚烈")
                + Text("\n• 容貌出众")
                + Text("\n• 心直口快")
                + Text("\n• 命运悲惨")
        case "妙玉":
            return Text("• 孤傲清高")
                + Text("\n• 才华横溢")
                + Text("\n• 洁身自好")
                + Text("\n• 命运坎坷")
        case "史湘云":
            return Text("• 豪爽直率")
                + Text("\n• 才思敏捷")
                + Text("\n• 乐观开朗")
                + Text("\n• 身世可怜")
        case "贾探春":
            return Text("• 精明能干")
                + Text("\n• 有远见卓识")
                + Text("\n• 志向高远")
                + Text("\n• 刚强自立")
        case "贾迎春":
            return Text("• 性格懦弱")
                + Text("\n• 逆来顺受")
                + Text("\n• 善良温和")
                + Text("\n• 命运悲惨")
        case "贾惜春":
            return Text("• 性格孤僻")
                + Text("\n• 喜好绘画")
                + Text("\n• 看破红尘")
                + Text("\n• 最终出家")
        case "鸳鸯":
            return Text("• 聪明能干")
                + Text("\n• 忠心耿耿")
                + Text("\n• 坚强不屈")
                + Text("\n• 誓死守节")
        case "秦可卿":
            return Text("• 美貌绝伦")
                + Text("\n• 温柔贤淑")
                + Text("\n• 身份神秘")
                + Text("\n• 命运离奇")
        case "平儿":
            return Text("• 善良公正")
                + Text("\n• 聪明能干")
                + Text("\n• 处事圆滑")
                + Text("\n• 忠心护主")
        case "贾琏":
            return Text("• 好色贪财")
                + Text("\n• 畏惧妻子")
                + Text("\n• 纨绔子弟")
                + Text("\n• 缺乏担当")
        case "刘姥姥":
            return Text("• 朴实善良")
                + Text("\n• 幽默风趣")
                + Text("\n• 见多识广")
                + Text("\n• 知恩图报")
        default:
            return Text("• 主要人物")
                + Text("\n• 性格鲜明")
                + Text("\n• 命运多舛")
        }
    }
    
    private func getFamousQuote(for characterName: String) -> String? {
        switch characterName {
        case "贾宝玉":
            return "女儿是水做的骨肉，男人是泥做的骨肉。我见了女儿便觉清爽，见了男子便觉浊臭逼人。"
        case "林黛玉":
            return "花谢花飞花满天，红消香断有谁怜？"
        case "薛宝钗":
            return "好风凭借力，送我上青云。"
        case "王熙凤":
            return "我是从来不信什么阴司地狱报应的，凭是什么事，我说要行就行。"
        case "贾母":
            return "咱们这样人家的姑娘，倒不要这些才华的名誉。"
        case "贾政":
            return "畜生！畜生！该死的畜生！"
        case "贾元春":
            return "田舍之家，虽齑盐布帛，终能聚天伦之乐；今虽富贵已极，骨肉各方，然终无意趣！"
        case "袭人":
            return "二爷何苦这样？总要想个法儿才是。"
        case "晴雯":
            return "只是一件，我死也不甘心的：我虽生得比别人略好些，并没有私情密意勾引你怎样。"
        case "妙玉":
            return "纵有千年铁门槛，终须一个土馒头。"
        case "史湘云":
            return "且住为佳耳，何必较真？"
        case "贾探春":
            return "我但凡是个男人，可以出得去，我必早走了，立一番事业。"
        case "贾迎春":
            return "我不信我的命就这么不好！"
        case "贾惜春":
            return "我这里正画着大观园，还没画完呢。"
        case "鸳鸯":
            return "别说大老爷要我做小老婆，就是太太这会子死了，大老爷要收我做房里人，我也不愿意！"
        case "秦可卿":
            return "月难逢，彩云易散。心比天高，身为下贱。"
        case "平儿":
            return "奶奶别生气，凡事都要慢慢来，急不得的。"
        case "贾琏":
            return "我不过是个混账东西罢了，哪里配得上你这样的贤妻！"
        case "刘姥姥":
            return "老刘，老刘，食量大如牛，吃个老母猪不抬头！"
        default:
            return nil
        }
    }
}

#Preview {
    CharactersView()
}