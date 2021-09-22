GPageReEnter = class("GPageReEnter", function()
    return display.newScene("GPageReEnter")
end)

function GPageReEnter:ctor()
	print("GPageReEnter:ctor()")

	self.maxWaitingTime = 5
	self._loadUI = nil
	self._percent = 0
	self.reconnect = 0
end

function GPageReEnter:onExit()
	self:stopAllActions()
	cc.CacheManager:getInstance():releaseUnused(false)
end

function GPageReEnter:onConnect(event)
	print("GPageReEnter:onConnect")
	GameSocket:Authenticate(101,GameBaseLogic.gameTicket,0,0)
end

function GPageReEnter:onAuth(event)
	if event.result == 100 then
		GameSocket:EnterGame(GameBaseLogic.chrName,GameBaseLogic.seedName)
	else
		GameBaseLogic.ExitToRelogin()
	end
end

function GPageReEnter:onResEnterGame(event)
	print("GPageReEnter:onResEnterGame "..event.result)
	if event.result==100 then

	elseif event.result==103 then
		GameUtilSenior.showAlert("提示","当前账号在线",{"再试一次","取消"},function (event)
			if event.buttonIndex == 1 then
				self:runAction(cca.seq({
					cca.delay(5),
					cca.cb(function()
						GameSocket:EnterGame(GameBaseLogic.chrName,GameBaseLogic.seedName)
					end)
				}))
			else
				GameBaseLogic.ExitToRelogin()
			end
		end,self)
	else
		GameBaseLogic.ExitToRelogin()
	end
end

function GPageReEnter:onPlatformLogout()
	GameBaseLogic.ExitToRelogin()
end

function GPageReEnter:onEnter()
	print("GPageReEnter:onEnter()")

	MAIN_IS_IN_GAME = false

	asyncload_frames("ui/sprite/GPageResourceLoad",".png",function ()
		self.maxWaitingTime = 5

		self._loadUI = GUIAnalysis.load("ui/layout/GPageReEnter.uif")
			:setContentSize(cc.size(display.width, display.height))
			:align(display.CENTER, display.cx, display.cy)
			:addTo(self)

		local img_sceneBg = self._loadUI:getWidgetByName("img_sceneBg")
		
		img_sceneBg:loadTexture("ui/image/img_battle.jpg",ccui.TextureResType.localType)
		local size = self._loadUI:getContentSize()
		img_sceneBg:align(display.CENTER, size.width/2, size.height/2)
		if display.height > 640 then
			img_sceneBg:scale(display.height/640)
		end

		local seceneBarBg = self._loadUI:getWidgetByName("seceneBarBg"):align(display.CENTER, display.cx, display.bottom + 100)
		-- local bar = self._loadUI:getWidgetByName("bar"):size(7,31):align(display.LEFT_CENTER, 52, 20):setScale9Enabled(true):setCapInsets(cc.rect(5,5,926,11))
		local barLight = self._loadUI:getWidgetByName("bar_light")
		local mask = self._loadUI:getWidgetByName("mask")
		self._loadUI:getWidgetByName("lbl_hint"):align(display.CENTER, display.cx, display.bottom + 140)

		self._percent = 0;
		local function runLoading()
			self._percent = self._percent + 1

			if GameSocket._connected then
				if GameSocket.mNetMap.mMapID then
					GameBaseLogic.noSubmit = true
					cc.Director:getInstance():replaceScene(cc.SceneGame:create())
				end
			else
				GameCCBridge.showMsg("服务器连接已断开")
				GameBaseLogic.ExitToRelogin()
			end

			if self._percent > 300 then
				self:stopAllActions()
				GameBaseLogic.ExitToRelogin()
			end
			local width = math.max(self._percent/3*890/100, 10)
			-- bar:size(width,16)
			-- barLight:setPosition(width-40, 45)
			mask:size(width + 10,83)
			barLight:pos(40 + 8.9 * self._percent/3, 25)		
			-- bar:setContentSize(self._percent*8.9,31)
			-- barLight:setPosition(cc.p(100+self._percent*8.9,24))
		end
		self:runAction(cca.repeatForever(
			cca.seq({
				cca.delay(1/10),
				cca.cb(runLoading)
			})
		));
		if PLATFORM_BANSHU then
			local url = CONFIG_TEST_URL..GameBaseLogic.gameKey
			
			local function httpcallback(request)
				if request.status==200 then
			        GameSocket:Authenticate(101,GameBaseLogic.gameKey,0,0);
			    end
		    end
		    GameUtilSenior.httpRequest(url,httpcallback,self)
		else
			print("GameSocket:Authenticate(101,GameBaseLogic.gameKey,0,0);")
			GameSocket:Authenticate(101,GameBaseLogic.gameTicket,0,0);
		end
	end,self)
end

function GPageReEnter:onEnterTransitionFinish()

	GameSocket:init()
	GameCharacter.initVar()

	cc.EventProxy.new(GameSocket,self)
		:addEventListener(GameMessageCode.EVENT_CONNECT_ON,handler(self,self.onConnect))
		:addEventListener(GameMessageCode.EVENT_AUTHENTICATE,handler(self,self.onAuth))
		:addEventListener(GameMessageCode.EVENT_RES_ENTER_GAME,handler(self,self.onResEnterGame))
		:addEventListener(GameMessageCode.EVENT_PLATFORM_LOGOUT,handler(self, self.onPlatformLogout))

	print("GPageReEnter:onEnterTransitionFinish()")

end

return GPageReEnter