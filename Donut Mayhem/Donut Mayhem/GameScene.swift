/*
	GameScene.swift
	Donut Mayhem

	Created by skunkmb on 2/16/17.
	Copyright © 2017 skunkmb. All rights reserved.
*/

import SpriteKit
import GameplayKit

/// The main Donut Mayhem game `SKScene`.
class GameScene: SKScene {
	/// Muffin types that the user can choose from.
	enum MuffinType: String {
		/// A basic, default muffin, with a light top and a blue wrapper.
		case basicMuffin

		/// A bran muffin, with a darker top and an orange wrapper.
		case branMuffin

		/// A cupcake, with a pink frosted top and a brown wrapper.
		case cupcakeMuffin

		/// A gluten-free muffin, with a yellow top and a turquoise wrapper.
		case glutenFreeMuffin

		/// An Illuminati muffin, with a big green eye on its top and a purple wrapper.
		case illuminatiMuffin

		/// A swag muffin, with a yellow top, red wrapper, a chain around its neck, and sunglasses.
		case swagMuffin
	}

	/// Donut types that the user can choose from.
	enum DonutType: String {
		/// A bagel.
		case bagelDonut

		/// An evil donut with purple frosting and red and orange sprinkles.
		case evilDonut

		/// A sprinkle donut, with pink frosting and rainbow sprinkles.
		case sprinkleDonut
	}

	/// The saturation used in the randomly-generated background color.
	let backgroundSaturation: CGFloat = 1

	/// The brightness used in the randomly-generated background color.
	let backgroundBrightness: CGFloat = 0.8

	/// The font family of the ammo `SKLabelNode` and the score `SKLabelNode`.
	let labelsFont = "Futura"

	/// The font size of the ammo `SKLabelNode` and the score `SKLabelNode`.
	let labelsFontSize: CGFloat = 24

	/// The amound of pixels in between the ammo `SKLabelNode` and the score `SKLabelNode` and the screen’s edge.
	let labelsEdgeOffset: CGFloat = 20

	/// The size of the muffin `SKSpriteNode`.
	let muffinSize = CGSize(width: 60, height: 129)

	/// The size of a donut `SKSpriteNode`.
	let donutSize = CGSize(width: 40, height: 40)

	/// The size of a bomb `SKSpriteNode`.
	let bombSize = CGSize(width: 38, height: 46)

	/// The `name` of the muffin `SKSpriteNode`.
	let muffinName = "muffin"

	/// The `name` of active donut `SKSpriteNode`s.
	let donutName = "donut"

	/// The `name` of removed donut `SKSpriteNode`s.
	let removedDonutName = "removedDonut"

	/// The `name` of active bomb `SKSpriteNode`s.
	let bombName = "bomb"

	/// The `name` of removed bomb `SKSpriteNode`s.
	let removedBombName = "removedBomb"

	/// The `name` of the score `SKLabelNode`.
	let scoreLabelName = "scoreLabel"

	/// The `name` of the ammo `SKLabelNode`.
	let ammoLabelName = "ammoLabel"

	/// The time (in seconds) in between when ammo is added.
	let ammoInterval: TimeInterval = 1

	/// The time (in seconds) in between when donuts are spawned.
	let donutInterval: TimeInterval = 1

	/// The time (in seconds) it takes for the donut to travel 1px towards the muffin.
	let donutSpeed: TimeInterval = 0.015

	/// The time (in seconds) it takes for the bomb to travel 1px towards its target.
	let bombSpeed: TimeInterval = 0.005

	/// The denominator of the chance that 1 free bonus ammo will be awarded.
	let ammoBonusChanceDenominator: UInt32 = 7

	/// The speed that the ammo `SKLabelNode` flickers at when it needs to alert that there is no more ammo.
	let noAmmoFlickerSpeed: TimeInterval = 0.2

	/// The color that the ammo `SKLabelNode` uses when it needs to alert that there is no more ammo.
	let noAmmoFlickerColor = UIColor.red

	/// The time (in seconds) it takes for a bomb and a donut to shrink when they hit eachother.
	let donutBombShrinkSpeed: TimeInterval = 0.1

	/// The score amounts when the `ammoPerRound` and `donutPerRound` are increased.
	let ammoDonutsPerRoundIncreasePoints = [15, 30, 60, 120, 240, 360, 500, 1000]

	/// The Storyboard ID of the game over `UIViewController`.
	let gameOverStoryboardID = "GameOverViewController"

	/// The parent `UIViewController`, which is set when this scene is presented.
	var parentViewController: UIViewController = UIViewController()

	/// The current amount of donuts destroyed.
	var score = 0

	/// The current amount of ammo.
	var ammo = 0

	/// The changing amount of ammo added every `ammoInterval`.
	var ammoPerRound = 1

	/// The changing amount of donuts created every `donutInterval`.
	var donutsPerRound = 1

	override func didMove(to view: SKView) {
		self.backgroundColor = randomizeColor(withSaturation: backgroundSaturation,
			brightness: backgroundBrightness)

		createLabels(withFont: labelsFont, fontSize: labelsFontSize)

		createMuffin()

		startAmmoTimer(withTimeInterval: ammoInterval, bonusChanceDenominator: ammoBonusChanceDenominator)
		startDonutTimer(withTimeInterval: donutInterval, donutSpeed: donutSpeed)
	}

	override func update(_ currentTime: TimeInterval) {
		checkForDonutMuffinCollision()
		checkForBombDonutCollision(withShrinkSpeed: donutBombShrinkSpeed)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if ammo >= 1 {
			createBomb(withTarget: touches.first!.location(in: self), speed: bombSpeed)

			self.ammo -= 1

			let ammoLabel = self.childNode(withName: self.ammoLabelName) as! SKLabelNode
			ammoLabel.text = "Ammo: " + String(self.ammo)
		} else {
			let ammoLabel = self.childNode(withName: self.ammoLabelName) as! SKLabelNode

			let waitAction = SKAction.wait(forDuration: noAmmoFlickerSpeed)

			let makeDifferentAction = SKAction.run {
				ammoLabel.fontColor = self.noAmmoFlickerColor
			}

			let makeDefaultAction = SKAction.run {
				ammoLabel.fontColor = UIColor.black
			}

			ammoLabel.run(SKAction.sequence([
				makeDifferentAction, waitAction, makeDefaultAction, waitAction,
				makeDifferentAction, waitAction, makeDefaultAction, waitAction
			]))
		}

		/*
			If a user taps thrice, change the background color.
			
			NOTE: first does not mean that this only works the first time the user tries it; rather, it
			means that only the first in a set of touches is checked when a user is using multitouch.
		*/
		if touches.first!.tapCount == 3 {
			self.backgroundColor = randomizeColor(withSaturation: backgroundSaturation,
				brightness: backgroundBrightness)
		}
	}

	// MARK: Set up.

	/**
		Creates a `UIColor` with a randomized hue.
		
		- Parameters: 
			- saturation: The saturation used in the `UIColor`.
			- brightness: The brightness used in the `UIColor`.
		
		- Returns: The created `UIColor`.
	*/
	func randomizeColor(withSaturation saturation: CGFloat, brightness: CGFloat) -> UIColor {
		/*
			Generate a random decimal from 0 to 1 by taking a large random number and dividing it by the
			maximum possible value for a random number.
		*/
		let randomMaximum = Float(UInt32.max)
		let randomFloat = Float(arc4random())
		let randomDecimal = CGFloat(randomFloat/randomMaximum)

		let color = UIColor.init(hue: randomDecimal, saturation: saturation, brightness: brightness, alpha: 1)

		return color
	}

	/**
		Creates an  `SKLabelNode` for the current points total.
		
		- Parameters:
			- font: The font family to be used in the label.
			- fontSize: The font size to be used in the label.
	*/
	func createLabels(withFont font: String, fontSize: CGFloat) {
		let scoreLabel = SKLabelNode.init(fontNamed: font)
		scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
		scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		scoreLabel.position = CGPoint(x: -self.size.width/2 + labelsEdgeOffset,
			y: self.size.height/2 - labelsEdgeOffset)

		// Set a higher z-position, so that it appears to be “above” the donuts.
		scoreLabel.zPosition = 0.1

		scoreLabel.text = String(score)
		scoreLabel.fontColor = UIColor.black
		scoreLabel.name = scoreLabelName
		scoreLabel.fontSize = fontSize

		self.addChild(scoreLabel)

		let ammoLabel = SKLabelNode.init(fontNamed: font)
		ammoLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
		ammoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
		ammoLabel.position = CGPoint(x: self.size.width/2 - labelsEdgeOffset,
			y: self.size.height/2 - labelsEdgeOffset)

		// Set a higher z-position, so that it appears to be “above” the donuts.
		ammoLabel.zPosition = 0.1

		ammoLabel.text = "Ammo: " + String(ammo)
		ammoLabel.fontColor = UIColor.black
		ammoLabel.name = ammoLabelName
		ammoLabel.fontSize = fontSize

		self.addChild(ammoLabel)
	}

	// MARK: Create muffins.

	/**
		Creates a muffin of the current type, or a `basicMuffin` if the user hasn’t chosen yet, at the center
		of the screen.
	*/
	func createMuffin() {
		/*
			Get the current muffinType that the user has selected, or, if they don’t have one selected,
			select one automatically and retry.
		*/
		guard let muffinTypeString = UserDefaults.standard.string(forKey: "muffinType") else {
			UserDefaults.standard.set(MuffinType.basicMuffin.rawValue, forKey: "muffinType")
			createMuffin()
			return
		}

		// Create a new SKSpriteNode with a texture equal to the image with muffinType’s value.
		let muffinImage = UIImage.init(named: muffinTypeString)
		let muffinSprite = SKSpriteNode.init(texture: SKTexture.init(image: muffinImage!), size: muffinSize)

		muffinSprite.position = CGPoint(x: 0, y: 0)

		// Set a name so that donuts can find it and it can be checked for collisions later.
		muffinSprite.name = muffinName

		// Set a lower z-position, so that it appears to be “underneath” the donuts.
		muffinSprite.zPosition = -0.1

		self.addChild(muffinSprite)
	}

	// MARK: Add ammo.

	/**
		Starts a timer that adds to the `ammo` based on `GameScene`’s `ammoPerRound`, and changes the ammo
		label accordingly. There is a change that a bonus ammo will be added.

		- Parameters:
			- timeInterval: The time (in seconds) between ammo being added.
			- bonusChanceDenominator: The denominator of a fraction equal to the chance an extra ammo will
			be added. For example, a value of 7 means that there is a 1/7 chance there will be a bonus.
	*/
	func startAmmoTimer(withTimeInterval timeInterval: TimeInterval, bonusChanceDenominator: UInt32) {
		let waitAction = SKAction.wait(forDuration: timeInterval)

		let addAmmoAction = SKAction.run {
			// If a random numer is 0 (with a 1/bonusChanceDenominator chance), award a bonus ammo.
			let isBonus = arc4random_uniform(bonusChanceDenominator) == 0

			if isBonus {
				self.ammo += self.ammoPerRound + 1

				self.run(SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false))
			} else {
				self.ammo += self.ammoPerRound
			}

			let ammoLabel = self.childNode(withName: self.ammoLabelName) as! SKLabelNode
			ammoLabel.text = "Ammo: " + String(self.ammo)
		}

		// Run each action forever, after the other one finishes.
		run(SKAction.repeatForever(SKAction.sequence([waitAction, addAmmoAction])))
	}

	// MARK: Create donuts.

	/**
		Starts a timer that spawns `GameScene`’s `donutsPerRound` donuts from random locations at the specified
		interval based on the current donut type.

		- Parameters:
			- timeInterval: The time (in seconds) between donuts being spawned.
			– donutSpeed: The time (in seconds) it takes for the donuts to travel 1px towards the muffin.
	*/
	func startDonutTimer(withTimeInterval timeInterval: TimeInterval, donutSpeed: TimeInterval) {
		let waitAction = SKAction.wait(forDuration: timeInterval)

		let createDonutAction = SKAction.run {
			for _ in 1...self.donutsPerRound {
				self.createDonut(withSpeed: donutSpeed)
			}
		}

		// Run each action forever, after the other one finishes.
		run(SKAction.repeatForever(SKAction.sequence([waitAction, createDonutAction])))
	}

	/**
		Creates a donut of the current type, or a `sprinkleDonut` if the user hasn’t chosen yet, from a random
		location. Then, the donut moves towards the muffin with the specified speed.
		
		- Parameters:
			- speed: The time (in seconds) it takes for the donut to travel 1px towards the muffin.
	*/
	func createDonut(withSpeed speed: TimeInterval) {
		run(SKAction.playSoundFileNamed("newDonut.wav", waitForCompletion: false))
		/*
			Get the current donutType that the user has selected, or, if they don’t have one selected,
			select one automatically and retry.
		*/
		guard let donutTypeString = UserDefaults.standard.string(forKey: "donutType") else {
			UserDefaults.standard.set(DonutType.sprinkleDonut.rawValue, forKey: "donutType")
			createDonut(withSpeed: speed)
			return
		}

		// Create a new SKSpriteNode with a texture equal to the image with donutType’s value.
		let donutImage = UIImage.init(named: donutTypeString)
		let donutSprite = SKSpriteNode.init(texture: SKTexture.init(image: donutImage!), size: donutSize)

		donutSprite.position = generateRandomEdgePosition()

		// Set a name so that it can be checked for collisions later.
		donutSprite.name = donutName

		self.addChild(donutSprite)

		// Create a normalized vector to be used as a direction, based on the muffin’s position.
		let muffinPosition = self.scene!.childNode(withName: muffinName)!.position
		let unnormalizedVector = CGVector.init(dx: muffinPosition.x - donutSprite.position.x,
			dy: muffinPosition.y - donutSprite.position.y)
		let normalizedVector = normalize(vector: unnormalizedVector)
		donutSprite.run(SKAction.repeatForever(SKAction.move(by: normalizedVector, duration: speed)))
	}

	/**
		Creates a `CGPoint` on a random edge of the user’s screen.
		
		- Returns: The created `CGPoint`.
	*/
	func generateRandomEdgePosition() -> CGPoint {
		/*
			Generate random booleans for what edge to place the point based on a number from 0 to 1 being
			equal to 0.
		*/
		let onSide = arc4random_uniform(2) == 0
		let onRightOrTop = arc4random_uniform(2) == 0

		var position = CGPoint.init()

		if onSide {
			/*
				Set the y to a random value, between −1/2 of the height and +1/2 of the height, due to
				the centered origin.
			*/
			let randomCGFloat = CGFloat(arc4random_uniform(UInt32(self.size.height)))
			let heightDividedBy2 = CGFloat(UInt32(self.size.height)/2)
			position.y = randomCGFloat - heightDividedBy2

			// Base the x on whether the donut should be onRightOrTop or not.
			if onRightOrTop {
				position.x = self.size.width/2
			} else {
				position.x = -self.size.width/2
			}
		} else {
			/*
				Set the x to a random value, between −1/2 of the width and +1/2 of the width, due to
				the centered origin.
			*/
			let randomCGFloat = CGFloat(arc4random_uniform(UInt32(self.size.height)))
			let widthDividedBy2 = CGFloat(UInt32(self.size.width)/2)
			position.x = randomCGFloat - widthDividedBy2

			// Base the y on whether the donut should be onRightOrTop or not.
			if onRightOrTop {
				position.y = self.size.height/2
			} else {
				position.y = -self.size.height/2
			}
		}

		return position
	}

	// MARK: Create bombs.

	/**
		Creates a bomb that is launched forever towards and past a target location at the specified speed.
		
		- Parameters:
			- target: The location where the bomb is aimed.
			- speed: The time (in seconds) it takes for the bomb to travel 1px towards the specified
			`target`.
	*/
	func createBomb(withTarget target: CGPoint, speed: TimeInterval) {
		run(SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false))

		// Create a new SKSpriteNode with a bomb texture.
		let bombImage = UIImage.init(named: bombName)
		let bombSprite = SKSpriteNode.init(texture: SKTexture.init(image: bombImage!), size: bombSize)

		bombSprite.position = self.scene!.childNode(withName: muffinName)!.position

		// Set a name so that it can be checked for collisions later.
		bombSprite.name = bombName

		self.addChild(bombSprite)

		// Create a normalized vector to be used as a direction, based on the muffin’s position.
		let muffinPosition = self.scene!.childNode(withName: muffinName)!.position
		let unnormalizedVector = CGVector.init(dx: target.x - muffinPosition.x,
			dy: target.y - muffinPosition.y)
		let normalizedVector = normalize(vector: unnormalizedVector)
		bombSprite.run(SKAction.repeatForever(SKAction.move(by: normalizedVector, duration: speed)))
	}

	// MARK: Check for collisions.

	/// Checks to see if any donut intersects with the muffin, and if one does, calls `gameOver`.
	func checkForDonutMuffinCollision() {
		self.scene?.enumerateChildNodes(withName: donutName, using: { (donut, _) in
			let muffin = self.scene?.childNode(withName: self.muffinName)

			if muffin!.frame.intersects(donut.frame) {
				/*
					Change its name so that while the gameOver sound is playing it does not get
					looped by the same donut.
				*/
				donut.name = self.removedDonutName
				self.gameOver()
			}
		})
	}

	/**
		Checks to see if any bomb intersects with a donut. If one does, removes them both after a shrinking
		animation and increase the `score`. Also, increase the `ammoPerRound` and `donutsPerRound` if the
		current `score` is included in `GameScene`’s `ammoDonutsPerRoundIncreasePoints`.
		
		- Parameters:
			- shrinkSpeed: The time (in seconds) it takes for the colliding donut and bomb to collide.
	*/
	func checkForBombDonutCollision(withShrinkSpeed shrinkSpeed: TimeInterval) {
		self.scene?.enumerateChildNodes(withName: bombName, using: { (bomb, _) in
			self.scene?.enumerateChildNodes(withName: self.donutName, using: { (donut, _) in
				if bomb.frame.intersects(donut.frame) {
					/*
						Change their names so that while the animation is happening they do not
						continue to give points or affect other nodes, even thought it will be
						completely removed later.
					*/
					donut.name = self.removedDonutName
					bomb.name = self.removedBombName

					let shrinkBombDonutAction = SKAction.group([
						SKAction.resize(toWidth: 0, duration: shrinkSpeed),
						SKAction.resize(toHeight: 0, duration: shrinkSpeed)
					])

					let removeBombAction = SKAction.run {
						bomb.removeFromParent()
					}

					let removeDonutAction = SKAction.run {
						donut.removeFromParent()
					}

					bomb.run(SKAction.sequence([shrinkBombDonutAction, removeBombAction]))
					donut.run(SKAction.sequence([shrinkBombDonutAction, removeDonutAction]))

					self.run(SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false))

					self.score += 1
					let scoreLabel = self.childNode(withName: self.scoreLabelName)
						as! SKLabelNode
					scoreLabel.text = String(self.score)

					if self.ammoDonutsPerRoundIncreasePoints.index(of: self.score) != nil {
						self.ammoPerRound += 1
						self.donutsPerRound += 1
					}
				}
			})
		})
	}

	/**
		Normalizes a `CGVector`. In other words, makes it so that its magnitude (or length) is equal to 1, but
		preserves its direction.
		
		- Parameters:
			- vector: The `CGVector` to normalize.
		
		- Returns: The normalized `CGVector`.
	*/
	func normalize(vector: CGVector) -> CGVector {
		let length = sqrt(pow(vector.dx, 2) + pow(vector.dy, 2))
		let normalizedVector = CGVector.init(dx: vector.dx/length, dy: vector.dy/length)
		return normalizedVector
	}

	// MARK: End the game.

	/**
		Plays a game over sound, then transitions to a game over view controller after checking if a new
		highscore was made.
	*/
	func gameOver() {
		let playAction = SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: false)

		let pauseAction = SKAction.run {
			self.scene?.isPaused = true
		}

		let moveAction = SKAction.run {
			let storyboard = self.parentViewController.storyboard

			guard let viewController = storyboard? .
				instantiateViewController(withIdentifier: self.gameOverStoryboardID)
				as? GameOverViewController else {
				return
			}

			viewController.finalScore = self.score

			if self.score > UserDefaults.standard.integer(forKey: "highScore") {
				UserDefaults.standard.set(self.score, forKey: "highScore")
				viewController.newHighScore = true
			} else {
				viewController.newHighScore = false
			}

			self.scene?.isPaused = true

			self.parentViewController.present(viewController, animated: true, completion: nil)
		}

		run(SKAction.sequence([playAction, pauseAction, moveAction]))
	}
}
