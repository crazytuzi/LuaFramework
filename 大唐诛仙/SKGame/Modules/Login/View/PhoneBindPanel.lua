PhoneBindPanel = BaseClass(BaseView)

function PhoneBindPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Login","PhoneBindPanel");
	self.id = "PhoneBindPanel"
	
	self.loginBGComp = self.ui:GetChild("loginBGComp")
	self.bg0 = self.ui:GetChild("bg0")
	self.bg1 = self.ui:GetChild("bg1")
	self.bg2 = self.ui:GetChild("bg2")
	self.labelPhoneNum = self.ui:GetChild("labelPhoneNum")
	self.btnSendMessage = self.ui:GetChild("btnSendMessage")
	self.btnClose = self.ui:GetChild("btnClose")
	self:Layout()
end

function PhoneBindPanel:InitEvent()
	-- 这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () end
	self.btnSendMessage.onClick:Add(function ()
		self:OnBtnSendMessageClick()
	end)

	self.btnClose.onClick:Add(function ()
		self.ctrl:OpenLoginPanel()
	end)

	self.handler0 = GlobalDispatcher:AddEventListener(EventName.GetBackPassword , function ()
		
		self:HandleGetBackPassword()
	end)
end

-- 布局UI
function PhoneBindPanel:Layout()
	
	-- 以下开始UI布局
	self:InitUI()
	self:InitData()
	self:InitEvent()
end

-- Dispose use PhoneBindPanel obj:Destroy()
function PhoneBindPanel:__delete()
	if self.loginBGComp then
		self.loginBGComp:Destroy()
		self.loginBGComp = nil
	end

	RenderMgr.Remove("PhoneBindPanel.CountDown")
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function PhoneBindPanel:InitUI()
	self.loginBGComp = LoginBGComp.Create(self.loginBGComp)
end

function PhoneBindPanel:InitData()
	self.ctrl = LoginController:GetInstance()
	self.loginModel = LoginModel:GetInstance()
	self.countDownTime = 0
end


function PhoneBindPanel:OnBtnSendMessageClick()
	local lastAccountTelePhone = self.loginModel:GetLastAccountBindPhone()
	local curAccountTelePhone = self.labelPhoneNum.text

	if lastAccountTelePhone == "" or lastAccountTelePhone == 0 then
		UIMgr.Win_FloatTip("此手机号码尚未在设置界面绑定过")
		return
	end

	if curAccountTelePhone == "" or CheckIsMobilePhoneNum(curAccountTelePhone) == false or curAccountTelePhone ~= lastAccountTelePhone then
		UIMgr.Win_FloatTip("请输入正确的绑定的手机号码")
		return
	end

	self.ctrl:ReqGetbackPassword(string.trim(curAccountTelePhone))
end

function PhoneBindPanel:HandleGetBackPassword()
	self.btnSendMessage.touchable = false
	self.btnSendMessage.title = "重新发送（60S）"
	self.countDownTime = 60
	RenderMgr.Add(function () self:CountDown() end, "PhoneBindPanel.CountDown")
end

function PhoneBindPanel:CountDown()
	self.countDownTime = self.countDownTime - Time.deltaTime
	self.btnSendMessage.title = StringFormat("重新发送（{0}S）" , math.ceil(self.countDownTime))
	if self.countDownTime <= 0 then
		self:StopCountDown()
	end
end

function PhoneBindPanel:StopCountDown()
	RenderMgr.Remove("PhoneBindPanel.CountDown")

	self.btnSendMessage.title = "发送信息"
	self.countDownTime = 0
	self.btnSendMessage.touchable = true
end