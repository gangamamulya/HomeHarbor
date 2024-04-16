//
//  CoreDataManager.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/23/24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    var tenantViewModel: RentViewModel = RentViewModel()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HomeHarbor")
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError?{
                fatalError("Unable to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveUserData(userType: SplitWise.UserType, name: String, email: String) {
        let context = persistentContainer.viewContext

        // Create a fetch request for the 'User' entity
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        do {
            // Execute the fetch request
            let results = try context.fetch(fetchRequest)

            // Check if a user with the same name already exists
            if let existingUser = results.first {
                // Update existing user's details if necessary
                existingUser.userTypeEnum = userType
                existingUser.email = email
            } else {
                // Create a new User object if no existing user was found
                let newUser = User(context: context)
                newUser.userTypeEnum = userType
                newUser.name = name
                newUser.email = email
            }

            // Save the context
            try context.save()
        } catch {
            print("Failed to save or update user: \(error)")
        }
    }

    
    func fetchTenantNames() -> [String] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userType = %@", SplitWise.UserType.tenant.rawValue)
        do {
            let users = try context.fetch(fetchRequest)
            return users.compactMap {$0.name}
        }
        catch {
          print("error fetching renters \(error)")
            return []
        }
    }
    
    func fetchTenantInfo() -> [(name: String, id: NSManagedObjectID)] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userType = %@", SplitWise.UserType.tenant.rawValue)
        do {
            let users = try context.fetch(fetchRequest)
            return users.compactMap { user in
                guard let name = user.name else { return nil }
                return (name: name, id: user.objectID)
            }
        } catch {
            print("error fetching renters \(error)")
            return []
        }
    }

    func updateTenantName(id: NSManagedObjectID, name newTenantName: String, completion: @escaping () -> Void){
        let context = persistentContainer.viewContext
        do {
            guard let tenantsToUpdate = try context.existingObject(with: id) as? User else {
                print("No tenant found with ID: \(id)")
                                return
            }
            tenantsToUpdate.name = newTenantName
            try context.save()
            DispatchQueue.main.async {
                            completion()
                        }
        }
        catch {
            print("Failed to save tenant name \(newTenantName), because of the error \(error)")
        }
    }
    
    
    func deleteUserData() {
        let context = persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            let deleteOperation = try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print("error deleting user entity: \(error)")
        }
    }
    
    func saveTenantName(name tenantName: String, email: String, ownerEmail: String, completion: @escaping () -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name = %@", tenantName)
        do {
            let tenant = try context.fetch(fetchRequest)
            if tenant.isEmpty {
                let newTenant = User(context: context)
                newTenant.name = tenantName
                newTenant.email = email
               // newTenant.ownerEmail = ownerEmail
                newTenant.userType = SplitWise.UserType.tenant.rawValue
            }
            
            try context.save()
            completion() // Call completion after saving successfully
            DispatchQueue.main.async {
                self.tenantViewModel.refreshTenantNames() // Add this method in your RentViewModel
            }
        }
        catch {
            print("Failed to save tenant name \(tenantName), because of the error \(error)")
        }
    }

    func deleteTenantByName(name: String, completion: @escaping () -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try context.fetch(fetchRequest)
            for name in result {
                context.delete(name)
            }
            try context.save()
            completion()
        }
        catch {
            print("unable to save tenant \(name) because of the error \(error)")
        }
    }
    
    func fetchTenantDetails(email: String) -> (name: String, rent:String, utilities: String, dueDate: Date?) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email = %@ AND userType = %@", email, SplitWise.UserType.tenant.rawValue)
        do {
            if let user = try context.fetch(fetchRequest).first {
                print("Fetched user: \(user.name ?? "Unknown"), Rent: \(user.rent ?? "N/A"), Utilities: \(user.utilities ?? "N/A")")
                return (name: user.name ?? "unkown", rent: user.rent ?? "0.00", utilities: user.utilities ?? "0.00", dueDate: user.due)
            }else {
                //print("No user found with email \(email)")
            }
        }
        catch {
            print("unable to fetch renter name, \(error)")
        }
        return (name: "unknown name", rent: "0.00", utilities: "0.00", dueDate: nil)
    }
    
    func updateTenantRentAndUtilities(email: String, rent: String, utilities: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email = %@ AND userType = %@", email, SplitWise.UserType.tenant.rawValue)

        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                print("No user found with email \(email)")
            } else {
                for user in results {
                    print("Found user: Name = \(user.name ?? "unknown"), Email = \(user.email ?? "unknown")")
                    user.rent = rent
                    user.utilities = utilities
                }
                try context.save()
                print("Successfully updated tenant details for email: \(email)")
            }
        } catch {
            print("Failed to update tenant rent and utilities: \(error)")
        }
    }


    
    func printAllUsers() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            for user in results {
                print("User: \(user.name ?? "Unknown"), Email: \(user.email ?? "N/A"), UserType: \(user.userType ?? "N/A")")
            }
        } catch {
            print("Error fetching users: \(error)")
        }
    }

    
    func fetchEmailForUserName(userName: String) -> String? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", userName)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.email
        } catch {
            print("Error fetching email for user name \(userName): \(error)")
            return nil
        }
    }
    
    func updateDueDateForTenants(_ dueDate: Date) {
//View context works on main thread (where UI updates happen)
//Changes we make to data using viewcontext, are safely reflected on UI
        let context = persistentContainer.viewContext
//fetches all the User entity info
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//predicate is applied on fetch request to filter the fetched data
        fetchRequest.predicate = NSPredicate(format: "userType = %@", SplitWise.UserType.tenant.rawValue)
        do {
//
            let tenants = try context.fetch(fetchRequest)
            for tenant in tenants {
                tenant.due = dueDate
            }
            try context.save()
        } catch let error as NSError {
            print("Could not fetch or save due to \(error), \(error.userInfo)")
        }
    }

    
}
