//
//  CameraOverlay.swift
//  ContinueLearing
//
//  Created by TOTI SABZ on 2/22/25.
//

import SwiftUI

struct CameraOverlay: View {
    var body: some View {
        ZStack {
            // Background view (e.g., camera preview or any other view)
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // Ellipse overlay
            Ellipse()
                .frame(width: 300, height: 350)
                .overlay(
                    Ellipse()
                        .stroke(Color.black, lineWidth: 2)
                )
                .background(
                    Ellipse()
                        .fill(Color.clear)
                )
                .compositingGroup()
                .blendMode(.destinationOut)
        }
        .background(Color.clear)
        .compositingGroup()
    }
}

#Preview {
    CameraOverlay()
}
