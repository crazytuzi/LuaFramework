--[[
******主场景*******

	-- by haidong.gan
	-- 2013/10/27
]]
local HomeScene = class("HomeScene", BaseScene);

function HomeScene:ctor(data)
	print("HomeScene:ctor() ....... bnbbbbb")
	self.super.ctor(self,data);
	self.menu_layer = require("lua.logic.home.MenuLayer"):new();
    self:addLayer(self.menu_layer);
    self.menu_layer.isShow = true;
    self.menu_layer:onShow();
end

function HomeScene:onEnter()
	print("HomeScene:onEnter() ....... bnbbbbb")
	GameResourceManager:clearAll()
	if AlertManager.Force_Scene_Callback then
		local callback = AlertManager.Force_Scene_Callback
		AlertManager.Force_Scene_Callback = nil
		callback()
	end
	TFDirector:dispatchGlobalEventWith("onEnterHomeScene")
	-- TFAudio.playMusic("sound/bgmusic/home.mp3", true)
	if self.gotoLayer then
		self.menu_layer:gotoLayerByType(self.gotoLayer)
		self.gotoLayer = nil
	end

	local flieName = "lua.logic.youli.AdventureHomeLayer"
    local _layer = AlertManager:getLayerByName( flieName )
    TFAudio.stopMusic()
    if  _layer ~= nil then
        TFAudio.playMusic("sound/bgmusic/youli_bgm.mp3", true)
    else    	
    	TFAudio.playMusic("sound/bgmusic/home.mp3", true)
    end

end

function HomeScene:gotoLayerByType( Layer_type )
	self.gotoLayer = Layer_type
end

function HomeScene:onExit()
	print("HomeScene:onExit() ....... bnbbbbb")
	TFAudio.stopMusic()
	self.super.onExit(self)
end

return HomeScene;