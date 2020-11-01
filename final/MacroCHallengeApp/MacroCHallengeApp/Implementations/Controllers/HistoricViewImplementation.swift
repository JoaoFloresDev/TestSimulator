//
//  HistoricViewImplementation.swift
//  MacroCHallengeApp
//
//  Created by Joao Flores on 27/10/20.
//

import Foundation
import UIKit
import KDCircularProgress

class HistoricViewImplementation: UIView, HistoricViewProtocol {
	// MARK: -IBOutlets
	@IBOutlet weak var tableViewSchools: UITableView!
	
	// MARK: - Dependencies
	var viewController: HistoricViewControllerProtocol

	// MARK: - Private attributes
	private var data: [School]
	private var dataTableView: [School]

	// MARK: - Init methods
	required init(data: [School], controller: HistoricViewControllerProtocol) {
		self.data = data
		self.dataTableView = SchoolsServiceManager().getSchools()

		self.viewController = controller
		super.init(frame: CGRect.zero)
		initFromNib()

		setupDelegateTableview()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func initFromNib() {
		if let nib = Bundle.main.loadNibNamed("HistoricViewImplementation", owner: self, options: nil),
		   let nibView = nib.first as? UIView {
			nibView.frame = bounds
			nibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			addSubview(nibView)
		}
	}
    
    /**
     
     Método responsável por converter o número de acertos de uma prova para um ângulo.
     
     - parameters numberOfRightQuestions: número de questões acertadas.
     
     */
    
    private func convertNumberOfRightQuestionsInAngle(numberOfRightQuestions: Int) -> Double {
        
        let angle = Double(360*numberOfRightQuestions/50)
        
        return angle
    }
    
    /**
     
     Método responsável por criar o gráfico circular relativo ao número de acertos de uma prova.
     
     - parameters toAngle: o ângulo relativo ao número de acertos de uma prova.
     
     */
    
    private func drawCircularProgress(toAngle: Double) -> KDCircularProgress {
        
        let circularProgress: KDCircularProgress = KDCircularProgress(frame: CGRect(x: 0,
                                                                                    y: 0,
                                                                                    width: 56,
                                                                                    height: 56))
        
        let colorGreen: UIColor = UIColor(red: 14/255, green: 173/255, blue: 0, alpha: 1)
        let colorGray: UIColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        
        circularProgress.startAngle = -90
        circularProgress.progressThickness = 0.4
        circularProgress.trackThickness = 0.4
        circularProgress.glowMode = .noGlow
        circularProgress.set(colors: colorGreen)
        circularProgress.trackColor = colorGray
        circularProgress.animate(fromAngle: 0,
                                 toAngle: toAngle,
                                 duration: 0,
                                 completion: nil)
        
        return circularProgress
    }
}

// MARK: - Extension Table View Data Source Methods
extension HistoricViewImplementation:UITableViewDataSource, UITableViewDelegate {

	func setupDelegateTableview() {
		tableViewSchools.delegate = self
		tableViewSchools.dataSource = self
		tableViewSchools.register(UINib(nibName: "SchoolsTableViewCell", bundle: nil), forCellReuseIdentifier: "SchoolsTableViewCell")
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return dataTableView.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return dataTableView[section].tests.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cellIdentifier = String()

		cellIdentifier = "TestTableViewCell"
		referenceXib(nibName: cellIdentifier)

		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TestTableViewCell  else {
			fatalError("The dequeued cell is not an instance of TestTableViewCell.")
		}

		let nameTitle = handleStringName(name: dataTableView[indexPath.section].tests[indexPath.row].name)
		cell.testLabel.text = nameTitle
        
        let correctAnswers: Int = 40
        let angle = convertNumberOfRightQuestionsInAngle(numberOfRightQuestions: correctAnswers)

        cell.circularProgressView.addSubview(drawCircularProgress(toAngle: angle))
        
        // Multiplica por dois, porque a porcentagem de acertos seria: (correctAnswers/50)*100.
        let percentageOfCorrectAnswers: Int = 2*correctAnswers

        cell.circularProgressLabel.text = "\(percentageOfCorrectAnswers)" + "%"
        
		return cell
	}

	/**
		Função para tratamento da string de título, insere um espaço entre o nome da prova e o ano respectivo

		- parameter name: nome concatenado
	*/
	func handleStringName(name: String) -> String {
		var characters = Array(name)

		for i in 0...(characters.count - 1) {
			if Int(String(characters[i])) != nil {
				characters.insert(" ", at: i)
				break
			}
		}

		return String(characters)
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableViewSchools.deselectRow(at: indexPath, animated: true)
		viewController.testWasSubmitted(data[indexPath.section].tests[indexPath.row])
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		return dataTableView[section].name
	}

	func referenceXib(nibName: String) {
		let nib = UINib.init(nibName: nibName, bundle: nil)
		self.tableViewSchools.register(nib, forCellReuseIdentifier: nibName)
	}

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.init(red: 242/255,
																						  green: 242/255,
																						  blue: 247/255,
																						  alpha: 1.0)
		(view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.init(red: 123/255,
																				   green: 123/255,
																				   blue: 123/255,
																				   alpha: 1.0)
	}
}
