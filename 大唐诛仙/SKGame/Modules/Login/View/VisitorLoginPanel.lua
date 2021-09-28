VisitorLoginPanel = BaseClass(BaseView)

function VisitorLoginPanel:__init( accountData )
	self.ui = UIPackage.CreateObject("Login","VisitorLoginPanel")
	self.id = "VisitorLoginPanel"
	self.loginBGComp = self.ui:GetChild("loginBGComp")
	self.bg0 = self.ui:GetChild("bg0")
	self.imgAccount = self.ui:GetChild("imgAccount")
	self.labelName = self.ui:GetChild("labelName")
	self.btnBind = self.ui:GetChild("btnBind")
	self.groupAccount = self.ui:GetChild("groupAccount")
	self.btnLogin = self.ui:GetChild("btnLogin")
	-- self.btnLogin:GetChild("upLayer").url = UIPackage.GetItemURL("Login" , "dengluyouxi")
	self.loaderBGAlpha = self.ui:GetChild("loaderBGAlpha")

	self.btnSelectServer = self.ui:GetChild("btnSelectServer")
	self.btnSelectServer = BtnSelectServer.Create(self.btnSelectServer)

	self:Layout()
	self:SetAccountData(accountData)
	self:SetUI()
end

function VisitorLoginPanel:InitEvent()
	-- 这里注册各种一次性创建事件
	-- self.closeCallback = function () end
	local ggModel = GgModel:GetInstance()
	local ggCtrl = GgController:GetInstance()
	self.openCallback  = function ()
		if ggModel:IsCanOpenNotice() == true then
			ggCtrl:Open()
			ggModel:SetNoticeOpenRecord()
		end
	end
	self.btnBind.onClick:Add(function (e)
		local isVisitorBind = true
		self.ctrl:OpenCreateAccountPanel(isVisitorBind)
	end)
	local t = 0
	self.btnLogin.onClick:Add(function (e)
		t = os.clock() - t
		if t < 2 then print("操作过快，请稍后再试！") return end
		t = os.clock()
		self:OnBtnLoginClick()
	end)
	self.btnSelectServer.ui.onClick:Add(function (e)
		self.ctrl:OpenServerSelectPanel(self.accountData)
	end)
	local function HandleSelectServer(serverData)
		self:HandleSelectServer(serverData)
	end
	self.eventHandler0 =  GlobalDispatcher:AddEventListener(EventName.SelectServer , HandleSelectServer)

end

-- 布局UI
function VisitorLoginPanel:Layout()
	-- 以下开始UI布局
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- Dispose use VisitorLoginPanel obj:Destroy()
function VisitorLoginPanel:__delete()
	GlobalDispatcher:RemoveEventListener(self.eventHandler0)
	if self.loginBGComp then
		self.loginBGComp:Destroy()
		self.loginBGComp = nil
	end

	if self.btnSelectServer then
		self.btnSelectServer:Destroy()
		self.btnSelectServer = nil
	end
	
end

function VisitorLoginPanel:InitData()
	self.accountData = {}
	self.serverData = {}
	self.loginModel = LoginModel:GetInstance()
	self.ctrl = LoginController:GetInstance()
end

function VisitorLoginPanel:SetAccountData(accountData)
	self.accountData = accountData or {}
end

function VisitorLoginPanel:SetServerData(serverData)
	self.serverData = serverData or {}
end

function VisitorLoginPanel:SetServerUI()
	if not TableIsEmpty(self.serverData) then
		self.btnSelectServer:SetServerName(self.serverData.serverName or "未选择服务器")
		local serverStateIcon = ""
		local isGrayed = false
		if self.serverData.severState == LoginConst.ServerState.Smooth then
			serverStateIcon = UIPackage.GetItemURL("Common" , "1liuchang")
		elseif self.serverData.severState == LoginConst.ServerState.Crowd then
			serverStateIcon = UIPackage.GetItemURL("Common" , "2yongji")
		elseif self.serverData.severState == LoginConst.ServerState.Hot then
			serverStateIcon = UIPackage.GetItemURL("Common" , "3huobao")
		elseif self.serverData.severState == LoginConst.ServerState.Close then
			--serverStateIcon = UIPackage.GetItemURL("")
		elseif self.serverData.severState == LoginConst.ServerState.Maintenance then
			serverStateIcon = UIPackage.GetItemURL("Common" , "1liuchang")
			isGrayed = true
		end
		
		self.btnSelectServer:SetGrayed(isGrayed)
		self.btnSelectServer:SetServerState(serverStateIcon)
	else
		self.btnSelectServer:SetServerName("未选择服务器")
	end
end

function VisitorLoginPanel:InitUI()
	self.loginBGComp = LoginBGComp.Create(self.loginBGComp)
	self.loginBGComp:SetMaskVisible(false)
	self.loaderBGAlpha.url = "Icon/Login/bgAlpha"
end

function VisitorLoginPanel:SetUI()
	if not TableIsEmpty(self.accountData) then
		local serverData = self.loginModel:GetLastServer()
		if not TableIsEmpty(serverData) then
			self.serverData = serverData
			
			self.btnSelectServer:SetServerName(serverData.serverName or "未选择服务器")
			local serverStateIcon = ""
			local isGrayed = false
			if serverData.severState == LoginConst.ServerState.Smooth then
				serverStateIcon = UIPackage.GetItemURL("Common" , "1liuchang")
			elseif serverData.severState == LoginConst.ServerState.Crowd then
				serverStateIcon = UIPackage.GetItemURL("Common" , "2yongji")
			elseif serverData.severState == LoginConst.ServerState.Hot then
				serverStateIcon = UIPackage.GetItemURL("Common" , "3huobao")
			elseif serverData.severState == LoginConst.ServerState.Close then
				--serverStateIcon = UIPackage.GetItemURL("")
			elseif serverData.severState == LoginConst.ServerState.Maintenance then
				serverStateIcon = UIPackage.GetItemURL("Common" , "1liuchang")
				isGrayed = true
			end
			
			self.btnSelectServer:SetGrayed(isGrayed)
			self.btnSelectServer:SetServerState(serverStateIcon)
		else
			--如果当前没有选择服务器，则默认选中最新的服务器
			self.loginModel:SetSelectNewestServer()
		end

		if self.accountData.isVisitor == true then
			self.btnBind.visible = true
			self.btnBind.title = "游客绑定"
			self.labelName.text = StringFormat("{0}{1}{2}" , "游客" , self.accountData.userName , "  进入游戏")
		else
			self.btnBind.visible = false
			self.btnBind.title = "进入游戏"
			self.labelName.text = StringFormat("{0}{1}", self.accountData.userName , "  进入游戏")
		end
	end
end

function VisitorLoginPanel:OnBtnLoginClick()
	
	if self.labelName.text ~= "" and (not TableIsEmpty(self.serverData)) and (not TableIsEmpty(self.accountData)) and (not self:CheckIsMainTain()) then
		self.ctrl:C_LoginGame(self.accountData)
		self.loginModel:SetLastAccount(self.accountData)
	end
end

function VisitorLoginPanel:HandleSelectServer(serverData)
	if serverData == nil then return end
	self:SetServerData(serverData)
	self:SetServerUI()
	
end

function VisitorLoginPanel:PopUpLoginNameTips()
	self.ctrl:OpenLoginNameTips(self.accountData)
end

function VisitorLoginPanel:CheckIsMainTain()
	if not TableIsEmpty(self.serverData) then
		if self.serverData.endStopTime and self.serverData.endStopTime > 0 then
			local diffTime = TimeTool.GetDiffTime(self.serverData.endStopTime)
			if diffTime > 0 then
				local strDiffTime = TimeTool.GetTimeDHM(diffTime)
				local strTips = StringFormat("十分抱歉，服务器正在维护中，请在约{0}后重试" , strDiffTime)
				self.ctrl:PopUpMaintainTips(strTips)
				return true
			end
		end
	end
	return false
end