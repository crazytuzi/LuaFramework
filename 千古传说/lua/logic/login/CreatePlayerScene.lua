local CreatePlayerScene = class("CreatePlayerScene", BaseScene);

function CreatePlayerScene:ctor(data)
	self.super.ctor(self,data);

	local layer = require("lua.logic.login.CreatePlayerNew"):new();
	--local layer = require("lua.logic.login.CreatePlayerLayer"):new();
	
    self:addLayer(layer);
end


function CreatePlayerScene:onEnter()
	self.super.onEnter(self)
	TFAudio.stopMusic()
	TFAudio.playMusic("sound/bgmusic/login.mp3", true)
end

return CreatePlayerScene;