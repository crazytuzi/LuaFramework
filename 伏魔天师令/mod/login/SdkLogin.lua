local isFirstComeIn=true
local switchAccount=""

local SdkLogin=classGc(function(self)

end)

function SdkLogin.loginSdk(self)
	if gc.SDKManager==nil or gc.SDKManager:getInstance():isInternalSDK() then
		self:showInternalLoginView()
		return
	end

	local isLogin=false
	local function onSDKCallBack(eventType,szMsg)
		print("[LUA onSDKCallBack]========>>>",eventType,szMsg)
		if eventType==_G.Const.SDK_TYPE_LOGIN_FAILD
			or eventType==_G.Const.SDK_TYPE_LOGIN_CANCEL then
			if isLogin then return end

			if _G.SysInfo:isQQSDKChannel() then
				self:tencent_showLoginBtn()
			else
				if self.m_isZhuoYiFirstLogin then
					self.m_isZhuoYiFirstLogin=false
					self:zhuoyi_removeDelayToLogin()
				end
				self:showAgainLoginBtn()
			end
		elseif eventType==_G.Const.SDK_TYPE_LOGIN_SUCCESS then
			if isLogin then return end
			self:loginServerByAccount()

			if _G.SysInfo:isQQSDKChannel() then
				self:tencent_hideLoginBtn()
				self:hideWaitCir()
			else
				if self.m_isZhuoYiFirstLogin then
					self.m_isZhuoYiFirstLogin=false
					self:zhuoyi_removeDelayToLogin()
				end
				self:hideAgainLoginBtn()
			end
			isLogin=true
		elseif eventType==_G.Const.SDK_TYPE_LOGOUT_SUCCESS then
			if not isLogin then return end
			if _G.SysInfo:isQQSDKChannel() then
				cc.UserDefault:getInstance():setStringForKey("QQ_LOGIN_TYPE_CACHE", "")
			end
			RESTART_GAME(_G.Const.kResetGameTypeChuangAccount)
		elseif eventType==_G.Const.SDK_TYPE_CHUANGE_ACCOUNT_SUCCESS then
			if not isLogin then return end
			switchAccount=szMsg
			RESTART_GAME(_G.Const.kResetGameTypeChuangAccount)
		end
	end
	local handler=gc.ScriptHandlerControl:create(onSDKCallBack)
	gc.SDKManager:getInstance():registerScriptHandler(handler)

	if _G.SysInfo:isQQSDKChannel() then
		if isFirstComeIn then
			isFirstComeIn=false
			local typeCache=cc.UserDefault:getInstance():getStringForKey("QQ_LOGIN_TYPE_CACHE", "")
			if typeCache~="" then
				self:tencent_showAutoLoginNotic()
			else
				self:tencent_showLoginBtn()
			end
		else
			self:tencent_showLoginBtn()
		end
	else
		if isFirstComeIn and _G.SysInfo:isZhuoYiChannel() then
			-- 卓易市场 SDK  首次安装卓易插件的时候，安装完了不会自动调登录界面，需要我们自己手动调
			isFirstComeIn=false
			self.m_isZhuoYiFirstLogin=true

			self:zhuoyi_delayToLogin()
		elseif switchAccount~="" then
			-- 直接切换帐号
			gc.UserCache:getInstance():setUserName(switchAccount)
			switchAccount=""
			self:loginServerByAccount()
			isLogin=true
			return
		end
		gc.SDKManager:getInstance():loginSDK()

		if _G.SysInfo:isKuaiFaChannel() or _G.SysInfo:isAnZhiChannel() then
			self:showAgainLoginBtn()
			self:handleAgainLoginBtnDelayTouch()
		end
	end
end

function SdkLogin.zhuoyi_delayToLogin(self)
	self:zhuoyi_removeDelayToLogin()
	self:showWaitCir()

	local function delayFun()
		self:zhuoyi_delayToLogin()
		gc.SDKManager:getInstance():loginSDK()
	end

	local tempAct=cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(delayFun))
	tempAct:setTag(6686)
	local runningScene=cc.Director:getInstance():getRunningScene()
	runningScene:runAction(tempAct)
end
function SdkLogin.zhuoyi_removeDelayToLogin(self)
	self:hideWaitCir()

	local runningScene=cc.Director:getInstance():getRunningScene()
	runningScene:stopActionByTag(6686)
end

function SdkLogin.showWaitCir(self)
	if self.m_waitCircleSpr then
		self.m_waitCircleSpr:setVisible(true)
		return
	end

	self.m_waitCircleSpr=cc.Sprite:createWithSpriteFrameName("general_loading.png")
    cc.Director:getInstance():getRunningScene():addChild(self.m_waitCircleSpr,100000)

    local rotaBy=cc.RotateBy:create(1,360)
    self.m_waitCircleSpr:runAction(cc.RepeatForever:create(rotaBy))

    local winSize=cc.Director:getInstance():getWinSize()
    self.m_waitCircleSpr:setPosition(winSize.width*0.5,winSize.height*0.5)
end
function SdkLogin.hideWaitCir(self)
	if self.m_waitCircleSpr then
		self.m_waitCircleSpr:setVisible(false)
	end
end

function SdkLogin.tencent_showAutoLoginNotic(self)
	local winSize=cc.Director:getInstance():getWinSize()
	local tempNode=cc.Node:create()
	tempNode:setPosition(winSize.width*0.5,150)
	cc.Director:getInstance():getRunningScene():addChild(tempNode,30)

	local tipsBgBtn=ccui.Scale9Sprite:createWithSpriteFrameName("general_box_hint.png")
	tipsBgBtn:setContentSize(cc.size(260,35))
    tempNode:addChild(tipsBgBtn)

	local noticLabel=_G.Util:createLabel("即将自动登录...",20)
	noticLabel:setPosition(-35,0)
	noticLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
	tempNode:addChild(noticLabel)

	local cancelLabel=_G.Util:createLabel("取消",20)
	local noticSize=noticLabel:getContentSize()
	local cancelSize=cancelLabel:getContentSize()
	local cancelPos=cc.p(noticSize.width*0.5+cancelSize.width*0.5,0)
	cancelLabel:setPosition(cancelPos)
	cancelLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LIGHTBLUE))
	tempNode:addChild(cancelLabel)

	local function c(sender, eventType)
    	if eventType==ccui.TouchEventType.ended then
    		tempNode:removeFromParent(true)
    		self:tencent_showLoginBtn()
    	end
	end

	local cancelWidget=ccui.Widget:create()
  	cancelWidget:setContentSize(cc.size(cancelSize.width+20,30))
  	cancelWidget:setTouchEnabled(true)
  	cancelWidget:addTouchEventListener(c)
  	cancelWidget:setPosition(cancelPos)
  	tempNode:addChild(cancelWidget,10)

  	local function delayFun()
  		tempNode:removeFromParent(true)

  		local typeCache=cc.UserDefault:getInstance():getStringForKey("QQ_LOGIN_TYPE_CACHE", "")
  		gc.UserCache:getInstance():setObject("QQ_LOGIN_TYPE",tostring(typeCache))
		gc.UserCache:getInstance():setObject("QQ_LOGIN_AUTO","1")
    	gc.SDKManager:getInstance():loginSDK()

    	self:showWaitCir()
  	end
  	tempNode:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(delayFun)))
end
function SdkLogin.tencent_hideLoginBtn(self)
	if self.m_qqLoginBtnQQ~=nil then
		self.m_qqLoginBtnQQ:setVisible(false)
	end
	if self.m_qqLoginBtnWX~=nil then
		self.m_qqLoginBtnWX:setVisible(false)
	end

	self:showWaitCir()
end
function SdkLogin.tencent_showLoginBtn(self)
	self:hideWaitCir()
	
	if self.m_qqLoginBtnQQ~=nil and self.m_qqLoginBtnWX~=nil then
		self.m_qqLoginBtnQQ:setVisible(true)
		self.m_qqLoginBtnWX:setVisible(true)
		return
	end

	local function cFun(sender, eventType) 
	    if eventType==ccui.TouchEventType.ended then
	    	local tempType=sender:getTag()

	    	self:tencent_hideLoginBtn()
	    	self:showWaitCir()
	    	gc.UserCache:getInstance():setObject("QQ_LOGIN_TYPE",tostring(tempType))
	    	gc.SDKManager:getInstance():loginSDK()
		end
	end

	local winSize=cc.Director:getInstance():getWinSize()
	self.m_qqLoginBtnQQ=gc.CButton:create("update_login_qq.png") 
    self.m_qqLoginBtnQQ:addTouchEventListener(cFun)
    self.m_qqLoginBtnQQ:setPosition(winSize.width*0.5-200,100)
    self.m_qqLoginBtnQQ:setTag(1)
    cc.Director:getInstance():getRunningScene():addChild(self.m_qqLoginBtnQQ,20)

    self.m_qqLoginBtnWX=gc.CButton:create("update_login_wx.png") 
    self.m_qqLoginBtnWX:addTouchEventListener(cFun)
    self.m_qqLoginBtnWX:setPosition(winSize.width*0.5+200,100)
    self.m_qqLoginBtnWX:setTag(2)
    cc.Director:getInstance():getRunningScene():addChild(self.m_qqLoginBtnWX,20)
end
function SdkLogin.hideAgainLoginBtn(self)
	if self.m_loginBtn~=nil then
		self.m_loginBtn:setVisible(false)
	end
end
function SdkLogin.showAgainLoginBtn(self)
	if self.m_loginBtn~=nil then
		self.m_loginBtn:setVisible(true)
		return
	end

	local function cFun(sender, eventType) 
	    if eventType==ccui.TouchEventType.ended then
	    	if _G.SysInfo:isKuaiFaChannel() or _G.SysInfo:isAnZhiChannel() then
		    	-- 快发渠道 不隐藏
		    	self:handleAgainLoginBtnDelayTouch()
		    else
		    	self:hideAgainLoginBtn()
		    end
		    gc.SDKManager:getInstance():loginSDK()
		end
	end

	local winSize=cc.Director:getInstance():getWinSize()
	self.m_loginBtn=gc.CButton:create("general_relogin.png") 
    self.m_loginBtn:addTouchEventListener(cFun)
    self.m_loginBtn:setPosition(winSize.width*0.5,100)
    cc.Director:getInstance():getRunningScene():addChild(self.m_loginBtn,20)
end
function SdkLogin.handleAgainLoginBtnDelayTouch(self)
	if self.m_loginBtn==nil then return end

	local function nF1(_node)
		_node:setTouchEnabled(false)
	end
	local function nF2(_node)
		_node:setTouchEnabled(true)
	end

	local tempTimes=_G.SysInfo:isAnZhiChannel() and 0.5 or 3
	local act=cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(nF1),cc.DelayTime:create(tempTimes),cc.CallFunc:create(nF2))
	act:setTag(6658)
	self.m_loginBtn:stopActionByTag(6658)
	self.m_loginBtn:runAction(act)
end

function SdkLogin.showInternalLoginView(self)
	local function nFun(_uuid)
		gc.UserCache:getInstance():setUserName(tostring(_uuid))
		self:showToServerView(_uuid)
	end
	local loginView=require("mod.login.LoginView")(nFun)
    local loginLayer=loginView:create()
    cc.Director:getInstance():getRunningScene():addChild(loginLayer,100)
end
function SdkLogin.showToServerView(self,_uuid)
	-- _uuid="362593"
	_G.SysInfo:initXmlVersion()
	_G.SysInfo:setUuid(_uuid)

	local function nFun()
		require("mod.login.LoginServerView")()
	end
	LOAD_LOGIN_RES(nFun)
end

function SdkLogin.loginServerByAccount(self)
	local szAccount=gc.UserCache:getInstance():getUserName()
	_G.SysInfo:setSDKUserName(szAccount)

	self:hideWaitCir()

	if _G.SysInfo:isQQSDKChannel() then
		local loginType=gc.UserCache:getInstance():getObject("QQ_LOGIN_TYPE")
		cc.UserDefault:getInstance():setStringForKey("QQ_LOGIN_TYPE_CACHE", loginType)
	end

	local sdkLoginUrl=string.format("%s",_G.SysInfo:urlSDKLogin())

	-- print("sdkLoginUrl=======>>>>>>>>>",sdkLoginUrl)
	local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("POST", sdkLoginUrl)

    local function http_login_handler()
        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            print("http_login_handler response="..response)
            local output   = json.decode(response,1)

            if output.ref==1 then
                local uuid=output.uuid
                self:showToServerView(uuid)
                return
            else
                local function nSureFun()
                	self:loginServerByAccount()
                end
                self:__showRetryTips(string.format("登录失败:%s(%d)",output.msg,output.error),nSureFun)
            end
        else
            local function nSureFun()
            	self:loginServerByAccount()
            end
            self:__showRetryTips("网络错误,请检查网络",nSureFun)
        end
        _G.Util:hideLoadCir()
    end

    xhrRequest:registerScriptHandler(http_login_handler)
    xhrRequest:send(_G.SysInfo:urlSDKLoginSignData())
end

function SdkLogin.__showRetryTips(self,_szContent,_sureFun)
	local function nCancelFun()
		cc.Director:getInstance():endToLua()
	end
	local view=require("mod.general.TipsBox")()
    local layer=view:create(_szContent,_sureFun,nCancelFun)
    view:setSureBtnText("重试")
    view:setCancelBtnText("退出")
    local nowScene = cc.Director:getInstance():getRunningScene()
	nowScene:addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC+10)
end

return SdkLogin