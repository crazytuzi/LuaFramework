GPageAcrossServer = class("GPageAcrossServer", function()
    return display.newScene("GPageAcrossServer")
end)

function GPageAcrossServer:ctor()
	
	GameSocket:disconnect()

	MAIN_IS_IN_GAME=false

	self.maxWaitingTime = 5
	self._loadUI = nil
	self._percent = nil
end

function GPageAcrossServer:onExit()
	self:stopAllActions()
	cc.CacheManager:getInstance():releaseUnused(false)
end

function GPageAcrossServer:onEnterTransitionFinish()

	-- GameCCBridge.logoutRoom()
	GameSocket:init()
	GameCharacter.initVar()

	self:runAction(
		cca.seq({
			cca.delay(1),
			cca.cb(function()
				print("GameSocket:connect")
				if GameSocket.kuaFuState then
					GameSocket:connect(GameSocket.kuaFuInfo.kuafuip, GameSocket.kuaFuInfo.kuafuport, 1)
				else
					GameSocket:connect(GameBaseLogic.serverIP, GameBaseLogic.serverPort, 2)
				end
			end)
		})
	)

	cc.EventProxy.new(GameSocket,self)
		:addEventListener(GameMessageCode.EVENT_PLATFORM_LOGOUT,handler(self, self.onPlatformLogout))
end

function GPageAcrossServer:onPlatformLogout()
	GameBaseLogic.ExitToRelogin()
end

function GPageAcrossServer:wait()
	if MAIN_IS_IN_GAME then
		return
	end
	GameUtilSenior.showAlert("提示","连接失败，是否需要重试？",{"确定","重新登录"},function (event)
		if MAIN_IS_IN_GAME then
			return
		end
		if event.buttonIndex == 1 then
			if GameSocket.kuaFuState then
				GameSocket:connect(GameSocket.kuaFuInfo.kuafuip, GameSocket.kuaFuInfo.kuafuport, 1)
			else
				GameSocket:connect(GameBaseLogic.serverIP, GameBaseLogic.serverPort, 2)
			end
			self:runAction(cca.seq({cca.delay(self.maxWaitingTime), cca.callFunc(handler(self, self.wait))}))
		elseif event.buttonIndex == 2 then
			GameBaseLogic.ExitToRelogin()
		end
	end,self)
end

function GPageAcrossServer:onEnter()
	asyncload_frames("ui/sprite/GPageResourceLoad",".png",function ()
		self._loadUI = GUIAnalysis.load("ui/layout/GPageAcrossServer.uif")
		:setContentSize(cc.size(display.width, display.height))
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

		local seceneBg = self._loadUI:getChildByName("seceneBg")
		local lbl_hint = self._loadUI:getChildByName("lbl_hint"):align(display.CENTER, display.cx, display.bottom + 140)

		if GameSocket.kuaFuState then
			seceneBg:loadTexture("ui/image/img_loading_bottom_02.jpg",ccui.TextureResType.localType)
			lbl_hint:setString("正在跨服，请稍等")
		else
			seceneBg:loadTexture("ui/image/img_loading_bottom_01.jpg",ccui.TextureResType.localType)
			lbl_hint:setString("正在返回，请稍等")
		end
		local size = self._loadUI:getContentSize()
		seceneBg:align(display.CENTER, size.width/2, size.height/2)
		if display.height > 640 then
			seceneBg:scale(display.height/640)
		end

		local seceneBarBg = self._loadUI:getWidgetByName("seceneBarBg"):align(display.CENTER, display.cx, display.bottom + 100)
		local bar = self._loadUI:getWidgetByName("bar"):size(40,31):align(display.LEFT_CENTER, 120, 100)
		local barLight = self._loadUI:getWidgetByName("bar_light")

		self._percent = 0;
		local function runLoading()
			self._percent = self._percent + 1
			if self._percent > 100 then
				self:stopAllActions()
				self:runAction(cca.seq({cca.delay(self.maxWaitingTime), cca.callFunc(handler(self, self.wait))}))
			end
			bar:size(self._percent*8.9,31)
			barLight:setPosition(cc.p(70+self._percent*8.9,100))
		end
		self:runAction(cca.repeatForever(
			cca.seq({
				cca.delay(1/40),
				cca.cb(runLoading)
			})
		))
	end,self)
end

return GPageAcrossServer