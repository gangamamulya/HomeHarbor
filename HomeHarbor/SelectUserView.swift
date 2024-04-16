//
//  SelectUserView.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/22/24.
//

import SwiftUI

struct SelectUserView: View {
    @State private var selectedUserType: SplitWise.UserType? = nil
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                Text("Select User Type")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(10)
                    .shadow(radius: 5)
                
                HStack(spacing: 20) {
                    NavigationLink(destination: AuthenticationView(userType: .tenant),
                                   tag: SplitWise.UserType.tenant,
                                   selection: $selectedUserType) {
                        
                        VStack {
                            Image("tenant")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                            Text("Tenant")
                        }
                    }
                    NavigationLink(destination: AuthenticationView(userType: .owner), tag: SplitWise.UserType.owner, selection: $selectedUserType) {
                        VStack{
                            Image("owner")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                            Text("Owner")
                        }
                    }
                }
                
            }
        }
    }
}

#Preview {
    SelectUserView()
}
