//
//  HomeHarborApp.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/22/24.
//

import SwiftUI

@main
struct HomeHarborApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SelectUserView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
