LoginPanel = BaseClass(BaseView)
function LoginPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Login","LoginPanel")
	self.id = "LoginPanel"
	self.loginBGComp = self.ui:GetChild("loginBGComp")
	self.bg = self.ui:GetChild("bg")
	self.imgLogo = self.ui:GetChild("imgLogo")
	self.passwordItem = self.ui:GetChild("passwordItem")
	self.btnLogin = self.ui:GetChild("btnLogin")
	self.btnBind = self.ui:GetChild("btnBind")
	self.btnForgetPassword = self.ui:GetChild("btnForgetPassword")
	self.userNameItem = self.ui:GetChild("userNameItem")
	self.btnComboBox = self.ui:GetChild("btnComboBox")
	self.accountScrollView = self.ui:GetChild("accountScrollView")
	self.btnClose = self.ui:GetChild("btnClose")
	self.btnResetPassword = self.ui:GetChild("btnResetPassword")

	self:Layout()
end
function LoginPanel:InitEvent()
	-- 这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () 
		self:Update()
	end
	ButtonToDelayClick(self.btnLogin , function () self:OnLoginBtnClick() end , 3 , "连接中...")
	self.btnComboBox.onClick:Add(self.OnBtnComboBoxClick , self)
	self.btnForgetPassword.onClick:Add(self.OnBtnForgetPasswordClick , self)
	local function HandleSelectAccountItem(accountData)
		self:SelectAccountItemHandle(accountData)
	end
	self.handler0 = self.model:AddEventListener(LoginConst.SelectAccountItem , HandleSelectAccountItem)

	local function HandleDeleteAccount(accountData)
		self:HandleDeleteAccount(accountData)
	end
	self.handler1 =  self.model:AddEventListener(LoginConst.OnAccountItemDelect , HandleDeleteAccount)

	self.btnClose.onClick:Add(function()
		self.controller:OpenAccountManagerPanel()
	end)

	self.btnBind.onClick:Add(function ()
		self:OnBtnBindClick()
	end)

	self.btnResetPassword.onClick:Add(function()
		self:OnBtnResetPasswordClick()
	end)
end

function LoginPanel:CleanEvent()
	self.model:RemoveEventListener(self.handler0)
	self.model:RemoveEventListener(self.handler1)	
end

-- 布局UI
function LoginPanel:Layout()
	
	-- 以下开始UI布局
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- Dispose use LoginPanel obj:Destroy()
function LoginPanel:__delete()
	self:CleanEvent()
	self:CleanUI()
end

function LoginPanel:InitData()
	self.model = LoginModel:GetInstance()
	self.controller = LoginController:GetInstance()
	self.curAccountContentVisible = false
	self.accountList = {}
	self.isVisitor = false
	self.curAccountData = {}
end

function LoginPanel:InitUI()
	self.accountScrollView = AccountContent.Create(self.accountScrollView)
	self.loginBGComp = LoginBGComp.Create(self.loginBGComp)
	self.userNameItem = LoginInfoItem.Create(self.userNameItem)
	self.passwordItem = LoginInfoItem.Create(self.passwordItem)
	self.accountScrollView:SetVisible(false)
	self.userNameItem:SetIcon(UIPackage.GetItemURL("Login", "zhanghao"))
	self.userNameItem:SetInputTips("请输入手机号码")

	self.passwordItem:SetIcon(UIPackage.GetItemURL("Login" , "mima"))
	self.passwordItem:SetInputTips("请输入密码")
	self.passwordItem:DisplayAsPassword()

	local lastAccountData = self.model:GetLastAccount()
	-- zy("=======LoginPanel lastAccountData " , lastAccountData)
	if not TableIsEmpty(lastAccountData) then
		self.userNameItem:SetContentUI(lastAccountData.userName or "")
		self.passwordItem:SetContentUI(lastAccountData.passWord or "")
		self.isVisitor = lastAccountData.isVisitor
		self.curAccountData = lastAccountData
	end

	self:SetStateUI()
end

function LoginPanel:CleanUI()
	if self.accountScrollView then
		self.accountScrollView:Destroy()
		self.accountScrollView = nil
	end

	if self.loginBGComp then
		self.loginBGComp:Destroy()
		self.loginBGComp = nil
	end

	if self.userNameItem then
		self.userNameItem:Destroy()
		self.userNameItem = nil
	end

	if self.passwordItem then
		self.passwordItem:Destroy()
		self.passwordItem = nil
	end
end

function LoginPanel:Update()
	self:UpdateData()
	self:UpdateUI()
end

function LoginPanel:UpdateData()
	--self:SetAccountData()
end

function LoginPanel:UpdateUI()

end

function LoginPanel:SetAccountData()
	self.accountList = {}
	self.accountList = self.model:GetAccountList()
end

function LoginPanel:OnLoginBtnClick()
	--UnityEngine.PlayerPrefs.DeleteAll()
	local userName = self.userNameItem:GetContent()
	local password = self.passwordItem:GetContent()
	if userName == "" then
		UIMgr.Win_FloatTip("账号不能为空")
		return
	end

	if password == "" then
		UIMgr.Win_FloatTip("密码不能为空")
		return
	end

	local isVisitor = 0 
	if not TableIsEmpty(self.curAccountData) then
		if userName ~= self.curAccountData.userName then
			self.isVisitor = false -- 手动输入名字和密码
		else
			if self.isVisitor then
				isVisitor = 1 
				userName = DeviceInfo:GetDeviceUID() 
			end
		end
	end

	self.model:SetCurRegistAccount(userName , password  , self.isVisitor)
	self.controller:ReqLoginAccount(userName , password , isVisitor)
end

function LoginPanel:OnBtnComboBoxClick()
	self.accountScrollView:SetVisible(not self.curAccountContentVisible)
	self:SetAccountContentVisibleState(not self.curAccountContentVisible)
	self.accountScrollView:SetData()
	self.accountScrollView:SetUI()
end

function LoginPanel:SetAccountContentVisibleState(state)
	self.curAccountContentVisible = state or false
end

function LoginPanel:OnBtnForgetPasswordClick()
	self.controller:OpenPhoneBindPanel()
end

function LoginPanel:OnBtnResetPasswordClick()
	
	self.controller:OpenResetPasswordPanel(self.curAccountData)
end

function LoginPanel:SelectAccountItemHandle(accountData)
	if not TableIsEmpty(accountData) then
		self.isVisitor = accountData.isVisitor
		self.userNameItem:SetContentUI(accountData.userName)
		self.passwordItem:SetContentUI(accountData.passWord)
		DelayCall(function()
			self.accountScrollView:SetVisible(false)
			self:SetAccountContentVisibleState(false)
		end , 0.15)
		self.curAccountData = accountData
	end
end

function LoginPanel:HandleDeleteAccount(accountData)
	self.accountScrollView:SetVisible(true)
	self:SetAccountContentVisibleState(true)
	self.accountScrollView:SetData()
	self.accountScrollView:SetUI()
end

function LoginPanel:OnBtnBindClick()
	local isVisitorBind = true
	self.controller:OpenCreateAccountPanel(isVisitorBind)
end

function LoginPanel:SetStateUI()
	if self.model:IsHasVisitor() then
		self.btnBind.visible = true
		self.bg.width = 492
		self.bg.height = 540
	else
		self.btnBind.visible = false
		self.bg.width = 492
		self.bg.height = 420
	end
end