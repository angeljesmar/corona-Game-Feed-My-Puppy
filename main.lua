-----------------------------------------------------------------------------------------
-- ABSTRACT - FEED MY PUPPY
-- CREATED BY PICKION GAMES
-- HTTP://PICKION.COM/

-- VERSION - 1.5
-- 
-- COPYRIGHT (C) 2014 PICKION. ALL RIGHTS RESERVED.
-----------------------------------------------------------------------------------------

-- Initial Settings
display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning

display.setDefault("background", 255/255, 255/255, 255/255)

local storyboard = require( "storyboard" )
storyboard.purgeOnSceneChange = true --So storyboard automatically purges for us.

connection = require("testconnection")
local gameNetwork = require("gameNetwork")
local loadsave = require("loadsave")

math.randomseed( os.time() )
math.random()
math.random()

_G.soundAllowed = true
_G.musicAllowed = true
_G.isAdsAllowed = true

--Our global play sound function.
local sounds = {}
if system.getInfo("platformName") == "Android" then
	sounds["music"] = audio.loadStream("sounds/goDoge.ogg") -- Android runs songs smoothly in ogg format only.
else
	sounds["music"] = audio.loadStream("sounds/goDoge.wav") -- iPhones don't play ogg format so use wav.
end
sounds["bark"] 		= audio.loadSound("sounds/bark.wav")
sounds["crunch"] 	= audio.loadSound("sounds/crunch.wav")
sounds["gameover"] 	= audio.loadSound("sounds/death.wav")
audio.setVolume(0.5, 	{channel = 1})
audio.setVolume(1, 		{channel = 2})
audio.setVolume(1, 		{channel = 3})
audio.setVolume(1, 		{channel = 4})
function playSound(name) --Just pass a name to it. e.g. "select"
	if name == "music" then
		audio.stop(1)
		audio.play(sounds["music"], {channel=1, loops=-1})
	elseif name == "bark" then
		audio.stop(2)
		audio.play(sounds["bark"], {channel=2})
	elseif name == "crunch" then
		audio.stop(3)
		audio.play(sounds["crunch"], {channel=3})
	elseif name == "gameover" then
		audio.stop(4)
		audio.play(sounds["gameover"], {channel=4})
	end
end

-- Set up global variables
if system.getInfo("platformName") == "Android" then
	customFont = "impact"
else
	customFont = "Impact"
end

local AdMob = require("ads")
local adMobListener = function(event) print("ADMOB AD - Event: " .. event.response) end
AdMob.init( "admob", adMobId, adMobListener )

function showAdMobbAd(position)
	if (connection.test()) then
		if isAdsAllowed then
			hideAdMobAd()
			AdMob.show( "banner", {x=0, y=position})
		end
	end
end

function showAdMobbAdInt(event)
	if (connection.test()) then
		if isAdsAllowed then
			hideAdMobAd()
			AdMob.show( "interstitial", {appId=adMobIntId} )
		end
	end
end

function hideAdMobAd( )
	AdMob.hide()
end

function requestCallback( event )
	if event.type == "setHighScore" then
		local function alertCompletion() gameNetwork.request( "loadScores", { leaderboard={ category="LetsHuntDucksHighScore", playerScope="Global", timeScope="AllTime", range={1,25} }, listener=requestCallback } ); end
	end
end

function initCallback( event )
	if event.type == "showSignIn" then
	elseif event.data then
		loggedIntoGC = true
		native.showAlert( "Success!", "", { "OK" } )
	end
end

function offlineAlert() 
	native.showAlert( "GameCenter Offline", "Please Sign In To Submit Your Score.", { "OK" } )
end

function onSystemEvent(event)
	if ( event.type == "applicationStart" ) then
		if system.getInfo("platformName") == "Android" then -- Don't log into game center if it's an Android device
		else
		gameNetwork.init( "gamecenter", { listener=initCallback } )
		print("Game Center Initiated.")
		return true
		end
	end
end

function checkIfDataExists()
	if gameData.gameDifficulty == nil 				then gameData.gameDifficulty = "normal"		else end
	if gameData.gameEasyHighScore == nil 			then gameData.gameEasyHighScore = 0 		else end
	if gameData.gameMediumHighScore == nil 			then gameData.gameMediumHighScore = 0		else end
	if gameData.gameHardHighScore == nil 			then gameData.gameHardHighScore = 0			else end
	if gameData.gameExtremeHighScore == nil 		then gameData.gameExtremeHighScore = 0		else end
end

gameData = loadsave.loadTable("dataFile01.json")

if gameData == nil then
	gameData = {}
	loadsave.saveTable(gameData, "dataFile01.json")
	print("Game Data Nil So Create Game Data.")
else
	print("Game Data Not Nil.")
end

checkIfDataExists()
--Runtime:addEventListener("system", onSystemEvent)

-- Now change scene to go to the menu.
storyboard.gotoScene( "menu", "crossFade", 500 )