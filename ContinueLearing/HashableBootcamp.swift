//
//  HashableBootcamp.swift
//  ContinueLearing
//
//  Created by TOTI SABZ on 3/5/25.
//

import SwiftUI

struct MyModel: Hashable {
    let name: String
    
    // THIS IS OPTIONAL CUZ SWIFTUI DO IT AUTOMATICLLY
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

struct HashableBootcamp: View {
    
    let data: [MyModel] = [
        MyModel(name: "ONE"),
        MyModel(name: "TWO"),
        MyModel(name: "THREE"),
        MyModel(name: "FOUR"),
        MyModel(name: "FIVE"),
    ]
    
    var body: some View {
        VStack {
            ForEach(data, id: \.self) { item in
                Text(item.name)
            }
        }
    }
}

#Preview {
    HashableBootcamp()
}
