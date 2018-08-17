-----------------------------------------------------------------------------------------
-- ABSTRACT - FEED MY PUPPY
-- CREATED BY PICKION GAMES
-- HTTP://PICKION.COM/

-- VERSION - 1.5
-- 
-- COPYRIGHT (C) 2014 PICKION. ALL RIGHTS RESERVED.
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene() 
local GGTwitter = require("GGTwitter")
local json = require("json")
local physics = require ("physics")	--Require physics
local loadsave = require("loadsave")
local gameNetwork = require("gameNetwork")

local gameSettings = {}
		gameSettings["Easy"] = 		{gravityY = 15, interval = 999, scale = 2}
		gameSettings["Normal"] = 	{gravityY = 25, interval = 750, scale = 1}
		gameSettings["Hard"] = 		{gravityY = 40, interval = 500, scale = 1}
		gameSettings["Extreme"] = 	{gravityY = 40, interval = 500,	scale = 0.5}
local gravityX = 0;

physics.start()
physics.setGravity(gravityX, gameSettings[gameData.gameDifficulty].gravityY)
physics.setScale(60)
physics.setDrawMode("normal") -- normal hybrid debug
physics.setContinuous( false )

--	CONSTANT VARIABLES
local screenLeft = display.screenOriginX
local screenWidth = display.contentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.contentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local mSin = math.sin
local mAtan2 = math.atan2
local mPi = math.pi
local mRand = math.random
local mCeil = math.ceil
local mSqrt = math.sqrt
local mPow = math.pow

-- Variables
local treatDropInterval = gameSettings[gameData.gameDifficulty].interval
local levelDifficulty = gameData.gameDifficulty
local screenShakeIntensity = 10 -- How much the screen shakes when the player dies
local screenShakeDuration = 10 -- How long the screen shakes for (50 = 1 second)
local decorSpeed = 2

-- Constants Do Not Edit
local isGameActive = true
local gameScore = 0
local bgChangeCount = 0

--	COLOR PALETTE
local colorWhite =		{R = 255/255,	G = 255/255,	B = 255/255,	A = 255/255}
local colorBlack =		{R = 0/255,		G = 0/255,		B = 0/255,		A = 255/255}

local dogShape = {-10 * gameSettings[gameData.gameDifficulty].scale,18 * gameSettings[gameData.gameDifficulty].scale, 10 * gameSettings[gameData.gameDifficulty].scale,18 * gameSettings[gameData.gameDifficulty].scale, 10 * gameSettings[gameData.gameDifficulty].scale,-18 * gameSettings[gameData.gameDifficulty].scale, -10 * gameSettings[gameData.gameDifficulty].scale,-18 * gameSettings[gameData.gameDifficulty].scale}
local boneShape = {-7,17, 7,17, 7,-17, -7,-17}

-- Sprite Sheet Images
local actionPuppyGameOverSequenceData = {name="actionPup", start=1, count=4, time=1000}
local actionPuppyGameOverSpriteSheet = graphics.newImageSheet("images/decor/actionPup.png", {width=60, height=80, numFrames=4, sheetContentWidth=240, sheetContentHeight=80})
local cryingPuppyGameOverSequenceData = {name="cryingPup", start=1, count=4, time=1000}
local cryingPuppyGameOverSpriteSheet = graphics.newImageSheet("images/decor/cryingPup.png", {width=160, height=186, numFrames=4, sheetContentWidth=640, sheetContentHeight=186})

local boneCollisionFilter = { categoryBits = 1, maskBits = 2 }								
local otherCollisionFilter = { categoryBits = 2, maskBits = 1 }								

--	DISPLAY GROUPS
local groupDecor	-- Background and Graphics
local groupClouds	-- 4 Clouds Used in Game Loop
local groupGame		-- Treats bones
local groupUI		-- Touch Overlay and Score
local groupEnd		-- Game Over Objects

--	FUNCTIONS LIST
local createStageSetting
local createReadyInstruction

local treatBonesFood = {}

-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
	local gameGroup = self.view

	groupDecor 		= display.newGroup();											gameGroup:insert(groupDecor)
	groupClouds 	= display.newGroup();											gameGroup:insert(groupClouds)
	groupGame 		= display.newGroup();											gameGroup:insert(groupGame)
	groupUI 		= display.newGroup();											gameGroup:insert(groupUI)
	groupEnd 		= display.newGroup();											gameGroup:insert(groupEnd)

	function createStageSetting()
		gameDecorBackground = display.newImageRect(groupDecor, "images/background01.png", 380, 570)
		gameDecorBackground.anchorX = 0.5;											gameDecorBackground.x = centerX;
		gameDecorBackground.anchorY = 0.5;											gameDecorBackground.y = centerY;

		gameDecorGround = display.newRect(groupDecor, 0, 0, screenWidth, 10)
		gameDecorGround.anchorX = 0.5;												gameDecorGround.x = centerX;
		gameDecorGround.anchorY = 1;												gameDecorGround.y = screenHeight;
		gameDecorGround.alpha = 0;
		gameDecorGround.objName = "ground"
		physics.addBody(gameDecorGround, "static", {filter = otherCollisionFilter})

		uiOverlayForDrag = display.newRect(groupUI, 0, 0, screenWidth, screenHeight)
		uiOverlayForDrag:setFillColor(colorWhite.R, colorWhite.G, colorWhite.B, colorWhite.A)
		uiOverlayForDrag.x = centerX;
		uiOverlayForDrag.y = centerY;
		uiOverlayForDrag.alpha = 0.01;

		gameImageCloud01 = display.newImageRect(groupClouds, "images/decor/tinyCloudA01.png", 90, 50)
		gameImageCloud01.x = mRand(20, screenWidth + 200);							gameImageCloud01.y = mRand(0, centerY)

		gameImageCloud02 = display.newImageRect(groupClouds, "images/decor/tinyCloudA01.png", 90, 50)
		gameImageCloud02.x = mRand(20, screenWidth + 200);							gameImageCloud02.y = mRand(0, centerY)

		gameImageCloud03 = display.newImageRect(groupClouds, "images/decor/tinyCloudB01.png", 90, 50)
		gameImageCloud03.x = mRand(20, screenWidth + 200);							gameImageCloud03.y = mRand(0, centerY)

		gameImageCloud04 = display.newImageRect(groupClouds, "images/decor/tinyCloudB01.png", 90, 50)
		gameImageCloud04.x = mRand(20, screenWidth + 200);							gameImageCloud04.y = mRand(0, centerY)

		------------------------------------------------
		-- SET UP UI INTERFACE SCORE AND HIGH SCORE ----
		------------------------------------------------

		uiTextScore = display.newText(groupUI, "Score: " .. gameScore, 0, 0, customFont, 36 * 2)
		uiTextScore:setFillColor(colorBlack.R, colorBlack.G, colorBlack.B, colorBlack.A)
		uiTextScore.xScale = 0.5;													uiTextScore.yScale = 0.5;
		uiTextScore.anchorX = 0.5;													uiTextScore.x = centerX;
		uiTextScore.anchorY = 0;													uiTextScore.y = 20;
		uiTextScore.isVisible = false;
	end

	function createReadyInstruction()
		gameImagePuppyDog = display.newSprite(groupDecor, actionPuppyGameOverSpriteSheet, actionPuppyGameOverSequenceData)
		gameImagePuppyDog.xScale = gameSettings[gameData.gameDifficulty].scale;						gameImagePuppyDog.yScale = gameSettings[gameData.gameDifficulty].scale;
		gameImagePuppyDog.x = centerX
		gameImagePuppyDog.y = screenHeight * 0.75
		gameImagePuppyDog.rotation = 0
		gameImagePuppyDog.objName = "dogMouth"
		physics.addBody(gameImagePuppyDog, "static", {shape = dogShape, filter = otherCollisionFilter})
		gameImagePuppyDog:setSequence("actionPup")

		uiDecorInstructionsBox = display.newRect(groupUI, 0, 0, 250, 350)
		uiDecorInstructionsBox:setFillColor(colorWhite.R, colorWhite.G, colorWhite.B, colorWhite.A)
		uiDecorInstructionsBox:setStrokeColor(colorBlack.R, colorBlack.G, colorBlack.B, colorBlack.A)
		uiDecorInstructionsBox.strokeWidth = 10;
		uiDecorInstructionsBox.x = centerX;
		uiDecorInstructionsBox.y = centerY;
		uiDecorInstructionsBox.myLabel = "startGame"

		uiImageInstruction = display.newImageRect(groupUI, "images/decor/newinstructions.png", 240, 340)
		uiImageInstruction.x = centerX;												uiImageInstruction.y = centerY;
	end
end

-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
	storyboard.removeAll()

	function scoreTransitionEffects(amount)
		local plusPointSymbol = {}

		for i = 1, 1 do
			plusPointSymbol[i] = display.newText("+" .. amount, 0, 0, customFont, 24 * 2)
			plusPointSymbol[i]:setFillColor(colorWhite.R, colorWhite.G, colorWhite.B, colorWhite.A)
			plusPointSymbol[i].x = gameImagePuppyDog.x;
			plusPointSymbol[i].y = gameImagePuppyDog.y - 20;
			plusPointSymbol[i].alpha = 0.8;
			groupDecor:insert(plusPointSymbol[i])
			transition.to(plusPointSymbol[i], {delay = 50, time = 250, x = uiTextScore.x, y = uiTextScore.y, alpha = 0, onComplete = function() if plusPointSymbol[i] then plusPointSymbol[i]:removeSelf() end end})
		end
	end

	function changeBackground()
		local randomDiceRoll = mRand(1, 3)
		bgChangeCount = 0

		gameDecorBackground:removeSelf()
		gameDecorBackground = nil
		gameDecorBackground = display.newImageRect(groupDecor, "images/background0" .. randomDiceRoll .. ".png", 380, 570)
		gameDecorBackground.anchorX = 0.5;											gameDecorBackground.x = centerX;
		gameDecorBackground.anchorY = 0.5;											gameDecorBackground.y = centerY;
		gameDecorBackground:toBack()
	end

	function updateScore(amount)
		scoreTransitionEffects(amount)
		gameScore = gameScore + amount
		uiTextScore.text = "Score: " .. gameScore
		bgChangeCount = bgChangeCount + amount

		if bgChangeCount >= 10 then
			changeBackground()
		end
	end

	function screenShake(event)
		if event.count == screenShakeDuration then
			self.view.x = 0
			self.view.y = 0
		else
			self.view.x = mRand(-screenShakeIntensity, screenShakeIntensity)
			self.view.y = mRand(-screenShakeIntensity, screenShakeIntensity)
		end
	end

	function onCollision(self, event)
		local id = event.other.objName

		if event.phase == "began" then
			if id == "dogMouth" then
				if soundAllowed then playSound("crunch") end
				timer.performWithDelay(10, function() self:removeSelf(); self = nil end, 1)
				updateScore(1)
				print("collision occurred with the dog")

			elseif id == "ground" then
				gameImagePuppyDog:pause()
				if soundAllowed then playSound("gameover") end
				timer.performWithDelay(10, function() self:removeSelf(); self = nil end, 1)
				timer.performWithDelay(20, screenShake, screenShakeDuration)
				timer.performWithDelay(50, gameOverEvent, 1)
				print("collision occurred with the ground")
			end
		end
		return true
	end

	function spawnNewTreat()
		local i
		local randomDiceRoll = mRand(1, 8)

		for i = 1, 1 do
			treatBonesFood[i] = display.newImageRect("images/bones/bone0" .. randomDiceRoll .. ".png", 15, 35)
			treatBonesFood[i].x = mRand(20, 300)
			treatBonesFood[i].y = -50;
			treatBonesFood[i].isFixedRotation = false;
			treatBonesFood[i].rotation = mRand(-45, 45)
			physics.addBody(treatBonesFood[i], "dynamic", {shape = boneShape, filter = boneCollisionFilter})
			treatBonesFood[i].collision = onCollision
			treatBonesFood[i]:addEventListener("collision", treatBonesFood[i])
			groupGame:insert(treatBonesFood[i])
		end
	end

	function destroyObjects()
		for i = groupGame.numChildren, 1, -1 do
			local decorObjects = groupGame[i]
			if decorObjects ~= nil then
				decorObjects:removeSelf()
				decorObjects = nil
			end
		end
	end

	function gameLoop()
		for i = groupClouds.numChildren, 1, -1 do
			local clouds = groupClouds[i]
			if clouds ~= nil and clouds.x ~= nil and clouds.x > -100 then
				clouds:translate(-decorSpeed, 0)
			else
				clouds.x = mRand(screenWidth + 50, screenWidth + 350)
				clouds.y = mRand(0, centerY)
			end
		end
	end

	function slideTheDog(event)
		local t = event.target

		if isGameActive then
			if event.phase == "began" then
				display.getCurrentStage():setFocus( t )
				t.isFocus = true

				gameImagePuppyDog.x0 = event.x - gameImagePuppyDog.x
			elseif t.isFocus then
				if event.phase == "moved" then
					gameImagePuppyDog.x = event.x - gameImagePuppyDog.x0
				if ((gameImagePuppyDog.x - gameImagePuppyDog.width * 0.5) < 0) then gameImagePuppyDog.x = gameImagePuppyDog.width * 0.5
				elseif ((gameImagePuppyDog.x + gameImagePuppyDog.width * 0.5) > screenWidth) then gameImagePuppyDog.x = screenWidth - gameImagePuppyDog.width * 0.5
				end
				elseif event.phase == "ended" or "cancelled" then
					display.getCurrentStage():setFocus( nil )
					t.isFocus = false
				end
			end
			return true
		end
	end

	function gameOverEvent()
		print("Game is Over, Showing Game Over Menu.")
		local function delay() display.getCurrentStage():setFocus(nil) end
		timer.performWithDelay(100, delay, 1)

		showAdMobbAdInt()
		destroyObjects()
		isGameActive = false
		if treatDropTimer ~= nil then timer.cancel(treatDropTimer) end

		uiOverlayForDrag:removeEventListener("touch", slideTheDog)
		Runtime:removeEventListener("enterFrame", gameLoop)

		uiTextScore.isVisible = false;

		gameOverOverlayBox = display.newRect(groupEnd, 0, 0, screenWidth, screenHeight)
		gameOverOverlayBox:setFillColor(colorWhite.R, colorWhite.G, colorWhite.B, colorWhite.A)
		gameOverOverlayBox:setStrokeColor(colorBlack.R, colorBlack.G, colorBlack.B, colorBlack.A)
		gameOverOverlayBox.strokeWidth = 10;
		gameOverOverlayBox.anchorX = 0.5;											gameOverOverlayBox.x = centerX;
		gameOverOverlayBox.anchorY = 0.5;											gameOverOverlayBox.y = centerY;

		gameOverCryingPuppy = display.newSprite(groupEnd, cryingPuppyGameOverSpriteSheet, cryingPuppyGameOverSequenceData)
		gameOverCryingPuppy.x = centerX
		gameOverCryingPuppy.y = centerY
		gameOverCryingPuppy:setSequence("cryingPup")
		gameOverCryingPuppy:play()

		gameOverCryCoverCircle = display.newImageRect(groupEnd, "images/decor/gameOverCover.png", 160, 186)
		gameOverCryCoverCircle.xScale = 1.25;									gameOverCryCoverCircle.yScale = 1.25;
		gameOverCryCoverCircle.x = centerX;
		gameOverCryCoverCircle.y = centerY;

		gameOverHeaderTitle = display.newText(groupEnd, "Game Over?", 0, 0, customFont, 36 * 2)
		gameOverHeaderTitle:setFillColor(colorBlack.R, colorBlack.G, colorBlack.B, colorBlack.A)
		gameOverHeaderTitle.xScale = 0.5;										gameOverHeaderTitle.yScale = 0.5;
		gameOverHeaderTitle.anchorX = 0.5;										gameOverHeaderTitle.x = centerX;
		gameOverHeaderTitle.anchorY = 0.5;										gameOverHeaderTitle.y = centerY - 180;

		gameOverGameScore = display.newText(groupEnd, "Your Score " .. gameScore .. " on " .. levelDifficulty, 0, 0, customFont, 24 * 2)
		gameOverGameScore:setFillColor(colorBlack.R, colorBlack.G, colorBlack.B, colorBlack.A)
		gameOverGameScore.xScale = 0.5;											gameOverGameScore.yScale = 0.5;
		gameOverGameScore.anchorX = 0.5;										gameOverGameScore.x = centerX;
		gameOverGameScore.anchorY = 0.5;										gameOverGameScore.y = centerY - 120;

		gameOverShareTwitter = display.newText(groupEnd, "Tweet Your Score On Twitter", 0, 0, customFont, 8 * 2)
		gameOverShareTwitter:setFillColor(colorBlack.R, colorBlack.G, colorBlack.B, colorBlack.A)
		gameOverShareTwitter.xScale = 0.5;										gameOverShareTwitter.yScale = 0.5;
		gameOverShareTwitter.anchorX = 0.5;										gameOverShareTwitter.x = centerX;
		gameOverShareTwitter.anchorY = 1;										gameOverShareTwitter.y = centerY + 220;

		gameOverButtonMenu = display.newImageRect(groupEnd, "images/button/buttonHome.png", 80, 80)
		gameOverButtonMenu.xScale = 0.8;										gameOverButtonMenu.yScale = 0.8;
		gameOverButtonMenu.anchorX = 0.5;										gameOverButtonMenu.x = centerX + 80;
		gameOverButtonMenu.anchorY = 0.5;										gameOverButtonMenu.y = centerY + 120;
		gameOverButtonMenu.myLabel = "menu"

		gameOverButtonReplay = display.newImageRect(groupEnd, "images/button/buttonReplay.png", 80, 80)
		gameOverButtonReplay.xScale = 0.8;										gameOverButtonReplay.yScale = 0.8;
		gameOverButtonReplay.anchorX = 0.5;										gameOverButtonReplay.x = centerX;
		gameOverButtonReplay.anchorY = 0.5;										gameOverButtonReplay.y = centerY + 120;
		gameOverButtonReplay.myLabel = "retry"

		gameOverButtonTwitter = display.newImageRect(groupEnd, "images/button/buttonTwitter.png", 80, 80)
		gameOverButtonTwitter.xScale = 0.8;										gameOverButtonTwitter.yScale = 0.8;
		gameOverButtonTwitter.anchorX = 0.5;									gameOverButtonTwitter.x = centerX - 80;
		gameOverButtonTwitter.anchorY = 0.5;									gameOverButtonTwitter.y = centerY + 120;
		gameOverButtonTwitter.myLabel = "twitter"

		gameOverButtonMenu:addEventListener("touch", gameButtonPressIndex)
		gameOverButtonReplay:addEventListener("touch", gameButtonPressIndex)
		gameOverButtonTwitter:addEventListener("touch", gameButtonPressIndex)
	end

	function gameButtonPressIndex(event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.alpha = 0.7

		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1

				--Check bounds. If we are in it then click!
				local b = t.contentBounds

				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
					if t.myLabel == "menu" then
						hideAdMobAd()
						if soundAllowed then playSound("bark") end
						storyboard.gotoScene("menu", "crossFade", 500)

					elseif t.myLabel == "twitter" then
						function tw_listener(event)
							if event.phase == "authorised" then
								twitter:post( "I just fed my puppy " .. gameScore .. " times. I don't have a puppy, its a game! #Pickion #Games #Apple #Puppy #Dogs #Addicted https://itunes.apple.com/us/app/id842846370?mt=8" )
							elseif event.phase == "posted" then
								native.showAlert("Twitter", "Thanks for Sharing Your Score.", {"ok"})
							elseif event.phase == "deauthorised" then
								twitter:destroy()
								twitter = nil
							end
						end

						if soundAllowed then playSound("bark") end
						twitter = GGTwitter:new( "s3Qh1MoSpGAya566Ai5nS5EyR", "n7gY5nVP3dqjVIiqqzJ5bQDZuSgJcgYBvA9JGDp2MxSprGzBX7", tw_listener )
						twitter:authorise()

					elseif t.myLabel == "retry" then
						hideAdMobAd()
						if soundAllowed then playSound("bark") end

						-- Removing display objects
						if gameImagePuppyDog		then gameImagePuppyDog:removeSelf()			gameImagePuppyDog = nil 		end

						if gameOverOverlayBox 		then gameOverOverlayBox:removeSelf(); 		gameOverOverlayBox = nil 		end
						if gameOverCryingPuppy		then gameOverCryingPuppy:removeSelf();		gameOverCryingPuppy = nil 		end
						if gameOverCryCoverCircle	then gameOverCryCoverCircle:removeSelf();	gameOverCryCoverCircle = nil 	end
						if gameOverHeaderTitle 		then gameOverHeaderTitle:removeSelf(); 		gameOverHeaderTitle = nil 		end
						if gameOverGameScore 		then gameOverGameScore:removeSelf(); 		gameOverGameScore = nil 		end
						if gameOverShareTwitter 	then gameOverShareTwitter:removeSelf(); 	gameOverShareTwitter = nil 		end
						if gameOverButtonMenu 		then gameOverButtonMenu:removeSelf(); 		gameOverButtonMenu = nil 		end
						if gameOverButtonReplay 	then gameOverButtonReplay:removeSelf(); 	gameOverButtonReplay = nil 		end
						if gameOverButtonTwitter 	then gameOverButtonTwitter:removeSelf(); 	gameOverButtonTwitter = nil 	end

						gameScore = 0
						bgChangeCount = 0
						uiTextScore.text = "Score: " .. gameScore
				
						createReadyInstruction()

						uiDecorInstructionsBox:addEventListener("touch", gameButtonPressIndex)

					elseif t.myLabel == "startGame" then
						hideAdMobAd()
						if soundAllowed then playSound("bark") end

						-- Removing display objects
						if uiDecorInstructionsBox 	then uiDecorInstructionsBox:removeSelf();	uiDecorInstructionsBox = nil	end
						if uiImageInstruction 		then uiImageInstruction:removeSelf();		uiImageInstruction = nil		end

						isGameActive = true
						gameImagePuppyDog:play()
						uiTextScore.isVisible = true;

						-- Call the timers
						uiOverlayForDrag:addEventListener("touch", slideTheDog)
						treatDropTimer = timer.performWithDelay(treatDropInterval, spawnNewTreat, -1)
						Runtime:addEventListener("enterFrame", gameLoop)
					end
					print(t.myLabel, " has been pressed")
				end
			end
		end
		return true
	end

showAdMobbAdInt()
createStageSetting()
createReadyInstruction()
uiDecorInstructionsBox:addEventListener("touch", gameButtonPressIndex)
end

-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
	if treatDropTimer ~= nil then timer.cancel(treatDropTimer) end
end

--Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
end

-----------------------------------------------	
-- Add the story board event listeners
-----------------------------------------------
scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene