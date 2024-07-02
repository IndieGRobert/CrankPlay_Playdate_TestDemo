import "CoreLibs/sprites"

local pd<const> = playdate
local gfx<const> = pd.graphics

class('Particle').extends(gfx.sprite)

local spawnParticleTimer
local boostSize = 8
local particleNum = 0
local particles = {}

function Particle:init(x,y,angle,speed,lifetime)
	Particle.super.init(self)

	self:reset(x,y,angle,speed,lifetime)
	--粒子的图片形式
	local boostImage = gfx.image.new(boostSize * 2, boostSize * 2)
	gfx.pushContext(boostImage)
		gfx.setColor(gfx.kColorWhite)
		-- gfx.fillRect( 0,0,boostSize,boostSize )
		gfx.fillCircleAtPoint( boostSize,boostSize,boostSize )
	gfx.popContext()
	self:setImage(boostImage)
	self:moveTo(x, y)
	self:setZIndex(5)
	self:add()

end

function Particle:reset(x,y,angle,speed,lifetime)
	self.x = x
	self.y = y
	self.angle = angle
	self.speed = speed
	self.lifetime = lifetime
	self.age = 0
	self:setVisible(true)

	--scale的相关数值
	self.scale = 1.0
	self.scaleStep = -0.04

end

function Particle:update()

	self.age += 1
	if self.age > self.lifetime then
		-- self:remove()
		self:setVisible(false)
		-- print("Particle_Remove")
		return
	end

	self.x += math.sin(self.angle)*self.speed
	self.y -= math.cos(self.angle)*self.speed
	self:moveTo(self.x,self.y)

	-- 每一帧缩小一点点
	self.scale = math.max( 0, self.scale + self.scaleStep )
	self:setScale(self.scale)
end

function Particle:isRemoved()
	return not self:isVisible()
end

------------ParticlePool-------------------------------

class('ParticlePool').extends()

function ParticlePool:init(size)
	self.pool = {}
	for i = 1,size do
		table.insert(self.pool, Particle(0,0,0,0,0)) --初始化粒子
	end
end

function ParticlePool:getParticle()
	for i = 1, #self.pool do
		local particle = self.pool[i]
		if particle:isRemoved() then
			return particle
		end
	end
	return nil
end

function ParticlePool:resetParticle(particle,x,y,angle,speed,lifetime)
	if particle then
		particle:reset(x,y,angle,speed,lifetime)
	end
end

-----------ripple effect------------------------------------

class('rippleAttack').extends(gfx.sprite)

local initialRippleSize = 2
local rippleMaxSize = 200
local updateInterval = 3 -- 每3帧更新一次 Interval间隔

function rippleAttack:init(x,y,lifetime)
	rippleAttack.super.init(self)

	self:reset(x,y,lifetime)
	self:setZIndex(5)
	self:add()

end

function rippleAttack:reset(x,y,lifetime)

	self.x = x
	self.y = y
	self.lifetime = lifetime
	self.age = 0
	self:setVisible(true)

	self.rippleSize = initialRippleSize
	self.scaleStep = 10
	self.updateCounter = 0 --帧数计数器

	self:createRippleImage()
	self:setImage( self.rippleImage )
	self:moveTo(x, y)

end

function rippleAttack:createRippleImage()
	self.rippleImage = gfx.image.new( rippleMaxSize * 2, rippleMaxSize * 2 )
	gfx.pushContext(self.rippleImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillCircleAtPoint( rippleMaxSize, rippleMaxSize, self.rippleSize )
	gfx.popContext()

	-- self:createRippleMask()
	-- self.rippleImage:addMask(self.rippleMask)
end

function  rippleAttack:createRippleMask()
	self.rippleMask = gfx.image.new( rippleMaxSize * 2, rippleMaxSize * 2 )

	-- Drawing into mask with dither effect
	gfx.pushContext(self.rippleMask)
	 	gfx.setColor(gfx.kColorWhite)
	 	gfx.fillRect(0, 0, rippleMaxSize * 2, rippleMaxSize * 2)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillCircleAtPoint(rippleMaxSize, rippleMaxSize, self.rippleSize)
    gfx.popContext()

	-- -- Copying the original mask to preserve transparent regions around the circle
	-- self.holeMask = self.rippleMask:copy()
	-- -- Drawing a hole into mask
	-- gfx.pushContext(self.holeMask)
	--     gfx.setColor(gfx.kColorBlack)
	--     local width, height = self.holeMask:getSize()
	--     gfx.fillCircleAtPoint(width/2, height/2, width/4)
	-- gfx.popContext()

end

function rippleAttack:update()

	self.age += 1

	if self.rippleSize > rippleMaxSize or self.age > self.lifetime then
		self:remove()
		return
	end

	self.updateCounter += 1 
	if self.updateCounter >= updateInterval then --隔帧更新的判断
		self.updateCounter = 0

		self.rippleSize = self.rippleSize + self.scaleStep
		-- self.holeMaskSize = self.rippleSize/4 + self.scaleStep
		-- print(self.rippleSize,self.holeMaskSize)

		-- gfx.pushContext(self.holeMask)
		-- 	gfx.setColor(gfx.kColorBlack)
		-- 	local width, height = self.holeMask:getSize()
		-- 	gfx.fillCircleAtPoint( width/2, height/2, self.holeMaskSize)
		-- gfx.popContext()

		-- self.rippleImage:setMaskImage(self.holeMask)
		-- self.rippleImage:draw(rippleMaxSize,rippleMaxSize)

		-- gfx.pushContext(self.ditherMask)

		-- 	gfx.setColor(gfx.kColorWhite)
		-- 	gfx.setDitherPattern(0.6, gfx.image.kDitherTypeBayer8x8)
		-- 	gfx.fillCircleAtPoint( rippleMaxSize, rippleMaxSize, self.rippleSize)

		-- gfx.popContext()

		-- self.rippleImage:setMaskImage(self.ditherMask)
		-- self.rippleImage:draw(rippleMaxSize,rippleMaxSize)

        self.rippleImage = gfx.image.new(rippleMaxSize * 2, rippleMaxSize * 2)

		gfx.pushContext(self.rippleImage)
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.6, gfx.image.kDitherTypeBayer8x8)
			gfx.fillCircleAtPoint( rippleMaxSize, rippleMaxSize, self.rippleSize )
		gfx.popContext()

		self:createRippleMask()

		-- self.rippleImage:addMask(self.rippleMask)

		self:setImage(self.rippleImage)
	end
	-- 每一帧放大一点点
	-- self.scale = math.max( 0, self.scale + self.scaleStep )
	-- self:setScale(self.scale)

end

