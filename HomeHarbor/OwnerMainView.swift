//
//  OwnerMainView.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 4/15/24.
//

import SwiftUI

struct OwnerMainView: View {
    @State private var selectedTab = "home"
    var body: some View {
        TabView {
            OwnerHomeView()
                .tabItem { Label("", systemImage: "house") }
            LaundryView()
                .tabItem { Label("", systemImage: "tshirt") }
        }
    }
}
#Preview {
    OwnerMainView()
}
