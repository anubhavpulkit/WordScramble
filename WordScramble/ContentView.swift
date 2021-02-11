//
//  ContentView.swift
//  WordScramble
//
//  Created by Pully on 10/02/21.
//  Copyright © 2021 catalyst. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {

        NavigationView{
            VStack{
                
                // onCommit is used to call the fun addNewWord when return key is pressed on keyboard.
                TextField("Enter the world", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self){
                    
                    // using SF symbol to mention how many words is used in newWorld
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }.navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }

        }
    }
    func addNewWord(){
        
        // remove spacing and line brack and all letters are in lowercased
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
       
        // using guard prop to insure newWord have at least 1 letter.
        // exit if the remaining string is empty
        guard answer.count > 0 else{
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }

        // inseart newWord in the usedWord at first place and make newWord string empty
        usedWords.insert(newWord, at: 0)
        newWord = ""
        
    }

    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    // Checking whether the word has been used before or not
    func isOriginal(word: String)-> Bool{
        !usedWords.contains(word)
    }
    
    // check whether a random word can be made out of the letters from another random word?
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else{
                return false
            }
        }
        return true
    }
    
    // Using UITextChecker for validation of string.
    func isReal(word: String) ->Bool{
        let check = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missSpelledRange = check.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missSpelledRange.location == NSNotFound
    }
    
    // method for showing alert
    func wordError(title:String, message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
