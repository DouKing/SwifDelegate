//
//  Dice.swift
//  SwiftDelegate
//
//  Created by WuYikai on 15/1/5.
//  Copyright (c) 2015年 secoo. All rights reserved.
//

import UIKit

protocol RandomNumberGenerator {
    func random() -> Double
}

protocol DiceGame {
    var dice : Dice { get }
    func play()
}

protocol DiceGameDelegate {
    func gameDidStart(game : DiceGame)
    func game(game : DiceGame, didStartNewTurnWithDiceRoll diceRoll : Int)
    func gameDidEnd(game : DiceGame)
}

class Dice: NSObject {
    let sides : Int
    let generator : RandomNumberGenerator
    
    init(sides : Int, generator : RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}

class LinearCongruentialGenerator : RandomNumberGenerator {
    var lastRandom = 42.0
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double {
        lastRandom = ((lastRandom * a + c) % m)
        return lastRandom / m
    }
}

class SnakesAndLadders : DiceGame {
    let finalSquare = 25
    let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    var square = 0
    var board : [Int]
    init() {
        board = [Int](count: finalSquare + 1, repeatedValue: 0)
        board[03] = +08
        board[06] = +11
        board[09] = +09
        board[10] = +02
        board[14] = -10
        board[19] = -11
        board[22] = -02
        board[24] = -08
    }
    var delegate : DiceGameDelegate?
    func play() {
        square = 0
        delegate?.gameDidStart(self)
        gameLoop: while square != finalSquare {
            let diceRoll = dice.roll()
            delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll)
            
            switch square + diceRoll {
            case finalSquare:
                break gameLoop
            case let newSquare where newSquare > finalSquare:
                continue gameLoop
            default:
                square += diceRoll
                square += board[square]
            }
        }
        delegate?.gameDidEnd(self)
    }
}

class DiceGameTracker : DiceGameDelegate {
    var numberOfTurns = 0
    
    func gameDidStart(game: DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders {
            println("Start a new game of Snakes and Ladders")
        }
        println("The game is using a \(game.dice.sides) - sided dice")
    }
    
    func game(game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
        ++numberOfTurns
        println("Rolled a \(diceRoll)")
    }
    
    func gameDidEnd(game: DiceGame) {
        println("The game lasted for \(numberOfTurns) turns")
    }
}


