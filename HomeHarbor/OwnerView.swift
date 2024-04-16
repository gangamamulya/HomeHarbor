//
//  OwnerView.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 4/15/24.
//

import SwiftUI
import CoreData
import GoogleSignIn

class RentViewModel: ObservableObject {
    @Published var tenantNames: [String] = [] //tenant names
    func addTenantName(_ name: String) {
        if !tenantNames.contains(name) {
            tenantNames.append(name)
        }
    }
    func refreshTenantNames() {
        self.tenantNames = CoreDataManager.shared.fetchTenantInfo().map { $0.name }
    }
}

struct OwnerView: View {
    ///Tenant bill details
    @State private var gas: String = ""
    @State private var electricity: String = ""
    @State private var internet: String = ""
    @State private var garbage: String = ""
    @State private var water: String = ""
    @State private var rent: [String: Int] = [:]
    @State private var dueDate: Date = Date()
    @State private var bills: [String: Double] = [:]
    @StateObject var viewModel = RentViewModel()
    //@StateObject var viewModel2 = TenantListViewModel()
    
    
    ///Tenant properties
    @State private var names: [String] = []
    @State private var tenantIDs: [NSManagedObjectID] = []
    
    ///Owner properties
    //@State private var ownerEmail: String = ""
    @State private var ownerEmail: String = UserDefaults.standard.string(forKey: "email") ?? ""
    
    ///Alert  properties
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var updateSuccessful = false
    @State var showingDetailedView = false
    
    ///Edit mode
    @Environment(\.editMode) var editMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Enter the Rent for each person")) {
                    ForEach(Array(zip(names.indices,names)), id: \.0) {index, name in
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "person.fill")
                            }
                            ///Edit tenant name
                            TextField("Tenant Name", text: Binding(
                                get: { self.names[index] },
                                set: { newName in
                                    self.names[index] = newName
                                    let tenantID = self.tenantIDs[index]
                                    CoreDataManager.shared.updateTenantName(id: tenantID, name: newName) {
                                        DispatchQueue.main.async {
                                                        self.refreshTenantsList()
                                                    }
                                    }
                                    
                                }
                            ))
                            TextField("rent", value: $rent[name], format: .number)
                                .keyboardType(.numberPad)
                        }
                    }///Delete tenant
                    .onDelete(perform: deleteTenant)
                    
                    Button(action: {
                        showingDetailedView = true
                        
                    }) {
                        ///add tenant
                        HStack {
                            Image(systemName: "person.fill.badge.plus")
                            Text("Add tenant name")
                        }
                    }
                    .sheet(isPresented: $showingDetailedView) {
                        DetailedView {newName, email in
                            if !viewModel.tenantNames.contains(newName) && !(newName.isEmpty) {
                                viewModel.tenantNames.append(newName)
                                CoreDataManager.shared.saveTenantName(name: newName, email: email, ownerEmail: ownerEmail) {
                                    self.refreshTenantsList()
                                }
                                showingDetailedView = false
                            }
                            
                            else {
                                showAlert = true
                                alertMessage = "Tenant already added"
                            }
                        }.alert(isPresented: $showAlert) {
                            Alert(title: Text(alertMessage))
                        }
                    }
                }
                
                DatePicker(
                    "Due Date",
                    selection: $dueDate,
                    displayedComponents: [.date]
                )
                .onChange(of: dueDate) { newValue in
                    updateDueDateForTenants(newValue)
                }
                
                Section(header: Text("Enter Utility Bills")) {
                    VStack {
                        HStack {
                            Text("Gas Bill")
                            Spacer() // this pushes the textfield to right
                            TextField("Gas Bill", text: $gas)
                        }
                        Divider() //adds a line
                        HStack {
                            Text("Electricity Bill")
                            Spacer()
                            TextField("Electricity Bill", text: $electricity)
                        }
                        Divider()
                        HStack {
                            Text("Internet Bill")
                            Spacer()
                            TextField("Internet Bill", text: $internet)
                        }
                        Divider()
                        HStack {
                            Text("Garbage Bill")
                            Spacer()
                            TextField("Garbage Bill", text: $garbage)
                        }
                        Divider()
                        HStack {
                            Text("Water and Sewer Bill")
                            Spacer()
                            TextField("Water and Sewer Bill", text: $water)
                        }
                    }.padding()
                }
                
                Button("Show My Split"){
                    CalculateSplits()
                }
                
                Section(header: Text("Calculated bills")) {
                    ForEach(bills.keys.sorted(), id: \.self) { key in
                        if let bill = bills[key], let rent = rent[key] {
                            Text("\(key)'s utilities: \(bill, specifier: "%.2f"),               rent: \(rent)")
                            
                        }
                    }
                }
                
                Button(action: {
                    for (name, rentAmount) in rent {
                        if let utiltiesAmount = bills[name],
                           let userEmail = CoreDataManager.shared.fetchEmailForUserName(userName: name) {
                            do {
                                print("Attempting to update rent and utilities for email: \(name)")
                                CoreDataManager.shared.updateTenantRentAndUtilities(
                                    email: userEmail,
                                    rent: String(rentAmount),
                                    utilities: String(utiltiesAmount))
                                updateSuccessful = true
                            }
                        }
                    }
                    showAlert = true
                }) {
                    Text("Update details to tenant")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Fill the width of the parent container
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15) // Apply corner radius to the background
                    // .padding(.horizontal, -10) // Negative padding to offset default padding
                }.listRowInsets(EdgeInsets()) // Add this line to remove default list padding
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Update Status"),
                            message: Text(updateSuccessful ? "Details have been successfully updated." : "Failed to update details."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                
                
            }
            .navigationTitle("Monthly expenses")
            .onAppear {
                let tenantInfo = CoreDataManager.shared.fetchTenantInfo()
                    self.names = tenantInfo.map { $0.name }
                    self.tenantIDs = tenantInfo.map { $0.id }
            }
            .background(Color.clear)
        }
    }
    /// Helper functions
    func CalculateSplits() {
        let utilityValues = SplitWise.Utilities(gas: Double(gas) ?? 0,
                                                electricity: Double(electricity) ?? 0,
                                                internet: Double(internet) ?? 0,
                                                garbage: Double(garbage) ?? 0,
                                                waterAndSewer: Double(water) ?? 0)
        let details = SplitWise.MyDetails(name: names, rent: rent,utilities: utilityValues)
        self.bills = SplitWise.showMySplit(details: details, utilities: utilityValues)
        rent = details.rent
    }

    func updateDueDateForTenants(_ newDueDate: Date) {
        CoreDataManager.shared.updateDueDateForTenants(newDueDate)
    }
    
    func deleteTenant(at offsets: IndexSet) {
        for index in offsets {
            let tenantNameToDelete = names[index]
            CoreDataManager.shared.deleteTenantByName(name: tenantNameToDelete) {
                self.refreshTenantsList()
            }
        }
    }
    
    func refreshTenantsList() {
        let tenants = CoreDataManager.shared.fetchTenantInfo()

        self.names = tenants.map {$0.name}
        self.tenantIDs = tenants.map {$0.id}
    }
    
}

struct DetailedView: View {
    @State private var newName: String = ""
    @State private var email: String = ""
    var onAdd: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add tenant")) {
                    HStack {
                        TextField("Tenant Name", text: $newName)
                        TextField("Tenant email", text: $email)
                        Button(action: {onAdd(newName, email)}) {
                            Label("", systemImage: "plus.circle")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OwnerView()
}

