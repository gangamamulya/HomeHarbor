//
//  PropertiesView.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 4/15/24.
//

import SwiftUI

struct PropertiesView: View {
    @State var properties: [String] = []
    
    ///Alert properties
    @State private var showDetailedView = false
    @State private var buttonTapped = false
    
    var body: some View {
        Spacer()
        VStack(alignment: .center) {
            NavigationLink(destination: AddPropertiesView())
            {
                Button(action: {
                    showDetailedView = true
                }) {
                    VStack {
                        Label("", systemImage: "house")
                            .dynamicTypeSize(.xxxLarge)
                            .foregroundColor(.black)
                        Text("Add properties")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
                .sheet(isPresented: $showDetailedView) {
                    AddPropertiesDetailedView { newProperty in
                        if !properties.contains(newProperty) && !properties.isEmpty {
                            properties.append(newProperty)
                           // CoreDataManager.shared.savePropertyName(name: newProperty)
                        }
                        
                    }
                }
            }
            
        }
        Spacer()
    }
    ///Helper functions
//    func refreshProperties() {
//        let myProperties = CoreDataManager.shared.
//    }
}

struct AddPropertiesDetailedView: View {
    @State private var newProperty: String = ""
    var onAdd: (String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add property")) {
                    HStack {
                        Text("Add:")
                        TextField("Property name", text: $newProperty)
                        Button(action: {onAdd(newProperty)}) {
                            Label("", systemImage: "plus.circle")
                        }
                        
                    }
                }
            }
        }
    }
    
}

#Preview {
    PropertiesView()
}
