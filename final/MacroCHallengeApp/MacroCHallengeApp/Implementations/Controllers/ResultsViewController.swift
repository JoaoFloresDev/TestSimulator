//
//  ResultsViewController.swift
//  MacroCHallengeApp
//
//  Created by João Pedro de Amorim on 13/10/20.
//

import UIKit

class ResultsViewController: UIViewController, ResultsViewControllerProtocol {
    // MARK: - Dependencies
    var myView: ResultsViewProtocol?
    var requestSender = RequestSenderImplementation()
    
    // MARK: - Private attributes
    private var test: Test
    private var answeredQuestions: [String : String]
    private(set) var resultsData: ResultsData?
    private var correctUserAnswers: [Int] = []
    private var wrongUserAnswers: [Int] = []
    private var timeElapsed: String
    private var questionController: QuestionViewControllerProtocol
    
    // MARK: - Init methods
    required init(test: Test, answeredQuestions: [String : String], timeElapsed: String, questionController: QuestionViewControllerProtocol) {
        self.test = test
        self.answeredQuestions = answeredQuestions
        self.timeElapsed = timeElapsed
        self.questionController = questionController
        super.init(nibName: nil, bundle: nil)
        setupResultsData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        setupDefaultView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Setup methods
    private func setupDefaultView() {
        if let resultsData = self.resultsData {
            let defaultView = ResultsViewImplementation(data: resultsData, viewController: self)
            self.myView = defaultView
            self.view = defaultView
        }
    }
    
    private func setupResultsData() {
        let totalNumberOfCorrectAnswers = getTotalNumberOfCorrectAnswers()
        let totalNumberOfQuestions = test.questions.count
        let totalPercentageOfCorrectAnswers = calculatePercentage(correctAnswers: totalNumberOfCorrectAnswers ,
                                                                  totalNumberOfQuestions: totalNumberOfQuestions)
        let totalNumberOfAnsweredQuestions = answeredQuestions.count
        let totalTimeElapsed = timeElapsed
        let resultsPerTopic: [String : ResultsPerTopic] = generateResultsForAllTopics()
        
        generateCorrectAndWrongUserAnswersAsIntArray()
        
        let resultsData = ResultsData(totalPercentageOfCorrectAnswers: totalPercentageOfCorrectAnswers,
                                      totalNumberOfCorrectAnswers: totalNumberOfCorrectAnswers,
                                      totalNumberOfAnsweredQuestions: totalNumberOfAnsweredQuestions,
                                      totalNumberOfQuestions: totalNumberOfQuestions,
                                      resultsPerTopic: resultsPerTopic,
                                      test: test,
                                      answeredQuestions: answeredQuestions,
                                      totalTimeElapsed: totalTimeElapsed,
                                      correctAnswers: correctUserAnswers,
                                      wrongAnswers: wrongUserAnswers)
        self.resultsData = resultsData
        sendResultsRequest(resultsData)
    }
    
    // MARK: - ResultsViewControllerProtocol methods
    func questionWasSubmitted(_ question: Question) {
        guard let navController = self.navigationController else {
            return
        }
        
        questionController.shouldDisplayAnswer = true
        questionController.displayQuestion(question)
        
        if let questionControllerAsUIViewController = questionController as? UIViewController {
            navController.pushViewController(questionControllerAsUIViewController, animated: true)
        }
    }
    
    // MARK: - Private methods
    /**
     
     Calcula a porcentagem de acertos(questões corretas/questões totais).
     
     - returns A porcentagem de acertos como um double arredondado (exemplo: 44.00)
     
     */
    
    private func calculatePercentage(correctAnswers: Int, totalNumberOfQuestions:Int) -> Double {
        let doubleValue = Double(correctAnswers) / Double(totalNumberOfQuestions)
        
        let roundedValue = (doubleValue * 100).rounded()
        
        return roundedValue
    }
    
    /**
     
     Calcula o número de questões corretas em uma prova.
     
     - returns A quantidade de questões corretas
     
     */
    
    private func getTotalNumberOfCorrectAnswers() -> Int {
        let testQuestions = test.questions
        var correctAnswers: Int = 0
        
        for (questionNumber, answer) in answeredQuestions {
            if let question = testQuestions.filter({ $0.number == questionNumber }).first {
                if question.answer == answer.uppercased() {
                    correctAnswers += 1
                }
            }
        }
        return correctAnswers
    }
    /**
     
     Função que retorna um conjunto (ou seja, sem elementos repetidos) de tópicos de questões da prova realizada
     
     - returns conjunto de tópicos das questões da prova realizada
     
     */
    
    private func getTopicsFromQuestions() -> Set<String> {
        var returnSet: Set<String> = Set<String>()
        
        for question in test.questions {
            returnSet.insert(question.topic)
        }
        
        return returnSet
    }
    
    /**
     
     Função que gera o data container ResultsPerTopic para um tópico (matéria) específico
     
     - returns o ResultsPerTopic daquela matéria
     
     */
    private func generateResultsPerIndividualTopic(_ topic: String) -> ResultsPerTopic {
        var topicTotalCorrect = 0
        var topicTotalAnswered = 0
        var topicTotal = 0
        
        let testQuestions = test.questions
        
        for (questionNumber, answer) in answeredQuestions {
            if let question = testQuestions.filter({ $0.number == questionNumber }).first {
                if question.topic == topic {
                    if question.answer == answer.uppercased() {
                        topicTotalCorrect += 1
                    }
                    topicTotalAnswered += 1
                }
            }
        }
        
        for question in testQuestions {
            if question.topic == topic {
                topicTotal += 1
            }
        }
        
        let topicPercentage = calculatePercentage(correctAnswers: topicTotalCorrect, totalNumberOfQuestions: topicTotal)
        
        
        let result = ResultsPerTopic(totalPercentageOfCorrectAnswers: topicPercentage,
                                     totalNumberOfCorrectAnswers: topicTotalCorrect,
                                     totalNumberOfAnsweredQuestions: topicTotalAnswered,
                                     totalNumberOfQuestions: topicTotal)
        
        return result
    }
    /**
     
     Gera o dicionário que possui como chaves as matérias da prova e como valor os resultados daquela matéria.
     
     - returns O dicionário que será fornecido à view
     
     */
    private func generateResultsForAllTopics() -> [String : ResultsPerTopic] {
        let topics = getTopicsFromQuestions()
        
        var returnData: [String : ResultsPerTopic] = [:]
        
        for topic in topics {
            returnData[topic] = generateResultsPerIndividualTopic(topic)
        }
        
        return returnData
    }
    
    /**
     
     Inicializa as variáveis de classe correctUserAnswers e wrongUserAnswers
     
     */
    
    private func generateCorrectAndWrongUserAnswersAsIntArray() {
        let testQuestions = test.questions
        
        for (questionNumber, answer) in answeredQuestions {
            if let question = testQuestions.filter({ $0.number == questionNumber }).first {
                if let questionNumberAsInt = Int(questionNumber) {
                    if question.answer == answer.uppercased() {
                        correctUserAnswers.append(questionNumberAsInt)
                    }
                }
            }
        }
        
        correctUserAnswers.sort()
        
        for question in test.questions {
            if let questionNumberAsInt = Int(question.number) {
                if !correctUserAnswers.contains(questionNumberAsInt) {
                    wrongUserAnswers.append(questionNumberAsInt)
                }
            }
        }
        
        wrongUserAnswers.sort()
    }
    
    private func sendResultsRequest(_ resultsData: ResultsData) {
        requestSender.postResultsForTest(testName: test.name, testYear: test.year, results: resultsData) { error in
            if let errorMessage = error {
                print("Erro ao fazer request dos resultados:\n\t \(errorMessage)")
                let alert = UIAlertController(title: "Erro",
                                              message: "Falha ao gravar os resultados no servidor, verifique sua conexão",
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok",
                                              style: .default,
                                              handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
}
