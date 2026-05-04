//
//  KinderSudokuTests.swift
//  KinderSudokuTests
//
//  Created by Fatljum Neziri on 06.12.24.
//

import Testing
@testable import KinderSudoku

struct KinderSudokuTests {

    @Test func validateCompletedGrid_rejectsDuplicateRows() async throws {
        let grid: [[String?]] = [
            ["🦁", "🦁"],
            ["🐼", "🐼"]
        ]

        #expect(SudokuGameView.validateCompletedGrid(grid, size: 2) == false)
    }

    @Test func removeRandomCells_removesExactlyHalfOfCells() async throws {
        let originalGrid = SudokuGameView.generateValidGrid(size: 4, emojis: ["🦁", "🐼", "🐸", "🐶"])
        let puzzleGrid = SudokuGameView.removeRandomCells(from: originalGrid, size: 4)
        let emptyCells = puzzleGrid.flatMap { $0 }.filter { $0 == nil }.count

        #expect(emptyCells == 8)
    }

    @Test func generateValidGrid_fillsAllCellsForNineByNine() async throws {
        let emojis = ["🦁", "🐼", "🐸", "🐶", "🐷", "🦊", "🐹", "🐰", "🐻"]
        let grid = SudokuGameView.generateValidGrid(size: 9, emojis: emojis)
        let hasNil = grid.flatMap { $0 }.contains(nil)

        #expect(hasNil == false)
        #expect(SudokuGameView.validateCompletedGrid(grid, size: 9) == true)
    }

    @Test func validateCompletedGrid_rejectsDuplicateInSubgrid() async throws {
        let grid: [[String?]] = [
            ["🦁", "🦁", "🐸", "🐶"],
            ["🐸", "🐶", "🦁", "🐼"],
            ["🐶", "🐸", "🐼", "🦁"],
            ["🐼", "🦁", "🐶", "🐸"]
        ]

        #expect(SudokuGameView.validateCompletedGrid(grid, size: 4) == false)
    }

}
