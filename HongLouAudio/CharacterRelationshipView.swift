//
//  CharacterRelationshipView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/7/31.
//

import SwiftUI

// MARK: - Data Models

struct RelationPerson: Identifiable {
    let id = UUID()
    let name: String
    let title: String        // e.g., "妻", "子", "女", "妾"
    let isSpouse: Bool       // shown beside, not below
    let isDeceased: Bool
    let branchColor: Color
}

struct PersonNode {
    let person: RelationPerson
    var children: [PersonNode] = []
    var spouse: RelationPerson? = nil
    var concubines: [RelationPerson] = []
}

// MARK: - Relationship View

struct CharacterRelationshipView: View {
    @ObservedObject private var theme = ThemeManager.shared
    private let vermillion = Color(red: 0.55, green: 0.08, blue: 0.08)
    private let deepRed = Color(red: 0.35, green: 0.02, blue: 0.02)
    private let antiqueGold = Color(red: 0.78, green: 0.65, blue: 0.35)
    private let creamWhite = Color(red: 0.96, green: 0.93, blue: 0.86)
    private let inkBlack = Color(red: 0.12, green: 0.08, blue: 0.05)
    private let jadeGreen = Color(red: 0.2, green: 0.5, blue: 0.4)
    private let ningguoBlue = Color(red: 0.15, green: 0.25, blue: 0.45)
    private let scholarBlue = Color(red: 0.12, green: 0.35, blue: 0.55)

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            VStack(alignment: .leading, spacing: 0) {
                // Title
                VStack(spacing: 8) {
                    Text("红楼梦 人物关系图")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(deepRed)

                    Rectangle()
                        .fill(antiqueGold.opacity(0.5))
                        .frame(width: 120, height: 1)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // ========== 荣国府 ==========
                sectionHeader("荣国府", color: vermillion)

                // --- 贾母 ---
                ancestorNode("贾母", subtitle: "史氏 · 老祖宗", color: vermillion)
                    .padding(.leading, 260)

                // Vertical connector from 贾母 to children
                verticalLine(from: CGPoint(x: 309, y: 0), height: 24, color: antiqueGold)
                    .padding(.leading, 260)

                // Three branches: 贾赦 / 贾政 / 贾敏
                HStack(alignment: .top, spacing: 0) {
                    // --- 贾赦 branch ---
                    jiaSheBranch()
                        .frame(width: 240)

                    branchDivider()

                    // --- 贾政 branch ---
                    jiaZhengBranch()
                        .frame(width: 300)

                    branchDivider()

                    // --- 贾敏 branch ---
                    jiaMinBranch()
                        .frame(width: 180)
                }
                .padding(.leading, 12)

                // ========== 宁国府 ==========
                sectionHeader("宁国府", color: ningguoBlue)
                    .padding(.top, 20)

                HStack(alignment: .top, spacing: 0) {
                    Spacer().frame(width: 260)
                    ningguoBranch()
                }

                // ========== 四大家族 ==========
                sectionHeader("四大家族姻亲关联", color: scholarBlue)
                    .padding(.top, 20)

                fourFamiliesSection()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)

                // ========== 金陵十二钗 ==========
                sectionHeader("金陵十二钗", color: vermillion)
                    .padding(.top, 10)

                twelveBeautiesSection()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 12)
        }
        .background(
            theme.pageBackground
                .ignoresSafeArea()
        )
        .navigationTitle("人物关系图")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Jia She Branch

    @ViewBuilder
    private func jiaSheBranch() -> some View {
        VStack(spacing: 0) {
            // 贾赦 + 邢夫人
            coupleNode("贾赦", "邢夫人", subtitle: "长子 · 一等将军", color: vermillion)

            verticalLine(height: 18, color: vermillion)

            // Children
            HStack(alignment: .top, spacing: 12) {
                // 贾琏 + 王熙凤
                VStack(spacing: 0) {
                    coupleNodeCompact("贾琏", "王熙凤", color: vermillion)
                    verticalLine(height: 12, color: vermillion)
                    childNode("巧姐", relation: "女", color: vermillion)
                }

                VStack(spacing: 0) {
                    childNode("贾迎春", relation: "庶女", color: vermillion)
                        .padding(.top, 12)
                }
            }

            // 贾琏 妾室
            HStack(spacing: 12) {
                concubineNode("平儿", color: vermillion)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Jia Zheng Branch

    @ViewBuilder
    private func jiaZhengBranch() -> some View {
        VStack(spacing: 0) {
            // 贾政 + 王夫人
            coupleNode("贾政", "王夫人", subtitle: "次子 · 工部员外郎", color: vermillion)

            verticalLine(height: 18, color: vermillion)

            // Children row
            HStack(alignment: .top, spacing: 16) {
                // 贾珠 + 李纨
                VStack(spacing: 0) {
                    coupleNodeCompact("贾珠", "李纨", isDeceased: true, color: vermillion)
                    verticalLine(height: 10, color: vermillion)
                    childNode("贾兰", relation: "子", color: vermillion)
                }

                // 贾元春
                VStack(spacing: 0) {
                    childNode("贾元春", relation: "长女\n贤德妃", color: vermillion)
                        .padding(.top, 10)
                }

                // 贾宝玉
                VStack(spacing: 0) {
                    childNode("贾宝玉", relation: "次子", color: vermillion)
                        .padding(.top, 10)
                }
            }

            // 宝玉的丫鬟/妾
            HStack(spacing: 10) {
                concubineNode("袭人", relation: "妾", color: vermillion)
                maidNode("晴雯", color: vermillion)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Jia Min Branch (Lin Daiyu)

    @ViewBuilder
    private func jiaMinBranch() -> some View {
        VStack(spacing: 0) {
            coupleNode("贾敏", "林如海", subtitle: "幼女 · 扬州巡盐御史", isDeceased: true, color: vermillion)

            verticalLine(height: 18, color: vermillion)

            childNode("林黛玉", relation: "女", color: vermillion)
        }
    }

    // MARK: - Ningguo Branch

    @ViewBuilder
    private func ningguoBranch() -> some View {
        VStack(spacing: 0) {
            coupleNode("贾珍", "尤氏", subtitle: "宁国公后 · 三品威烈将军", color: ningguoBlue)

            verticalLine(height: 18, color: ningguoBlue)

            HStack(alignment: .top, spacing: 20) {
                VStack(spacing: 0) {
                    coupleNodeCompact("贾蓉", "秦可卿", color: ningguoBlue)
                }
                VStack(spacing: 0) {
                    childNode("贾惜春", relation: "妹", color: ningguoBlue)
                        .padding(.top, 10)
                }
            }
        }
    }

    // MARK: - Four Families Section

    @ViewBuilder
    private func fourFamiliesSection() -> some View {
        VStack(spacing: 16) {
            familyConnectionCard(
                title: "贾史王薛 · 一荣俱荣",
                body: "贾不假，白玉为堂金作马。\n阿房宫，三百里，住不下金陵一个史。\n东海缺少白玉床，龙王来请金陵王。\n丰年好大雪，珍珠如土金如铁。",
                color: scholarBlue
            )

            HStack(spacing: 12) {
                familyTag("王家", names: "王夫人 · 王熙凤 · 薛姨妈", color: antiqueGold)
                arrowRight()
                familyTag("贾家", names: "贾政 · 贾琏", color: vermillion)
            }

            HStack(spacing: 12) {
                familyTag("薛家", names: "薛姨妈 → 薛宝钗 · 薛蟠", color: jadeGreen)
                arrowRight()
                familyTag("贾家", names: "贾宝玉（金玉良缘）", color: vermillion)
            }

            HStack(spacing: 12) {
                familyTag("史家", names: "史湘云（贾母侄孙女）", color: ningguoBlue)
                arrowRight()
                familyTag("贾家", names: "常住贾府", color: vermillion)
            }

            HStack(spacing: 12) {
                familyTag("林家", names: "林如海 · 贾敏", color: Color(red: 0.5, green: 0.4, blue: 0.6))
                arrowRight()
                familyTag("贾家", names: "林黛玉（木石前盟）", color: vermillion)
            }
        }
    }

    // MARK: - Twelve Beauties Section

    @ViewBuilder
    private func twelveBeautiesSection() -> some View {
        VStack(spacing: 10) {
            // Row 1
            HStack(spacing: 8) {
                beautyTag("林黛玉")
                beautyTag("薛宝钗")
                beautyTag("贾元春")
                beautyTag("贾探春")
            }
            // Row 2
            HStack(spacing: 8) {
                beautyTag("史湘云")
                beautyTag("妙玉")
                beautyTag("贾迎春")
                beautyTag("贾惜春")
            }
            // Row 3
            HStack(spacing: 8) {
                beautyTag("王熙凤")
                beautyTag("巧姐")
                beautyTag("李纨")
                beautyTag("秦可卿")
            }
        }
    }

    // MARK: - Shared Components

    private func sectionHeader(_ title: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(color)
                .frame(width: 4, height: 22)
                .cornerRadius(2)
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(color)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func ancestorNode(_ name: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color, lineWidth: 2)
                    )
                VStack(spacing: 2) {
                    Text(name)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(color)
                    Text(subtitle)
                        .font(.system(size: 10, design: .serif))
                        .foregroundColor(color.opacity(0.7))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
            }
            .fixedSize()
        }
    }

    private func coupleNode(_ person1: String, _ person2: String, subtitle: String, isDeceased: Bool = false, color: Color) -> some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.4), lineWidth: 1.5)
                    )
                HStack(spacing: 6) {
                    Text(person1)
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(isDeceased ? color.opacity(0.5) : color)
                        .strikethrough(isDeceased)
                    Text("·")
                        .font(.system(size: 12))
                        .foregroundColor(antiqueGold)
                    Text(person2)
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(color.opacity(0.8))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)

                // Subtitle badge
                if !subtitle.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(subtitle)
                                .font(.system(size: 8, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(color.opacity(0.7))
                                .cornerRadius(4)
                                .offset(x: 4, y: 10)
                        }
                    }
                }
            }
            .fixedSize()
        }
    }

    private func coupleNodeCompact(_ person1: String, _ person2: String, isDeceased: Bool = false, color: Color) -> some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
                HStack(spacing: 4) {
                    Text(person1)
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundColor(isDeceased ? color.opacity(0.5) : color)
                        .strikethrough(isDeceased)
                    Text("·")
                        .font(.system(size: 10))
                        .foregroundColor(antiqueGold)
                    Text(person2)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(color.opacity(0.8))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
            }
            .fixedSize()
        }
    }

    private func childNode(_ name: String, relation: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            VStack(spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundColor(color)
                Text(relation)
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(color.opacity(0.5))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
        }
        .fixedSize()
    }

    private func concubineNode(_ name: String, relation: String = "通房", color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(color.opacity(0.2), lineWidth: 1, dash: [3, 2])
            HStack(spacing: 3) {
                Text(name)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(color.opacity(0.6))
                Text("(\(relation))")
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(color.opacity(0.4))
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .fixedSize()
    }

    private func maidNode(_ name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(color.opacity(0.15), lineWidth: 1, dash: [3, 2])
            Text(name)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(color.opacity(0.5))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
        }
        .fixedSize()
    }

    private func verticalLine(height: CGFloat, color: Color) -> some View {
        Rectangle()
            .fill(color.opacity(0.3))
            .frame(width: 2, height: height)
    }

    private func verticalLine(from start: CGPoint, height: CGFloat, color: Color) -> some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: CGPoint(x: start.x, y: start.y + height))
        }
        .stroke(color.opacity(0.3), lineWidth: 2)
        .frame(height: height)
    }

    private func branchDivider() -> some View {
        Rectangle()
            .fill(antiqueGold.opacity(0.12))
            .frame(width: 1)
            .padding(.horizontal, 6)
    }

    private func familyConnectionCard(title: String, body: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundColor(color)
            Text(body)
                .font(.system(size: 12, design: .serif))
                .foregroundColor(inkBlack.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func familyTag(_ family: String, names: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(family)
                .font(.system(size: 14, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(color)
                .cornerRadius(6)
            Text(names)
                .font(.system(size: 10, design: .serif))
                .foregroundColor(inkBlack.opacity(0.5))
        }
    }

    private func arrowRight() -> some View {
        Image(systemName: "arrow.right")
            .font(.caption2)
            .foregroundColor(antiqueGold)
    }

    private func beautyTag(_ name: String) -> some View {
        Text(name)
            .font(.system(size: 13, design: .serif))
            .foregroundColor(deepRed)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(vermillion.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(vermillion.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Shape dash stroke extension

extension Shape {
    func stroke<Content: ShapeStyle>(_ content: Content, lineWidth: CGFloat = 1, dash: [CGFloat]) -> some View {
        self.stroke(content, style: StrokeStyle(lineWidth: lineWidth, dash: dash))
    }
}

#Preview {
    NavigationStack {
        CharacterRelationshipView()
    }
}
