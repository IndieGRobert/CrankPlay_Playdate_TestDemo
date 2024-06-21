local sfx = playdate.sound

audioManager = {}

audioManager.bounce = 'bounce'
audioManager.dash = 'dash'

local audioes = {}

for _, v in pairs(audioManager) do
	audioes[v] = sfx.sampleplayer.new ('Audio/'..v )
end

audioManager.audioes = audioes

function audioManager:playAudio( name )
	self.audioes[name]:play(1)
end

function audioManager:stopAudio( name )
	self.audioes[name]:stop()
end

function audioManager:playBackgroundMusic( musicName )
	local filePlayer = sfx.fileplayer.new( musicName )
	filePlayer:play(0) -- repeat forever
end