local DefaultScene = class("DefaultScene", BaseScene)

function DefaultScene:ctor(data)
	self.super.ctor(self, data)

	local layer = nil

	layer = require("lua.logic.default.DefaultLayer"):new()
	
	-- layer = TFLayer:create()
    self:addLayer(layer)
end

function DefaultScene:onEnter()
	-- TFAudio.playMusic("sound/bgmusic/login.mp3", true)
end

return DefaultScene