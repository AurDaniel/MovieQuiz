import Foundation

 struct QuizQuestion {
       let image: String
       let text: String
       let correctAnswer: Bool

      init(image: String, text: String, correctAnswer: Bool) {
          self.image = image
          self.text = text
          self.correctAnswer = correctAnswer
      }
   }
