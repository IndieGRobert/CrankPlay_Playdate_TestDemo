
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Enemy').extends(gfx.sprite)

function Enemy:init(x,y,moveSpeedx,moveSpeedy,angle)
	local ballEnemy = gfx.image.new('Sprites/Enemy')
	self:setImage(ballEnemy)
	self:setZIndex(300)
	self:moveTo(x,y)
	self:add()

	self:setCollideRect(0,0,self:getSize())

	self.moveSpeedx = moveSpeedx
	self.moveSpeedy = moveSpeedy
	self.x, self.y = enemyX,enemyY
	self.enemyAngle = angle
	self.rotateSpeed = 1
end

function Enemy:update()
	local x,y = self:getPosition()
	local Ew,Eh = self:getSize()
	local enemyAngle = self:getRotation()
	-- print()
	self:moveWithCollisions(self.moveSpeedx, self.moveSpeedy)

	if x < 2 - Ew/2 then
		x = 398 + Ew/2
	elseif x > 398 + Ew/2 then
		x = 2 - Ew/2
	end

	if y < 1 - Eh/2 then
		y = 238 - 20 + Eh/2
	elseif y > 238 - 20 + Eh/2 then -- cut the UI part
		y = 1 - Eh/2
	end

	self:moveTo(x+self.moveSpeedx,y+self.moveSpeedy)
	self:setRotation( enemyAngle + 1)
	-- print("<>>>>>>>>>>>>",x,y)
end

function Enemy:collisionResponse()
	return "overlap"
end