//
//  HomeView.swift
//  Crew_Assignment
//
//  Created by Karan Verma on 15/01/26.
//


import SwiftUI

// MARK: - Home Page 
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Crew Chat")
                    .font(.title)
                    .padding()
                
                NavigationLink(destination: ChatView()) {
                    Text("Start Chatting")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
        }
    }
}