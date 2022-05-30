local LogoScene = class("LogoScene", function()
	return display.newScene("LogoScene")
end)

function LogoScene:ctor()
	local colorBg = display.newColorLayer(cc.c4b(0, 0, 0, 255))
	self:addChild(colorBg)
	GameAudio.init()
	CSDKShell.init()
	SDKTKData.onStart()
	if self._logo == nil then
		self._logo = display.newSprite("logo/logo.png")
	end
	if self._logo ~= nil then
		self._logo:setPosition(display.cx, display.cy)
		self:addChild(self._logo)
	end
end

function LogoScene:onEnter()
	local scheduler = require("framework.scheduler")
	local logoSche
	logoSche = scheduler.scheduleGlobal(function()
		if CSDKShell.isInit() == true then
			local update = function()
				local scene = require("app.scenes.VersionCheckScene").new()
				display.replaceScene(scene, "fade", 0.5)
			end
			self:performWithDelay(update, 2)
			dump("enter logo scene")
			scheduler.unscheduleGlobal(logoSche)
		else
			print("sdsdsds")
		end
	end,
	0.1)
end

function LogoScene:onExit()
	CCTextureCache:sharedTextureCache():removeTextureForKey("logo/logo.png")
end

return LogoScene