local gfx = playdate.graphics

local function setPattern0() gfx.setColor(gfx.kColorWhite) end
local function setPattern25() gfx.setPattern({0xff, 0x55, 0xff, 0x55, 0xff, 0x55, 0xff, 0x55}) end
local function setPattern50() gfx.setPattern({0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55}) end
local function setPattern75() gfx.setPattern({0xaa, 0x00, 0xaa, 0x00, 0xaa, 0x00, 0xaa, 0x00}) end
local function setPattern100() gfx.setColor(gfx.kColorBlack) end

day = gfx.image.new('Background/Day')
night = gfx.image.new('Background/night')
earthBorn = gfx.image.new('Background/earthBorn')


function drawDayBackground()
	gfx.setImageDrawMode(gfx.kDrawModeNXOR)
	day:draw(0,0)
	day:setPattern25()
end

function drawNightBackground()
	gfx.setImageDrawMode(gfx.kDrawModeNXOR)
	night:draw(0,0)
	day:setPattern50()
end

function drawEarthBorn()
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
	earthBorn:draw(0,0)
end

function drawBackground()
	local rand = math.random(0,100)
	gfx.setImageDrawMode(gfx.kDrawModeNXOR)

	if rand <= 30 then
		night:draw(0,0)
	elseif rand > 30 and rand < 60 then
		day:draw(0,0)
	else
		earthBorn:draw(0,0)
	end
end