import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

-- import "visualControl"
import "player"
import "bullet"
import "Particle"
-- import "BallBounce"
import "enemySpawner"
import "scoreDisplay"
import "screenShaker"

-- sound manager--
import "audioManager"

local gfx = playdate.graphics

local screenShakeSprite = ScreenShake()
local bullets = {} -- bullet's table
local particles = {} -- particles' table

--White
local refreshRate = 50
local elapsedTime = 0

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

local buttonDown = false

playdate.display.setRefreshRate( refreshRate )

-- game states

local kGameState = {menu, ready, playing, over, rank, credit} -- menu, game, rank, credit
local currentState = kGameState.menu

local kGameMenuState, kGameReadyState, kGamePlayingState, kGameOverState,kGameRankState,kGameCreditState = 0,1,2,3,4,5,6
local gameState = kGameMenuState

--! set up sprites

local titleSprite = gfx.sprite.new()
local gameTitle = gfx.image.new('UI/GameTitle')
assert(gameTitle)
titleSprite:setImage(gameTitle)
titleSprite:moveTo(screenWidth / 2, screenHeight / 2)
titleSprite:setZIndex(900)--背景深度，调整图片前后位置用,数值越高越靠前。
titleSprite:addSprite()

local backGroundSprite = gfx.sprite.new()
local skyNight = gfx.image.new("Background/SkyNight")
assert(skyNight)
backGroundSprite:setImage(gfx.image.new("Background/SkyNight"))
backGroundSprite:moveTo(screenWidth / 2, screenHeight / 2)
backGroundSprite:setZIndex(0)
backGroundSprite:addSprite()
backGroundSprite:setVisible(false)

local function gameOver()

	gameState = kGameOverState

	clearScreen()

	finalScore()

	titleSprite:setImage(gfx.image.new('UI/gameOver'))
	titleSprite:setVisible(true)

end

local function setUpGame()
	playerInstance = player(200,120) -- initial_player's position
end

local function startGame()
	assert(playerInstance, "Player instance not created!")
	isDay = true
	isDocked = nil

	gameState = kGamePlayingState

	createScoreDisplay()--已经包含了初始化分数血量的指令

	startSpawner() -- spawn enemy

	titleSprite:setVisible(false)

	backGroundSprite:setVisible(true)

	-- another way to put the background image on the back
	-- local backGroundImage = gfx.image.new("Background/SkyNight")
	-- assert( backGroundImage )

	-- gfx.sprite.setBackgroundDrawingCallback(
	-- 	function( x,y,width,height )
	-- 		backGroundImage:draw(0,0)
	-- 	end
	-- )
end

function clearScreen()
	gfx.clear(gfx.kColorBlack)

	removeScoreDisplay()
	playerInstance:remove()
    clearEnemies()
    stopSpawner()

	titleSprite:setVisible(false)
	backGroundSprite:setVisible(false)

end

function showMainMenu()
	gfx.clear(gfx.kColorBlack)

	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	menu:addMenuItem("Start Game", function()
		gameState = "game"
		gameSetUp()
	end)

	menu:addMenuItem("Scoreboard", function()
        gameState = "rank"
        showScoreboard()
    end)

    menu:addMenuItem("Credits", function()
        gameState = "credit"
        showCredits()
    end)

    menu:addMenuItem("Exit", function()
        playdate.exit()
    end)

    gfx.drawText("Main Menu", 150, 50)
    gfx.drawText("Use the menu to select an option", 100, 100)
end

function showScoreboard()
	gfx.clear(gfx.kColorBlack)
	-- Implement the scoreboard display logic here
    gfx.drawText("Scoreboard", 150, 50)
    gfx.drawText("Press B to return to menu", 100, 100)
end

function showCredits()
    gfx.clear(gfx.kColorBlack)
    -- Implement the credits display logic here
    gfx.drawText("Credits", 150, 50)
    gfx.drawText("Press B to return to menu", 100, 100)
end

function setShakeAmount(amount)
	screenShakeSprite:setShakeAmount(amount)
end

-- startGame()

function playdate:update()
	-- machine main update 
	-- this happens ~ 30 times a second
	dt = 1/refreshRate

	if gameState == kGameMenuState then
		gfx.clear(gfx.kColorBlack)

		-- showMainMenu()

		titleSprite:setImage(gfx.image.new('UI/GameTitle'))
		titleSprite:setVisible(true)

    elseif gameState == kGamePlayingState then
    	if hp <= 0 then
			gameOver()
		end
		if playerInstance then
	        playerInstance:update()
	    end
        playdate.timer.updateTimers()
    elseif gameState == kGameRankState then
        showScoreboard()
    elseif gameState == kGameCreditState then
        showCredits()
    end

	-- onEnemyNumber()

	-- drawBackground()

	-- gravityx, gravityy = playdate.readAccelerometer()
	-- print(">>>>>>>>>>>>",gravityx,gravityy)

    gfx.sprite.update()
	playdate.drawFPS(0, 0)
	-- 检查 B 按钮是否被按下并且可以射击
    -- if playdate.buttonJustPressed(playdate.kButtonB) and canShoot then
    --     canShoot = false
    --     local gunX, gunY = playerInstance:getGunPosition()
    --     local bulletSpeed = 5
    --     table.insert(bullets, Bullet(gunX, gunY, bulletSpeed, playerInstance.crankAngle))
    --     print("Shoot bullet")
    -- elseif playdate.buttonJustReleased(playdate.kButtonB) then
    --     canShoot = true
    -- end
end

function resetGame()
	if gameState == kGamePlayingState or gameState == kGameOverState then
		resetScore()
	    clearEnemies()
	    stopSpawner()
	    startSpawner()
	    setShakeAmount(10)
	    playerInstance:resetPlayerState()
	end
end

function switchTime()
	-- print( isDocked )
	if isDay == true then
		drawDayBackground()
		isDay = false
	else 
		drawNightBackground()
		isDay = true
	end
end

function playdate.leftButtonDown()
	if gameState == kGamePlayingState then
		--在键按下去的一瞬间获得方向值
		local gunX, gunY = playerInstance:getGunPosition()
	    local bulletSpeed = 10
	    table.insert(bullets, bullet(gunX, gunY, bulletSpeed, playerInstance.crankAngle))
	end
end

function playdate.leftButtonUp()
end

function playdate.rightButtonDown()
	if gameState == kGamePlayingState then
		gameOver()
	end
	-- switchTime()
end


function playdate.upButtonDown()
	if gameState == kGamePlayingState then

		audioManager:playAudio('dash')

		-- local boostX,boostY = playerInstance:getBoostPosition()

		playerInstance:startThrust()
		-- Particle:startParticleSpawn()
	end
	-- switchTime()
end

function playdate.upButtonUp()
	if gameState == kGamePlayingState then
		playerInstance:stopThrust()
	end
end

function playdate.downButtonDown()
	-- setScreenShake(10)
end

function playdate.BButtonDown()
	-- if gameState == kGamePlayingState then
	-- 	local gunX, gunY = playerInstance:getGunPosition()
	--     local bulletSpeed = 5
	--     table.insert(bullets, bullet(gunX, gunY, bulletSpeed, playerInstance.crankAngle))
	-- end
end

function playdate.AButtonDown()
	if gameState == kGameMenuState or gameState == kGameOverState then

		resetGame()
		setUpGame()
		startGame()

	elseif gameState == kGamePlayingState then

	end
	    -- local function timerCallback()
	    --     print("key repeat timer fired!")
	    -- end
	    -- keyTimer = playdate.timer.keyRepeatTimer(timerCallback)
	-- switchTime()
end

function playdate.AButtonUp()
	if gameState == kGamePlayingState then
		-- keyTimer:remove()
	end
end

-----------add Menu title in system Menu----

local menu = playdate.getSystemMenu()

local menuItem, error = menu:addMenuItem("ResetGame", resetGame)

-- local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("Item 2", true, function(value)
--     print("Checkmark menu item value changed to: ", value)
-- end)