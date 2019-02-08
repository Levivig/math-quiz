//
//  MainMenuViewController.swift
//  rft
//
//  Created by Levente Vig on 2018. 09. 29..
//  Copyright © 2018. Levente Vig. All rights reserved.
//

import Hero
import RxCocoa
import RxSwift
import UIKit

class MainMenuViewController: UIViewController {

	// MARK: - IBOutlets

    @IBOutlet var tableView: UITableView!

	// MARK: - Variables

    let difficulties: BehaviorRelay<[Difficulty]> = BehaviorRelay(value: [])
    let disposeBag = DisposeBag()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDatasource()
        setupTableView()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.deselectRow(at: tableView?.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0), animated: false)
	}

	// MARK: - Setup methods

    func setUpDatasource() {
        difficulties.accept(DifficultyProvider.shared.getDifficulties())

        difficulties.asObservable()
			.bind(to: self.tableView.rx
			.items(cellIdentifier: Constants.Cells.DifficultyCell)) { [weak self] (_, model, cell: DifficultyCell) in
            self?.bind(to: cell, with: model)
            cell.wrapperView.clipsToBounds = false
            cell.wrapperView.layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
            cell.wrapperView.layer.shadowOpacity = 0.3
            cell.wrapperView.layer.shadowOffset = CGSize(width: 0, height: 2)
            }.disposed(by: disposeBag)
    }

    func setupTableView() {
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            NSLog("✅ Row \(indexPath.row) selected")
			let heroID = "diff\(indexPath.row)"
			guard let cell = self?.tableView.cellForRow(at: indexPath) as? DifficultyCell else { return }
			cell.hero.id = heroID
			cell.levelImageView.alpha = 0
			cell.titleLabel.alpha = 0

			if let navController = self?.storyboard?.instantiateViewController(
				withIdentifier: Constants.ViewControllers.GameNavigationController) as? UINavigationController {
				if navController.viewControllers.first is BaseGameViewController {
					let gameController = navController.viewControllers.first as? BaseGameViewController
					let selectedLevel = self?.tableView.indexPathForSelectedRow?.row

					gameController?.hero.isEnabled = true
					gameController?.view.hero.id = heroID

					if let difficulty = DifficultyLevel(rawValue: selectedLevel ?? 0) {
						gameController?.difficultyLevel = difficulty
						self?.present(navController, animated: true, completion: {
							cell.levelImageView.alpha = 1
							cell.titleLabel.alpha = 1
						})
					}
				}
			}
        }).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Constants.Segues.StartGame {
			if segue.destination is UINavigationController {
				let navController = segue.destination as? UINavigationController
				if navController?.viewControllers.first is BaseGameViewController {
					let gameController = navController?.viewControllers.first as? BaseGameViewController
					let selectedLevel = tableView.indexPathForSelectedRow?.row

					gameController?.hero.isEnabled = true
					gameController?.view.hero.id = "gameStart"

					if let difficulty = DifficultyLevel(rawValue: selectedLevel ?? 0) {
						gameController?.difficultyLevel = difficulty
					}
				}
			}
		}
	}
}

// MARK: - Cell binding

extension MainMenuViewController: DifficultyCellBinding {
    func bind(to cell: DifficultyCell, with model: Difficulty) {
        cell.titleLabel.text = model.name
        cell.levelImageView.image = model.image
		cell.wrapperView.backgroundColor = model.color
    }
}

// MARK: - TableView delegate

extension MainMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}
