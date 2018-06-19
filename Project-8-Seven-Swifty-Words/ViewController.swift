//
//  ViewController.swift
//  Project-8-Seven-Swifty-Words
//
//  Created by verebes on 19/06/2018.
//  Copyright © 2018 A&D Progress. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!    
    @IBOutlet weak var currentAnswer: UITextField!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLetterButtons()
        loadLevel()
        
    }
    
    func loadLevel(){
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") {
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                var lines = levelContents.components(separatedBy: "\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
                
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue) \n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    
                    solutionString += "\(solutionWord.count) letters \n"
                    
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        //configure the buttons and labels
        startGame(clue: clueString, solution: solutionString, letterChunks: letterBits)
    }
    
    func startGame(clue: String, solution: String, letterChunks: [String]){
        let clueString = clue
        let solutionString = solution
        var letterBits = letterChunks
        
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]

        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    func levelUp(action: UIAlertAction){
        level += 1
        solutions.removeAll(keepingCapacity: true)
        loadLevel()
        for btn in letterButtons {
            btn.isHidden = false
        }
    }
    
    //MARK: Button configuration
    
    func configureLetterButtons() {
               for subview in view.subviews where subview.tag == 1001 {
                let btn = subview as! UIButton
                letterButtons.append(btn)
                btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
            }
    }
    
    //MARK: - Button Tapped methods

    @IBAction func submitTapped(_ sender: UIButton) {
        if let solutionPosition = solutions.index(of: currentAnswer.text!) {
            activatedButtons.removeAll()
            
            var splitClues = answersLabel.text!.components(separatedBy: "\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
            
        }else {
            clearTheButtons()
        }
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        clearTheButtons()
    }
    
    @objc func letterTapped(btn: UIButton){
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.isHidden = true
    }

    func clearTheButtons(){
        currentAnswer.text = ""
        
        for btn in activatedButtons {
            btn.isHidden = false
        }
        
        activatedButtons.removeAll()
    }
}

