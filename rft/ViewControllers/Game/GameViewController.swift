//
//  GameViewController.swift
//  rft
//
//  Created by Levente Vig on 2018. 10. 13..
//  Copyright © 2018. Levente Vig. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class GameViewController: UIViewController {

	// MARK: - IBOutlets

	@IBOutlet var correctLabel: UILabel!
	@IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerTextField: UITextField!

	// MARK: - Variables

	var exercise: BehaviorRelay<Exercise> = BehaviorRelay(value: Exercise())
	let disposeBag = DisposeBag()

	// MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
		exercise
			.map({ $0.question })
			.asObservable()
			.bind(to: questionLabel.rx.text)
			.disposed(by: disposeBag)

		answerTextField.addDoneButtonToKeyboard(with: self, myAction: #selector(self.didEnterAnswer(_:)), minusAction: #selector(self.insertMinus(_:)))
    }

	@objc private func insertMinus(_ sender: Any) {
		guard answerTextField.text?.isEmpty ?? false else {
			if let number = Int(answerTextField.text ?? "") {
				answerTextField.text = String(describing: number * -1)
			}
			return
		}
		answerTextField.text = "-"
	}

	@objc private func didEnterAnswer(_ sender: Any) {
		var isCorrect = false

		correctLabel.layer.removeAllAnimations()
		correctLabel.text = "Wrong"
		correctLabel.textColor = Theme.red
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			self?.correctLabel.alpha = 1
		})

		if let answerText = answerTextField?.text {
			if let answer = Double(answerText) {
				if answer == exercise.value.correctAnswer {
					isCorrect = true
					correctLabel.text = "Correct"
					correctLabel.textColor = Theme.lightGreen
				}
			}
		}

		correctLabel.layer.removeAllAnimations()
		UIView.animate(withDuration: 1, animations: { [weak self] in
			self?.correctLabel.alpha = 0
		})

		let userinfo = ["isCorrect" : isCorrect]
		NotificationCenter.default.post(name: Constants.Notifications.FinishedCurrentExecise, object: self, userInfo: userinfo)
		answerTextField?.text = ""
	}
}
