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
	self:setZIndex(10)
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
	self.scaleStep = -0.02

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
