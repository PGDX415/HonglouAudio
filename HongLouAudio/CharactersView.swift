//
//  CharactersView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct CharactersView: View {
    // Main characters data
    @ObservedObject private var theme = ThemeManager.shared
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
    
    @State private var selectedCharacter: Character? = nil

    var body: some View {
        ZStack {
            List(mainCharacters, id: \.name) { character in
                HStack(spacing: 16) {
                        // Character image with tap gesture for enlargement
                        CharacterImageView(imageName: character.imageName, name: character.name)
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                // Only show enlarged image if actual image exists (not placeholder)
                                if UIImage(named: character.imageName) != nil {
                                    _ = EnlargedImageView(imageName: character.imageName, characterName: character.name)
                                }
                            }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(character.name)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(theme.primaryText)
                            
                            Text(character.description)
                                .font(.caption)
                                .foregroundColor(theme.secondaryText)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCharacter = character
                }
                .listRowBackground(theme.cardBackground)
            }
            .navigationTitle("人物")
            .listStyle(PlainListStyle())
            .background(
                theme.pageBackground
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CharacterRelationshipView()) {
                        Image(systemName: "flowchart.fill")
                            .foregroundColor(theme.accentRed)
                            .font(.title3)
                    }
                }
            }

            // Hidden NavigationLink outside List
            if let character = selectedCharacter {
                NavigationLink(
                    destination: CharacterDetailView(character: character),
                    isActive: Binding(
                        get: { selectedCharacter != nil },
                        set: { if !$0 { selectedCharacter = nil } }
                    )
                ) { EmptyView() }
                .hidden()
            }
        }
    }
}

struct Character: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
}

struct CharacterImageView: View {
    @ObservedObject private var theme = ThemeManager.shared
    let imageName: String
    let name: String

    var body: some View {
        ZStack {
            Circle()
                .fill(theme.cardBackground)
            
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else {
                // Fallback to text placeholder if image not found
                Text(String(name.first ?? " "))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.accentRed)
            }
        }
    }
}

struct EnlargedImageView: View {
    @ObservedObject private var theme = ThemeManager.shared
    let imageName: String
    let characterName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Full-screen dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack {
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                }

                Text(characterName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 16)
            }
        }
    }
}

struct CharacterDetailView: View {
    @ObservedObject private var theme = ThemeManager.shared
    let character: Character
    @State private var showingEnlargedImage = false

    var body: some View {
        ZStack {
            // Consistent background for entire view
            theme.pageBackground
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
                        .foregroundColor(theme.primaryText)
                    
                    Text(character.description)
                        .font(.body)
                        .foregroundColor(theme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Additional character info section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("人物特点")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.primaryText)
                        
                        createCharacterTraitsText(for: character.name)
                            .font(.body)
                            .foregroundColor(theme.primaryText)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    
                    // Famous quotes section
                    let quotes = CharacterQuoteStore.quotesFor(character.name)
                    if !quotes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("经典语录")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(theme.primaryText)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)

                            ForEach(quotes) { quote in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        Rectangle()
                                            .fill(theme.accentRed.opacity(0.4))
                                            .frame(width: 3)
                                            .cornerRadius(1.5)

                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("「\(quote.text)」")
                                                .font(.system(size: 15, design: .serif))
                                                .foregroundColor(theme.primaryText)
                                                .lineSpacing(5)

                                            HStack {
                                                Text(quote.context)
                                                    .font(.system(size: 11, design: .serif))
                                                    .foregroundColor(theme.tertiaryText)
                                                    .lineLimit(2)

                                                Spacer()

                                                Button(action: {
                                                    let card = QuoteShareCard(
                                                        quote: quote.text,
                                                        character: character.name,
                                                        chapterInfo: "第\(quote.chapterNumber)回"
                                                    )
                                                    let cardSize = CGSize(width: 390, height: 550)
                                                    if let image = ShareCardRenderer.render(card, size: cardSize) {
                                                        ShareCardRenderer.share(image: image)
                                                    }
                                                }) {
                                                    Image(systemName: "square.and.arrow.up")
                                                        .font(.caption2)
                                                        .foregroundColor(theme.accentRed.opacity(0.6))
                                                }
                                            }

                                            Text("—— 第\(quote.chapterNumber)回")
                                                .font(.system(size: 10, design: .serif))
                                                .foregroundColor(theme.tertiaryText.opacity(0.7))
                                        }
                                    }
                                }
                                .padding(12)
                                .background(theme.cardBackground)
                                .cornerRadius(10)
                                .padding(.horizontal, 24)
                            }
                        }
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
    
    private let characterTraits: [String: String] = [
        "贾宝玉": "• 叛逆不羁\n• 厌恶科举\n• 重情重义\n• 才华横溢",
        "林黛玉": "• 才情出众\n• 敏感多疑\n• 体弱多病\n• 情深意重",
        "薛宝钗": "• 端庄贤淑\n• 处事圆滑\n• 温柔体贴\n• 知书达理",
        "王熙凤": "• 精明能干\n• 手段狠辣\n• 掌管贾府\n• 心机深沉",
        "贾母": "• 慈祥威严\n• 贾府权威\n• 疼爱宝玉\n• 家族核心",
        "贾政": "• 严肃古板\n• 重视礼教\n• 望子成龙\n• 传统家长",
        "贾元春": "• 贵为皇妃\n• 才德兼备\n• 忧国忧家\n• 命运悲凉",
        "袭人": "• 温柔体贴\n• 忠心耿耿\n• 细心周到\n• 善解人意",
        "晴雯": "• 性格刚烈\n• 容貌出众\n• 心直口快\n• 命运悲惨",
        "妙玉": "• 孤傲清高\n• 才华横溢\n• 洁身自好\n• 命运坎坷",
        "史湘云": "• 豪爽直率\n• 才思敏捷\n• 乐观开朗\n• 身世可怜",
        "贾探春": "• 精明能干\n• 有远见卓识\n• 志向高远\n• 刚强自立",
        "贾迎春": "• 性格懦弱\n• 逆来顺受\n• 善良温和\n• 命运悲惨",
        "贾惜春": "• 性格孤僻\n• 喜好绘画\n• 看破红尘\n• 最终出家",
        "鸳鸯": "• 聪明能干\n• 忠心耿耿\n• 坚强不屈\n• 誓死守节",
        "秦可卿": "• 美貌绝伦\n• 温柔贤淑\n• 身份神秘\n• 命运离奇",
        "平儿": "• 善良公正\n• 聪明能干\n• 处事圆滑\n• 忠心护主",
        "贾琏": "• 好色贪财\n• 畏惧妻子\n• 纨绔子弟\n• 缺乏担当",
        "刘姥姥": "• 朴实善良\n• 幽默风趣\n• 见多识广\n• 知恩图报"
    ]

    private func createCharacterTraitsText(for characterName: String) -> Text {
        Text(characterTraits[characterName] ?? "• 主要人物\n• 性格鲜明\n• 命运多舛")
    }
}

#Preview {
    CharactersView()
}