GPageSignIn = class("GPageSignIn", function()
    return display.newScene("GPageSignIn")
end)

function GPageSignIn:ctor()
	self.m_loginUI = nil
	self.m_testip = nil
	self.m_testport = nil
	self.m_account = nil
end

function GPageSignIn:onEnter()
	if GameMusic.musicName~="music/43.mp3" then
		GameMusic.music("music/43.mp3")
	end

	self.m_loginUI = GUIAnalysis.load("ui/layout/GPageSignIn.uif")
	if self.m_loginUI then
		
		self.m_loginUI:size(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy)
		self:addChild(self.m_loginUI)
		-- GameUtilSenior.addEffect( parent,name,group,id,pos,ap,isblend,loop,fun )
		
		--默认先显示1个
		local imgBg = self.m_loginUI:getWidgetByName("img_bg"):align(display.CENTER, display.cx, display.cy)
		asyncload_callback("ui/image/img_welcome_bg_1.png", imgBg, function (filepath, texture)
			if GameUtilSenior.isObjectExist(imgBg) then
				imgBg:loadTexture(filepath):scale(cc.MAX_SCALE)
			end
		end)
		
		--动态显示
		local startNum = 1
		local function startShowBg()
		
			local imgBg = self.m_loginUI:getWidgetByName("img_bg"):align(display.CENTER, display.cx, display.cy)
			asyncload_callback("ui/image/img_welcome_bg_"..startNum..".png", imgBg, function (filepath, texture)
				if GameUtilSenior.isObjectExist(imgBg) then
					imgBg:loadTexture(filepath):scale(cc.MAX_SCALE)
				end
			end)
			
			startNum= startNum+1
			if startNum >=1 then
				startNum =1
			end
		end
		--self.m_loginUI:runAction(cca.repeatForever(cca.seq({cca.delay(0.25),cca.cb(startShowBg)}),tonumber(4)))

		local btnSdkLogin = self.m_loginUI:getWidgetByName("btn_sdk_login")
		btnSdkLogin:setTouchEnabled(true)
		btnSdkLogin:addClickEventListener(handler(self,self.pushLoginButton))

		self.m_textRegister = self.m_loginUI:getWidgetByName("Text_register")
		self.m_textRegister:setTouchEnabled(true)
		self.m_textRegister:addClickEventListener(handler(self,self.pushRegistText))
		
		self.m_textLogin = self.m_loginUI:getWidgetByName("Text_login")
		self.m_textLogin:setTouchEnabled(true)
		self.m_textLogin:addClickEventListener(handler(self,self.pushLoginText))
		--self.m_textRegister:setString("帐号注册")
		--self.m_textRegister:loadTexturePressed("new_common_ui_login_toregister_btn.png",ccui.TextureResType.plistType)

		self.m_btnLogin = self.m_loginUI:getWidgetByName("btn_login")
		self.m_btnLogin:setTouchEnabled(true)
		self.m_btnLogin:addClickEventListener(handler(self,self.pushLoginButton))

		self.m_btnRegister = self.m_loginUI:getWidgetByName("btn_register")
		self.m_btnRegister:setTouchEnabled(true)
		self.m_btnRegister:addClickEventListener(handler(self,self.pushRegisterButton))
		self.m_btnRegister:hide();
		self.m_isLogin = true;

		asyncload_callback("ui/image/tip_chenmi.png", self, function (filepath, texture)
			if GameUtilSenior.isObjectExist(self) then
				ccui.ImageView:create(filepath):align(display.BOTTOM_CENTER, display.cx, 1):addTo(self,1)
			end
		end)

		--self.m_loginUI:getWidgetByName("lbl_hint"):runAction(cca.repeatForever(cca.seq({cca.fadeTo(0.5, 0.5),cca.fadeIn(0.5)})))
		self.m_loginUI:getWidgetByName("box_login"):pos(display.cx, display.cy)

		self._labPrompt = self.m_loginUI:getWidgetByName("Text_Prompt")
		self._labPrompt:hide()
		

		if device.platform~="windows" and GameCCBridge.getPlatformId() ~= GameCCBridge.PLATFORM_TEST_ID and PLATFORM_MILI_LOGIN == false then
			self.m_loginUI:getWidgetByName("box_login"):setVisible(false)
			btnSdkLogin:setVisible(true)

			--GameCCBridge.doSdkLogin()
		else
			if device.platform~="android" then
				btnSdkLogin:setVisible(false)
				self:initInput()
				--GameCCBridge.doSdkInit()
				--GameCCBridge.doSdkLogin()
			else
				btnSdkLogin:setVisible(false)
				self:initInput()
				--self.m_loginUI:getWidgetByName("box_login"):setVisible(false)
				--GameCCBridge.doSdkInit()
				--GameCCBridge.doSdkLogin()
			end
		end
	end
end

function GPageSignIn:onExit()
	cc.SpriteManager:getInstance():removeFramesByFile("ui/sprite/GPageServerList")
	cc.CacheManager:getInstance():releaseUnused(false)
end

function GPageSignIn:pushRegistText(pSender)
	--if (self.m_isLogin) then
		self.m_isLogin = false
		--self.m_textRegister:setString("帐号登录")
	--	self.m_textRegister:loadTexturePressed("new_common_ui_login_tologin_btn.png",ccui.TextureResType.plistType)
		self.m_btnRegister:show();
		self.m_btnLogin:hide();
	self.m_textRegister:hide();
	self.m_textLogin:show();
	--else
	--	self.m_isLogin = true;
		--self.m_textRegister:setString("帐号注册")
	--	self.m_textRegister:loadTexturePressed("new_common_ui_login_toregister_btn.png",ccui.TextureResType.plistType)
	--	self.m_btnRegister:hide();
	--	self.m_btnLogin:show();
	--end
end

function GPageSignIn:pushLoginText(pSender)
	self.m_isLogin = true;
	self.m_btnRegister:hide();
	self.m_btnLogin:show();
	self.m_textRegister:show();
	self.m_textLogin:hide();
end

function GPageSignIn:pushRegisterButton(psender)
	local account = self.m_account:getText();
	local password = self.m_password:getText();
	if device.platform ~= "windows" then
		local centerUrl = GameCCBridge.getCenterUrl();
		local update_url = centerUrl.."playerRegister?account="..account.."&password="..password;

		local http=cc.XMLHttpRequest:new()
	    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	    http:open("GET", update_url)
	    local function callback()
	        local state=http.status
	        --print("-------state = "..state.."  data: "..http.response)
	        if state==200 then
	            local response=http.response
	            local json=string.gsub(GameUtilBase.unicode_to_utf8(response),"\\","")
	            json=GameUtilBase.decode(json)
	            if type(json)=="table" and json.code then
	            	local code = tonumber(json["code"]);
	                if code == 0 then
	                    --注册成功
	                    GameCCBridge.showMsg(GameLanguage.Register_Success);
	                    self:pushLoginText()
	                elseif code == 10 then
	                    --已经注册
	                    GameCCBridge.showMsg(GameLanguage.Have_Register);
	                    self:pushLoginText()
	                elseif code == 11 then
	                	--信息为空
	                	self:openPanelPrompt(GameLanguage.GPageSignIn_Account_Empty)
	                end
	            end
	        else

	        end
	    end
	    http:registerScriptHandler(callback)
	    http:send()

	end

	GameSetting.Data["LastAccount"] = account
	GameSetting.Data["LastPassword"] = password
	GameSetting.save()
end

function GPageSignIn:pushLoginButton(pSender)
	if device.platform=="windows" or GameCCBridge.getPlatformId() == GameCCBridge.PLATFORM_TEST_ID or PLATFORM_MILI_LOGIN then
		GameBaseLogic.serverIP = "127.0.0.1"
		GameBaseLogic.serverPort = "7863"

		local account = self.m_account:getText();
		local password = self.m_password:getText();
		if account and tostring(account) ~= "" and password and tostring(password) ~= "" then
			--一直为真
			print("----------doTestLogin------------")
			GameBaseLogic.gameKey=account
			if device.platform ~= "windows" then
				GameCCBridge.doTestLogin(GameBaseLogic.gameKey, password)  --模拟登陆
			else
				asyncload_frames("ui/sprite/GPageAnnounce",".png",function ()
					display.replaceScene(GPageAnnounce.new())
			    end, self)
			end
			GameSetting.Data["LastAccount"] = account
			GameSetting.Data["LastPassword"] = password
			GameSetting.save()
		else
			self:openPanelPrompt(GameLanguage.GPageSignIn_Account_Empty)
		end
	else
		print("------------渠道登录----------")
		GameCCBridge.doSdkLogin()
	end
end

function GPageSignIn:openPanelPrompt( text )
	self._labPrompt:stopAllActions()
	self._labPrompt:align(display.CENTER, display.cx, display.cy)
	self._labPrompt:show()
	self._labPrompt:setString(text)
	self._labPrompt:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.8,cc.p(display.cx, display.cy+50)),
			cc.CallFunc:create(function( ... )
				self._labPrompt:hide()
			end)
		)
	)
end

function GPageSignIn:initInput()
	local function onEdit(event, editbox)

	end

	self.m_account = GameUtilSenior.newEditBox({
			image = "image/icon/null.png",
			size = cc.size(224,40),
			listener = onEdit,
			x = 10,
			y = 0,
			fontSize = 18,
		})

	local lastAccount = GameSetting.Data["LastAccount"]
	self.m_account:setPlaceHolder("账号")
	self.m_account:setString(lastAccount)

	self.m_account:setAnchorPoint(cc.p(0,0))
	self.m_loginUI:getWidgetByName("edit_account"):addChild(self.m_account)

	----------------------
	self.m_password = GameUtilSenior.newEditBox({
			image = "image/icon/null.png",
			size = cc.size(224,40),
			listener = onEdit,
			x = 10,
			y = 0,
			fontSize = 18,
		})

	local lastPassword = GameSetting.Data["LastPassword"]
	self.m_password:setPlaceHolder("密码")
	if device.platform ~= "ios" then
		self.m_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD);
	end
	self.m_password:setString(lastPassword)

	self.m_password:setAnchorPoint(cc.p(0,0))
	self.m_loginUI:getWidgetByName("edit_password"):addChild(self.m_password)
	
end

return GPageSignIn