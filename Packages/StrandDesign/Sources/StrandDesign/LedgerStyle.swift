import SwiftUI

// MARK: - Ledger shell (editorial / instrument)
//
// A deliberately non-"wellness app" surface: flat paper, hairline rules, serif mastheads,
// monospaced numerals, and sharp corners. Opt in via TodayShellStyle.ledger — not the default.

public enum LedgerMetrics {
    public static let cornerRadius: CGFloat = 10
    public static let ruleWidth: CGFloat = 1
    public static let columnGap: CGFloat = 0
}

/// One score column in the day ledger (Charge / Effort / Rest).
public struct LedgerScoreCell: Identifiable {
    public let id: String
    public let title: LocalizedStringKey
    public let value: String
    public let detail: String?
    public let accent: Color
    public let onTap: (() -> Void)?

    public init(
        id: String,
        title: LocalizedStringKey,
        value: String,
        detail: String? = nil,
        accent: Color,
        onTap: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.detail = detail
        self.accent = accent
        self.onTap = onTap
    }
}

/// Flat card fill: no gradient, no shadow — only a single hairline frame.
public struct LedgerFlatSurface: View {
    public var cornerRadius: CGFloat
    @AppStorage(CardAppearancePrefs.opacityKey) private var cardOpacityPercent = CardAppearancePrefs.defaultPercent

    public init(cornerRadius: CGFloat = LedgerMetrics.cornerRadius) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        let op = max(0, min(1, Double(cardOpacityPercent) / 100.0))
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        shape
            .fill(StrandPalette.surfaceRaised)
            .overlay(shape.strokeBorder(StrandPalette.hairline, lineWidth: LedgerMetrics.ruleWidth))
            .opacity(op)
    }
}

/// The three-up score strip — one bordered panel, vertical rules, typographic hierarchy.
public struct LedgerDayScoresBoard: View {
    public var cells: [LedgerScoreCell]

    public init(cells: [LedgerScoreCell]) {
        self.cells = cells
    }

    public var body: some View {
        HStack(spacing: LedgerMetrics.columnGap) {
            ForEach(Array(cells.enumerated()), id: \.element.id) { index, cell in
                if index > 0 {
                    Rectangle()
                        .fill(StrandPalette.hairline)
                        .frame(width: LedgerMetrics.ruleWidth)
                }
                column(cell)
            }
        }
        .frame(maxWidth: .infinity)
        .background(LedgerFlatSurface())
    }

    @ViewBuilder
    private func column(_ cell: LedgerScoreCell) -> some View {
        let content = VStack(alignment: .leading, spacing: 6) {
            Text(cell.title)
                .font(LedgerFont.kicker)
                .foregroundStyle(StrandPalette.textTertiary)
                .textCase(.uppercase)
                .tracking(1.2)
            Text(cell.value)
                .font(LedgerFont.score(36))
                .foregroundStyle(cell.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
            if let detail = cell.detail, !detail.isEmpty {
                Text(detail)
                    .font(LedgerFont.detail)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)

        if let onTap = cell.onTap {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}

public enum LedgerFont {
    /// Masthead date line — New York / serif on Apple platforms.
    public static var masthead: Font {
        .system(.title2, design: .serif, weight: .regular)
    }

    public static var kicker: Font {
        .system(size: 10, weight: .semibold, design: .default)
    }

    public static func score(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced).monospacedDigit()
    }

    public static var detail: Font {
        .system(size: 12, weight: .regular, design: .default)
    }
}

public extension View {
    /// Ledger section titles: serif, left-aligned, no overline chip aesthetic.
    func ledgerSectionTitle() -> some View {
        font(LedgerFont.masthead)
            .foregroundStyle(StrandPalette.textPrimary)
    }
}
