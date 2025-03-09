//
//  MaskBootcamp.swift
//  ContinueLearing
//
//  Created by TOTI SABZ on 3/3/25.
//

import SwiftUI

struct MaskBootcamp: View {
    
    @State var rating: Int = 0
    
    var body: some View {
        starsView
            .overlay {
                overlayView.mask(starsView)
            }
    }
    
    private var overlayView: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(.yellow)
                .frame(width: CGFloat(rating) / 5 * geo.size.width)
        }
        .allowsHitTesting(false) // USER CANT TAP ON THE RECANGLE BECAUSE THEN WE CANT UNDO THE RATING
    }
    
    private var starsView: some View {
        HStack{
            ForEach(1..<6){ index in
                Image(systemName: "star.fill")
                    .font(.largeTitle)
                    .foregroundStyle(index <= rating ? .yellow : .gray)
                    .onTapGesture {
                        withAnimation{
                            rating = index
                        }
                    }
            }
        }
    }

}

#Preview {
    MaskBootcamp()
}
