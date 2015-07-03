//
//  ViewController.swift
//  Tic Tac Toe
//
//  Created by Jack Cable on 7/1/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

public struct MinMaxResult {
    var spot : Int
    var score : Int
}

class ViewController: UIViewController {

    @IBOutlet var announcementLabel: UILabel!
    
    @IBOutlet var buttonCollection: [UIButton]!
    
    let BOARD_HEIGHT = 3
    let BOARD_WIDTH = 3
    let patterns: [[Int]] = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    let corners: [Int] = [0, 2, 6, 8]
    let middle: Int = 4
    let INITIAL_DEPTH = 2
    let AI_PIECE = "X"
    let HUMAN_PIECE = "O"
    
    var gameType = 0 //0 single player, 1 multi player
    
    var currentTurn = "X"
    var board: [String] = []
    var gameIsOver = false
    var isComputerMove = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyBoard()
        
        if(gameType == 0) {
            computerTurn()
        }
    }
    
    func emptyBoard() {
        board = []
        for(var i=0; i<BOARD_HEIGHT*BOARD_WIDTH; i++) {
            board.append("")
        }
    }

    @IBAction func buttonPressed(sender: UIButton) {
        
        if(gameIsOver || sender.titleLabel?.text != nil || isComputerMove) {
            return;
        }
        
        if !playAtIndex(sender.tag) { //game didn't end, computer goes
            if(gameType == 0) { //single player
                computerTurn()
            }
        }
    }
    
    func playAtIndex(index: Int) -> Bool {
        board[index] = currentTurn
        
        buttonCollection[index].setTitle(currentTurn, forState: UIControlState.Normal)
        
        if(checkBoard()) {
            resetGame()
            return true;
        }
        
        if(currentTurn == "X") {
            currentTurn = "O"
        } else {
            currentTurn = "X"
        }
        
        announcementLabel.text = currentTurn + "'s turn!"
        
        return false
    }
    
    //MARK: Computer AI
    
    func computerTurn() {
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("playComputerMove"), userInfo: nil, repeats: false)
    }
    
    func playComputerMove() {
        playAtIndex(decideComputerMove())
    }
    
    func decideComputerMove() -> Int {
        if(boardIsEmpty()) { //first turn
            if(board[middle] == "") { return middle }
            return getRandomCorner()
        }
        
        if let spot = playerCanWin(AI_PIECE) { //can win
            return spot
        }
        
        if let spot = playerCanWin(HUMAN_PIECE) { //can block player
            return spot
        }
        
        
        if let space = getFinalSpace() {
            return space
        }
        
        let result = minmax(INITIAL_DEPTH, player: AI_PIECE, lowerBound: Int.min, upperBound: Int.max, emptyPieces: getAvailableSpaces())
        if(result.score < 0) { //can block fork
            return result.spot
        }
        
        if(board[middle] == "") { return middle } //center is open
        
        if let corner = getRandomOpenCorner() {
            return corner
        }
        
        for(var i=0; i<board.count; i++) {
            if(board[i] == "") {
                return i;
            }
        }
        
        print("Got to the end... uh oh")
        
        return 0
        
        
    }
    
    func getRandomCorner() -> Int {
        return corners[Int(arc4random_uniform(UInt32(corners.count)))]
    }
    
    func getRandomOpenCorner() -> Int? {
        for corner in corners {
            if(board[corner] == "") {
                return corner
            }
        }
        return nil
    }
    
    func getFinalSpace() -> Int? {
        var space = -1
        for(var i=0; i<board.count; i++) {
            if(board[i] == "") {
                if(space == -1) {
                    space = i
                } else {
                    return nil
                }
            }
        }
        return space
    }
    
    func getAvailableSpaces() -> [Int] {
        var spaces : [Int] = [];
        for(var i=0; i<board.count; i++) {
            if(board[i] == "") {
                spaces.append(i)
            }
        }
        return spaces
    }

    func minmax(depth: Int, player: String, lowerBound: Int, upperBound: Int, emptyPieces: [Int]) -> MinMaxResult {
        var score : Int = 0
        var bestSpot = -1
        var currentLower = lowerBound
        var currentUpper = upperBound
        
        if emptyPieces.count == 0 || depth == 0 {
            return MinMaxResult(spot: bestSpot, score: score)
        }
        for piece in emptyPieces {
            let owner = board[piece]
            if(owner == "O") {
                score = minmax(depth-1, player: "X", lowerBound: lowerBound, upperBound: upperBound, emptyPieces: emptyPieces).score
                if(score > currentLower) {
                    currentLower = score
                    bestSpot = piece
                }
            } else {
                score = minmax(depth-1, player: "O", lowerBound: lowerBound, upperBound: upperBound, emptyPieces: emptyPieces).score
                if(score < currentUpper) {
                    currentUpper = score
                    bestSpot = piece
                }
            }
            
            if(currentUpper >= currentUpper) { break }
        }
        
        return MinMaxResult(spot: bestSpot, score: score)
        
    }
    
    func playerCanWin(player: String) -> Int? {
        for pattern in patterns {
            var type = ""
            var blank = -1
            var wasBroken = false
            for spot in pattern {
                if(board[spot] == "") {
                    if(blank != -1) {
                        wasBroken = true
                        break
                    }
                    blank = spot
                } else {
                    if(type == "") {
                        type = board[spot]
                    } else if type != board[spot] {
                        wasBroken = true
                        break
                    }
                }
            }
            if(!wasBroken && type == player && blank != -1) {
                return blank
            }
        }
        return nil
    }
    
    //MARK: Game execution
    
    func checkBoard() -> Bool {
        for pattern in patterns { //check if someone wins
            if(board[pattern[0]] == "") { //no one there
                continue
            }
            
            if(board[pattern[0]] == board[pattern[1]] && board[pattern[0]] == board[pattern[2]]) { //someone wins
                let message = currentTurn + " wins!"
                announcementLabel.text = message
                alert("Game over", message: message);
                gameIsOver = true;
                return true;
            }
            
        }
        
        if boardIsFull() { //check if cat's game
            alert("Cat's game!", message: "");
            return true;
        }
        
        return false;
    }
    
    func boardIsFull() -> Bool {
        for element in  board {
            if(element == "") {
                return false
            }
        }
        return true
    }
    
    func boardIsEmpty() -> Bool {
        for element in  board {
            if(element != "") {
                return false
            }
        }
        return true
    }
    
    func alert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resetGame() {
        emptyBoard()
        currentTurn = "X"
        gameIsOver = false
        for button in buttonCollection {
            button.setTitle("", forState: UIControlState.Normal)
            button.titleLabel?.text = nil
        }
        announcementLabel.text = currentTurn + "'s turn!"
        
        if(gameType == 0) {
            computerTurn()
        }
    }
    

}

