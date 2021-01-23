//
//  HangmanViewController
//  Hangman
//
//  Created by iOS Decal on Feb 11 2020.
//  Copyright © 2020 iosdecal. All rights reserved.
//

import UIKit

class HangmanViewController: UIViewController {

    // MARK: - Instances: Models
    var hangman = Hangman()
        
    @IBOutlet weak var hangmanImage: UIImageView!
    @IBOutlet weak var guessLabel: UILabel!
    @IBOutlet weak var outerStack: UIStackView!
    @IBOutlet weak var incorrectGuess: UILabel!
    @IBOutlet weak var lastGuess: UILabel!
    
    // MARK: - Class Props/Vars
    var imageNum = 1
    var phraseArr = [String]()
    var currGuess = ""
    var guessLetter = [String]()
    var assist = false
    
    
    // MARK: - IBActions
    @IBAction func buttonPressed(_ urGuessButton: UIButton) {
        var urGuess = false
        currGuess = urGuessButton.titleLabel!.text!
        if (assist == true) {
        urGuessButton.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
            urGuessButton.isEnabled = false
        }
        guessLetter.append(currGuess)
        let currGuessLow = currGuess.lowercased()
        let currGuessCap = currGuess.uppercased()
        lastGuess.text = urGuessButton.titleLabel!.text!
        for i in 0...(phraseArr.count - 1) {
            if (currGuessLow == phraseArr[i] || currGuessCap == phraseArr[i]){
                urGuess = true
                break
            }
        }
        if (urGuess == false) {
            wrongGuess(the: currGuess);
        }
        updateGuessLabel()
        if (imageNum == 7){
            endGame()
        }

    }
    @IBAction func assist(_ sender: UIButton) {
        assist = true
    }
    
    @IBAction func exit(_ sender: UIButton) {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        reset()
    }
    
    @IBAction func restart(_ sender: UIButton) {
        reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phraseArr = newpharse().map { String($0) }
        updateGuessLabel()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Class Methods
    
    func updateGuessLabel() {
        var currText = ""
        var numOfUnder = 0
        for index in 0...(phraseArr.count - 1) {
            let charLow = phraseArr[index].lowercased()
            let charCap = phraseArr[index].uppercased()
            if (guessLetter.contains(charLow) || guessLetter.contains(charCap)) {
                currText += String(phraseArr[index]) + " "
            } else if (phraseArr[index] == " ") {
                currText += "  "
            } else {
                currText += "_ "
                numOfUnder += 1
            }
        }
        guessLabel.text = currText
        if (numOfUnder == 0) {
            win()
        }
    }
    
    // If you make a wrong guess
    func wrongGuess(the letter: String) {
        imageNum += 1
        hangmanImage.image = UIImage(named: "hangman\(imageNum)")
        if let ch = incorrectGuess.text {
        incorrectGuess.text = ch + letter
        }
            }
    
    //win
    func win() {
        disableButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                  self.winAlert()
              })
    }
    
    private func reset() -> Void {
        enableButton()
        assist = false
        guessLabel.text = ""
        incorrectGuess.text = ""
        lastGuess.text = ""
        imageNum = 1
        phraseArr = newpharse().map { String($0) }
        currGuess = ""
        guessLetter = []
        updateGuessLabel()
        hangmanImage.image = #imageLiteral(resourceName: "hangman1")
      }
      
      
    private func endGame() -> Void {
        hangmanImage.image = #imageLiteral(resourceName: "hangman7")
        disableButton()
        guessLabel.text = phraseArr.joined()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.loseAlert()
        })
        
      }

    func newpharse() -> String {
        let hangman = Hangman()
        return hangman.randomWd()
    }
    

    func exitApp() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    
    func winAlert() {
        let alert = UIAlertController(title: "Congratulations! You Win!", message: "Do you wanna play another round?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            self.reset()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {action in
            self.exitApp()
    }))
        self.present(alert, animated: true)
    }
    
    func loseAlert() {
        let alert = UIAlertController(title: "Sorry, the man is hanged!", message: "Do you wanna play another round?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.reset()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler:
            {action in
                self.exitApp()
        }))
        self.present(alert, animated: true)
    }
    
    func disableButton() {
        for view in outerStack.arrangedSubviews {
            if let innerStack = view as? UIStackView {
                for innerView in innerStack.arrangedSubviews {
                    if let button = innerView as? UIButton {
                        button.isEnabled = false
                    }
                }
            }
        }
    }
    
    func enableButton() {
        for view in outerStack.arrangedSubviews {
            if let innerStack = view as? UIStackView {
                for innerView in innerStack.arrangedSubviews {
                    if let button = innerView as? UIButton {
                        button.isEnabled = true
                        button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    }
                }
            }
        }
    }
    
}
