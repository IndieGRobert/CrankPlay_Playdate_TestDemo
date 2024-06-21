import "CoreLibs/sprites"

import "player"

local pd<const> = playdate
local gfx<const> = pd.graphics

class('bullet').extends(gfx.sprite)

local bulletSize = 3

function bullet:init( x,y,speed,angle )

	local bulletImage = gfx.image.new(bulletSize * 2, bulletSize * 2)
	gfx.pushContext(bulletImage)
		gfx.setColor(gfx.kColorWhite)
		-- gfx.drawCircleAtPoint( bulletSize,bulletSize,bulletSize)
		gfx.fillCircleAtPoint( bulletSize,bulletSize,bulletSize )
	gfx.popContext()
	self:setImage( bulletImage )

	self:setCollideRect(0,0,self:getSize())
	self.bulletSpeed = speed
	self.bulletAngle = angle
	self:moveTo( x,y )
	self:add()

end


function bullet:update()
	local x,y, collisions, length = self:moveWithCollisions(self.x + math.sin(self.bulletAngle) * self.bulletSpeed, self.y - math.cos(self.bulletAngle) * self.bulletSpeed)

	-- print(">>>>bulletLength",length)
	if length > 0 then
		for index, collision in ipairs(collisions) do
			local collideObject = collision['other']
			if collideObject:isa(Enemy) then
				collideObject:remove()
				self:remove() 
				incrementScore()
				setShakeAmount(1)
			end
		end
	end

	if self.x <= 0 or self.x >= 400 then
		self:remove()
	-- else
	-- 	self.x += math.sin(self.bulletAngle) * self.bulletSpeed
		-- print(math.sin(self.bulletAngle))
	end

	if self.y <= 0 or self.y >= 240 then
		self:remove()
	-- else
	-- 	self.y -= math.cos(self.bulletAngle) * self.bulletSpeed
		-- print(math.cos(self.bulletAngle))
	end

	-- print(">>>>>>>>bullet",self.x,self.y)
end

function bullet:isOffscreen()
    local x, y = self:getPosition()
    return x < 0 or x > 400 or y < 0 or y > 240
end

function bullet:collisionResponse()
	return "playerOverlap"
end