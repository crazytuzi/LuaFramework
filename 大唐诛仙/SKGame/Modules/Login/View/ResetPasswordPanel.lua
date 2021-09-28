ResetPasswordPanel = BaseClass(BaseView)
function ResetPasswordPanel:__init( accountData )
	self.ui = UIPackage.CreateObject("Login","ResetPasswordPanel"); -- self.URL = "ui://0qk3a0fjxn4519";
	
	self.loginBGComp = self.ui:GetChild("loginBGComp")
	self.bg0 = self.ui:GetChild("bg0")
	self.bg1 = self.ui:GetChild("bg1")
	self.userNameItem = self.ui:GetChild("userNameItem")
	self.passwordItem0 = self.ui:GetChild("passwordItem0")
	self.passwordItem1 = self.ui:GetChild("passwordItem1")
	self.passwordItem2 = self.ui:GetChild("passwordItem2")
	self.btnResetPassword = self.ui:GetChild("btnResetPassword")
	self.btnClose = self.ui:GetChild("btnClose")
	self.id = "ResetPasswordPanel"
	self:InitData(accountData)
	self:InitEvent()
	self:InitUI()

end

function ResetPasswordPanel:InitEvent()
	self.closeCallback = function() end
	self.openCallback  = function() end
	self.btnResetPassword.onClick:Add(function()
		self:OnBtnResetPasswordClick()
	end)
	self.btnClose.onClick:Add(function() 
		self.controller:OpenLoginPanel()
	end)
end

function ResetPasswordPanel:__delete()
	if self.loginBGComp then
		self.loginBGComp:Destroy()
		self.loginBGComp = nil
	end

	self.controller = nil
	self.model = nil
	self.accountData = {}
end

function ResetPasswordPanel:InitData(accountData)
	self.controller = LoginController:GetInstance()
	self.model = LoginModel:GetInstance()
	self.accountData = accountData or {}

end

function ResetPasswordPanel:InitUI()
	self.userNameItem = LoginInfoItem.Create(self.userNameItem)
	self.passwordItem0 = LoginInfoItem.Create(self.passwordItem0)
	self.passwordItem1 = LoginInfoItem.Create(self.passwordItem1)
	self.passwordItem2 = LoginInfoItem.Create(self.passwordItem2)

	if not TableIsEmpty(self.accountData) then
		self.userNameItem:SetContentUI(self.accountData.userName)
	end
	self.userNameItem:SetInputTips("请输入用户名")
	self.userNameItem:SetIcon(UIPackage.GetItemURL("Login" , "zhanghao"))
	self.userNameItem:SetKeyBoardType(5)
	self.userNameItem:SetEditable(false)

	self.passwordItem0:SetInputTips("请输入旧密码")
	self.passwordItem0:DisplayAsPassword()
	self.passwordItem0:SetIcon(UIPackage.GetItemURL("Login" , "mima"))
	self.passwordItem0:SetKeyBoardType(1)
	self.passwordItem1:SetInputTips("请输入新密码(6-15个字符)")
	self.passwordItem1:DisplayAsPassword()
	self.passwordItem1:SetIcon(UIPackage.GetItemURL("Login" , "mima"))
	self.passwordItem1:SetKeyBoardType(1)
	self.passwordItem2:SetInputTips("请确认新密码")
	self.passwordItem2:DisplayAsPassword()
	self.passwordItem2:SetIcon(UIPackage.GetItemURL("Login" , "mima"))
	self.passwordItem2:SetKeyBoardType(1)

	self.loginBGComp = LoginBGComp.Create(self.loginBGComp)
end

function ResetPasswordPanel:OnBtnResetPasswordClick()
	local userName , replaceCnt0 = self.userNameItem:GetContent()
	local password0 , replaceCnt1 = self.passwordItem0:GetContent()
	local password1 , replaceCnt2 = self.passwordItem1:GetContent()
	local password2 , replaceCnt3 = self.passwordItem2:GetContent()

	if replaceCnt0 > 0 then
		UIMgr.Win_FloatTip("手机号码非法，不能含有空白字符")
		return
	end

	if replaceCnt1 > 0 then
		UIMgr.Win_FloatTip("旧密码非法，不能含有空白字符")
		return
	end

	if replaceCnt2 > 0 then
		UIMgr.Win_FloatTip("新密码非法，不能含有空白字符")
		return
	end

	if replaceCnt3 > 0 then
		UIMgr.Win_FloatTip("确认密码非法，不能含有空白字符")
		return
	end

	if #userName == 0 then
		UIMgr.Win_FloatTip("账号不能为空")
		return
	end
	if #password0 == 0  then
		UIMgr.Win_FloatTip("旧密码不能为空")
		return
	end

	if #password1 == 0 then
		UIMgr.Win_FloatTip("新密码不能为空")
		return
	end

	if #password2 == 0 then
		UIMgr.Win_FloatTip("确认密码不能为空")
		return
	end

	if not TableIsEmpty(self.accountData) then
		if self.accountData.isVisitor then
			UIMgr.Win_FloatTip("该账号为游客账号，请先转正")
			return
		end 

		if not CheckIsMobilePhoneNum(userName)  then
			UIMgr.Win_FloatTip("手机号码错误")
			--if GameConst.Debug ~= true then
				return
			--end
		end

		if userName ~= self.accountData.userName or password0 ~= self.accountData.passWord then
			UIMgr.Win_FloatTip("手机号码错误或旧密码错误")
			return
		end

	end

	if #password1 < 6 or #password1 > 15 then
		UIMgr.Win_FloatTip("新密码错误")
		return
	end

	if password1 ~= password2 then
		UIMgr.Win_FloatTip("新密码不一致")
		return
	end

	self.model:SetCurResetPasswordInfo(self.accountData.userId or 0 , userName , password0 , password1)
	self.controller:ReqResetPassword(userName , password0 , password1)
end
