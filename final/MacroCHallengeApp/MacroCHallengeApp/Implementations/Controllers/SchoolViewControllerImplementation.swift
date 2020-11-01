//
//  SchoolViewControllerImplementation.swift
//  MacroCHallengeApp
//
//  Created by João Pedro de Amorim on 05/10/20.
//

import UIKit

class SchoolViewControllerImplementation: UIViewController, SchoolViewControllerProtocol {

    // MARK: - Dependencies
    var myView: SchoolViewProtocol?
    
    // MARK: - Private attributes
    private var data: School
    private var requestSender = RequestSenderImplementation()
    
    // MARK: - Init methods
    required init(data: School) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    override func loadView() {
        super.loadView()
        setupDefaultView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = data.name
    }
    
    // MARK: - Setup methods
    private func setupDefaultView() {
        let defaultView = SchoolViewImplementation(data: self.data, controller: self)
        self.myView = defaultView
        self.view = defaultView
    }
    
    // MARK: - SchoolViewControllerProtocol methods
    func testWasSubmitted(_ test: TestHeader) {
        self.myView?.startActivity()
        requestSender.getQuestionsForTestRequest(
            testName: test.name,
            testYear: test.year,
            completion: { questions, error in
                
                self.myView?.stopActivity()
                guard let questionsArray = questions else {
                    print("Erro ao fazer request das questoes:\n\t \(error ?? "Error message is nil")")
                    let alert = UIAlertController(title: "Erro",
                                                  message: "Falha ao carregar questões, verifique sua conexão",
                                                  preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok",
                                                  style: .default,
                                                  handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let navController = self.navigationController {
                    let testAsTestType = Test(name: test.name, year: test.year, questions: questionsArray)
                    let overviewViewController = OverviewViewControllerImplementation(data: testAsTestType)
                    navController.pushViewController(overviewViewController, animated: true)
                }
            })
    }
    
    func noticeWasSubmitted(_ notice: Notice) {
        if let navController = self.navigationController {
            let overviewViewController = NoticeViewControllerImplementation(data: notice)
            navController.pushViewController(overviewViewController, animated: true)
        }
    }
}

