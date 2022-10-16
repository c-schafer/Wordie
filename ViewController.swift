//
//  ViewController.swift
//  Wordie
//
//  Created by Carter Schafer on 2/14/22.
//

import UIKit

extension String {
  //Get the filename from a String
  func fileName() -> String {
    return URL(fileURLWithPath: self).deletingPathExtension ().lastPathComponent
  }
  
  //Get the file extension from a String
  func fileExtension() -> String {
    return URL(fileURLWithPath: self).pathExtension
  }
}

class ViewController: UIViewController, UITextFieldDelegate {
  
  let rows = 6
  let cols = 5
  var currentRow = 1 // rows number from 1...6
  var currentCol = 0 // columns number from 0...4
  var goalWord = "catch"
  var shareString = "" // for use after the user gets it right
  var guesses:[[UILabel]] = [[]]
  var prevTextLen = 0
  var score = 0
  var dateIndex = 0
//  let allowedCharacters = CharacterSet(charactersIn:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxyz").inverted

  
  @IBOutlet var textField: UITextField!
  
  @IBAction func editingChanged(_ sender: Any) {
    // get last character typed and assign it to the correct box
    
    if score == 0 {
      if textField.text?.count ?? 0 >= prevTextLen { // a letter on the keyboard was tapped, not the delete key
        if currentCol >= 0 && currentCol <= 4 { // crucial check so no indices are out of range
          let letter = String((textField.text!).suffix(1))
          guesses[currentRow][currentCol].text = letter
        }
        currentCol = min(currentCol + 1, cols) // iterates up to one past cols so that delete functionality works
      } else { // the delete key was pressed
        delMade()
      }
      prevTextLen = textField.text?.count ?? 0
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
//    textField.becomeFirstResponder()
    textField.autocorrectionType = .no
    
    if #available(iOS 15.0, *) {
        let item = textField.inputAssistantItem
        item.leadingBarButtonGroups = [];
        item.trailingBarButtonGroups = [];
    }
    
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let viewW = Int(self.view.frame.size.width)
//    let viewH = Int(self.view.frame.size.height)

    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewW - 50, height: 50))
    titleLabel.center.x = self.view.center.x
    titleLabel.center.y = 80
    
    titleLabel.textAlignment = .center
    titleLabel.textColor = .white
    titleLabel.font = UIFont.boldSystemFont(ofSize: 30.0)
    titleLabel.text = "Wordie"
    
    self.view.addSubview(titleLabel)
    
    textField.center.x = self.view.center.x
    textField.backgroundColor = .white
    textField.textColor = .white
    textField.center.y = 600

    for i in 0...rows - 1 {
      var guess:[UILabel] = []
      
      for j in 0...cols - 1 {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 65, height: 48))
//        label.center.x = CGFloat(viewW*(j+1)/cols-viewW/cols/2)
        label.center.x = CGFloat(map(minRange: 0, maxRange: cols - 1, minDomain: 55, maxDomain: viewW - 55, value: j))
        label.center.y = CGFloat(55 * (i+1) + 75)
        label.layer.borderWidth = 2.0
        label.layer.cornerRadius = 5.0
        label.layer.borderColor = UIColor.darkGray.cgColor
        label.layer.masksToBounds = true
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.textColor = .white
        
        label.textAlignment = .center
//        label.text = String(i)

        guess.append(label)
        
      }
      guesses.append(guess)
      
    }
    for guess in guesses {
      for label in guess {
        self.view.addSubview(label)
      }
    }
    
    let guessButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    guessButton.center.x = self.view.center.x
    guessButton.center.y = 470
//    guessButton.backgroundColor = .gray
    guessButton.layer.borderWidth = 3.0
    guessButton.layer.borderColor = UIColor.white.cgColor
    guessButton.layer.cornerRadius = 7.0
    guessButton.setTitleColor(.white, for: .normal)
    guessButton.setTitle("Guess", for: .normal)
    guessButton.addTarget(self, action: #selector(guessPressed), for: .touchUpInside)
    
    let delButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    delButton.center.x = CGFloat(viewW - 100)
    delButton.center.y = 470
    delButton.layer.borderWidth = 3.0
    delButton.layer.borderColor = UIColor.lightText.cgColor
    delButton.layer.cornerRadius = 7.0
    delButton.setTitleColor(.lightText, for: .normal)
    delButton.setTitle("Del", for: .normal)
    delButton.addTarget(self, action: #selector(delPressed), for: .touchUpInside)

    self.view.addSubview(guessButton)
    
    // Get current date to update daily puzzle word
    var dateComponents = DateComponents()
    dateComponents.year = 2022
    dateComponents.month = 9
    dateComponents.day = 22
    
    // Create date from components
    let userCalendar = Calendar(identifier: .gregorian)
    let startDate = userCalendar.date(from: dateComponents)!
    
    dateIndex = Calendar.current.dateComponents([.day], from: startDate, to: Date.now).day ?? 0
    
    let goalFile = "goal_words"
    let goalWordList = readFile(fileName: goalFile)
    let goalWordArray = goalWordList.split(whereSeparator: \.isNewline)
    
    // Assign goal word to the word of the day
    goalWord = String(goalWordArray[dateIndex])
  }
  
  func map(minRange:Int, maxRange:Int, minDomain:Int, maxDomain:Int, value:Int) -> Int {
      return minDomain + (maxDomain - minDomain) * (value - minRange) / (maxRange - minRange)
  }
  
  
  func readFile(fileName: String) -> String {
    // Read from project txt file
    var legalWordList = ""
    
    let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
    
    // File location
    let fileURLProject = Bundle.main.path(forResource: fileName, ofType: "txt")
    // Read from the file
    do {
      legalWordList = try String(contentsOfFile: fileURLProject!, encoding: String.Encoding.utf8)
    } catch let error as NSError {
         print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
    }
    
    return legalWordList
  }
  
  func win() {
    for label in guesses[currentRow] {
      label.backgroundColor = UIColor(cgColor: CGColor(red: 20, green: 175, blue: 60, alpha: 1.0))
    }
    score = currentRow
    displayWinAlert()
  }
  
  
  func guessMade() {
    var guessWord = ""
    for label in guesses[currentRow] {
      guessWord.append(label.text ?? "")
    }
    
    if guessWord.count == 5 { // long enough guess
      // check for win
      if guessWord == goalWord {
        win()
      }
      
      // next step: read goal_words file and set goalWord to one of those
      
      // check if word is a legal play
      let legalFile = "five_letter_word_list"
      let legalWordList = readFile(fileName: legalFile)
      if legalWordList.contains(guessWord) {
        // determine yellow and green feedback
        var i = 0
        for ch in guessWord {
          guesses[currentRow][i].layer.borderWidth = 0
          let guessChar = guessWord[guessWord.index(guessWord.startIndex, offsetBy: i)]
          let goalChar = goalWord[goalWord.index(goalWord.startIndex, offsetBy: i)]
          guesses[currentRow][i].layer.borderWidth = 0.0
          if goalWord.contains(ch) { // the character is somewhere in the word
            if guessChar == goalChar { // in the correct place
              shareString += "🟩"
//              guesses[currentRow][i].textColor = .darkText
              guesses[currentRow][i].backgroundColor = UIColor(cgColor: CGColor(red: 10/255, green: 125/255, blue: 40/255, alpha: 1.0))
            } else { // elsewhere in the word
              shareString += "🟨"
//              guesses[currentRow][i].textColor = .darkText
              guesses[currentRow][i].backgroundColor = UIColor(cgColor: CGColor(red: 160/255, green: 160/255, blue: 5/255, alpha: 1.0))
            }
          } else { // character is not in word
            shareString += "⬛"
//            guesses[currentRow][i].textColor = .lightText
            guesses[currentRow][i].backgroundColor = .darkGray
          }
          
          i += 1
        }
        
        currentRow = min(currentRow + 1, rows)
        currentCol = 0
        shareString += "\n"
      }
      
    }
  }
  
  func delMade() {
    if currentCol >= 0 {
      if currentCol == 0 {
        guesses[currentRow][currentCol].text = ""
      } else {
        currentCol = max(currentCol - 1, 0)
        guesses[currentRow][currentCol].text = ""
      }
    }
    
  }
  
  func displayWinAlert() {
    // Declare Alert message
    let dialogMessage = UIAlertController(title: "Congrats!", message: "Nice job on today's Wordie :)", preferredStyle: .alert)
    
    // Create share button with action handler
    let share = UIAlertAction(title: "Share", style: .default, handler: { (action) -> Void in
      self.shareResult()
    })
    
    // Create done button to dismiss view
    let done = UIAlertAction(title: "Done", style: .default, handler: { (action) -> Void in
      self.dismiss(animated: true, completion: nil)
    })
    
    
    //Add Done and Share button to dialog message
    dialogMessage.addAction(share)
    dialogMessage.addAction(done)
    
    // Present dialog message to user
    self.present(dialogMessage, animated: true, completion: nil)
    
  }
  
  
  func shareResult() {
    shareString += "#\(dateIndex):  \(score) / 6"
    UIPasteboard.general.string = shareString
  }
  
  @objc func guessPressed(sender: UIButton!) {
    guessMade()
  }
  
  @objc func delPressed(sender: UIButton!) {
    delMade()
  }

}

