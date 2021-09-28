CreateAccountPanel = BaseClass(BaseView)
function CreateAccountPanel:__init( isVisitorBind )
	self.ui = UIPackage.CreateObject("Login","CreateAccountPanel")
	self.id = "CreateAccountPanel"

	self.loginBGComp = self.ui:GetChild("loginBGComp")
	self.btnClose = self.ui:GetChild("btnClose")
	self.bg0 = self.ui:GetChild("bg0")
	self.bg1 = self.ui:GetChild("bg1")
	self.userNameItem = self.ui:GetChild("userNameItem")
	self.passwordItem0 = self.ui:GetChild("passwordItem0")
	self.passwordItem1 = self.ui:GetChild("passwordItem1")
	self.btnCreateAccount = self.ui:GetChild("btnCreateAccount")
	self.ctrl = LoginController:GetInstance()
	self:Layout()
	self.isVisitorBind = isVisitorBind
end
function CreateAccountPanel:InitEvent()
	-- 这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () end
	self.btnCreateAccount.onClick:Add(function ()
		self:OnBtnCreateAccountClick()
	end)
	self.btnClose.onClick:Add(function()
		self.ctrl:OpenAccountManagerPanel()
	end)
end
-- 布局UI
function CreateAccountPanel:Layout()
	-- 以下开始UI布局
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- Dispose use CreateAccountPanel obj:Destroy()
function CreateAccountPanel:__delete()
	if self.loginBGComp then
		self.loginBGComp:Destroy()
		self.loginBGComp = nil
	end

	if self.userNameItem then
		self.userNameItem:Destroy()
		self.userNameItem = nil
	end

	if self.passwordItem0 then
		self.passwordItem0:Destroy()
		self.passwordItem0 = nil
	end

	if self.passwordItem1 then
		self.passwordItem1:Destroy()
		self.passwordItem1 = nil
	end
end

function CreateAccountPanel:InitData()
end

function CreateAccountPanel:InitUI()
	self.loginBGComp = LoginBGComp.Create(self.loginBGComp)
	self.userNameItem = LoginInfoItem.Create(self.userNameItem)
	self.passwordItem0 = LoginInfoItem.Create(self.passwordItem0)
	self.passwordItem1 = LoginInfoItem.Create(self.passwordItem1)
	
	self.userNameItem:SetInputTips("请输入手机号码")
	self.userNameItem:SetIcon(UIPackage.GetItemURL("Login" , "zhanghao"))
	self.userNameItem:SetKeyBoardType(5)
	self.passwordItem0:SetInputTips("请输入密码(6-15个字符)")
	self.passwordItem0:DisplayAsPassword()
	self.passwordItem0:SetIcon(UIPackage.GetItemURL("Login" , "mima"))
	self.passwordItem0:SetKeyBoardType(1)
	self.passwordItem1:SetInputTips("请再次输入密码")
	self.passwordItem1:DisplayAsPassword()
	self.passwordItem1:SetIcon(UIPackage.GetItemURL("Login" , "mima"))
	self.passwordItem1:SetKeyBoardType(1)
end

function CreateAccountPanel:OnBtnCreateAccountClick()
	local userName , replaceCnt0 = self.userNameItem:GetContent()
	local password0 , replaceCnt1 = self.passwordItem0:GetContent()
	local password1 , replaceCnt2 = self.passwordItem1:GetContent()

	if replaceCnt0 > 0 then
		UIMgr.Win_FloatTip("手机号码非法，不能含有空白字符")
		return
	end

	if replaceCnt1 > 0 then
		UIMgr.Win_FloatTip("密码非法，不能含有空白字符")
		return
	end

	if replaceCnt2 > 0 then
		UIMgr.Win_FloatTip("确认密码非法，不能含有空白字符")
		return
	end

	if #userName == 0 then
		UIMgr.Win_FloatTip("账号不能为空")
		return
	end
	if #password0 == 0  then
		UIMgr.Win_FloatTip("密码不能为空")
		return
	end

	if not CheckIsMobilePhoneNum(userName)  then
		UIMgr.Win_FloatTip("手机号码错误")
		--if GameConst.Debug ~= true then
			return
		--end
	end
	if #password0 < 6 and #password1 < 6 then
		UIMgr.Win_FloatTip("密码字符数太少")
		return
	end
	if #password0 > 15 and #password1 >15 then
		UIMgr.Win_FloatTip("密码字符数超过限制")
		return
	end
	if #password1 == 0 then
		UIMgr.Win_FloatTip("请输入确认密码")
		return
	end

	if password0 ~= password1 then
		return
		UIMgr.Win_FloatTip("确认密码不对")
	end

	if self.isVisitorBind then
		LoginModel:GetInstance():SetCurRegistAccount(userName , password0  , true)
		self.ctrl:ReqVisitorBind(userName , password0)
	else
		self.ctrl:ReqRegistAccount(userName , password0 , self.isVisitorBind)	
	end
end



