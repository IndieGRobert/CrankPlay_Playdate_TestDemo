import "bullet"
import "Particle"
import "CoreLibs/graphics"
import "CoreLibs/crank"
import "scoreDisplay"

local pd<const> = playdate
local gfx<const> = pd.graphics

class('player').extends(gfx.sprite)

local playerX, playerY = 200, 120

local Normal, Left, Right = 1, 2, 3
local flyImageIndex = 1
local ticksPerRevolution = 2

playerStates = {"left","right","normal"}
shipState = playerStates[current]
-- playerSpeed = 1
-- bulletSpeed = 5

local maxSpeed = 3
local minSpeed = 0.5 --初始速度
local acceleration = 0.03
local deceleration = 0.03
local accelerationRate = 0.01
local maxAcceleration = 0.5

local maxParticles = 10


function player:init(x,y,width,hight) --初始化player
	-- player.super.init(self)
	self.playerIcon = gfx.imagetable.new( "Sprites/player")
	assert(self.playerIcon,"Player icon not loaded")  -- 确保 playerIcon 已正确加载

	self:setImage(self.playerIcon:getImage(1))
	self:setCollideRect(8,8,12,12)--动态更新的物理
	self:moveTo(x,y) 
	self:add()

	--Trail拖尾打点初始化

	-- self.trailSprites = {} -- 拖尾点的集合table
	-- self.trailLength = 10 --拖尾的长度
	-- self.trailOpacityStep = 1/self.trailLength -- 拖尾部分的透明度进度？

	-- for i = 1, self.trailLength do
	-- 	local trailSprite = gfx.sprite.new()
	-- 	trailSprite:setSize(6,6)
	-- 	trailSprite:moveTo(-10,-10)
	-- 	trailSprite:setZIndex(0)
	-- 	trailSprite:add()
	-- 	table.insert(self.trailSprites,trailSprite)--在表中添加新的粒子
	-- end

	--加速的喷射动画子sprite
	local anim01 = gfx.image.new("Sprites/jet01")
	assert(anim01,"Jet01 image not loaded")

	-- local anim02 = gfx.image.new("Sprites/jet02")

	-- local bw,bh = anim01:getSize()

	self.boostSprite = gfx.sprite.new(anim01)
	self.boostSprite:setCenter(0.5,-0.5) -- 将火焰的中心点定在飞行器的中心。
	self.boostSprite:add()
	self.boostSprite:setVisible(false)

	-- self.boostFire = { gfx.sprite.new(anim01), 
	-- 				   gfx.sprite.new(anim02) }

	-- self.boostFire[1]:addSprite()
	-- self.boostFire[2]:addSprite()

	-- self.boostFire[1]:setVisible(false)
	-- self.boostFire[2]:setVisible(false)

	-- self.boostFrame = 1

	self.boosting = 0
	self.crankAngle = 0
	self.hitTimer = nil

	self.isAcc = false
	self.currentSpeed = minSpeed
	self.currentAcc = 0

	self.updateCount = 0

	self.particlePool = ParticlePool(maxParticles) --创建粒子池实例
	self.particles = {}

	return self
end

function player:update()
	local x,y,collisions, length = self:moveWithCollisions(self.x, self.y)

	if length > 0 then
		for index, collision in ipairs(collisions) do
			local collideObject = collision.other
			if collideObject:isa(Enemy) then
				collideObject:remove()
				setShakeAmount(6)
				lostEnergy()
				-- self:remove()
				incrementScore()
			end
		end
	end

	self.crankAngle = math.rad(pd.getCrankPosition())
	self:updateImage()

	--加速度逻辑

	if self.isAcc then
		if self.currentSpeed < maxSpeed then
			self.currentAcc = math.min(self.currentAcc + accelerationRate, maxAcceleration)
			self.currentSpeed = math.min(self.currentSpeed + self.currentAcc, maxSpeed)
			-- print(self.currentSpeed)
		end
	elseif self.isAcc == false then
		if self.currentSpeed > minSpeed then
            self.currentAcc = math.max(self.currentAcc - deceleration, 0)
            self.currentSpeed = math.max(self.currentSpeed - deceleration, minSpeed)
			-- print("deceleration",self.currentSpeed)
        end
	end

	if self.boosting == 1 then
		self.updateCount = self.updateCount + 1 --帧数计算器
		if self.updateCount % 4 == 0 then
			self:updateParticles()
		end
		-- print("updatingBoostImage")
		-- self:createParticle()
		-- self.boostSprite:setVisible(false)
	end

	if hp == 0 then
		self.boostSprite:remove()
	end

	self:updatePlayerPosition()--更新主角的位置

end

-- function player:updateTrail()

-- 	print("update Trail?")
-- 	--添加当前帧的位置到拖尾
-- 	for i = #self.trailSprites, 2, -1 do
-- 		local current = self.trailSprites[i]
-- 		local previous = self.trailSprites[ i - 1 ]
-- 		current:moveTo(previous.x, previous.y)
-- 		print(previous.x,previous.y)
-- 		current:setVisible(previous:isVisible())
-- 		current:setImage(self:createTrailImage(i*self.trailOpacityStep))
-- 	end

-- 	self.trailSprites[1]:moveTo(self.x, self.y)
-- 	self.trailSprites[1]:setVisible(true)
-- 	self.trailSprites[1]:setImage(self:createTrailImage(self.trailOpacityStep))


-- end

-- function player:createTrailImage(opacity)
-- 	local trailImage = gfx.image.new(6,6)
-- 	gfx.pushContext(trailImage)
-- 		gfx.setColor(gfx.kColorWhite)
-- 		gfx.setDitherPattern(opacity)
-- 		gfx.fillCircleAtPoint(3, 3, 3)
-- 	gfx.popContext()
-- 	return trialImage
-- end

function player:startThrust()
	self.isAcc = true
	self:startParticleSpawn()
	-- self.boostSprite:setVisible(true)--拖尾的动画图
	self.boosting = 1
end

function player:stopThrust()
	self.isAcc = false
	self:stopParticleSpawn()
	-- self.boostSprite:setVisible(false)
	self.boosting = 0
end

function player:getGunPosition()

	assert(self, "Player sprite is not initialized")
	local dx,dy = self:getPosition()

	 -- 计算射击的位置，假设机头在sprite中心前方10个单位
	local offset = 20
	local gunX = dx + math.sin(self.crankAngle) * offset
	local gunY = dy - math.cos(self.crankAngle) * offset
	-- print(gunX,gunY)
	return gunX, gunY
end

function player:getBoostPosition()
	assert(self, "Player sprite is not initialized")
	local bx,by = self:getPosition()

	local offset = 20
	local boostX = bx + math.sin(self.crankAngle) * -offset
	local boostY = by - math.cos(self.crankAngle) * -offset

	return boostX, boostY
end


--------------------particles related---------------------

function player:startParticleSpawn()
	self:stopParticleSpawn()
	self:onParticleNumber()
	local spawnTime = math.randomseed(0,20) --粒子的生成间隔

	self.particleTimer = pd.timer.keyRepeatTimerWithDelay(0,spawnTime,function()
		if #self.particles < maxParticles then
			self:createParticle()--调用 CreateParticle
		end
	end)
end

function player:stopParticleSpawn()
	--停止粒子的释放
	if self.particleTimer then
		self.particleTimer:remove()
		self.particleTimer = nil
		-- self:removeAllParticles()--停止喷射之后的粒子全清，换用池之后不清除，复用所有粒子。
	end
end

function player:createParticle()
	--创造粒子
	local x,y = self:getBoostPosition()
	local angle = self.crankAngle + math.pi -- 粒子在角色后面释放
	local speed = 0.5
	local lifetime = 40
	local particle = self.particlePool:getParticle()
	print( "CalcuParticles",self.particlePool )
	if particle then
		self.particlePool:resetParticle(particle,x,y,angle,speed,lifetime)
		table.insert(self.particles, particle)
	end
end

function player:updateParticles()
	for i = #self.particles, 1, -1 do
		local particle = self.particles[i]
		particle:update()
		if particle:isRemoved() then
			table.remove( self.particles, i )
		end
	end
end

function player:onParticleNumber()
	local count = 0
	local allSprites = gfx.sprite.getAllSprites()

	for index, sprite in ipairs(allSprites) do
		if sprite:isa(Particle) then
			count = count + 1
		end
	end
	self.particleNum = count
	print(">>>>>>particleNum", #self.particles )
	return self.particleNum
end

function player:removeAllParticles()
	local count = 0
	local allSprites = gfx.sprite.getAllSprites()

	for index, sprite in ipairs(allSprites) do
		if sprite:isa(Particle) then
			sprite:remove()
		end
	end
end

-- function player:removeAllParticles()
--     for i = #self.particles, 1, -1 do
--         local particle = self.particles[i]
--         particle:remove()
--         table.remove(self.particles, i)
--     end
-- end

function player:updatePlayerPosition()

	local pw,ph = self:getSize()

	self.x += math.sin(self.crankAngle) * self.currentSpeed
	self.y -= math.cos(self.crankAngle) * self.currentSpeed 

	if self.x < 2 - pw/2 then
		self.x = 398 + pw/2
	elseif self.x > 398 + pw/2 then
		self.x = 2 - pw/2
	end

	if self.y < 1 - ph/2 then
		self.y = 238 - 20 + ph/2 -- cut the UI part
	elseif self.y > 238 - 20 + ph/2 then
		self.y = 1 - ph/2
	end

	self:moveTo(self.x, self.y)
	self:setCollideRect(8,8,pw/2,ph/2)--动态更新的物理
	self:setRotation(pd.getCrankPosition())

	-- --喷射器的sprite位置更新
	self.boostSprite:moveTo(self.x, self.y)
	self.boostSprite:setRotation(pd.getCrankPosition())
end

function player:onDamage()
	-- If already flashing, restart the flash
	if self.hitTimer then
		self.hitTimer:remove()
	end

	local flashCount = 0
	self.hitTimer = pd.timer.new(200,function()--计时器0.1s?
		flashCount += 1
		self:setVisible(flashCount % 2 == 0)
		if flashCount >= 10 then
			self:setVisible(true)
			self.hitTimer:remove()
			self.hitTimer = nil
		end
	end)
end

function player:resetPlayerState()
	self.currentSpeed = minSpeed
	self.currentAcceleration = 0
	bulletSpeed = 5
end

function player:updateImage()
	-- print("playerIcon",current)
	--左右专项image变化的控制。

	if current == 'right' then
        self:setImage(self.playerIcon:getImage(3))
	elseif current == 'left' then
        self:setImage(self.playerIcon:getImage(2))
	elseif current == 'normal' then
        self:setImage(self.playerIcon:getImage(1))		
	end
	---last try -------
	-- local crankTicks = playdate.getCrankTicks(ticksPerRevolution)
	-- local change, acceleratedChange = playdate.getCrankChange()

	-- if pd.isCrankDocked() then
    --     self:setImage(self.playerIcon:getImage(1))
    -- end

    -- if crankTicks == 1 then
    -- 	if acceleratedChange > 0.3 then
	--         self:setImage(self.playerIcon:getImage(3))
	--     else
	--     	self:setImage(self.playerIcon:getImage(1))
	--     end
    --     print("Forward tick",crankTicks,change,acceleratedChange)
    -- elseif crankTicks == -1 then
    --     if acceleratedChange < -0.3 then
	--         self:setImage(self.playerIcon:getImage(2))
	--     else
	--     	self:setImage(self.playerIcon:getImage(1))
	--     end
    --     print("Backward tick",crankTicks,change,acceleratedChange)
    -- elseif crankTicks == 0 then

    -- end
    ---------prev try-------------
	-- local crankPosition = pd.getCrankPosition()
	-- local crankChange = crankPosition - self.prevCrank
	-- print(">>>>>>>>>",crankChange)

	-- -- if not playdate.cranked() then return end

	-- if crankChange > 0 then
	-- 	print(">>>>>>>>",right)
	-- 	self:setImage(self.playerIcon:getImage(3))
	-- 	--turnright--
	-- elseif crankChange < 0 then
	-- 	print(">>>>>>>>",left)
	-- 	self:setImage(self.playerIcon:getImage(2))
	-- 	--turnleft--
	-- end
	-- self.prevCrank = crankPosition
end

function playdate.cranked(change, acceleratedChange)
	-- local state = playerStates[current]
	-- print(">>>>>>>>",change,acceleratedChange) --Negative values are anti-clockwise.
	-- local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

	-- if state == nil then
	-- 	if change 

	if acceleratedChange > 0.3 then
		current = "right"
        -- player:setImage(player.playerIcon:getImage(3))
        -- print("Forward tick",crankTicks,change,acceleratedChange)

    elseif acceleratedChange < -0.3 then
		current = "left"

        -- player:setImage(player.playerIcon:getImage(2))
        -- print("Backward tick",crankTicks,change,acceleratedChange)
    else
    	current = 'normal'
    	-- player:setImage(player.playerIcon:getImage(1))

    end
end

function player:collisionResponse()
	return "playerOverlap"
end
