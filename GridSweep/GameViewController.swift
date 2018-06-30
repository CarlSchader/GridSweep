//
//  ViewController.swift
//  GridSweep
//
//  Created by Carl Schader on 6/3/18.
//  Copyright © 2018 bitspace. All rights reserved.
//

import UIKit

class GameViewController: UIViewController
{
    @IBOutlet weak var gameView: GridView!
    var gameModel: GridModel!
    var seed: Int!
    
    @IBOutlet weak var seedLabel: UILabel!
    @IBOutlet weak var escapeButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    let rows = 10
    let columns = 10
    let startingEnemies = 5
    
    var standardDotRadius: CGFloat = CGFloat()
    
    let buttonAnimationTime: Double = 0.5
    let gridAnimationTime: Double = 0.75
    let soldierAttackAnimationTime: Double = 0.35
    let mageAttackAnimationTime: Double = 0.5
    let healAnimationTime: Double = 1
    
    let allyBoardColor = UIColor.blue.withAlphaComponent(0.25)
    
    let characterColors: [Cell: UIColor] =
        [Cell.soldier: UIColor.blue,
         Cell.mage: UIColor.purple,
         Cell.healer: UIColor.green,
         Cell.enemy: UIColor.red]
    
    let allyMovementColor = UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.33)
    let enemyMovementColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.33)
    let selectMovementColor = UIColor(red: 0, green: 0.5, blue: 0.5, alpha: 0.25)
    let selectEnemyToAttackColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)
    let healColor = UIColor(red: 0, green: 1.0, blue: 0, alpha: 0.33)
    let selectedTotHealColor = UIColor(red: 0, green: 0.75, blue: 0.75, alpha: 0.67)
    
    
    // Set Up Views
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameModel = GridModel(Seed: seed, Rows: rows, Columns: columns, Enemies: startingEnemies)
        gameView.designerInit(Rows: rows, Columns: columns, Color: gameView.color, LineWidth: 1)
        seedLabel.text! = String(seed)
        self.standardDotRadius = self.gameView.cellWidth/2 - self.gameView.cellWidth/8
        
        for i in 0...gameModel.rows-1
        {
            for j in 0...gameModel.columns-1
            {
                gameView.buttonGrid[i][j].backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                gameView.buttonGrid[i][j].addTarget(self, action: #selector(buttonGridTap), for: .touchUpInside)
            }
        }
        
        // Button Starting Attributes
        deactivateGameButtons()
        UIView.transition(with: actionButton, duration: buttonAnimationTime, options: [.transitionCrossDissolve], animations: {UIView.performWithoutAnimation {
            self.actionButton.setTitle("start", for: UIControlState.normal)
            self.actionButton.tintColor = UIColor.blue
            self.actionButton.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
            }})
        actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        escapeButton.addTarget(self, action: #selector(escapeButtonTap), for: .touchUpInside)
    }
    
    
    // Button Actions
    @objc func buttonGridTap(button: UIButton)
    {
        let title = button.title(for: UIControlState.normal)!
        let row = Int(String(title[title.startIndex]))!
        let column = Int(String(title[title.index(title.startIndex, offsetBy: 1)]))!
        let character = gameModel.grid[row][column]
        
        switch gameModel.gameState
        {
        case State.preGame:
            break
            
        case State.unselectedCharacter:
            if character != Cell.enemy && character != Cell.none && gameModel.characterStates[character]!!
            {
                gameModel.selectCharacter(character: character)
                clearMovementRange(animation: true)
                drawMovementRange(character: character, color: allyMovementColor, row: row, column: column, true)
                gameModel.gameState = State.movement    // State Transition
                
                setEscapeButton(escapeTitle: "back")
            }
            else if character == Cell.enemy
            {
                gameModel.deselectCharacter()
                clearMovementRange(animation: true)
                drawMovementRange(character: character, color: enemyMovementColor, row: row, column: column, true)
                
                deactivateGameButtons()
            }
            else
            {
                gameModel.deselectCharacter()
                clearMovementRange(animation: true)
                
                deactivateGameButtons()
            }
            
        case State.movement:
            if button.backgroundColor == allyMovementColor
            {
                clearMovementRange(animation: false)
                drawMovementRange(character: gameModel.selectedCharacter!, color: allyMovementColor, row: gameModel.characterPositions[gameModel.selectedCharacter!]!.0, column: gameModel.characterPositions[gameModel.selectedCharacter!]!.1, false)
                button.backgroundColor = selectMovementColor
                gameModel.selectSpace(row: row, column: column)
                gameModel.gameState = State.selectedMovementSpace   // State Transition
                
                setActionButton(actionTitle: "move")
            }
            else
            {
                clearMovementRange(animation: true)
                gameModel.deselectCharacter()
                gameModel.gameState = State.unselectedCharacter     // State Backward Transition
                
                deactivateGameButtons()
            }
            
        case State.selectedMovementSpace:
            if button.backgroundColor == allyMovementColor || button.backgroundColor == selectMovementColor
            {
                clearMovementRange(animation: false)
                drawMovementRange(character: gameModel.selectedCharacter!, color: allyMovementColor, row: gameModel.characterPositions[gameModel.selectedCharacter!]!.0, column: gameModel.characterPositions[gameModel.selectedCharacter!]!.1, false)
                button.backgroundColor = selectMovementColor
                gameModel.selectSpace(row: row, column: column)
            }
            else
            {
                clearMovementRange(animation: true)
                gameModel.deselectCharacter()
                gameModel.deselectSpace()
                gameModel.gameState = State.unselectedCharacter     // State Backward Transition
                
                deactivateGameButtons()
            }
            
        case State.attack:
            if button.backgroundColor == enemyMovementColor || button.backgroundColor == healColor
            {
                clearMovementRange(animation: true)
                drawCharacterActionSpaces(character: gameModel.selectedCharacter!, row: row, column: column)
                gameModel.selectSpace(row: row, column: column)
                gameModel.gameState = State.selectedAttackSpace     // State Transition
                
                if gameModel.selectedCharacter == Cell.healer
                {
                    setGameButtons(escapeTitle: "back", actionTitle: "heal")
                }
                else
                {
                    setGameButtons(escapeTitle: "back", actionTitle: "attack")
                }
                
            }
            else
            {
                break
//                print("unfinished")
            }
            
        case State.selectedAttackSpace:
            if button.backgroundColor == UIColor.clear
            {
                clearMovementRange(animation: true)
                gameModel.deselectSpace()
                drawActionRange(character: gameModel.selectedCharacter!, true)
                gameModel.gameState = State.attack      // State Backward Transition
                
                deactivateGameButtons()
                setEscapeButton(escapeTitle: "wait")
            }
            else
            {
                break
            }
        case State.enemyTurn:
            print("Enemies turn!!!")
        }
        
        
    }
    
    @objc func actionButtonTap(button: UIButton)
    {
        if button.title(for: UIControlState.normal) == "start" && gameModel.gameState == State.preGame
        {
            gameModel.gameState = State.unselectedCharacter     // State Transition
            startGameAnimation()    // This is slow and needs a performance boost
        }
        else if button.title(for: UIControlState.normal) == "move" && gameModel.gameState == State.selectedMovementSpace
        {
            clearMovementRange(animation: true)
            moveCharacter(character: gameModel.selectedCharacter!, row: gameModel.selectedSpace!.0, column: gameModel.selectedSpace!.1, true)
            gameModel.deselectSpace()
            drawActionRange(character: gameModel.selectedCharacter!, true)
            gameModel.gameState = State.attack      // State Transition
            
            deactivateGameButtons()
            setEscapeButton(escapeTitle: "wait")
        }
        else if button.title(for: UIControlState.normal) == "attack" && gameModel.gameState == State.selectedAttackSpace
        {
            switch gameModel.selectedCharacter!
            {
            case Cell.soldier:
                soldierAttackAnimation(startingRow: gameModel.selectedSpace!.0, startingColumn: gameModel.selectedSpace!.1)
            case Cell.mage:
                mageAttackAnimation()
            default:
                print("error")
            }
            deactivateCharacter(character: gameModel.selectedCharacter!)
            gameModel.deselectSpace()
            gameModel.deselectCharacter()
            if endOfPlayerTurn()
            {
                gameModel.gameState = State.enemyTurn               // State Transition
            }
            else
            {
                gameModel.gameState = State.unselectedCharacter     // State Backward Transition
            }
            
            deactivateGameButtons()
        }
        else if button.title(for: UIControlState.normal) == "heal" && gameModel.gameState == State.selectedAttackSpace
        {
            healAnimation()
            deactivateCharacter(character: gameModel.selectedCharacter!)
            gameModel.deselectSpace()
            gameModel.deselectCharacter()
            if endOfPlayerTurn()
            {
                gameModel.gameState = State.enemyTurn               // State Transition
            }
            else
            {
                gameModel.gameState = State.unselectedCharacter     // State Backward Transition
            }
            
            deactivateGameButtons()
        }
    }
    
    @objc func escapeButtonTap(button: UIButton)
    {
        if button.title(for: UIControlState.normal) == "back" && gameModel.gameState != State.selectedAttackSpace
        {
            clearMovementRange(animation: true)
            gameModel.deselectSpace()
            gameModel.deselectCharacter()
            gameModel.gameState = State.unselectedCharacter     // State Backward Transition
            
            deactivateGameButtons()
        }
        else if button.title(for: UIControlState.normal) == "back" && gameModel.gameState == State.selectedAttackSpace
        {
            clearMovementRange(animation: true)
            gameModel.deselectSpace()
            drawActionRange(character: gameModel.selectedCharacter!, true)
            gameModel.gameState = State.attack      // State Backward Transition
            
            deactivateGameButtons()
            setEscapeButton(escapeTitle: "wait")
        }
        else if button.title(for: UIControlState.normal) == "wait" && (gameModel.gameState == State.attack || gameModel.gameState == State.selectedAttackSpace)
        {
            clearMovementRange(animation: true)
            deactivateCharacter(character: gameModel.selectedCharacter!)
            if endOfPlayerTurn()
            {
                gameModel.gameState = State.enemyTurn               // State Transition
            }
            else
            {
                gameModel.gameState = State.unselectedCharacter     // State Backward Transition
            }
            
            deactivateGameButtons()
        }
    }
    
    
    // Supporting Functions
    func drawMovementRange(character: Cell, color: UIColor, row: Int, column: Int, _ animated: Bool = true)
    {
        var movementRange: Int
        switch character
        {
        case Cell.soldier:
            movementRange = gameModel.soldierMovementRange
        case Cell.mage:
            movementRange = gameModel.mageMovementRange
        case Cell.healer:
            movementRange = gameModel.healerMovementRange
        case Cell.enemy:
            movementRange = gameModel.enemyMovementRange
        default:
            movementRange = 0
        }
        if animated
        {
            traverseMovementRange(movesLeft: movementRange, color: color, row: row, column: column)
        }
        else
        {
            traverseMovementRange(movesLeft: movementRange, color: color, row: row, column: column, false)
        }
        
        
    }
    
    func clearMovementRange(animation: Bool)
    {
        for i in 0...gameModel.rows-1
        {
            for j in 0...gameModel.columns-1
            {
                if animation && self.gameView.buttonGrid[i][j].backgroundColor != UIColor.clear
                {
                    UIView.transition(with: gameView.buttonGrid[i][j], duration: gridAnimationTime, options: [.transitionFlipFromRight], animations: {
                            self.gameView.buttonGrid[i][j].backgroundColor = UIColor.clear
                    })
                }
                else if !animation && self.gameView.buttonGrid[i][j].backgroundColor != UIColor.clear
                {
                        gameView.buttonGrid[i][j].backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    func traverseMovementRange(movesLeft: Int, color: UIColor, row: Int, column: Int, _ animated: Bool=true)
    {
        if animated
        {
            UIView.transition(with: gameView.buttonGrid[row][column], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {self.gameView.buttonGrid[row][column].backgroundColor = color})
            if movesLeft == 0
            {
                return
            }
            if (row+1 >= 0 && row+1 < gameModel.rows) && (gameModel.grid[row+1][column] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row+1, column: column)
            }
            if (row-1 >= 0 && row-1 < gameModel.rows) && (gameModel.grid[row-1][column] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row-1, column: column)
            }
            if (column+1 >= 0 && column+1 < gameModel.columns) && (gameModel.grid[row][column+1] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row, column: column+1)
            }
            if (column-1 >= 0 && column-1 < gameModel.columns) && (gameModel.grid[row][column-1] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row, column: column-1)
            }
        }
        else
        {
            self.gameView.buttonGrid[row][column].backgroundColor = color
            if movesLeft == 0
            {
                return
            }
            if (row+1 >= 0 && row+1 < gameModel.rows) && (gameModel.grid[row+1][column] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row+1, column: column, false)
            }
            if (row-1 >= 0 && row-1 < gameModel.rows) && (gameModel.grid[row-1][column] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row-1, column: column, false)
            }
            if (column+1 >= 0 && column+1 < gameModel.columns) && (gameModel.grid[row][column+1] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row, column: column+1, false)
            }
            if (column-1 >= 0 && column-1 < gameModel.columns) && (gameModel.grid[row][column-1] == Cell.none)
            {
                traverseMovementRange(movesLeft: movesLeft-1, color: color, row: row, column: column-1, false)
            }
        }
    }
    
    func drawDot(Row: Int, Column: Int, Radius: CGFloat, LineWidth: CGFloat, Color: UIColor, layerName: String, _ animation: Bool = true)
    {
        let path = UIBezierPath()
        let point = CGPoint(x: gameView.buttonGrid[Row][Column].frame.width/2, y: gameView.buttonGrid[Row][Column].frame.height/2)
        path.addArc(withCenter: point, radius: Radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = Color.cgColor
        layer.strokeColor = Color.cgColor
        layer.lineWidth = LineWidth
        layer.name = layerName
        
        //  THIS IS WHERE YOU LEFT OFF
        
//        if gameModel.grid[Row][Column] == Cell.enemy
//        {
//            let enemy: Int = self.gameModel.invertedEnemyHashedPositions[hashPoint(row: Row, column: Column)]!
//            self.gameView.buttonGrid[Row][Column].
//        }
//        else if gameModel.grid[Row][Column] != Cell.enemy && gameModel.grid[Row][Column] != Cell.none
//        {
//            let character: Cell = self.gameModel.grid[Row][Column]
//        }
        
        if animation
        {
            UIView.transition(with: self.gameView.buttonGrid[Row][Column], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {
                self.gameView.buttonGrid[Row][Column].layer.addSublayer(layer)
            })
        }
        else
        {
            self.gameView.buttonGrid[Row][Column].layer.addSublayer(layer)
        }
    }
    
    func drawDots(animation: Bool=true)
    {
        for i in 0...gameView.rows-1
        {
            for j in 0...gameView.columns-1
            {
                let temp = gameModel.grid[i][j]
                if(temp == Cell.enemy)
                {
                    drawDot(Row: i, Column: j, Radius: gameView.cellWidth/2 - gameView.cellWidth/8, LineWidth: 1, Color: UIColor.red, layerName: gameModel.characterNames[Cell.enemy]!, animation)
                }
                else if(temp == Cell.soldier)
                {
                    drawDot(Row: i, Column: j, Radius: gameView.cellWidth/2 - gameView.cellWidth/8, LineWidth: 1, Color: UIColor.blue, layerName: gameModel.characterNames[Cell.soldier]!, animation)
                }
                else if(temp == Cell.mage)
                {
                    drawDot(Row: i, Column: j, Radius: gameView.cellWidth/2 - gameView.cellWidth/8, LineWidth: 1, Color:UIColor.purple, layerName: gameModel.characterNames[Cell.mage]!, animation)
                }
                else if(temp == Cell.healer)
                {
                    drawDot(Row: i, Column: j, Radius: gameView.cellWidth/2 - gameView.cellWidth/8, LineWidth: 1, Color: UIColor.green, layerName: gameModel.characterNames[Cell.healer]!, animation)
                }
            }
        }
    }
    
    func setGameButtons(escapeTitle: String, actionTitle: String)
    {
        UIView.transition(with: escapeButton, duration: buttonAnimationTime, options: [.transitionCrossDissolve], animations: {UIView.performWithoutAnimation {
            self.escapeButton.setTitle(escapeTitle, for: UIControlState.normal)
            self.escapeButton.tintColor = UIColor.red
            self.escapeButton.backgroundColor = UIColor.red.withAlphaComponent(0.1)
            }})
        UIView.transition(with: actionButton, duration: buttonAnimationTime, options: [.transitionCrossDissolve], animations: {UIView.performWithoutAnimation {
            self.actionButton.setTitle(actionTitle, for: UIControlState.normal)
            self.actionButton.tintColor = UIColor.blue
            self.actionButton.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
            }})
    }
    
    func setActionButton(actionTitle: String)
    {
        UIView.transition(with: actionButton, duration: buttonAnimationTime, options: [.transitionCrossDissolve], animations: {UIView.performWithoutAnimation {
            self.actionButton.setTitle(actionTitle, for: UIControlState.normal)
            self.actionButton.tintColor = UIColor.blue
            self.actionButton.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
            }})
    }
    
    func setEscapeButton(escapeTitle: String)
    {
        UIView.transition(with: escapeButton, duration: buttonAnimationTime, options: [.transitionCrossDissolve], animations: {UIView.performWithoutAnimation {
            self.escapeButton.setTitle(escapeTitle, for: UIControlState.normal)
            self.escapeButton.tintColor = UIColor.red
            self.escapeButton.backgroundColor = UIColor.red.withAlphaComponent(0.1)
            }})
    }
    
    func deactivateGameButtons()
    {
        UIView.transition(with: escapeButton, duration: buttonAnimationTime, options: [.transitionCrossDissolve], animations: {UIView.performWithoutAnimation {
            self.escapeButton.setTitle("unset", for: UIControlState.normal)
            self.escapeButton.tintColor = UIColor.clear
            self.escapeButton.backgroundColor = UIColor.clear
            }})
        UIView.transition(with: actionButton, duration: buttonAnimationTime, options: [.transitionCrossDissolve], animations: {UIView.performWithoutAnimation {
            self.actionButton.setTitle("unset", for: UIControlState.normal)
            self.actionButton.tintColor = UIColor.clear
            self.actionButton.backgroundColor = UIColor.clear
            }})
    }
    
    func startGameAnimation() // This is slow and needs a performance boost
    {
        deactivateGameButtons()
        for i in 0...gameModel.rows-1
        {
            for j in 0...gameModel.columns-1
            {
                UIView.transition(with: self.gameView.buttonGrid[i][j], duration: 2, options: [.transitionFlipFromLeft], animations: {
                    self.gameView.buttonGrid[i][j].backgroundColor = UIColor.clear
                    let temp = self.gameModel.grid[i][j]
                    if(temp == Cell.enemy)
                    {
                        self.drawDot(Row: i, Column: j, Radius: self.gameView.cellWidth/2 - self.gameView.cellWidth/8, LineWidth: 1, Color: UIColor.red, layerName: "enemy", false)
                    }
                    else if(temp == Cell.soldier)
                    {
                        self.drawDot(Row: i, Column: j, Radius: self.gameView.cellWidth/2 - self.gameView.cellWidth/8, LineWidth: 1, Color: UIColor.blue, layerName: "soldier", false)
                    }
                    else if(temp == Cell.mage)
                    {
                        self.drawDot(Row: i, Column: j, Radius: self.gameView.cellWidth/2 - self.gameView.cellWidth/8, LineWidth: 1, Color:UIColor.purple, layerName: "mage", false)
                    }
                    else if(temp == Cell.healer)
                    {
                        self.drawDot(Row: i, Column: j, Radius: self.gameView.cellWidth/2 - self.gameView.cellWidth/8, LineWidth: 1, Color: UIColor.green, layerName: "healer", false)
                    }
                })
            }
        }
    }
    
    func clearDot(character: Cell)
    {
        let row: Int = gameModel.characterPositions[character]!.0
        let column: Int = gameModel.characterPositions[character]!.1
        
        for layer in gameView.buttonGrid[row][column].layer.sublayers!
        {
            if layer.name == gameModel.characterNames[character]
            {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func moveCharacter(character: Cell, row: Int, column: Int, _ animation: Bool=true)
    {
        let currentRow = gameModel.characterPositions[character]!.0
        let currentColumn = gameModel.characterPositions[character]!.1
        let color = characterColors[character]!
        
        if animation
        {
            UIView.transition(with: self.gameView.buttonGrid[currentRow][currentColumn], duration: self.gridAnimationTime, options: [.transitionFlipFromRight], animations: {self.clearDot(character: character)})
            UIView.transition(with: self.gameView.buttonGrid[row][column], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {
                self.drawDot(Row: row, Column: column, Radius: self.standardDotRadius, LineWidth: 1, Color: color, layerName: self.gameModel.characterNames[character]!, false)
            })
        }
        else
        {
            self.clearDot(character: character)
            self.drawDot(Row: row, Column: column, Radius: self.standardDotRadius, LineWidth: 1, Color: color, layerName: self.gameModel.characterNames[character]!, false)
        }
        
        gameModel.characterPositions[character] = (row,column)
        gameModel.grid[currentRow][currentColumn] = Cell.none
        gameModel.grid[row][column] = character
    }
    
    func drawActionRange(character: Cell, _ animation: Bool=true)
    {
        let row = gameModel.characterPositions[character]!.0
        let column = gameModel.characterPositions[character]!.1
        let attackColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.33)
        let healColor = UIColor(red: 0, green: 1.0, blue: 0, alpha: 0.33)
        
        for (r,c) in gameModel.actionRanges[character]!
        {
            if row+r >= 0 && row+r < rows && column+c >= 0 && column+c < columns && animation
            {
                if character == Cell.healer //&& (gameModel.grid[row+r][column+c] != Cell.enemy && gameModel.grid[row+r][column+c] != Cell.none)
                {
                    UIView.transition(with: self.gameView.buttonGrid[row+r][column+c], duration: self.gridAnimationTime, options: [.transitionFlipFromRight], animations: {self.gameView.buttonGrid[row+r][column+c].backgroundColor = healColor})
                }
                else if character != Cell.healer //&& gameModel.grid[row+r][column+c] == Cell.enemy
                {
                    UIView.transition(with: self.gameView.buttonGrid[row+r][column+c], duration: self.gridAnimationTime, options: [.transitionFlipFromRight], animations: {self.gameView.buttonGrid[row+r][column+c].backgroundColor = attackColor})
                }
            }
            if row+r >= 0 && row+r < rows && column+c >= 0 && column+c < columns && !animation
            {
                if character == Cell.healer //&& (gameModel.grid[row+r][column+c] != Cell.enemy && gameModel.grid[row+r][column+c] != Cell.none)
                {
                    gameView.buttonGrid[row+r][column+c].backgroundColor = healColor
                }
                else if character != Cell.healer //&& gameModel.grid[row+r][column+c] == Cell.enemy
                {
                    gameView.buttonGrid[row+r][column+c].backgroundColor = attackColor
                }
            }
        }
    }
    
    func deactivateCharacter(character: Cell)
    {
        clearDot(character: character)
        let row = gameModel.characterPositions[character]!.0
        let column = gameModel.characterPositions[character]!.1
        let color = characterColors[character]!.withAlphaComponent(0.25)
        drawDot(Row: row, Column: column, Radius: standardDotRadius, LineWidth: 1, Color: color, layerName: gameModel.characterNames[character]!)
        gameModel.characterStates[character] = false
    }
    
    func drawCharacterActionSpaces(character: Cell, row: Int, column: Int, _ animation: Bool=true)
    {
        var direction: Direction = Direction.none
        if gameModel.characterPositions[character]!.0 > row
        {
            direction = Direction.up
        }
        else if gameModel.characterPositions[character]!.0 < row
        {
            direction = Direction.down
        }
        else if gameModel.characterPositions[character]!.1 > column
        {
            direction = Direction.left
        }
        else if gameModel.characterPositions[character]!.1 < column
        {
            direction = Direction.right
        }
        
        switch character
        {
        case Cell.soldier:
            switch direction
            {
            case Direction.right:
                var k: Int = column
                while(true)
                {
                    if !(row >= 0 && row < rows && k >= 0 && k < columns)
                    {
                        break
                    }
                    if gameModel.grid[row][k] != Cell.none
                    {
                        if animation
                        {
                            UIView.transition(with: gameView.buttonGrid[row][k], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {self.gameView.buttonGrid[row][k].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)})
                        }
                        else
                        {
                            gameView.buttonGrid[row][k].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)
                        }
                        k = k + 1
                    }
                    else
                    {
                        break
                    }
                }
            case Direction.up:
                var k: Int = row
                while(true)
                {
                    if !(k >= 0 && k < rows && column >= 0 && column < columns)
                    {
                        break
                    }
                    if gameModel.grid[k][column] != Cell.none
                    {
                        if animation
                        {
                            UIView.transition(with: gameView.buttonGrid[k][column], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {self.gameView.buttonGrid[k][column].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)})
                        }
                        else
                        {
                            gameView.buttonGrid[k][column].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)
                        }
                        k = k - 1
                    }
                    else
                    {
                        break
                    }
                }
            case Direction.left:
                var k: Int = column
                while(true)
                {
                    if !(row >= 0 && row < rows && k >= 0 && k < columns)
                    {
                        break
                    }
                    if gameModel.grid[row][k] != Cell.none
                    {
                        if animation
                        {
                            UIView.transition(with: gameView.buttonGrid[row][k], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {self.gameView.buttonGrid[row][k].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)})
                        }
                        else
                        {
                            gameView.buttonGrid[row][k].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)
                        }
                        k = k - 1
                    }
                    else
                    {
                        break
                    }
                }
            case Direction.down:
                var k: Int = row
                while(true)
                {
                    if !(k >= 0 && k < rows && column >= 0 && column < columns)
                    {
                        break
                    }
                    if gameModel.grid[k][column] != Cell.none
                    {
                        if animation
                        {
                            UIView.transition(with: gameView.buttonGrid[k][column], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {self.gameView.buttonGrid[k][column].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)})
                        }
                        else
                        {
                            gameView.buttonGrid[k][column].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)
                        }
                        k = k + 1
                    }
                    else
                    {
                        break
                    }
                }
            default:
                print("error in action spaces: soldier")
                break
            }
        case Cell.mage:
            let array: [(Int,Int)] = [(0,0),(0,1),(-1,0),(0,-1),(1,0)]
            for (r,c) in array
            {
                if !(row+r >= 0 && row+r < rows && column+c >= 0 && column+c < columns)
                {
                    continue
                }
                if animation
                {
                    UIView.transition(with: gameView.buttonGrid[row+r][column+c], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {self.gameView.buttonGrid[row+r][column+c].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)})
                }
                else
                {
                    gameView.buttonGrid[row+r][column+c].backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)
                }
            }
        case Cell.healer:
            for (r,c) in gameModel.actionRanges[Cell.healer]!
            {
                if !pointWithinGrid(row: gameModel.characterPositions[Cell.healer]!.0 + r, column: gameModel.characterPositions[Cell.healer]!.1 + c, rowCount: rows, columnCount: columns)
                {
                    continue
                }
                if animation
                {
                    UIView.transition(with: gameView.buttonGrid[gameModel.characterPositions[Cell.healer]!.0 + r][gameModel.characterPositions[Cell.healer]!.1 + c], duration: gridAnimationTime, options: [.transitionFlipFromLeft], animations: {self.gameView.buttonGrid[self.gameModel.characterPositions[Cell.healer]!.0 + r][self.gameModel.characterPositions[Cell.healer]!.1 + c].backgroundColor = self.selectedTotHealColor})
                }
                else
                {
                    gameView.buttonGrid[gameModel.characterPositions[Cell.healer]!.0 + r][gameModel.characterPositions[Cell.healer]!.1 + c].backgroundColor = selectedTotHealColor
                }
            }
        default:
            print("error in action spaces: no character")
            break
        }
    }
    
    func mageAttackAnimation()
    {
        for row in 0...rows-1
        {
            for column in 0...columns-1
            {
                if gameView.buttonGrid[row][column].backgroundColor == UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.33)
                {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: mageAttackAnimationTime, delay: 0, options: [], animations: {self.gameView.buttonGrid[row][column].transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
                        self.gameView.buttonGrid[row][column].backgroundColor = self.enemyMovementColor
                    }, completion: { position in
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.mageAttackAnimationTime, delay: 0, options: [], animations: {self.gameView.buttonGrid[row][column].transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                            self.gameView.buttonGrid[row][column].backgroundColor = UIColor.clear
                        })
                    })
                }
            }
        }
    }
    
    func soldierAttackAnimation(startingRow: Int, startingColumn: Int, _ translation: (Int,Int)=(0,0) )
    {
        var tr: (Int,Int) = translation
        if translation == (0,0)
        {
            if gameModel.characterPositions[gameModel.selectedCharacter!]!.0 > gameModel.selectedSpace!.0
            {
                tr = (-1,0)
            }
            else if gameModel.characterPositions[gameModel.selectedCharacter!]!.0 < gameModel.selectedSpace!.0
            {
                tr = (1,0)
            }
            else if gameModel.characterPositions[gameModel.selectedCharacter!]!.1 > gameModel.selectedSpace!.1
            {
                tr = (0,-1)
            }
            else if gameModel.characterPositions[gameModel.selectedCharacter!]!.1 < gameModel.selectedSpace!.1
            {
                tr = (0,1)
            }
        }
        if startingRow >= 0 && startingRow < rows && startingColumn >= 0 && startingColumn < columns && gameView.buttonGrid[startingRow][startingColumn].backgroundColor == selectEnemyToAttackColor
        {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: soldierAttackAnimationTime, delay: 0, options: [], animations: {self.gameView.buttonGrid[startingRow][startingColumn].transform = CGAffineTransform.identity.translatedBy(x: CGFloat(tr.1 * 10), y: CGFloat(tr.0 * 10))
                self.gameView.buttonGrid[startingRow][startingColumn].backgroundColor = UIColor.clear
            }, completion: { position in
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.soldierAttackAnimationTime, delay: 0, options: [], animations: {
                    self.soldierAttackAnimation(startingRow: startingRow + tr.0, startingColumn: startingColumn + tr.1, tr)
                    self.gameView.buttonGrid[startingRow][startingColumn].transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
                }   )
            })
        }
    }
    
    func healAnimation()
    {
        for row in 0...rows-1
        {
            for column in 0...columns-1
            {
                if gameView.buttonGrid[row][column].backgroundColor == selectedTotHealColor
                {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: healAnimationTime, delay: 0, options: [], animations: {
                        self.gameView.buttonGrid[row][column].transform = CGAffineTransform.identity.rotated(by: CGFloat(Double.pi))
                    }, completion: { position in
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.healAnimationTime, delay: 0, options: [.transitionCrossDissolve], animations: {
                            self.gameView.buttonGrid[row][column].transform = CGAffineTransform.identity.rotated(by: CGFloat(Double.pi))
                            self.gameView.buttonGrid[row][column].backgroundColor = UIColor.clear})
                    })
                }
            }
        }
    }
    
    func endOfPlayerTurn() -> Bool
    {
        for ch in gameModel.playableCharacters
        {
            if gameModel.characterStates[ch]!!
            {
                return false
            }
        }
        return true
    }
    
    
    
    func enemyTurn()
    {
        return
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
//            self.clearMovementRange(animation: true)
//        }
