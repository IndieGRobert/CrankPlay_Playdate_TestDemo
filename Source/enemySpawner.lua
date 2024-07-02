import "Enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

local spawnTimer
local timerCount = 0
local maxEnemyNum = 10
local enemyNumber = 0

local isWaveStart = false

local enemies = table.create(maxEnemyNum,0)
local enemyPool = {}
-- local enemies = table.create(10,0)

function startSpawner()
	math.randomseed(pd.getSecondsSinceEpoch())
	initializeEnemyPool()
	createTimer()
end

function initializeEnemyPool()
	--在游戏开始预导入预定数量的敌人
	print("initializeEnemyPool")
	for i = 1, maxEnemyNum do
		local enemy = Enemy(240,120,0,0,0)
		enemy:setVisible(false)
		enemy:remove()
		table.insert(enemyPool,enemy)
	end
end

function createTimer()
	--重复敌人数量。
	local spawnTime = math.random(500,1000)
	-- if timerCount >= maxEnemyNum then return end
	spawnTimer = pd.timer.performAfterDelay(spawnTime,function()
		timerCount += 1
		createTimer()
		-- onEnemyNumber()
		if #enemies < maxEnemyNum then
			spawnEnemy()
		end
	end)
end

function onWaveStart()

	isWaveStart = false
end

function spawnEnemy()

	local spawnX = math.random(20,380)	
	local spawnY = math.random(20,220)
	local moveSpeedX = math.random(-1,1)/2
	local moveSpeedY = math.random(-1,1)/2
	local angle = math.random(0,360)

	print("spawnEnemy",#enemies,spawnX,spawnY)

	local enemy = getEnemyFromPool(spawnX,spawnY,moveSpeedX,moveSpeedY,angle)
	enemy:setVisible(true)
	enemy:moveTo(spawnX,spawnY)
	enemy:add()

	table.insert(enemies, enemy)

	-- print('enemyPoolNum',#enemyPool)
	-- print('onEnemyTableNumber>>',table.getsize(enemies))
end

function stopSpawner()
	if spawnTimer then
		spawnTimer:remove()
		isFirstTimeSpawn = false
	end
end

function getEnemyFromPool(x,y,moveSpeedx,moveSpeedy,angle)
	print("get",#enemies,"EnemyFromPool")
	if #enemyPool > 0 then
		local enemy = table.remove(enemyPool)
		enemy:reset(x,y,moveSpeedx,moveSpeedy,angle)
		-- print("getEnemyFromPool>>>>",x,y,moveSpeedx,moveSpeedy,angle)
		return enemy
	else
		return Enemy(x,y,moveSpeedx,moveSpeedy,angle)
	end
end

function releaseEnemyToPool(enemy)
	--Enemy被干掉后移到池中。
	print("No.",#enemies,"EnemyDestoryed","_BackToPool",#enemyPool)
	enemy:setVisible(false)
	enemy:remove()
	table.insert( enemyPool, enemy )
end

function clearEnemies()
	-- local allSprites = gfx.sprite.getAllSprites()
	-- for index, sprite in ipairs(allSprites) do
	-- 	if sprite:isa(Enemy) then
	-- 		sprite:remove()
	-- 		table.remove(enemies)
	-- 	end
	-- end
	for _, enemy in ipairs(enemies) do
		if enemy:isa(Enemy) then
			releaseEnemyToPool(enemy)
		end
	end

	enemies = {}
	enemyNumber = 0
end


function onEnemyNumber()
	local count = 0
    for i = #enemies, 1, -1 do
        if enemies[i]:isDead() then
            releaseEnemyToPool(enemies[i])
            table.remove(enemies, i)
            count -= 1
            print("RemoveNO.",i,"EnemyCount",count)
        else
            count += 1
        end
    end

    if timerCount == 10 and #enemies == 0 then
    	timerCount = 0
    end

    print("EnemyCount",#enemies)
	-- print('onEnemyTableNumber>>',table.getsize(enemies))
	-- print(">>>>>>>>>enemyNum",count)
	-- print('enemyPoolNum',#enemyPool)
end


-- function onEnemyNumber()
-- 	local count = 0
-- 	-- local allSprites = gfx.sprite.getAllSprites()
-- 	-- printTable(allSprites)
-- 	-- for index, sprite in ipairs(allSprites) do
-- 	for _, enemy in ipairs(enemies) do
-- 		if enemy:isa(Enemy) then
-- 			count = count + 1
-- 		end
-- 	end
-- 	enemyNumber = count
-- end

function updateEnemies()
    for i = #enemies, 1, -1 do
    	local enemy = enemies[i]
    	if enemy:isDead() then
    		table.remove(enemies, i)
    		releaseEnemyToPool(enemy)
    	else
	        -- enemy:update()
	    end
    end
end

function respawnEnemy()
	if #enemies < maxEnemyNum then
		startSpawner()
	end
end