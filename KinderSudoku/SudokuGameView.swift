//
//  SudokuGameView.swift
//  KinderSudoku
//
//  Created by Fatljum Neziri on 06.12.24.
//


import SwiftUI
import AVFoundation

struct SudokuGameView: View {
    let gridSize: Int
    @State private var grid: [[String?]] = []
    @State private var originalGrid: [[String?]] = []
    @State private var selectedEmoji: String? = nil
    @State private var showSuccessAlert = false
    @State private var player: AVAudioPlayer?

    var animalEmojis: [String] {
        Array(["🦁", "🐼", "🐸", "🐶", "🐷", "🦊", "🐹", "🐰", "🐻"].prefix(gridSize))
    }

    init(gridSize: Int) {
        self.gridSize = gridSize
        let emojis = Array(["🦁", "🐼", "🐸", "🐶", "🐷", "🦊", "🐹", "🐰", "🐻"].prefix(gridSize))
        let fullGrid = SudokuGameView.generateValidGrid(size: gridSize, emojis: emojis)
        let puzzleGrid = SudokuGameView.removeRandomCells(from: fullGrid, size: gridSize)
        self._grid = State(initialValue: puzzleGrid)
        self._originalGrid = State(initialValue: puzzleGrid)
    }

    var body: some View {
        GeometryReader { geometry in
            let cellSize = min((geometry.size.width - 40) / CGFloat(gridSize), 55.0)

            VStack {
                VStack(spacing: 2) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                let isOriginal = originalGrid[row][col] != nil
                                SudokuCell(
                                    emoji: grid[row][col],
                                    isOriginal: isOriginal,
                                    cellSize: cellSize
                                ) {
                                    if isOriginal { return }
                                    if grid[row][col] != nil {
                                        // Benutzerzelle antippen zum Löschen
                                        grid[row][col] = nil
                                    } else if let selectedEmoji = selectedEmoji {
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
                                .scaleEffect(selectedEmoji == emoji ? 1.2 : 1)
                        }
                    }
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
        }
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
        // Alle Felder müssen gefüllt sein
        for row in grid {
            if row.contains(nil) { return }
        }

        // Zeilen prüfen
        for row in 0..<gridSize {
            if Set(grid[row]).count != gridSize { return }
        }

        // Spalten prüfen
        for col in 0..<gridSize {
            let columnValues = (0..<gridSize).map { grid[$0][col] }
            if Set(columnValues).count != gridSize { return }
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
        _ = solve(grid: &grid, size: size, emojis: emojis)
        return grid
    }

    @discardableResult
    private static func solve(grid: inout [[String?]], size: Int, emojis: [String]) -> Bool {
        for row in 0..<size {
            for col in 0..<size {
                guard grid[row][col] == nil else { continue }
                for emoji in emojis.shuffled() {
                    if isValidPlacement(grid: grid, row: row, col: col, emoji: emoji) {
                        grid[row][col] = emoji
                        if solve(grid: &grid, size: size, emojis: emojis) {
                            return true
                        }
                        grid[row][col] = nil
                    }
                }
                return false
            }
        }
        return true
    }

    static func removeRandomCells(from grid: [[String?]], size: Int) -> [[String?]] {
        var modifiedGrid = grid
        let cellsToRemove = (size * size) / 2

        var positions = (0..<size).flatMap { row in (0..<size).map { col in (row, col) } }
        positions.shuffle()

        for i in 0..<cellsToRemove {
            let (row, col) = positions[i]
            modifiedGrid[row][col] = nil
        }

        return modifiedGrid
    }

    static func isValidPlacement(grid: [[String?]], row: Int, col: Int, emoji: String) -> Bool {
        for c in 0..<grid[row].count {
            if grid[row][c] == emoji { return false }
        }
        for r in 0..<grid.count {
            if grid[r][col] == emoji { return false }
        }
        return true
    }
}

struct SudokuCell: View {
    var emoji: String?
    var isOriginal: Bool
    var cellSize: CGFloat
    var onTap: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isOriginal ? Color.gray.opacity(0.3) : (emoji != nil ? Color.blue.opacity(0.1) : Color.white))
                .frame(width: cellSize, height: cellSize)
                .border(Color.gray, width: 1)

            if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: cellSize * 0.65))
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
