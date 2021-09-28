AccountManagerPanel = BaseClass(BaseView)
function AccountManagerPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Login","AccountManagerPanel")
	self.id = "AccountManagerPanel"
	self.loginBGComp = self.ui:GetChild("loginBGComp")
	self.bg = self.ui:GetChild("bg")
	self.bgGameName = self.ui:GetChild("bgGameName")
	self.btnCreateAccount = self.ui:GetChild("btnCreateAccount")
	self.btnLogin = self.ui:GetChild("btnLogin")
	self.btnVisitorLogin = self.ui:GetChild("btnVisitorLogin")

	self:Layout()
end
function AccountManagerPanel:InitEvent()
	-- 这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () 
		self:Update()
	end
	self.btnCreateAccount.onClick:Add(function ()
		self:OnBtnCreateAccountClick()
	end)
	self.btnLogin.onClick:Add(function ()
		self:OnBtnLoginClick()
	end)
	self.btnVisitorLogin.onClick:Add(function ()
		self:OnBtnVisitorLoginClick()
	end)
end
-- 布局UI
function AccountManagerPanel:Layout()
	-- 以下开始UI布局
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- Dispose use AccountManagerPanel obj:Destroy()
function AccountManagerPanel:__delete()
	if self.loginBGComp then
		self.loginBGComp:Destroy()
		self.loginBGComp = nil
	end
end

function AccountManagerPanel:InitData()
	self.controller = LoginController:GetInstance()
	self.model = LoginModel:GetInstance()
end

function AccountManagerPanel:InitUI()
	self.loginBGComp = LoginBGComp.Create(self.loginBGComp)
end

function AccountManagerPanel:OnBtnCreateAccountClick()
	local isVisitorBind = false
	self.controller:OpenCreateAccountPanel(isVisitorBind)
end

function AccountManagerPanel:OnBtnLoginClick()
	self.controller:OpenLoginPanel()
end

function AccountManagerPanel:OnBtnVisitorLoginClick()
	local visitorName = self.model:GetVisitorName()
	local visitorPassWord = self.model:GetVisitorPassWord()
	local isVisitor = true
	if visitorName ~= "" and visitorPassWord then
		self.model:SetCurRegistAccount(visitorName, visitorPassWord, isVisitor)
		self.controller:ReqLoginAccount(DeviceInfo:GetDeviceUID(), visitorPassWord, 1)
	end
end

function AccountManagerPanel:Update()
	self:UpdateData()
	self:UpdateUI()
end

function AccountManagerPanel:UpdateData()

end

function AccountManagerPanel:UpdateUI()
	if self.model:IsHasAccount() then
		self.btnVisitorLogin.visible = false
		self.bg.height = 283
	else
		self.btnVisitorLogin.visible = true
		self.bg.height = 397
	end
end
