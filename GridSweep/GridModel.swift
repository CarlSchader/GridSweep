//
//  GridModel.swift
//  GridSweep
//
//  Created by Carl Schader on 5/17/18.
//  Copyright © 2018 bitspace. All rights reserved.
//

import Foundation

func hashPoint(row: Int, column: Int) -> Int
{
    return (10*row) + column
}

func unhashPoint(hashValue: Int) -> (Int,Int)
{
    return((hashValue/10),(hashValue%10))
}

func pointWithinGrid(row: Int, column: Int, rowCount: Int, columnCount: Int) -> Bool
{
    return row >= 0 && row < rowCount && column >= 0 && column < columnCount
}

enum State
{
    case preGame
    case unselectedCharacter
    case movement
    case selectedMovementSpace
    case attack
    case selectedAttackSpace
    case enemyTurn
}

enum Cell: Int
{
    case none = 0
    case enemy = -1
    case soldier = 1
    case mage = 2
    case healer = 3
}

class GridModel
{
    let playableCharacters = [Cell.soldier, Cell.mage, Cell.healer]
    
    var gameState: State
    
    let rows: Int
    let columns: Int
    var grid: [[Cell]]
    var enemyCount: Int
    
    let maxHealths: [Cell: Int] = [
        Cell.soldier: 4,
        Cell.mage: 2,
        Cell.healer: 3,
        Cell.enemy: 2]
    
    var characterPositions: [Cell: (Int,Int)] = [:]
    var characterNames: [Cell: String] = [:]
    var characterStates: [Cell: Bool?] = [:]
    var characterHealth: [Cell: Int] = [:]
    
    var enemyStates: [Int: Bool?] = [:]
    var enemyPositions: [Int: (Int,Int)] = [:]
    var invertedEnemyHashedPositions: [Int: Int] = [:]
    var enemyHealth: [Int: Int] = [:]
    
    var soldierMovementRange: Int
    var mageMovementRange: Int
    var healerMovementRange: Int
    var enemyMovementRange: Int
    
    var actionRanges: [Cell: [(Int,Int)]] = [:]
    
    var selectedCharacter: Cell?
    
    var selectedSpace: (Int,Int)?
    
    init(Seed: Int, Rows: Int, Columns: Int, Enemies: Int)
    {
        srand48(Seed)
        
        // Initial gameState
        self.gameState = State.preGame
        
        // Setting rows and columns and enemy count
        self.rows = Rows
        self.columns = Columns
        self.enemyCount = Enemies
        
        // Initialize an empty grid
        let temp = Array(repeating: Cell.none, count: self.columns)
        self.grid = Array(repeating: temp, count: self.rows)
        
        // PRE-Initialize positions
        self.characterPositions[Cell.soldier] = (Int(),Int())
        self.characterPositions[Cell.mage] = (Int(),Int())
        self.characterPositions[Cell.healer] = (Int(),Int())
        
        // Initialize movement ranges
        self.soldierMovementRange = 5
        self.mageMovementRange = 5
        self.healerMovementRange = 5
        self.enemyMovementRange = 2
        
        // Initialize attack ranges
        self.actionRanges = [
            Cell.soldier: [(0,1),(-1,0),(0,-1),(1,0)],
            Cell.mage: [(0,2),(-1,1),(-2,0),(-1,-1),(0,-2),(1,-1),(2,0),(1,1)],
            Cell.healer: [(0,1),(-1,0),(0,-1),(1,0)]]
        
        // Initialize selected charcter
        self.selectedCharacter = nil
        
        // Initialize the playable Cells
        var i: Int; var j: Int
        (i,j) = findUnusedCell()
        self.grid[i][j] = Cell.soldier
        self.characterPositions[Cell.soldier] = (i,j)
        self.characterNames[Cell.soldier] = "soldier"
        self.characterStates[Cell.soldier] = true
        self.characterHealth[Cell.soldier] = self.maxHealths[Cell.soldier]
        
        (i,j) = findUnusedCell()
        self.grid[i][j] = Cell.mage
        self.characterPositions[Cell.mage] = (i,j)
        self.characterNames[Cell.mage] = "mage"
        self.characterStates[Cell.mage] = true
        self.characterHealth[Cell.mage] = self.maxHealths[Cell.mage]
        
        (i,j) = findUnusedCell()
        self.grid[i][j] = Cell.healer
        self.characterPositions[Cell.healer] = (i,j)
        self.characterNames[Cell.healer] = "healer"
        self.characterStates[Cell.healer] = true
        self.characterHealth[Cell.healer] = self.maxHealths[Cell.healer]
        
        // Initialize the enemy Cells
        for k in 0...self.enemyCount-1
        {
            (i,j) = findUnusedCell()
            self.enemyStates[k] = true
            self.enemyPositions[k] = (i,j)
            self.invertedEnemyHashedPositions[hashPoint(row: i, column: j)] = k
            self.grid[i][j] = Cell.enemy
            self.enemyHealth[k] = self.maxHealths[Cell.enemy]
        }
        self.characterNames[Cell.enemy] = "enemy"
    }
    
    func findUnusedCell() -> (Int,Int)
    {
        var i: Int = Int(drand48()*1000) % rows
        var j: Int = Int(drand48()*1000) % columns
        while(grid[i][j] != Cell.none)
        {
            i = Int(drand48()*1000) % rows
            j = Int(drand48()*1000) % columns
        }
        return (i,j)
    }
    
    func selectCharacter(character: Cell)
    {
        self.selectedCharacter = character
    }
    
    func deselectCharacter()
    {
        self.selectedCharacter = nil
    }
    
    func selectSpace(row: Int, column: Int)
    {
        self.selectedSpace = (row,column)
    }
    
    func deselectSpace()
    {
        self.selectedSpace = nil
    }
    
}
