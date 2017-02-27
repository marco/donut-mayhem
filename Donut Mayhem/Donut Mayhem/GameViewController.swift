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

		// Create a new view to present a SKScene on later, or return if there is an error.
		guard let view = self.view as! SKView? else {
			return
		}

		// Load the SKScene from GameScene.sks, or return if there is an error.
		guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
			return
		}

		// Set the scale mode to scale to fit the window.
		scene.scaleMode = SKSceneScaleMode.aspectFill

		// Tell the scene what its parent is, so that it can do transitions later.
		scene.parentViewController = self

		// Present the scene.
		view.presentScene(scene)

		view.ignoresSiblingOrder = true
		view.showsFPS = false
		view.showsNodeCount = false
		view.isMultipleTouchEnabled = true
	}

	override var shouldAutorotate: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
			return UIInterfaceOrientationMask.landscape
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
