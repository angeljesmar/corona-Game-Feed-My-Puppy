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

local worldGravity = 20

local physics = require ("physics")	-- Require physics
physics.start()
physics.setGravity(0, worldGravity)
physics.setDrawMode("normal") --normal or hybrid

-----------------------------------------------
--*** Set up our variables and group ***
-----------------------------------------------
-- Variables
local _W = display.contentWidth
local _H = display.contentHeight
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

local treatDropInterval = 250

local colorBackgroundWall =			{R = 170/255, G = 222/255, B = 135/255, A = 255/255}

-- Display Groups
local groupGameObjects
local groupUI
local groupTreatsBone

-- Functions
local menuTreatTimer
local dropTreat
local playTappedMedium
local facebookShare
local rateUsApple

local treatBone = {}

-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
	local mainMenuGroup = self.view

	groupGameObjects = display.newGroup();										mainMenuGroup:insert(groupGameObjects)
	groupTreatsBone = display.newGroup();										mainMenuGroup:insert(groupTreatsBone)
	groupUI = display.newGroup();												mainMenuGroup:insert(groupUI)

	menuDecorBackground = display.newRect(0, 0, 380, 570)
	menuDecorBackground:setFillColor(colorBackgroundWall.R, colorBackgroundWall.G, colorBackgroundWall.B, colorBackgroundWall.A)
	menuDecorBackground.x = centerX
	menuDecorBackground.y = centerY

	menuDecorWindowFrame = display.newImageRect("images/decor/window.png", 173, 243)
	menuDecorWindowFrame.anchorX = 0.5;											menuDecorWindowFrame.x = mRand((menuDecorWindowFrame.width * 0.5), _W - (menuDecorWindowFrame.width * 0.5));
	menuDecorWindowFrame.anchorY = 1;											menuDecorWindowFrame.y = centerY;

	menuDecorWallSocket = display.newImageRect("images/decor/wallOutlet.png", 22, 32)
	menuDecorWallSocket.x = mRand(menuDecorWallSocket.width * 0.5, _W - (menuDecorWallSocket.width * 0.5))
	menuDecorWallSocket.y = mRand(centerY + 60, centerY + 140)

	menuDecorMainPuppy = display.newImageRect("images/decor/menuPuppy.png", 160, 186)
	menuDecorMainPuppy.x = centerX - (menuDecorMainPuppy.contentWidth * 0.40)
	menuDecorMainPuppy.y = _H - menuDecorMainPuppy.height * 0.75

	menuButtonPlayEasy = display.newImageRect("images/button/buttonEasy.png", 120, 50)
	menuButtonPlayEasy.x = centerX + (menuButtonPlayEasy.contentWidth * 0.75)
	menuButtonPlayEasy.y = centerY - 20
	menuButtonPlayEasy.mySetting = "Easy"
	menuButtonPlayEasy.myLabel = "startButton"

	menuButtonPlayMedium = display.newImageRect("images/button/buttonMedium.png", 120, 50)
	menuButtonPlayMedium.x = centerX + (menuButtonPlayMedium.contentWidth * 0.75)
	menuButtonPlayMedium.y = menuButtonPlayEasy.y + (menuButtonPlayMedium.contentHeight + 5)
	menuButtonPlayMedium.mySetting = "Normal"
	menuButtonPlayMedium.myLabel = "startButton"

	menuButtonPlayHard = display.newImageRect("images/button/buttonHard.png", 120, 50)
	menuButtonPlayHard.x = centerX + (menuButtonPlayHard.contentWidth * 0.75)
	menuButtonPlayHard.y = menuButtonPlayMedium.y + (menuButtonPlayHard.contentHeight + 5)
	menuButtonPlayHard.mySetting = "Hard"
	menuButtonPlayHard.myLabel = "startButton"

	menuButtonPlayExtreme = display.newImageRect("images/button/buttonExtreme.png", 120, 50)
	menuButtonPlayExtreme.x = centerX + (menuButtonPlayExtreme.contentWidth * 0.75)
	menuButtonPlayExtreme.y = menuButtonPlayHard.y + (menuButtonPlayExtreme.contentHeight + 5)
	menuButtonPlayExtreme.mySetting = "Extreme"
	menuButtonPlayExtreme.myLabel = "startButton"

	-- Set up the logo
	menuImageLogo = display.newImageRect("images/decor/logo.png", 280, 132)
	menuImageLogo.x = centerX
	menuImageLogo.y = centerY - 200
	menuImageLogo.alpha = 0

	menuButtonFacebook = display.newImageRect("images/button/buttonFacebook.png", 80, 80)
	menuButtonFacebook.xScale = 0.6;											menuButtonFacebook.yScale = 0.6;
	menuButtonFacebook.x = -_W
	menuButtonFacebook.y = _H - 35
	menuButtonFacebook.alpha = 0
	menuButtonFacebook.myLabel = "facebook"

	menuButtonMoreGames = display.newImageRect("images/button/buttonMoreGames.png", 80, 80)
	menuButtonMoreGames.xScale = 0.6;											menuButtonMoreGames.yScale = 0.6;
	menuButtonMoreGames.x = -_W
	menuButtonMoreGames.y = _H - 35
	menuButtonMoreGames.alpha = 0
	menuButtonMoreGames.myLabel = "appstore"

	menuButtonCredits = display.newImageRect("images/button/buttonCredits.png", 80, 80)
	menuButtonCredits.xScale = 0.6;											menuButtonCredits.yScale = 0.6;
	menuButtonCredits.x = -_W
	menuButtonCredits.y = _H - 35
	menuButtonCredits.alpha = 0
	menuButtonCredits.myLabel = "credits"

	-- Create the floor
	menuDecorFloor = display.newImageRect("images/decor/wallAndCarpetDecor.png", 380, 100)
	menuDecorFloor.x = centerX
	menuDecorFloor.anchorY = 1;													menuDecorFloor.y = screenHeight;
	floorShape = {-190,-14, 190,-14, 190,50, -190,50}
	physics.addBody(menuDecorFloor, "static", { density=0.5, bounce=0.5, friction=0.5, shape = floorShape})

	groupGameObjects:insert(menuDecorBackground)
	groupGameObjects:insert(menuDecorWindowFrame)
	groupGameObjects:insert(menuDecorWallSocket)
	groupGameObjects:insert(menuDecorFloor)
	groupGameObjects:insert(menuImageLogo)
	groupUI:insert(menuDecorMainPuppy)
	groupUI:insert(menuButtonPlayEasy)
	groupUI:insert(menuButtonPlayMedium)
	groupUI:insert(menuButtonPlayHard)
	groupUI:insert(menuButtonPlayExtreme)
	groupUI:insert(menuButtonFacebook)
	groupUI:insert(menuButtonMoreGames)
	groupUI:insert(menuButtonCredits)
end

-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
	-- Completely remove the previous scene/all scenes.
    -- Handy in this case where we want to keep everything simple.
    storyboard.removeAll()

	function destroyGameObjects()
		for i = groupTreatsBone.numChildren, 1, -1 do
			local treatObjects = groupTreatsBone[i]
			if treatObjects ~= nil then
				treatObjects:removeSelf()
				treatObjects = nil
			end
		end
	end

	function menuButtonIndex(event)
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
					if t.myLabel == "startButton" then
						hideAdMobAd()
						if soundAllowed then playSound("bark") end
						timer.cancel(menuTreatDropTimer)
						destroyGameObjects()
						gameData.gameDifficulty = t.mySetting
						storyboard.gotoScene("game", "crossFade", 500)

					elseif t.myLabel == "credits" then
						hideAdMobAd()
						if soundAllowed then playSound("bark") end
						timer.cancel(menuTreatDropTimer)
						destroyGameObjects()
						gameData.gameDifficulty = t.mySetting
						storyboard.gotoScene("infoCredit", "crossFade", 500)

					elseif t.myLabel == "facebook" then
						if soundAllowed then playSound("bark") end
						system.openURL( "https://www.facebook.com/pages/Pickion-Games/497675963658121" )

					elseif t.myLabel == "appstore" then
						if soundAllowed then playSound("bark") end
						system.openURL( "https://itunes.apple.com/us/artist/id836188014" )

					end
					print(t.myLabel, " has been pressed")
					print(gameData.gameDifficulty)
				end
			end
		end
		return true
	end

	function spawnTreatsDrop()
		local i

		for i = 1, 2 do
			local boneTreatColor = mRand(1, 8)

			treatBone[i] = display.newImageRect("images/bones/bone0" .. boneTreatColor .. ".png", 15, 30)
			treatBone[i].x = mRand(80, 240)
			treatBone[i].y = 0;
			treatBone[i].isHit = false;
			treatBone[i].isFixedRotation = false;
			treatBone[i].rotation = mRand(-90, 90)
			physics.addBody(treatBone[i], "dynamic", {density = 0.5, bounce = 0.5, friction = 0.5})
			groupTreatsBone:insert(treatBone[i])
		end
	end

	local menuTreatTimer = function(event)
		menuTreatDropTimer = timer.performWithDelay(treatDropInterval, spawnTreatsDrop, 15 )
	end

	-- Transition in the logo
	transition.to(menuImageLogo, {y=menuButtonPlayEasy.y - 110, alpha = 1, time = 400, delay = 100})
	transition.to(menuButtonFacebook, {x = menuDecorMainPuppy.x - 50, alpha = 1, time = 400, delay = 100})
	transition.to(menuButtonMoreGames, {x = menuDecorMainPuppy.x + 10, alpha = 1, time = 400, delay = 100})
	transition.to(menuButtonCredits, {x = menuDecorMainPuppy.x + 70, alpha = 1, time = 400, delay = 100})

	showAdMobbAd(0)
	menuTreatTimer()
	
	if musicAllowed then playSound("music") end

	-- Add the event listeners
	menuButtonPlayEasy:addEventListener("touch", menuButtonIndex)
	menuButtonPlayMedium:addEventListener("touch", menuButtonIndex)
	menuButtonPlayHard:addEventListener("touch", menuButtonIndex)
	menuButtonPlayExtreme:addEventListener("touch", menuButtonIndex)
	menuButtonFacebook:addEventListener("touch", menuButtonIndex)
	menuButtonMoreGames:addEventListener("touch", menuButtonIndex)
	menuButtonCredits:addEventListener("touch", menuButtonIndex)
end

-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
	menuButtonPlayEasy:removeEventListener("touch", menuButtonIndex)
	menuButtonPlayMedium:removeEventListener("touch", menuButtonIndex)
	menuButtonPlayHard:removeEventListener("touch", menuButtonIndex)
	menuButtonPlayExtreme:removeEventListener("touch", menuButtonIndex)
	menuButtonFacebook:removeEventListener("touch", menuButtonIndex)
	menuButtonMoreGames:removeEventListener("touch", menuButtonIndex)
	menuButtonCredits:removeEventListener("touch", menuButtonIndex)
end

--Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	--
end

-----------------------------------------------
-- Add the story board event listeners
-----------------------------------------------
scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene
