import "player"

local pd <const> = playdate
local gfx <const> = pd.graphics

local scoreSprite
local hpSprite

function createScoreDisplay()
	if scoreSprite then scoreSprite:remove() end
	--hp血量初始化
	hpSprite = gfx.sprite.new()
	hp = 100
	--Score初始化
	scoreSprite = gfx.sprite.new()
	score = 0
	updateDisplay()
	scoreSprite:setCenter(0,0)
	scoreSprite:moveTo(0,220)
	scoreSprite:add()
	print("display")

	hpSprite:setCenter(0,0)
	hpSprite:moveTo(300,0)
	hpSprite:add()

end

function removeScoreDisplay()
	hpSprite:remove()
	scoreSprite:remove()
end

function updateDisplay()
	local scoreText = "*Score*:" .. score
	local score
	local hpText = "*Energy:*" .. hp
	local hp
	local textWidth, textHeight = gfx.getTextSize(scoreText)
	local scoreImage = gfx.image.new(400,textHeight,gfx.kColorWhite)

	gfx.pushContext(scoreImage)
		-- gfx.setImageDrawMode(gfx.kDrawModeInverted)--setcolormode
		gfx.drawTextAligned(scoreText,8,0,kTextAlignment.left)
		gfx.drawText(hpText,310,0)
		gfx.setFont(gfx.font.kVariantBold)
		print(gfx.getFont())
	gfx.popContext()
	scoreSprite:setImage(scoreImage)

end

function incrementScore()
	score += 1
	updateDisplay()
end

function lostEnergy()
	hp -= 1
	updateDisplay()
end


function resetScore()
	score = 0
	hp = 5
	updateDisplay()
end

function finalScore()
	scoreSprite:moveTo(150,150)
	scoreSprite:add()
   local scoreText = tostring(score) -- 确保分数变字符串
	local finalScoreText = "*FinalScore:*" .. scoreText
	print(finalScoreText)
	gfx.setFont(gfx.font.kVariantBold)
	
	local textWidth, textHeight = gfx.getTextSize(finalScoreText)
	local finalScoreImage = gfx.image.new(textWidth + 20,textHeight,gfx.kColorWhite)

	gfx.pushContext(finalScoreImage)
		gfx.drawTextAligned( finalScoreText,10,0,kTextAlignment.left )
	gfx.popContext()

	scoreSprite:setImage(finalScoreImage)
end

