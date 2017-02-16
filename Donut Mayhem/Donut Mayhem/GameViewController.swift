/*
	GameViewController.swift
	Donut Mayhem

	Created by skunkmb on 2/16/17.
	Copyright © 2017 skunkmb. All rights reserved.
*/

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		// Create a new view to present a SKScene on later, and return if there is an error.
		guard let view = self.view as! SKView? else {
			return
		}

		// Load the SKScene from GameScene.sks.
		if let scene = SKScene(fileNamed: "GameScene") {
			// Set the scale mode to scale to fit the window.
			scene.scaleMode = SKSceneScaleMode.aspectFill

			// Present the scene.
			view.presentScene(scene)
		}
		
		view.ignoresSiblingOrder = true
		view.showsFPS = false
		view.showsNodeCount = false
	}

	override var shouldAutorotate: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
			return UIInterfaceOrientationMask.allButUpsideDown
		} else {
			return UIInterfaceOrientationMask.all
		}
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
