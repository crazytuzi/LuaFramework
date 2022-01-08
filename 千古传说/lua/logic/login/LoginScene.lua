local LoginScene = class("LoginScene", BaseScene)

function LoginScene:ctor(data)
	self.super.ctor(self,data)

	local layer = nil

	-- if HeitaoSdk then
	-- 	layer = require("lua.logic.login.LoginNoticePage"):new()
	-- else
	-- 	layer = require("lua.logic.login.LoginLayer"):new()
	-- end
	layer = require("lua.logic.login.LoginLayer"):new()
	
    self:addLayer(layer)
end

function LoginScene:onEnter()
	self.super.onEnter(self)
	AlertManager:closeAll()
	TFAudio.stopMusic()
	TFAudio.playMusic("sound/bgmusic/login.mp3", true)
end

function LoginScene:onExit()
	self.super.onExit(self)
end

return LoginScene;