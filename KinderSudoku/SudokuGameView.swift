//
//  SudokuGameView.swift
//  KinderSudoku
//
//  Created by Fatljum Neziri on 06.12.24.
//


import SwiftUI
import AVFoundation // Für Soundeffekte

struct SudokuGameView: View {
    let gridSize: Int
    @State private var grid: [[String?]] = []
    @State private var selectedEmoji: String? = nil
    @State private var showSuccessAlert = false
    @State private var player: AVAudioPlayer?
    
    // Emojis, die verwendet werden, basierend auf der Größe des Spiels
    var animalEmojis: [String] {
        Array(["🦁", "🐼", "🐸", "🐶", "🐷", "🦊", "🐹", "🐰", "🐻"].prefix(gridSize))
    }

    init(gridSize: Int) {
        self.gridSize = gridSize
        let fullGrid = SudokuGameView.generateValidGrid(size: gridSize, emojis: Array(["🦁", "🐼", "🐸", "🐶", "🐷", "🦊", "🐹", "🐰", "🐻"].prefix(gridSize)))
        self._grid = State(initialValue: SudokuGameView.removeRandomCells(from: fullGrid, size: gridSize))
    }

    var body: some View {
        VStack {
            VStack(spacing: 2) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            SudokuCell(emoji: grid[row][col]) {
                                if grid[row][col] == nil, let selectedEmoji = selectedEmoji {
                                    grid[row][col] = selectedEmoji
                                    playSound(named: "click")
                                    checkForSuccess()
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            
            // Emoji-Auswahl
            let columns: [GridItem] = gridSize == 4
                ? Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
                : Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(animalEmojis, id: \.self) { emoji in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEmoji = emoji
                        }
                        playSound(named: "click")
                    }) {
                        Text(emoji)
                            .font(.system(size: gridSize == 4 ? 40 : 30))
                            .padding()
                            .background(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                            .scaleEffect(selectedEmoji == emoji ? 1.2 : 1) // Animation
                    }
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .navigationTitle("Sudoku \(gridSize)x\(gridSize)")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Erfolg!"),
                message: Text("Du hast das Sudoku erfolgreich gelöst! 🎉"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func checkForSuccess() {
        for row in grid {
            if row.contains(nil) {
                return
            }
        }
        
        for col in 0..<gridSize {
            var columnValues: [String?] = []
            for row in 0..<gridSize {
                columnValues.append(grid[row][col])
            }
            if Set(columnValues).count != gridSize {
                return
            }
        }
        
        playSound(named: "success")
        showSuccessAlert = true
    }

    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }

    static func generateValidGrid(size: Int, emojis: [String]) -> [[String?]] {
        var grid: [[String?]] = Array(repeating: Array(repeating: nil, count: size), count: size)

        for row in 0..<size {
            var availableEmojis = emojis.shuffled()
            for col in 0..<size {
                for emoji in availableEmojis {
                    if isValidPlacement(grid: grid, row: row, col: col, emoji: emoji) {
                        grid[row][col] = emoji
                        availableEmojis.removeAll { $0 == emoji }
                        break
                    }
                }
            }
        }
        
        return grid
    }

    static func removeRandomCells(from grid: [[String?]], size: Int) -> [[String?]] {
        var modifiedGrid = grid
        let totalCells = size * size
        let cellsToRemove = totalCells / 2 // 50% der Felder leer lassen
        
        for _ in 0..<cellsToRemove {
            let randomRow = Int.random(in: 0..<size)
            let randomCol = Int.random(in: 0..<size)
            modifiedGrid[randomRow][randomCol] = nil
        }
        
        return modifiedGrid
    }

    static func isValidPlacement(grid: [[String?]], row: Int, col: Int, emoji: String) -> Bool {
        // Überprüfen der Zeile
        for c in 0..<grid[row].count {
            if grid[row][c] == emoji {
                return false
            }
        }

        // Überprüfen der Spalte
        for r in 0..<grid.count {
            if grid[r][col] == emoji {
                return false
            }
        }

        return true
    }
}

struct SudokuCell: View {
    var emoji: String?
    var onTap: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(emoji != nil ? Color.gray.opacity(0.2) : Color.white)
                .frame(width: 40, height: 40)
                .border(Color.gray, width: 1)

            if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: 30))
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct SudokuGameView_Previews: PreviewProvider {
    static var previews: some View {
        SudokuGameView(gridSize: 6)
    }
}
