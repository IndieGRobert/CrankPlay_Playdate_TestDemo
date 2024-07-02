local pd <const> = playdate
local gfx <const> = pd.graphics

class('Enemy').extends(gfx.sprite)

function Enemy:init(x,y,moveSpeedx,moveSpeedy,angle)
	self:reset(x,y,moveSpeedx,moveSpeedy,angle)

	--定义类的图片
	local ballEnemy = gfx.image.new('Sprites/Enemy')
	self:setImage(ballEnemy)
	self:setZIndex(5)
	self:moveTo(x,y)
	self:add()

	--定义物理
	self:setCollideRect(0,0,self:getSize())
end

function Enemy:reset(x,y,moveSpeedx,moveSpeedy,angle)
	--敌人的数据的重置。
	print("EnemyGetBackInStageAgain",x,y,moveSpeedx,moveSpeedy,angle)
	self.x = x 
	self.y = y

	self.moveSpeedx = moveSpeedx
	self.moveSpeedy = moveSpeedy
	self.enemyAngle = angle
	self.rotateSpeed = 1

	--激活状况
	self.dead = false
	self.hp = 10
	self:setVisible(true)
	self:moveTo(x,y)

end

function Enemy:update()
	local x,y = self:getPosition()
	local Ew,Eh = self:getSize()
	local enemyAngle = self:getRotation()
	-- self:moveWithCollisions(self.moveSpeedx, self.moveSpeedy)
	local ax,ay,collisions,length = self:moveWithCollisions(self.moveSpeedx, self.moveSpeedy)

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

	-- print("Enemy_Length",length)

	if length > 0 then
		for index, collision in ipairs(collisions) do
			local collideObject = collision['other']
			if collideObject:isa(bullet) or collideObject:isa(player) then
				self:onHit()
				incrementScore()
				if collideObject:isa(player) then
					setShakeAmount(6)
					lostEnergy()
				elseif collideObject:isa(bullet) then
					collideObject:remove()
					setShakeAmount(1)
				end
			end
		end
	end

	self:moveTo(x+self.moveSpeedx,y+self.moveSpeedy)
	self:setRotation( enemyAngle + 1)
end

function Enemy:onHit()
	print("onHit")
	self.hp = self.hp - 10
	if self.hp <= 0 then
		self.dead = true
	end
end

function Enemy:isDead()
	return self.dead
end


function Enemy:collisionResponse()
	return "overlap"
end