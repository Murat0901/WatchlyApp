//
//  PremiumTag.swift
//  Watchly
//
//  Created by Murat Menzilci on 2/3/22.
//

import SwiftUI

/// Shows a premium tag overlay on certain watch faces
struct PremiumTag: View {
    
    // MARK: - Main rendering function
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 3) {
                Text("PRO").font(.system(size: 11, weight: .medium))
                Image(systemName: "crown.fill").font(.system(size: 12))
            }.foregroundColor(.white).padding(.horizontal, 7).padding(.vertical, 3).background(
                Color.black.cornerRadius(10)
            )
        }.padding(15)
    }
}

// MARK: - Preview UI
struct PremiumTag_Previews: PreviewProvider {
    static var previews: some View {
        PremiumTag()
    }
}
