//
//  ContentView.swift
//  KinderSudoku
//
//  Created by Fatljum Neziri on 06.12.24.
//



import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Willkommen zu Tier-Sudoku 🐾")
                    .font(.largeTitle)
                    .padding()
                
                Text("Viel Spaß beim Spielen!")
                    .font(.headline)
                    .padding()
                
                NavigationLink(destination: SudokuLevelSelectionView()) {
                    Text("Spiel starten")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Tier-Sudoku")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
