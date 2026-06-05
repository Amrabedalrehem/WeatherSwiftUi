//
//  FlowLayout.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 05/06/2026.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map {
            $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        }
        .reduce(0) { $0 + $1 + spacing }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map {
                $0.sizeThatFits(.unspecified).height
            }.max() ?? 0

            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: .unspecified
                )
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var currentRowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth,
               !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentRowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            currentRowWidth += size.width + spacing
        }
        return rows
    }
}
