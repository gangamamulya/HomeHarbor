//
//  RenterView.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/22/24.
//

import SwiftUI
import GoogleSignIn

struct RenterView: View {
    @State var rent: String = ""
    @State var utilities: String = ""
    @State var name: String = ""
    @StateObject var viewModel = RentViewModel()
    @State private var showSelectUser = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    RentPaymentsCard(rent: rent, utilities: utilities)
                }
            }.navigationTitle("Dashboard")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Menu {
                            Button("Option 1", action: {})
                            Button("Option 2", action: {})
                            Button("Sign Out") {
                                // Update the state to show the sign out view
                                 self.showSelectUser = true
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                        }

                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Welcome \(name)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {Image(systemName: "person.circle")}
                    }
                }
                .onAppear {
                    if let currentUser = GIDSignIn.sharedInstance.currentUser {
                        self.name = currentUser.profile?.name ?? ""
                    }
                }
            
                .fullScreenCover(isPresented: $showSelectUser) {
                    SelectUserView()
                }
        }
    }
}

struct RentPaymentsCard: View {
    @State var rent: String = ""
    @State var utilities: String = ""
    @State var name: String = ""
    @State var dueDate: Date?
    //date formatter is used to represent dates and times in textual representation
    let dateFormatter: DateFormatter = {
        // creates an object for date formatter
        let formatter = DateFormatter()
        //long will print names in this format October 25, 2024
        formatter.dateStyle = .long
        return formatter
    }()
    var finalRentAmount: Double {
        return Double(rent) ?? 0.00
    }
    
    var finalUtilitiesAmount: Double {
        return Double(utilities) ?? 0.00
    }
    var finalAmount: Double {
        return (finalRentAmount) + (finalUtilitiesAmount)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("Rent Payments")
                .font(.custom( "HelveticaNeue-Bold", fixedSize: 18))
                .fontWeight(.bold)
                .fontDesign(.monospaced)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                VStack {
                    Text(String(format: "%.2f", finalAmount))
                        .font(.custom( "HelveticaNeue-Bold", fixedSize: 60))
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                    Text("Balance due")
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.gray)
                        .font(.custom( "HelveticaNeue-Bold", fixedSize: 18))
                    
                }.padding()
            }
            .frame(height: 100)
            .padding(.vertical)
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Rent split")
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.gray)
                        .font(.custom( "HelveticaNeue-Bold", fixedSize: 20))
                    Text("\(rent)")
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.gray)
                        .font(.custom( "HelveticaNeue-Bold", fixedSize: 20))
                }
                HStack {
                    Text("Utilities split")
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.gray)
                        .font(.custom( "HelveticaNeue-Bold", fixedSize: 20))
                    Text("\(utilities)")
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.gray)
                        .font(.custom( "HelveticaNeue-Bold", fixedSize: 20))
                }
                HStack(spacing: 50) {
                    Text("Due by")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.gray)
                        .font(.custom("HelveticaNeue-Bold", fixedSize: 20))
                    if let dueDate = dueDate {
                        Text("\(dueDate, formatter: dateFormatter)")
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .font(.custom("HelveticaNeue-Bold", fixedSize: 20))
                    }else {
                        Text("Due date not set by your owner")
                    }
                    
                    
                }
                .onAppear {
                    if let currentUser = GIDSignIn.sharedInstance.currentUser {
                        let userEmail = currentUser.profile?.email ?? ""
                        self.name = currentUser.profile?.name ?? ""
                        let tenantDetails = CoreDataManager.shared.fetchTenantDetails(email: userEmail)
                        self.rent = tenantDetails.rent
                        self.utilities = tenantDetails.utilities
                        self.dueDate = tenantDetails.dueDate
                    }
                }
                
            }.padding()
        }.padding()
    }
}
#Preview {
    RenterView()
}
