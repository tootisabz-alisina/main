//
//  GeometryReaderBootcamp.swift
//  ContinueLearing
//
//  Created by TOTI SABZ on 3/2/25.
//

// FIRST OF ALL TRY NOT TO USE GEOMETRY READER
// IT HAS A STRONG EMPACT ON PREFORMANCE
// JUST USE IT WHEN NEEDED

import SwiftUI

struct GeometryReaderBootcamp: View {
    
    // WHEN THE CARD MID X WAS AT THE CENTER THEN MAKE THE DEGREE ZERO
    func getPercentage(geo: GeometryProxy) -> CGFloat{
        let maxDistance = UIScreen.main.bounds.width / 2
        let currentX = geo.frame(in: .global).midX // THIS WILL TAKE THE CENTER OF THE CARDS
        return 1 - (currentX / maxDistance)
    }
    
    var body: some View {
        
        
        // WITHOUT GEOMETRY READER
        // IT IGNORES THE DEVICE ROTATION
//        HStack(spacing: 0){
//            Rectangle()
//                .fill(Color.red)
//                .frame(width: UIScreen.main.bounds.width * 0.6666)
//            Rectangle()
//                .fill(Color.cyan)
//        }
//        .ignoresSafeArea()
        
        // SO NOW WITH THE GEOMETRY READER WE DONT HAVE TO WORRY ABOUT THE DEVICE ORIENTATION
//        GeometryReader { geo in
//            HStack(spacing: 0){
//                Rectangle()
//                    .fill(Color.red)
//                    .frame(width: geo.size.width * 0.6666)
//                Rectangle()
//                    .fill(Color.cyan)
//            }
//            .ignoresSafeArea()
//        }
        
        // EXAMPLE OF REAL WORLD
        ScrollView(.horizontal) {
            HStack(spacing: 0){
                ForEach(0..<20) { i in
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.cyan)
                            .rotation3DEffect(Angle(degrees: getPercentage(geo: geo) * 30), axis: (x: 0.0, y: 1.0, z: 0.0))

                    }
                    .frame(width: 300, height: 250)
                    .padding()
                }
            }
        }
        
    }
}

#Preview {
    GeometryReaderBootcamp()
}
