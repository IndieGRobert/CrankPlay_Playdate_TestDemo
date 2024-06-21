-- import 'CoreLibs/sprites.lua'
-- import 'CoreLibs/graphics.lua'

local gfx = playdate.graphics
local sfx = playdate.sound

local radius = 20

local gravity = 0.4
local bounce = 0.8

local ball = gfx.sprite.new() -- draw new ball
gravityx, gravityy = 0,0
ball:setSize(2*radius+1, 2*radius+1)
ball:moveTo( 200, 120 )
ball:addSprite()
-- ball:setCollideRect( 0,0, 2*radius+1, 2*radius+1 )

playdate.startAccelerometer()

function hypot(x,y)
	return math.sqrt(x*x+y*y)
end

local dx,dy = math.random(-20,20), math.random(-20,20)


function ball:draw()
	gfx.setColor(gfx.kColorWhite)
	-- gfx.drawCircleAtPoint(radius, radius, radius)
	if ball.collided then
		gfx.fillCircleAtPoint(radius, radius, radius)
		ball.collided = false
	else
		gfx.drawCircleAtPoint(radius, radius, radius)
	end
end

function playdate.update()
	gravityx, gravityy = playdate.readAccelerometer()
	gfx.sprite.update()
end

function ball:update()
	if gravity > 0 then
		dx,dy = dx + gravityx / 4, dy + gravityy / 4
	end

	-- bounce off the walls

	local left = radius
	local right = 400 - radius

	local newx = ball.x + dx
	local newy = ball.y + dy

	if newx < left and dx < 0 then
		-- print(ball:getPosition())
		newx = left
		dx *= -bounce
		ball.collide = true
		audioManager:playAudio('bounce')
	elseif newx > right and dx > 0 then
		-- print(ball:getPosition())
		newx = right
		dx *= -bounce
		ball.collide = true
		audioManager:playAudio('bounce')
	end

	local top = radius
	local bottom = 240 - 20 - radius --去掉了Ui的宽度

	if newy < top and dx < 0 then
		-- print(ball:getPosition())
		newy = top
		dy *= -bounce
		ball.collide = true
		audioManager:playAudio('bounce')

	elseif newy > bottom and dy > 0 then
		-- print(ball:getPosition())
		newy = bottom
		dy *= -bounce
		ball.collide = true
		audioManager:playAudio('bounce')

	end

	ball:moveTo(newx, newy)
	-- ball:moveWithCollisions(newx, newy)
end

function ball:collisionResponse()
	return "overlap"
end
