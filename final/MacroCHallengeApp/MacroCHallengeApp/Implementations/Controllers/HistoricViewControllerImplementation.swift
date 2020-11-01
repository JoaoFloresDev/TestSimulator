//
//  HistoricViewController.swift
//  MacroCHallengeApp
//
//  Created by Joao Flores on 27/10/20.
//

import UIKit

class HistoricViewControllerImplementation: UIViewController,  HistoricViewControllerProtocol, OverviewViewControllerProtocol {
	
	// MARK: - OverviewViewProtocol methods
	required init(data: Test) {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func questionWasSubmitted(_ question: Question) {}
	
	func answerForQuestionWasSubmitted(question: Question, answer: String) {}
	
	func questionWasUnsubmitted(question: Question) {}
	
	func hasBegun() {}
	
	func hasEnded() {}
	
	var myView: OverviewViewProtocol?
	
	var questionController: QuestionViewControllerProtocol?
	
	// MARK: - Dependencies
	/*
	
	Nota: como este View Controller é o primeiro a ser instanciado no Storyboard, ele é o único que possuirá
	dependências opcionais que não são a sua view. Para contornarmos isso, existem métodos de setup que são responsáveis
	por popular essas variáveis com suas implementações padrões. Para os demais controllers, as implementações padrões de
	suas dependências (exceto pela view) são passadas em seu inicializador (veja o método schoolWasSubmitted, por exemplo).
	*/
	
	var myHistoricView: HistoricViewProtocol?
	var schools: SchoolsProtocol?
	
	// MARK: - Lifecycle methods
	override func loadView() {
		super.loadView()
		setupDefaultSchoolsImplementation()
		setupDefaultViewImplementation()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Histórico"
	}
	
	// MARK: - Setup methods
	private func setupDefaultSchoolsImplementation() {
		self.schools = SchoolsServiceManager()
	}
	
	private func setupDefaultViewImplementation() {
		if let data = schools?.getSchools() {
			let defaultView = HistoricViewImplementation(data: data, controller: self)
			self.myHistoricView = defaultView
			self.view = defaultView
		}
	}
	
	// MARK: - HistoricViewControllerProtocol methods
	
	func testWasSubmitted(_ test: TestHeader) {
		
		let testFromTestHeader = Test(name: test.name, year: test.year, questions: [])
		
		let questionsVC = QuestionViewControllerImplementation(data: [], parentController: self)
		
		questionsVC.shouldDisplayAnswer = true
		
		if let navController = self.navigationController {
			let resultsVC = ResultsViewController(test: testFromTestHeader, answeredQuestions: ["1":"a", "2": "b"], timeElapsed: "00:00", questionController: questionsVC)
			navController.pushViewController(resultsVC, animated: true)
		}
	}
}

