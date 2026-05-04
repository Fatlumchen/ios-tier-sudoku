import Foundation

enum SudokuEngine {
    static func generateValidGrid(size: Int, emojis: [String]) -> [[String?]] {
        let symbols = Array(emojis.prefix(size))
        guard symbols.count == size else {
            return Array(repeating: Array(repeating: nil, count: size), count: size)
        }

        var grid: [[String?]] = Array(repeating: Array(repeating: nil, count: size), count: size)

        func fillCell(_ index: Int) -> Bool {
            if index == size * size { return true }

            let row = index / size
            let col = index % size

            for emoji in symbols.shuffled() {
                if isValidPlacement(grid: grid, row: row, col: col, emoji: emoji, size: size) {
                    grid[row][col] = emoji
                    if fillCell(index + 1) { return true }
                    grid[row][col] = nil
                }
            }
            return false
        }

        _ = fillCell(0)
        return grid
    }

    static func removeRandomCells(from grid: [[String?]], size: Int) -> [[String?]] {
        var modifiedGrid = grid
        let totalCells = size * size
        let cellsToRemove = totalCells / 2

        let indicesToRemove = Array(0..<totalCells).shuffled().prefix(cellsToRemove)
        for index in indicesToRemove {
            let row = index / size
            let col = index % size
            modifiedGrid[row][col] = nil
        }

        return modifiedGrid
    }

    static func validateCompletedGrid(_ grid: [[String?]], size: Int) -> Bool {
        guard grid.count == size else { return false }

        for row in grid {
            guard row.count == size, !row.contains(nil), Set(row.compactMap { $0 }).count == size else {
                return false
            }
        }

        for col in 0..<size {
            let columnValues = (0..<size).compactMap { grid[$0][col] }
            if columnValues.count != size || Set(columnValues).count != size {
                return false
            }
        }

        let blockSize = Int(Double(size).squareRoot())
        if blockSize * blockSize == size {
            for blockRow in stride(from: 0, to: size, by: blockSize) {
                for blockCol in stride(from: 0, to: size, by: blockSize) {
                    var blockValues: [String] = []
                    for row in blockRow..<(blockRow + blockSize) {
                        for col in blockCol..<(blockCol + blockSize) {
                            guard let value = grid[row][col] else { return false }
                            blockValues.append(value)
                        }
                    }
                    if Set(blockValues).count != size { return false }
                }
            }
        }

        return true
    }

    static func isValidPlacement(grid: [[String?]], row: Int, col: Int, emoji: String, size: Int) -> Bool {
        for c in 0..<size where grid[row][c] == emoji { return false }
        for r in 0..<size where grid[r][col] == emoji { return false }

        let blockSize = Int(Double(size).squareRoot())
        if blockSize * blockSize == size {
            let startRow = (row / blockSize) * blockSize
            let startCol = (col / blockSize) * blockSize
            for r in startRow..<(startRow + blockSize) {
                for c in startCol..<(startCol + blockSize) where grid[r][c] == emoji { return false }
            }
        }

        return true
    }
}
