//
//  OwnerHomeView.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/23/24.
//

import SwiftUI

struct OwnerHomeView: View {

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                NavigationButton(title: "Show Properties", systemImage: "eye", destination: PropertiesView())
                NavigationButton(title: "Rent + Utilities", systemImage: "dollarsign.circle", destination: OwnerView())
                NavigationButton(title: "Leasing doc's", systemImage: "doc", destination: LeasingDocumentsView())
                Spacer()
            }
            .navigationTitle("Property Management")
        }
    }
}

struct NavigationButton<Destination: View>: View {
    var title: String
    var systemImage: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: self.destination) {
            HStack {
                Label(title, systemImage: systemImage)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity) // This will expand the button to the maximum width available
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.gray.opacity(0.2)]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
            .foregroundColor(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle()) // This removes the default button styling that might affect the frame
    }
}



#Preview {
    OwnerHomeView()
}
