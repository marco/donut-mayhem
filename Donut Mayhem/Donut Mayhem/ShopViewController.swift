/*
	ShopViewController.swift
	Donut Mayhem

	Created by skunkmb on 2/16/17.
	Copyright © 2017 skunkmb. All rights reserved.
*/

import UIKit
import QuartzCore

class ShopViewController: UIViewController {
	let selectedBorderColor = UIColor(red:0.89, green:0.00, blue:0.02, alpha:1.0).cgColor
	let selectedBorderWidth: CGFloat = 2
	let selectedBorderRadius: CGFloat = 5

	@IBOutlet var coinsLabel: UILabel!
	@IBOutlet var moreDetailLabel: UILabel!

	@IBOutlet var basicMuffinImageView: UIImageView!
	@IBOutlet var branMuffinImageView: UIImageView!
	@IBOutlet var cupcakeMuffinImageView: UIImageView!
	@IBOutlet var glutenFreeMuffinImageView: UIImageView!
	@IBOutlet var illuminatiMuffinImageView: UIImageView!
	@IBOutlet var swagMuffinImageView: UIImageView!

	@IBOutlet var basicMuffinButton: UIButton!
	@IBOutlet var branMuffinButton: UIButton!
	@IBOutlet var cupcakeMuffinButton: UIButton!
	@IBOutlet var glutenFreeMuffinButton: UIButton!
	@IBOutlet var illuminatiMuffinButton: UIButton!
	@IBOutlet var swagMuffinButton: UIButton!

	@IBOutlet var bagelDonutImageView: UIImageView!
	@IBOutlet var basicDonutImageView: UIImageView!
	@IBOutlet var evilDonutImageView: UIImageView!
	@IBOutlet var holeDonutImageView: UIImageView!
	@IBOutlet var jellyDonutImageView: UIImageView!
	@IBOutlet var nerdDonutImageView: UIImageView!

	@IBOutlet var bagelDonutButton: UIButton!
	@IBOutlet var basicDonutButton: UIButton!
	@IBOutlet var evilDonutButton: UIButton!
	@IBOutlet var holeDonutButton: UIButton!
	@IBOutlet var jellyDonutButton: UIButton!
	@IBOutlet var nerdDonutButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		refresh()
	}

	/**
		Updates the shop by refreshing the coin coint and the selected muffin and donut, and hiding unowned
		muffins and donuts.
	*/
	func refresh() {
		let currentCoins = UserDefaults.standard.integer(forKey: "coins")
		coinsLabel.text = "Coins: " + String(currentCoins)

		// If there are no ownedMuffins, add one.
		if UserDefaults.standard.array(forKey: "ownedMuffins") == nil {
			UserDefaults.standard.set([GameScene.MuffinType.basicMuffin.rawValue], forKey: "ownedMuffins")
		}

		// If there are no ownedDonuts, add one.
		if UserDefaults.standard.array(forKey: "ownedDonuts") == nil {
			UserDefaults.standard.set([GameScene.DonutType.basicDonut.rawValue], forKey: "ownedDonuts")
		}

		let muffinTypeString = UserDefaults.standard.string(forKey: "muffinType")!
		let muffinType = GameScene.MuffinType(rawValue: muffinTypeString)

		let donutTypeString = UserDefaults.standard.string(forKey: "donutType")!
		let donutType = GameScene.DonutType(rawValue: donutTypeString)

		let selectedMuffinImageView = findMuffinImageView(withType: muffinType!)
		let selectedDonutImageView = findDonutImageView(withType: donutType!)

		selectedMuffinImageView.layer.borderColor = selectedBorderColor
		selectedMuffinImageView.layer.borderWidth = selectedBorderWidth
		selectedMuffinImageView.layer.cornerRadius = selectedBorderRadius
		selectedDonutImageView.layer.borderColor = selectedBorderColor
		selectedDonutImageView.layer.borderWidth = selectedBorderWidth
		selectedDonutImageView.layer.cornerRadius = selectedBorderRadius

		// Go through the rest of the ownedMuffins.
		for ownedMuffinString in UserDefaults.standard.array(forKey: "ownedMuffins") as! [String] {
			guard ownedMuffinString != muffinTypeString else {
				continue
			}

			// Remove their borders in the event that a new muffin is bought and selected.
			let ownedMuffinImageView = findMuffinImageView(withType: GameScene.MuffinType(rawValue:
				ownedMuffinString)!)
			ownedMuffinImageView.layer.borderColor = nil
			ownedMuffinImageView.layer.borderWidth = 0
			ownedMuffinImageView.layer.cornerRadius = 0
		}

		// Go through the rest of the ownedDonuts.
		for ownedDonutString in UserDefaults.standard.array(forKey: "ownedDonuts") as! [String] {
			guard ownedDonutString != donutTypeString else {
				continue
			}

			// Remove their borders in the event that a new donut is bought and selected.
			let ownedDonutImageView = findDonutImageView(withType: GameScene.DonutType(rawValue:
				ownedDonutString)!)
			ownedDonutImageView.layer.borderColor = nil
			ownedDonutImageView.layer.borderWidth = 0
			ownedDonutImageView.layer.cornerRadius = 0
		}


		let unownedMuffinStrings = getUnownedMuffinStrings()
		let unownedDonutStrings = getUnownedDonutStrings()

		// Go through and change the unowned muffins.
		for unownedMuffinString in unownedMuffinStrings {
			let unownedMuffinType = GameScene.MuffinType.init(rawValue: unownedMuffinString)
			let unownedMuffinImageView = findMuffinImageView(withType: unownedMuffinType!)

			unownedMuffinImageView.image = UIImage.init(named: "mysteryMuffin")
		}

		// Also change the unowned donuts.
		for unownedDonutString in unownedDonutStrings {
			let unownedDonutType = GameScene.DonutType.init(rawValue: unownedDonutString)
			let unownedDonutImageView = findDonutImageView(withType: unownedDonutType!)

			unownedDonutImageView.image = UIImage.init(named: "mysteryDonut")
		}
	}

	/**
		Finds and returns the `UIImageView` of a `GameScene.MuffinType`.
		
		- Parameters:
			- type: The `GameScene.MuffinType` to find the `UIImageView` of.
		
		- Returns: The `UIImageView` that was found.
	*/
	func findMuffinImageView(withType type: GameScene.MuffinType) -> UIImageView {
		switch type {
		case GameScene.MuffinType.basicMuffin:
			return basicMuffinImageView
		case GameScene.MuffinType.branMuffin:
			return branMuffinImageView
		case GameScene.MuffinType.cupcakeMuffin:
			return cupcakeMuffinImageView
		case GameScene.MuffinType.glutenFreeMuffin:
			return glutenFreeMuffinImageView
		case GameScene.MuffinType.illuminatiMuffin:
			return illuminatiMuffinImageView
		case GameScene.MuffinType.swagMuffin:
			return swagMuffinImageView
		}
	}

	/**
		Finds and returns the `UIImageView` of a `GameScene.DonutType`.
		
		- Parameters:
			- type: The `GameScene.DonutType` to find the `UIImageView` of.
		
		- Returns: The `UIImageView` that was found.
	*/
	func findDonutImageView(withType type: GameScene.DonutType) -> UIImageView {
		switch type {
		case GameScene.DonutType.basicDonut:
			return basicDonutImageView
		case GameScene.DonutType.bagelDonut:
			return bagelDonutImageView
		case GameScene.DonutType.evilDonut:
			return evilDonutImageView
		case GameScene.DonutType.holeDonut:
			return holeDonutImageView
		case GameScene.DonutType.jellyDonut:
			return jellyDonutImageView
		case GameScene.DonutType.nerdDonut:
			return nerdDonutImageView
		}
	}

	/**
		Generates and returns an array of currently unowned muffins as `String`s.
		
		- Returns: The array of currently unowned muffins as `String`s.
	*/
	func getUnownedMuffinStrings() -> [String] {
		// Temporarily create a local list of unowned muffins, which can then be shortened by a loop.
		var unownedMuffins = [
			GameScene.MuffinType.basicMuffin.rawValue,
			GameScene.MuffinType.branMuffin.rawValue,
			GameScene.MuffinType.cupcakeMuffin.rawValue,
			GameScene.MuffinType.glutenFreeMuffin.rawValue,
			GameScene.MuffinType.illuminatiMuffin.rawValue,
			GameScene.MuffinType.swagMuffin.rawValue,
		]

		for ownedMuffinString in UserDefaults.standard.array(forKey: "ownedMuffins")! {
			unownedMuffins.remove(at: unownedMuffins.index(of: ownedMuffinString as! String)!)
		}

		return unownedMuffins
	}

	/**
		Generates and returns an array of currently unowned donuts as `String`s.
		
		- Returns: The array of currently unowned donuts as `String`s.
	*/
	func getUnownedDonutStrings() -> [String] {
		// Temporarily create a local list of unowned donuts, which can then be shortened by a loop.
		var unownedDonuts = [
			GameScene.DonutType.bagelDonut.rawValue,
			GameScene.DonutType.basicDonut.rawValue,
			GameScene.DonutType.evilDonut.rawValue,
			GameScene.DonutType.holeDonut.rawValue,
			GameScene.DonutType.jellyDonut.rawValue,
			GameScene.DonutType.nerdDonut.rawValue,
		]

		for ownedDonutString in UserDefaults.standard.array(forKey: "ownedDonuts")! {
			unownedDonuts.remove(at: unownedDonuts.index(of: ownedDonutString as! String)!)
		}

		return unownedDonuts
	}

	/**
		Tries to select a muffin with the specified `GameScene.MuffinType`.
		
		- Parameters:
			- type: The `GameScene.MuffinType` of the muffin to attempt to select.
	*/
	func attemptToSelectMuffin(withType type: GameScene.MuffinType) {
		let muffinString = type.rawValue
		let ownedMuffinsArray = UserDefaults.standard.array(forKey: "ownedMuffins") as! [String]

		guard ownedMuffinsArray.index(of: muffinString) != nil else {
			let alertController = UIAlertController(title: nil, message: "You haven’t unlocked that!",
				preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel,
				handler: nil))
			self.present(alertController, animated: true, completion: nil)

			return
		}

		UserDefaults.standard.set(muffinString, forKey: "muffinType")
		refresh()
	}

	/**
		Tries to select a donut with the specified `GameScene.DonutType`.
		
		- Parameters:
			- type: The `GameScene.DonutType` of the donut to attempt to select.
	*/
	func attemptToSelectDonut(withType type: GameScene.DonutType) {
		let donutString = type.rawValue
		let ownedDonutsArray = UserDefaults.standard.array(forKey: "ownedDonuts") as! [String]

		guard ownedDonutsArray.index(of: donutString) != nil else {
			let alertController = UIAlertController(title: nil, message: "You haven’t unlocked that!",
				preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel,
				handler: nil))
			self.present(alertController, animated: true, completion: nil)

			return
		}

		UserDefaults.standard.set(donutString, forKey: "donutType")
		refresh()
	}

	/**
		Calls `attemptToSelectMuffin` on the `GameScene.MuffinType` of a muffin when it is pressed.
		
		- Parameters:
			- sender: The `UIButton` of the muffin which was pressed.
	*/
	@IBAction func anyMuffinButtonTouchUpInside(_ sender: UIButton) {
		switch sender {
		case basicMuffinButton:
			attemptToSelectMuffin(withType: GameScene.MuffinType.basicMuffin)
		case branMuffinButton:
			attemptToSelectMuffin(withType: GameScene.MuffinType.branMuffin)
		case cupcakeMuffinButton:
			attemptToSelectMuffin(withType: GameScene.MuffinType.cupcakeMuffin)
		case glutenFreeMuffinButton:
			attemptToSelectMuffin(withType: GameScene.MuffinType.glutenFreeMuffin)
		case illuminatiMuffinButton:
			attemptToSelectMuffin(withType: GameScene.MuffinType.illuminatiMuffin)
		case swagMuffinButton:
			attemptToSelectMuffin(withType: GameScene.MuffinType.swagMuffin)
		default:
			break
		}
	}

	/**
		Calls `attemptToSelectDonut` on the `GameScene.DonutType` of a donut when it is pressed.
		
		- Parameters:
			- sender: The `UIButton` of the donut which was pressed.
	*/
	@IBAction func anyDonutButtonTouchUpInside(_ sender: UIButton) {
		switch sender {
		case bagelDonutButton:
			attemptToSelectDonut(withType: GameScene.DonutType.bagelDonut)
		case basicDonutButton:
			attemptToSelectDonut(withType: GameScene.DonutType.basicDonut)
		case evilDonutButton:
			attemptToSelectDonut(withType: GameScene.DonutType.evilDonut)
		case holeDonutButton:
			attemptToSelectDonut(withType: GameScene.DonutType.holeDonut)
		case jellyDonutButton:
			attemptToSelectDonut(withType: GameScene.DonutType.jellyDonut)
		case nerdDonutButton:
			attemptToSelectDonut(withType: GameScene.DonutType.nerdDonut)
		default:
			break
		}
	}

	/**
		Buys and selects random muffin or donut for 100 coins (if the user has enough) when the “buy” button is
		pressed.
	*/
	@IBAction func buyButtonTouchUpInside() {
		var currentCoins = UserDefaults.standard.integer(forKey: "coins")

		guard currentCoins >= 100 else {
			let alertController = UIAlertController(title: nil, message: "You don’t have enough coins!",
				preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel,
				handler: nil))
			self.present(alertController, animated: true, completion: nil)

			return
		}

		var unownedMuffinStrings = getUnownedMuffinStrings()
		var unownedDonutStrings = getUnownedDonutStrings()

		// Decide whether to unlock a muffin or donut by seeing if a random integer from 0 to 1 is equal to 0.
		let unlockMuffin = arc4random_uniform(2) == 0

		if unlockMuffin {
			let randomIndex = arc4random_uniform(UInt32(unownedMuffinStrings.count))
			let unlockedMuffinString = unownedMuffinStrings[Int(randomIndex)]
			var currentOwnedMuffins = UserDefaults.standard.array(forKey: "ownedMuffins")
			currentOwnedMuffins?.append(unlockedMuffinString)
			UserDefaults.standard.set(currentOwnedMuffins, forKey: "ownedMuffins")
			attemptToSelectMuffin(withType: GameScene.MuffinType(rawValue: unlockedMuffinString)!)

			// Reset the unlocked muffin’s image view to use the actual muffin, not the mystery muffin.
			let newMuffinImageView = findMuffinImageView(withType: GameScene.MuffinType(rawValue:
				unlockedMuffinString)!)
			newMuffinImageView.image = UIImage(named: unlockedMuffinString)
		} else {
			let randomIndex = arc4random_uniform(UInt32(unownedDonutStrings.count))
			let unlockedDonutString = unownedDonutStrings[Int(randomIndex)]
			var currentOwnedDonuts = UserDefaults.standard.array(forKey: "ownedDonuts")
			currentOwnedDonuts?.append(unlockedDonutString)
			UserDefaults.standard.set(currentOwnedDonuts, forKey: "ownedDonuts")
			attemptToSelectDonut(withType: GameScene.DonutType(rawValue: unlockedDonutString)!)

			// Reset the unlocked donut’s image view to use the actual donut, not the mystery donut.
			let newDonutImageView = findDonutImageView(withType: GameScene.DonutType(rawValue:
				unlockedDonutString)!)
			newDonutImageView.image = UIImage(named: unlockedDonutString)
		}

		currentCoins -= 100
		UserDefaults.standard.set(currentCoins, forKey: "coins")

		refresh()
	}
}
