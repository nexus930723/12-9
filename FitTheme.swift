//
//  FitTheme.swift
//  Final (FitCart)
//  Design System for unified styling
//
//  Created by Assistant on 2025/12/18.
//

import SwiftUI

// MARK: - Theme Tokens

enum FitColor {
    static let brand = Color.teal
    static let accent = Color.orange
    static let cardBackground = Color(.secondarySystemBackground)
    static let groupBackground = Color(.systemBackground)
    static let separator = Color(.separator)
    static let subtleFill = Color.accentColor.opacity(0.12)

    
    static var sceneBackground: Color {
        Color(uiColor: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                
                return UIColor(red: 0.08, green: 0.10, blue: 0.11, alpha: 1.0)
            } else {
                return UIColor(red: 0.94, green: 0.97, blue: 0.97, alpha: 1.0)
            }
        })
    }
}

enum FitRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 22
}

enum FitSpacing {
    static let xSmall: CGFloat = 6
    static let small: CGFloat = 10
    static let medium: CGFloat = 14
    static let large: CGFloat = 18
    static let xLarge: CGFloat = 24
}

enum FitShadow {
    static let card = ShadowStyle(color: .black.opacity(0.08), radius: 10, y: 4)
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat = 0
        let y: CGFloat
    }
}

// MARK: - Reusable Styles

struct FitCardBackground: View {
    let fill: Color
    var body: some View {
        RoundedRectangle(cornerRadius: FitRadius.large, style: .continuous)
            .fill(fill)
    }
}

struct FitCardModifier: ViewModifier {
    var fill: Color = FitColor.cardBackground
    var shadow: FitShadow.ShadowStyle = FitShadow.card

    func body(content: Content) -> some View {
        content
            .padding(FitSpacing.medium)
            .background(FitCardBackground(fill: fill))
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func fitCard(fill: Color = FitColor.cardBackground) -> some View {
        modifier(FitCardModifier(fill: fill))
    }

    func fitSectionHeader(_ title: String, systemImage: String? = nil) -> some View {
        HStack(spacing: FitSpacing.small) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(FitColor.brand)
            }
            Text(title)
                .font(.headline.weight(.semibold))
                .textCase(nil)
            Spacer()
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 2)
    }

    func fitGroupBox() -> some View {
        self
            .padding(FitSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: FitRadius.large, style: .continuous)
                    .fill(FitColor.cardBackground)
            )
    }

    func fitPill(background: Color = FitColor.subtleFill, foreground: Color = .primary) -> some View {
        self
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(background))
            .foregroundStyle(foreground)
    }
}

// MARK: - Buttons

struct FitPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: FitRadius.medium, style: .continuous)
                    .fill(FitColor.brand)
                    .opacity(configuration.isPressed ? 0.85 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct FitSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(FitColor.brand)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: FitRadius.medium, style: .continuous)
                    .fill(FitColor.subtleFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FitRadius.medium, style: .continuous)
                    .stroke(FitColor.brand.opacity(0.25), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == FitPrimaryButtonStyle {
    static var fitPrimary: FitPrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == FitSecondaryButtonStyle {
    static var fitSecondary: FitSecondaryButtonStyle { .init() }
}

// MARK: - Components

struct SectionContainer<Content: View>: View {
    let title: String
    let systemImage: String?
    @ViewBuilder var content: () -> Content

    init(_ title: String, systemImage: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FitSpacing.small) {
            HStack(spacing: FitSpacing.small) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(FitColor.brand)
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                Spacer()
            }
            .padding(.bottom, 2)
            content()
        }
        .fitCard()
    }
}

struct MetricValueView: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Text(value)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "flame.fill")
                .foregroundStyle(color.opacity(0.85))
        }
        .padding(FitSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: FitRadius.large, style: .continuous)
                .fill(FitColor.cardBackground)
        )
    }
}
