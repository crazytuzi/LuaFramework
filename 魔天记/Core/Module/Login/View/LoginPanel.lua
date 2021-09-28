require "Core.Module.Common.Panel"
require "net.LoginHttp"

LoginPanel = Panel:New();
LoginPanel.OPEN_TESTCODE_PANEL = "OPEN_TESTCODE_PANEL"

local useSdkToken = GameConfig.instance.useSdkToken
function LoginPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	LogHttp.SendLog("log/load")
	LoginHttp.SetIsLoginCallBack(false)
	local o = UserConfig.GetInstance();
	local userName = o:GetValue("username");
	if(userName ~= "") then
		self._inputName.value = userName
	else
		self._inputName.value = ""
	end
	
	local password = o:GetValue("password");
	if(password ~= "") then
		self._inputPassword.value = password
	else
		self._inputPassword.value = ""
	end
	
	self._txtVersion.text = LogHelp.instance.app_ver
	SDKHelper.instance:AutoLogin()
	SoundManager.instance:PlayMusic("bgm_login");
	if GameConfig.instance.autoLogin then self:StartLogin(self) end
end

function LoginPanel:IsPopup()
	return false;
end


function LoginPanel:GetUIOpenSoundName()
	return ""
end

function LoginPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtLabel = UIUtil.GetChildInComponents(txts, "txtLabel");
	self._txtVersion = UIUtil.GetChildInComponents(txts, "txtVersion")
	self._inputParent = UIUtil.GetChildByName(self._trsContent, "devPanel/inputParent").gameObject
	local inputs = UIUtil.GetComponentsInChildren(self._trsContent, "UIInput");
	self._inputName = UIUtil.GetChildInComponents(inputs, "inputUserName");
	self._inputPassword = UIUtil.GetChildInComponents(inputs, "inputPassWord");
	self._inputToken = UIUtil.GetChildInComponents(inputs, "inputSdkToken");
	self._btnLogin = UIUtil.GetChildByName(self._trsContent, "UIButton", "devPanel/btnLogin");
	self._btnLogin1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "devPanel/btnLogin1");
	self._btnLogin2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "devPanel/btnLogin2");
	
	self._btnLogin1.gameObject:SetActive(false)
	self._btnLogin2.gameObject:SetActive(false)
	
	self._inputParent:SetActive(false)
	self._sdkTokenParent = UIUtil.GetChildByName(self._trsContent, "trsSdkTokenLogin").gameObject
	self._sdkTokenParent:SetActive(useSdkToken)
	
	self._alert = UIUtil.GetChildByName(self._trsContent, "UITexture", "alert/bg")
	--奥菲才需要这个闪屏
	if(GameConfig.instance.platformId == 1)  then
   		self.timer = Timer.New(function()	    	
        self._alert.gameObject:SetActive(false)
   		 end, 0.5, 1):Start()
   	else
   		self._alert.gameObject:SetActive(false)
	end

end

function LoginPanel:_InitListener()
	self._onClickBtnLogin = function(go) self:_OnClickBtnLogin(self) end
	UIUtil.GetComponent(self._btnLogin, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLogin);
	self._onClickBtnLogin1 = function(go) self:_OnClickBtnLogin1(self) end
	UIUtil.GetComponent(self._btnLogin1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLogin1);
	self._onClickBtnLogin2 = function(go) self:_OnClickBtnLogin2(self) end
	UIUtil.GetComponent(self._btnLogin2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLogin2);
	MessageManager.AddListener(LoginManager, LoginManager.LOGINSUCCESS, LoginPanel.LoginSuccess, self)
	MessageManager.AddListener(LoginManager, LoginManager.LOGINFAILD, LoginPanel.LoginFail, self)
	MessageManager.AddListener(LoginPanel, LoginPanel.OPEN_TESTCODE_PANEL, LoginPanel.OpenTestCodePanel)
end

function LoginPanel.OpenTestCodePanel()
	ModuleManager.SendNotification(LoginNotes.OPEN_GOTOGAME_PANEL)
end

function LoginPanel:CheckTestCode()
	coroutine.start(LoginHttp.CheckTestCode, function(result)
		if(result) then
			
			if(result.need == 0) then
				self:StartLogin()
			else
				ModuleManager.SendNotification(LoginNotes.OPEN_TESTCODE_PANEL)
			end
		end
	end
	)
end


function LoginPanel:LoginSuccess()
	if(GameConfig.instance.useSdk) then
		self:CheckTestCode()
	else
		self:StartLogin()
	end
end

function LoginPanel:StartLogin()
	if(useSdkToken) then
		if(self._inputToken.value ~= "") then
			LoginHttp.LoginCallBack({token = self._inputToken.value})
		end
	else
		-- if(self._loginC) then
		-- 	coroutine.stop(self._loginC)
		-- 	self._loginC = nil
		-- end
		-- self._loginC =	coroutine.start(LoginHttp.TryLogin, self._inputName.value, self._inputPassword.value)
		coroutine.start(LoginHttp.TryLogin, self._inputName.value, self._inputPassword.value)
	end	
end


function LoginPanel:LoginFail()
	-- GameConfig.instance.platformTagValue 对应打包平台的设置项
	-- 没有接sdk的处理和有接sdk的处理不同
	if(not GameConfig.instance.useSdk) then
		self._inputParent:SetActive(true)
	end

 
	if(GameConfig.instance.platformId == 3) then
		self._btnLogin.gameObject:SetActive(false)	
		self._btnLogin1.gameObject:SetActive(true)
		self._btnLogin2.gameObject:SetActive(true)		
	end
end

function LoginPanel:_OnClickBtnLogin1(self)
	if GameConfig.PreloadAppSplit() and not AppSplitDownProxy.ForceLoad() then return end
	SDKHelper.instance:AutoLoginSpecial1()
	
	
end

function LoginPanel:_OnClickBtnLogin2(self)
	if GameConfig.PreloadAppSplit() and not AppSplitDownProxy.ForceLoad() then return end
	SDKHelper.instance:AutoLoginSpecial2()
	
	
end

function LoginPanel:_OnClickBtnLogin(self)
	if GameConfig.PreloadAppSplit() and not AppSplitDownProxy.ForceLoad() then return end
	
	if(GameConfig.instance.useSdk) then
		SDKHelper.instance:AutoLogin()
	else
		local o = UserConfig.GetInstance();
		o:SetConfig("username", self._inputName.value);
		o:SetConfig("password", self._inputPassword.value);
		o:Save();
		self:StartLogin()
		-- coroutine.start(LoginPanel._LoadServerInfo, self._inputName.value, self._inputPassword.value)
	end
end

-- function LoginPanel._LoadServerInfo(userName, passWord)
--    LoginHttp.TryLogin(userName, passWord);
-- end
function LoginPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function LoginPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnLogin, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnLogin = nil;
	
	UIUtil.GetComponent(self._btnLogin1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnLogin1 = nil;
	
	UIUtil.GetComponent(self._btnLogin2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnLogin2 = nil;
	MessageManager.RemoveListener(LoginManager, LoginManager.LOGINSUCCESS, LoginPanel.LoginSuccess)
	MessageManager.RemoveListener(LoginManager, LoginManager.LOGINFAILD, LoginPanel.LoginFail)
	MessageManager.RemoveListener(LoginPanel, LoginPanel.OPEN_TESTCODE_PANEL, LoginPanel.OpenTestCodePanel)
end

function LoginPanel:_DisposeReference()
	self._btnLogin = nil;
	self._inputName = nil
	self._inputPassword = nil
end
