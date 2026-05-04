//
//  SudokuGameView.swift
//  KinderSudoku
//
//  Created by Fatljum Neziri on 06.12.24.
//


import SwiftUI
import AVFoundation // Für Soundeffekte

struct SudokuGameView: View {
    private static let baseAnimalEmojis = ["🦁", "🐼", "🐸", "🐶", "🐷", "🦊", "🐹", "🐰", "🐻"]
    let gridSize: Int
    @State private var grid: [[String?]] = []
    @State private var fixedCells: [[Bool]] = []
    @State private var selectedEmoji: String? = nil
    @State private var showSuccessAlert = false
    @State private var player: AVAudioPlayer?
    
    // Emojis, die verwendet werden, basierend auf der Größe des Spiels
    var animalEmojis: [String] {
        Array(Self.baseAnimalEmojis.prefix(gridSize))
    }
    
    var pickerColumns: [GridItem] {
        gridSize == 4
            ? Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
            : Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    }

    init(gridSize: Int) {
        self.gridSize = gridSize
        let fullGrid = SudokuEngine.generateValidGrid(size: gridSize, emojis: Array(Self.baseAnimalEmojis.prefix(gridSize)))
        let puzzleGrid = SudokuEngine.removeRandomCells(from: fullGrid, size: gridSize)
        self._grid = State(initialValue: puzzleGrid)
        self._fixedCells = State(initialValue: puzzleGrid.map { row in row.map { $0 != nil } })
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 2) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                SudokuCell(emoji: grid[row][col], isFixed: fixedCells[row][col], cellSize: cellSize(for: geometry.size.width)) {
                                    if !fixedCells[row][col] {
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

                LazyVGrid(columns: pickerColumns, spacing: 10) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEmoji = nil
                        }
                    }) {
                        Text("🧽")
                            .font(.system(size: gridSize == 4 ? 40 : 30))
                            .padding()
                            .background(selectedEmoji == nil ? Color.orange.opacity(0.25) : Color.clear)
                            .clipShape(Circle())
                    }

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
        if !SudokuEngine.validateCompletedGrid(grid, size: gridSize) {
            return
        }

        playSound(named: "success")
        showSuccessAlert = true
    }

    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }

    private func cellSize(for availableWidth: CGFloat) -> CGFloat {
        max(26, min(44, (availableWidth - 32) / CGFloat(gridSize)))
    }

}

struct SudokuCell: View {
    var emoji: String?
    var isFixed: Bool
    var cellSize: CGFloat
    var onTap: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isFixed ? Color.gray.opacity(0.35) : Color.white)
                .frame(width: cellSize, height: cellSize)
                .border(Color.gray, width: 1)

            if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: cellSize * 0.62))
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
