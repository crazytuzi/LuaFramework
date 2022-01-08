local LoginNoticeScene = class("LoginNoticeScene", BaseScene)

function LoginNoticeScene:ctor(data)
	self.super.ctor(self,data)

	local layer = nil

	if HeitaoSdk then
		layer = require("lua.logic.login.LoginNoticePage"):new()
	else
		-- layer = require("lua.logic.login.LoginLayer"):new()
		layer = require("lua.logic.login.LoginNoticePage"):new()
	end
	
    self:addLayer(layer)
end

function LoginNoticeScene:onEnter()

	TFAudio.stopMusic()
	
	TFAudio.playMusic("sound/bgmusic/login.m4a", true)
end

function LoginNoticeScene:onExit()
	self.super.onExit(self)
end

return LoginNoticeScene;