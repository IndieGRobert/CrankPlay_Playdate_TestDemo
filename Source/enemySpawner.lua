import "Enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

local spawnTimer
local maxEnemyNum = 10
local enemyNumber = 0
local enemies = table.create(10,0)

function startSpawner()
	math.randomseed(pd.getSecondsSinceEpoch())
	createTimer()
	-- printTable(pd.timer.allTimers())
end

function createTimer()
	local spawnTime = math.random(500,1000)

	spawnTimer = pd.timer.performAfterDelay(spawnTime,function()
		createTimer()
		onEnemyNumber()
		if enemyNumber < 10 then
			spawnEnemy()
		end
	end)
end

function spawnEnemy()
	-- print(">>>>>>>>>>>>>",enemyNumber)
	-- if enemyNumber == 10 then return end

	local spawnX = math.random(10,390)	
	local spawnY = math.random(10,230)
	local moveSpeedX = math.random(-1,1)
	local moveSpeedY = math.random(-1,1)
	table.insert(enemies, Enemy(spawnX,spawnY,moveSpeedX/2,moveSpeedY/2))
	print('onEnemyTableNumber>>',table.getsize(enemies))
end

function stopSpawner()
	if spawnTimer then
		spawnTimer:remove()
		isFirstTimeSpawn = false
	end
end

function clearEnemies()
	local allSprites = gfx.sprite.getAllSprites()
	for index, sprite in ipairs(allSprites) do
		if sprite:isa(Enemy) then
			sprite:remove()
			table.remove(enemies)
		end
	end
end

function onEnemyNumber()
	local count = 0
	local allSprites = gfx.sprite.getAllSprites()
	-- printTable(allSprites)
	for index, sprite in ipairs(allSprites) do
		if sprite:isa(Enemy) then
			count = count + 1
		end
	end
	enemyNumber = count
	print(">>>>>>>>>>>>>",enemyNumber)
end

function isRespawn()
	if enemyNumber == 10 then
		stopSpawner()
		-- clearEnemies()
	elseif enemyNumber == 0 then
		startSpawner()
	end
end