
local LoginLayer = class("LoginLayer", BaseLayer)
-- local serverList = require('lua.config.server')
LogonHelper = require('lua.manager.LogonHelper')

function LoginLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.login.LoginLayer")
end

function LoginLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui
	LoginLayer.ui = ui

	LoginLayer.panel_close 			= TFDirector:getChildByPath(ui, 'panel_close')

    -- local resPath = "effect/loading_simple.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    -- local skillEff = TFArmature:create("loading_simple_anim")
    -- skillEff:setPosition(ccp(GameConfig.WS.width/2,300))

    -- skillEff:setAnimationFps(GameConfig.ANIM_FPS)
    -- skillEff:playByIndex(0, -1, -1, 1)
    -- LoginLayer.panel_close:addChild(skillEff,2)

	self.input_name  = TFDirector:getChildByPath(ui, 'input_name')
	self.lb_name     = TFDirector:getChildByPath(ui, 'lb_name')
	self.btn_selectAcount = TFDirector:getChildByPath(ui, 'btn_selectAcount')

	self.input_name:setCursorEnabled(true)

	self.img_bg 	= TFDirector:getChildByPath(ui, 'bg')

	--add by david.dai
	self.img_input_bg = TFDirector:getChildByPath(ui, 'img_input_bg')

	self.input_pos_mark = self.img_input_bg:getPosition()

--   显示出名字log begin
	self.img_title = TFDirector:getChildByPath(ui, 'img_title')
 
	self.img_title:setVisible(true)
	-- self.img_title:setVisible(false)
-- end

	self.input_name:setVisible(true);
	self.lb_name:setVisible(false);
	-- self.btn_selectAcount:setTouchEnabled(false);
	self:initDefault()

	LoginLayer.input_name = self.input_name

	self.panel_touch 	= TFDirector:getChildByPath(ui, 'panel_touch')
	self:playEffect()


	-- LogincallBack
	self.LogincallBack =  function (code, msg)
		    --处理回调函数	
		if code == UserActionResultCode.kLoginSuccess  then   --登陆成功回调
		    --登陆成功后，游戏相关处理
		    local userId = TFPlugins.getUserID()
		    --print("UserActionResultCode.kLoginSuccess userId = ", userId)
		    self.input_name:setText(userId)
		end
		if code == UserActionResultCode.kLoginTimeOut  then   --登陆失败回调
		    --登陆失败后，游戏相关处理

		end
		if code == UserActionResultCode.kLoginCancel   then   --登陆取消回调
		    --登陆失败后，游戏相关处理

		end
		if code == UserActionResultCode.kLoginFail     then   --登陆失败回调
		    --登陆失败后，游戏相关处理

		end

	end

	-- if TFPlugins.ge tChannelId() ~= "" and TFPlugins.isLogined() ~= true then
	if TFPlugins.isPluginExist() then
		TFPlugins.hideToolBar()
	 	if TFPlugins.isLogined() ~= true then
			TFPlugins.Login(self.LogincallBack)
		end
	end


	self:showWebViewNotice()
end

function LoginLayer:initDefault()
	local userInfo  = SaveManager:getUserInfo()
	local username = userInfo.userName
	if username then
		self.input_name:setText(username)
	end
end

function LoginLayer:removeUI()
	self.super.removeUI(self)
end

function LoginLayer:registerEvents()
	self.super.registerEvents(self)

	self.lb_name.logic = self

	self.btn_selectAcount:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectAccountClickHandle))
	self.lb_name:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectAccountClickHandle))

	local function onTextFieldChangedHandle(input)
        self.img_input_bg:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y))
    end

	--add by david.dai
	--添加输入账号时输入框上移逻辑
	local function onTextFieldAttachHandle(input)
        self.img_input_bg:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y))
        self.input_name:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
    end
    self.input_name:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)

    local function onTextFieldDetachHandle(input)
		local text = input:getText()
        local new_text = string.gsub(text, "[^a-zA-Z0-9]", "")
        input:setText(new_text)
        self.img_input_bg:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y))
        self.input_name:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    end

    self.input_name:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)

	self:registerNotification()
	if HeitaoSdk == nil then
		self.panel_touch:addMEListener(TFWIDGET_CLICK, audioClickfun(self.enterNextPage))
	else
		self.panel_touch:addMEListener(TFWIDGET_CLICK, audioClickfun(self.enterNextPage))
	end
	self.panel_touch.logic = self
	ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
end

function LoginLayer:removeEvents()
end

function LoginLayer.onSelectAccountClickHandle(btn)
	local self = btn.logic

	-- print("LoginLayer.onSelectAccountClickHandle")
	-- if TFSdk then
	-- 	changeAccount()
	-- end
	if TFPlugins.isPluginExist() then
	 	if TFPlugins.isLogined() ~= true then
	 		print("没有登录，继续登录")
			TFPlugins.Login(LoginLayer.LogincallBack)
		else
			print("登录，切换账号")
			TFPlugins.accountSwitch()
		end
	end
end

function LoginLayer:playEffect()

	if not self.img_bg then
		return
	end

	if self.ChooseEffect == nil then
		local effectID = "denglu"
		ModelManager:addResourceFromFile(2, effectID, 1)
		local effect = ModelManager:createResource(2, effectID)
		effect:setPosition(ccp(self.img_bg:getSize().width / 2, self.img_bg:getSize().height / 2))
		self.img_bg:addChild(effect, 1)

		self.ChooseEffect = effect
	end
	ModelManager:playWithNameAndIndex(self.ChooseEffect, "", 0, 1, -1, -1)

	-- if self.ChooseEffect == nil then
	-- 	local resPath = "effect/logineffect.xml"
	--     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	--     local effect = TFArmature:create("logineffect_anim")

	--     effect:setAnimationFps(GameConfig.ANIM_FPS)
 --        effect:setPosition(ccp(self.img_bg:getSize().width/2,self.img_bg:getSize().height/2 - 22))

 --        self.img_bg:addChild(effect, 1)


	--     effect:addMEListener(TFARMATURE_COMPLETE,function()
	--         -- effect:removeMEListener(TFARMATURE_COMPLETE)
	--         -- effect:removeFromParent()
	--         -- self.ChooseEffect:playByIndex(1, -1, -1, 1)
	--     end)

	--     self.ChooseEffect = effect
 --   	end

 --    self.ChooseEffect:playByIndex(0, -1, -1, 1)
 --    self.ChooseEffect:setVisible(true)

 --    	if self.titleEffect == nil then
	-- 	local resPath = "effect/titleeffect.xml"
	--     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	--     local effect = TFArmature:create("titleeffect_anim")

	--     effect:setAnimationFps(GameConfig.ANIM_FPS)
 --        effect:setPosition(ccp(self.img_bg:getSize().width/2,self.img_bg:getSize().height/2 - 22))

 --        self.img_bg:addChild(effect, 2)


	--     effect:addMEListener(TFARMATURE_COMPLETE,function()
	--         -- effect:removeMEListener(TFARMATURE_COMPLETE)
	--         -- effect:removeFromParent()
	--         -- self.titleEffect:playByIndex(1, -1, -1, 1)
	--     end)

	--     self.titleEffect = effect
 --   	end

 --    self.titleEffect:playByIndex(0, -1, -1, 1)
end

function LoginLayer:hideEffect()

	if self.ChooseEffect then
		self.ChooseEffect:setVisible(false)
	end
end


function LoginLayer.enterNextPage(sender)

	TFWebView.removeWebView()
	
	local LoginNoticePage   = require("lua.logic.login.LoginNoticePage")

	if HeitaoSdk then
		if HeitaoSdk.startGame() == true then
			-- self.userName = HeitaoSdk.getplatformUserId()
		    AlertManager:changeScene(LoginNoticePage:scene())
		else
			-- HeitaoSdk.login()
		end

		return
	end

	local self = sender.logic 
	-- if TFSdk:getSdkName() then
	-- 	if not TFSdk:getUserIsLogin() then
	-- 		changeAccount()
	-- 		return
	-- 	end
	-- end

	if TFPlugins.isPluginExist() then
		print("------->LoginLayer : " .. TFPlugins.isLogined())
	 	if TFPlugins.isLogined() ~= true then
			TFPlugins.Login(LoginLayer.LogincallBack)
			return
		end
	end

	local userName = LoginLayer.input_name:getText()
	
	if string.len(userName) < 6 then
		--toastMessage("请输入账号")
		toastMessage(localizable.loginLayer_input_account)
		return
	end


	if HeitaoSdk == nil then
		TFPlugins.setUserID(userName)
		self:requestServerList(nil)
	end

	LoginNoticePage.userName = userName
    AlertManager:changeScene(LoginNoticePage:scene())
end

function LoginLayer:registerNotification()

	local function getNowtime()
	-- MainPlayer:getNowtime()
		return os.time()
	end

	local  function startDateNotification(key, desc, date, repeatType)
		if date == nil then
			return
		end
		
		local nowTime 	= getNowtime()
		local nextTime 	= getTimeByDate(date)
		local delay 	= nextTime - nowTime
		if nowTime < nextTime then
			--print("还未到达时间")
			--print("delay = ", delay/3600)

			-- TFNotificationManager:getInstance():notification(desc, delay, repeatType, key)
			if TFPushServer then
				TFPushServer.setLocalTimer(nextTime, desc, key)
			end
			return
		end

		--print("该事件的已过期 ---- ", date)
	end

	-- date 时间
	local  function startDailyNotification(key, desc, eventdate, repeatType)
		local nowTime 	= getNowtime()
		local date 		= os.date("*t", os.time())
		
		local nextDate  = getDateByString(eventdate)

		-- 把当前的事件置为每天的目标时间
		date.hour = nextDate.hour
		date.min  = nextDate.min
		date.sec  = nextDate.sec

		-- date.
		local nextTime 	= os.time(date)
		local delay = 0
		-- 还未到达今日目的时间
		if nowTime < nextTime then
			--print("时间还未到达1")
			delay = nextTime - nowTime

		-- 今日目的时间已过, 明天再执行
		else
			--print("时间已过，等待下次到达")
			nextTime = 24 * 3600 + nextTime
			delay = nextTime - nowTime
		end

		--print("delay = ", delay/3600)
		date = os.date("*t", nextTime)
		--print("下次到达时间", date)
		-- TFNotificationManager:getInstance():notification(desc, delay, repeatType, key)

		if TFPushServer then
			TFPushServer.setLocalTimer(nextTime, desc, key)
		end

	end

	-- -- 先移除所有事件
	-- TFNotificationManager:getInstance():removeNotification()
	if TFPushServer then
		TFPushServer.cancelAllLocalTimer()
	end

	-- 开启所有推送
	local eventList = require("lua.table.t_s_events")

    -- 
    for v in eventList:iterator() do
		--print("v = ", v)
		local nextDate = getDateByString(v.date)
		-- print("----------------------------")
		-- print("事件名称：", v.name)
		-- print("事件描述：", v.desc)
		-- print("事件执行的时间点  = ", v.date)
		if nextDate.year == "0" and nextDate.month == "0" and nextDate.day == "0" then
			--print("每天都要重复的事件")
			startDailyNotification(""..v.id, v.desc, v.date, 1)
		else
			--print("只执行一次的事件")
			startDateNotification(""..v.id, v.desc, v.date, 0)
		end
		--print("----------------------------")

    end

	-- if TFPushServer then
	-- 	TFPushServer.setLocalTimer(getNowtime() + 10, "本地推送测试", "test")
	-- 	TFPushServer.cancelLocalTimer(nil, nil, "1")
	-- end
	-- -- name date hour repeat 

	-- -- ("大侠请留步，用餐时间已到，小宝喊你回游戏吃花雕茯苓猪！", timeDelay, 1, "eatpig1")
	-- startDailyNotification("eatpig1", "大侠请留步，用餐时间已到，小宝喊你回游戏吃花雕茯苓猪！", 12, 1)
	-- startDailyNotification("eatpig2", "大侠请留步，用餐时间已到，小宝喊你回游戏吃花雕茯苓猪！", 18, 1)
end

function LoginLayer:showWebViewNotice()

    self.img_gonggaodi      = TFDirector:getChildByPath(self, 'img_gonggaodi')
	self.img_dengru 		= TFDirector:getChildByPath(self, 'img_dengru')
	self.Button_Gonggao_1 	= TFDirector:getChildByPath(self, 'Button_Gonggao_1')

	-- if HeitaoSdk == nil then
		-- self:playEffect()
		-- self.img_title:setVisible(false)
		self.img_gonggaodi:setVisible(false)
		-- return
	-- end

	if HeitaoSdk then

		self.img_input_bg:setVisible(false)

		local function LogincallBack(result, msg)
			if result == HeitaoSdk.LOGIN_IN_SUC then
				local platformid = HeitaoSdk.getplatformId()

				local notice_url = "http://smi.heitao.com/mhqx/affiche?pfid="..platformid
				local designsize = CCDirector:sharedDirector():getOpenGLView():getDesignResolutionSize()
				local newx = (designsize.width - 960) / 2 + 145
				local newy = 100

				TFWebView.showWebView(notice_url, newx, 135, 660, 350)


				self:requestServerList(platformid)

				self:hideEffect()

				self.img_title:setVisible(false)
				self.img_input_bg:setVisible(false)
				self.img_gonggaodi:setVisible(true)
				self.img_dengru:setVisible(false)

				HeitaoSdk.logincallback = nil

			elseif result == HeitaoSdk.LOGIN_IN_FAIL then
				-- toastMessage(msg)
				self.panel_touch:addMEListener(TFWIDGET_CLICK, audioClickfun(self.enterNextPage))
        	end

			-- HeitaoSdk.init()
		end


		if HeitaoSdk.startGame() == true then
			-- self.userName = HeitaoSdk.getplatformUserId()
		    self.panel_touch:addMEListener(TFWIDGET_CLICK, audioClickfun(self.enterNextPage))
		    
			HeitaoSdk.logincallback = nil

			self:initLoginInfo()
			
			local platformid = HeitaoSdk.getplatformId()
			self:requestServerList(platformid)
		else		
			HeitaoSdk.setLogincallback(LogincallBack)
			-- HeitaoSdk.login()
			HeitaoSdk.ShowFunctionMenu(false)

			self.Button_Gonggao_1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.enterNextPage))

		end
	else
		-- local platformid = nil
		-- if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		-- 	platformid = "win2015"
		-- end
		-- self:requestServerList(platformid)
	end

				-- local notice_url = "http://smi.heitao.com/mhqx/affiche?pfid="..HeitaoSdk.getplatformId()
				-- local designsize = CCDirector:sharedDirector():getOpenGLView():getDesignResolutionSize()
				-- local newx = (designsize.width - 960) / 2 + 145
				-- local newy = 100
				-- TFWebView.showWebView(notice_url, newx, 135, 660, 350)
	if HeitaoSdk then

	end

end

-- function LoginLayer:requestServerList(platformid)
-- 	-- local serverList_url = "http://120.131.3.51:9000/server/list.do"


-- 	-- -- 内网测试
-- 	-- if VERSION_DEBUG == true then
-- 	-- 	serverList_url = "http://112.74.111.206:9000/server/list.do"
-- 	-- end
	
-- 	-- -- 内网测试
-- 	-- serverList_url = "http://192.168.10.115:9000/server/list.do"

-- 	local serverList_url = TFPlugins.serverList_url

-- 	local system = 0 	-- pc
-- 	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
--     	system = 1 		--ios
-- 	elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
-- 		system = 2 		--android
-- 	end

-- 	serverList_url = serverList_url .. "?system=" .. system
-- 	if platformid ~= nil then
-- 		serverList_url = serverList_url .. "&channel=" .. platformid
-- 	end

-- 	local userId = nil
-- 	if HeitaoSdk then
-- 		userId            = HeitaoSdk.getuserid()
-- 	else
-- 		if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
-- 			userId = "pcTest001"
-- 		end
-- 	end

-- 	if userId ~= nil then
-- 		serverList_url = serverList_url .. "&userid=" .. userId
-- 	end
	
-- 	TFPlugins.serverList_url = serverList_url
	
-- 	print("LoginLayer:requestServerList = ",TFPlugins.serverList_url)

-- 	LogonHelper:requestServerList(TFPlugins.serverList_url)
-- end


function LoginLayer:requestServerList(none)
	local platformid = nil
	local userId 	 = nil

	if HeitaoSdk then
		platformid = HeitaoSdk.getplatformId()
		userId 	   = HeitaoSdk.getuserid()
	else
		platformid = "win2015"
		userId 	   = TFPlugins.getUserID()
	end

	local serverList_url = TFPlugins.serverList_url
	local system = 0 	-- pc
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    	system = 1 		--ios
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		system = 2 		--android
	end

	serverList_url = serverList_url .. "?system=" .. system
	if platformid ~= nil then
		serverList_url = serverList_url .. "&channel=" .. platformid
	end
	if userId ~= nil then
		serverList_url = serverList_url .. "&userid=" .. userId
	end
	
	-- add version
	serverList_url = serverList_url .. "&appverison=" .. TFDeviceInfo.getCurAppVersion()
	-- TFPlugins.serverList_url = serverList_url
	

    
	print("请求服务器列表 = ", serverList_url)

	LogonHelper:requestServerList(serverList_url)
end

function LoginLayer:initLoginInfo()
	if HeitaoSdk == nil or TFPlugins == nil then
		return
	end

    local userId            = HeitaoSdk.getuserid()
    local platformUserId    = HeitaoSdk.getplatformUserId()
    local platformid        = HeitaoSdk.getplatformId()
    local token             = HeitaoSdk.gettoken()    
    local sdkVersion        = HeitaoSdk.getSDKVersion()

    print("______________ long in success ___________________")
    print("userId           = ", userId)
    print("platformUserId   = ", platformUserId)
    print("platformid       = ", platformid)
    print("token            = ", token)                
    print("sdkVersion       = ", sdkVersion)
    print("______________ long in end ___________________")

    TFPlugins.setSdkVersion(sdkVersion)
    TFPlugins.setSdkName(platformid)
    TFPlugins.setUserID(userId)
    TFPlugins.setToken(token)
end

return LoginLayer;
