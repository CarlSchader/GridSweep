//
//  GridView.swift
//  GridSweep
//
//  Created by Carl Schader on 5/19/18.
//  Copyright © 2018 bitspace. All rights reserved.
//



import UIKit

enum Direction
{
    case right
    case up
    case left
    case down
    case none
}

class GridView: UIView
{
    // Inspectable Data Members
    @IBInspectable
    var rows: Int = 10
    @IBInspectable
    var columns: Int = 10
    @IBInspectable
    var color: UIColor = UIColor.black
    @IBInspectable
    var lineWidth: CGFloat = CGFloat()
    
    // Generic Data Members
    var gridPoints = [[CGPoint]]()
    var topLeft = CGPoint()
    var topRight = CGPoint()
    var bottomLeft = CGPoint()
    var bottomRight = CGPoint()
    var cellHeight = CGFloat()
    var cellWidth = CGFloat()
    
    // Subiew Data Members
    var buttonGrid = [[UIButton]]()
    
    override func draw(_ rect: CGRect)
    {
        designerInit(Rows: self.rows, Columns: self.columns, Color: self.color, LineWidth: self.lineWidth)
        // Generalized Grid Drawing
        let gridPath = UIBezierPath()
        gridPath.lineWidth = lineWidth
        color.setStroke()
        gridPath.move(to: topLeft)
        gridPath.addLine(to: topRight)
        gridPath.addLine(to: bottomRight)
        gridPath.addLine(to: bottomLeft)
        gridPath.addLine(to: topLeft)
        
        for i in stride(from: 1, through: columns, by: 2)
        {
            gridPath.addLine(to: CGPoint(x: topLeft.x + (CGFloat(i) * cellWidth), y: topLeft.y))
            gridPath.addLine(to: CGPoint(x: topLeft.x + (CGFloat(i) * cellWidth), y: bottomLeft.y))
            gridPath.addLine(to: CGPoint(x: topLeft.x + (CGFloat(i+1) * cellWidth), y: bottomLeft.y))
            gridPath.addLine(to: CGPoint(x: topLeft.x + (CGFloat(i+1) * cellWidth), y: topLeft.y))
        }
        for i in stride(from: 1, through: rows, by: 2)
        {
            gridPath.addLine(to: CGPoint(x: topRight.x, y: topRight.y + (CGFloat(i) * cellHeight)))
            gridPath.addLine(to: CGPoint(x: topLeft.x, y: topRight.y + (CGFloat(i) * cellHeight)))
            gridPath.addLine(to: CGPoint(x: topLeft.x, y: topRight.y + (CGFloat(i+1) * cellHeight)))
            gridPath.addLine(to: CGPoint(x: topRight.x, y: topRight.y + (CGFloat(i+1) * cellHeight)))
        }
        gridPath.stroke()
        
    }
    
    func designerInit(Rows: Int, Columns: Int, Color: UIColor, LineWidth: CGFloat)
    {
        self.rows = Rows
        self.columns = Columns
        self.color = Color
        self.lineWidth = LineWidth
        self.topLeft = CGPoint(x: bounds.minX, y: bounds.minY)
        self.topRight = CGPoint(x: bounds.maxX, y: bounds.minY)
        self.bottomLeft = CGPoint(x: bounds.minX, y: bounds.maxY)
        self.bottomRight = CGPoint(x: bounds.maxX, y: bounds.maxY)
        self.cellHeight = bounds.height/CGFloat(rows)
        self.cellWidth = bounds.width/CGFloat(columns)
        
        for i in 0...rows-1
        {
            var temp = [CGPoint]()
            var tempView = [UIButton]()
            for j in 0...columns-1
            {
                temp.append(CGPoint(x: topLeft.x + (cellWidth/2) + (CGFloat(j) * cellWidth), y: topLeft.y + (cellHeight/2) + (CGFloat(i) * cellHeight)))
                tempView.append(UIButton(frame: CGRect(x: topLeft.x + (CGFloat(j) * cellWidth), y: topLeft.y + (CGFloat(i) * cellHeight), width: cellWidth, height: cellHeight)))
            }
            self.gridPoints.append(temp)
            
            self.buttonGrid.append(tempView)
        }
        
        for i in 0...rows-1
        {
            for j in 0...columns-1
            {
                buttonGrid[i][j].setTitle(String(i)+String(j), for: UIControlState.normal)
                buttonGrid[i][j].setTitleColor(UIColor.clear, for: UIControlState.normal)
                self.addSubview(buttonGrid[i][j])
            }
        }
    }
}
