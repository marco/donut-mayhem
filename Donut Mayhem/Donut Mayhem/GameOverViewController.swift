/*
	GameViewController.swift
	Donut Mayhem

	Created by skunkmb on 2/16/17.
	Copyright © 2017 skunkmb. All rights reserved.
*/

import UIKit

class GameOverViewController: UIViewController {
	var finalScore = 0
	var newHighScore = false

	@IBOutlet var yourScoreLabel: UILabel!
	@IBOutlet var yourHighscoreLabel: UILabel!

	override func viewDidLoad() {
		/*
			NOTE: Other game over related functions (such as setting a highscore or adding coins) are done
			in GameScene.
		*/
		super.viewDidLoad()

		yourScoreLabel.text = "Your Score: " + String(finalScore)

		if newHighScore {
			yourHighscoreLabel.text = "NEW HIGHSCORE!"
		} else {
			yourHighscoreLabel.text = "Your Highscore: " +
				String(UserDefaults.standard.integer(forKey: "highScore"))
		}
	}
}
