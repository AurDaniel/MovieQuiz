import UIKit

final class MovieQuizViewController: UIViewController {
    
// MARK: Аутлеты
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    
// MARK: Методы
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz model: QuizStepViewModel) {
        imageView.image = model.image
        textLabel.text = model.question
        counterLabel.text = model.questionNumber
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrRoundResults()

        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
// MARK: Отключение кнопок
    
    private func makeButtonsInactive() {
          yesButton.isEnabled = false
          noButton.isEnabled = false
      }

      private func makeButtonsActive() {
          yesButton.isEnabled = true
          noButton.isEnabled = true
      }
    
    private func showNextQuestionOrRoundResults() {
        makeButtonsActive()
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let date = statisticService.bestGame.date.dateTimeString
            let totalAccuracy = (String(format: "%.2f", statisticService.totalAccuracy) + "%")
            let message = """
                   Ваш результат: \(correctAnswers)/\(questionsAmount)\n\
                   Количесство сыгранных квизов: \(statisticService.gamesCount)
                   Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))
                   Средняя точность: \(totalAccuracy)
               """
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                })
            alertPresenter?.showAlert(model: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
        
// MARK: Загрузка вьюшки
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 20
            
            questionFactory = QuestionFactory(delegate: self)
            questionFactory?.requestNextQuestion()
            alertPresenter = AlertPresenter(delegate: self)
            statisticService = StatisticServiceImplementation()
        }
    
    
//MARK: Кнопки
    
@IBAction private func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
   
        let correctAnswer: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == false)
        makeButtonsInactive()
    }
    
@IBAction private func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
      
        let correctAnswer: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == true)
        makeButtonsInactive()
    }
}

// MARK: Завод вопросов
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

