//
//  ProgressBar.swift
//  smallGaol
//
//  Created by Apple on 2024/04/30.
//

import SwiftUI

struct ProgressBar: View {
    var value: Double
    var maxValue: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.3)
                    .foregroundColor(color)
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(value / maxValue))
                    .foregroundColor(color)
            }
        }
        .cornerRadius(8.0)
    }
}

#Preview {
    ProgressBar(value: 1, maxValue: 10, color: .red)
}
