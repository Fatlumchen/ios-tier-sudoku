//
//  SudokuLevelSelectionView.swift
//  KinderSudoku
//
//  Created by Fatljum Neziri on 09.12.24.
//

import SwiftUI

struct SudokuLevelSelectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Wähle deine Sudoku-Größe")
                .font(.largeTitle)
                .padding()
            
            VStack(spacing: 20) {
                ForEach([4, 6, 9], id: \.self) { size in
                    NavigationLink(destination: SudokuGameView(gridSize: size)) {
                        Text("\(size) x \(size)")
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(size == 4 ? Color.blue : (size == 6 ? Color.green : Color.red))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Tier-Sudoku Level")
    }
}

struct SudokuLevelSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SudokuLevelSelectionView()
    }
}
