//
//  BackgroundThreadAndQueueBootcamp.swift
//  ContinueLearing
//
//  Created by TOTI SABZ on 3/5/25.
//

import SwiftUI

class MyViewModel: ObservableObject{
    
    @Published var dataArray: [String] = []
    
    func fetchData(){
        DispatchQueue.global().async {
            let downloadedData = self.downloadData()
            
            DispatchQueue.main.async {
                self.dataArray = downloadedData
            }
        }
    }
    
    func downloadData() -> [String]{
        var downloadedData: [String] = []
        for x in 0..<5000 {
            downloadedData.append("\(x)")
            print(x)
        }
        return downloadedData
    }
    
}

struct BackgroundThreadAndQueueBootcamp: View {
    
    @StateObject var vm: MyViewModel = MyViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack{
                Button("Load Data") {
                    vm.fetchData()
                }

                ForEach(vm.dataArray, id: \.self){ x in
                    Text("\(x)")
                }
            }
        }
    }
}

#Preview {
    BackgroundThreadAndQueueBootcamp()
}
