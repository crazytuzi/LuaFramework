local CLoginServerPage = class("CLoginServerPage", CPageBase)

function CLoginServerPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CLoginServerPage.OnInitPage(self)
	self.m_ServerBtn = self:NewUI(1, CButton)
	self.m_ConnectBtn = self:NewUI(2, CButton)
	self.m_ChangeAccountBtn = self:NewUI(3, CButton)
	self.m_NoticeBtn = self:NewUI(4, CButton)
	self.m_ScanQRCodeBtn = self:NewUI(5, CButton)

	self.m_ServerBtn:AddUIEvent("click", callback(self, "SelectServerView"))
	self.m_ConnectBtn:AddUIEvent("click", callback(self, "ConnectServer"))
	self.m_ChangeAccountBtn:AddUIEvent("click", callback(self, "ChangeAccount"))
	self.m_ScanQRCodeBtn:AddUIEvent("click", callback(self, "ScanQRCode"))
	self.m_NoticeBtn:SetActive(true)
	self.m_ScanQRCodeBtn:SetActive(g_LoginCtrl:IsSdkLogin() and (not Utils.IsPC()) and Utils.IsDevUser())
	self.m_NoticeBtn:AddUIEvent("click", callback(self, "ShowNotice"))
	self.m_ChangeAccountBtn:SetActive(not g_LoginCtrl:IsSdkLogin())
end

function CLoginServerPage.OnShowPage(self)
	local bShowServer = g_ServerCtrl:IsInit()
	if g_LoginCtrl:IsSdkLogin() then
		bShowServer = bShowServer and g_SdkCtrl:IsLogin()
	end
	if bShowServer then
		local dServer = IOTools.GetClientData("login_server")
		if dServer and dServer.server_id then
			local dNew = g_ServerCtrl:GetServerByID(dServer.server_id)
			if dNew then
				table.update(dServer, dNew)
			else
				dServer = g_ServerCtrl:GetNewestServer()
			end
		else
			dServer = g_ServerCtrl:GetNewestServer()
		end
		self:SetServer(dServer)
	end
	self.m_ServerBtn:SetActive(bShowServer)
	if g_LoginCtrl:IsForceShowNotice() then
		CLoginNoticeView:ShowView()
	end
end

function CLoginServerPage.ScanQRCode(self)
	CQRCodeScanView:ShowView()
end

function CLoginServerPage.ShowNotice(self)
	if g_LoginCtrl:GetNoticeMd5() then
		CLoginNoticeView:ShowView()
	else
		g_NotifyCtrl:FloatMsg("暂无公告")
	end
end

function CLoginServerPage.SetServer(self, dServer)
	self.m_Server = dServer
	if self.m_Server  then
		IOTools.SetClientData("login_server", self.m_Server)
		self.m_ServerBtn:SetText(self.m_Server.name)
	end
end

function CLoginServerPage.SelectServerView(self)
	CSelectServerView:ShowView(
		function (oView)
			oView:SetConfirmCb(callback(self, "Login"))
			oView:SetServer(self.m_Server)
		end
	)
end

function CLoginServerPage.Login(self, dServer)
	self:SetServer(dServer)
	self:ConnectServer()
end

function CLoginServerPage.IsCanConnect(self)
	if g_LoginCtrl:IsSdkLogin() then
		if not g_SdkCtrl:IsInit() then
			print("初始化失败, 重新初始化")
			g_SdkCtrl:Init()
			return false
		end
		if not g_SdkCtrl:IsLogin() then
			print("登录失败, 重新登录")
			g_SdkCtrl:Login()
			return false
		end
	end
	if not self.m_Server then
		g_NotifyCtrl:FloatMsg("请选择服务器")
		return false
	end
	if g_AttrCtrl.pid ~= 0 then
		print("正在加载地图...")
		return false
	end
	return true
end

function CLoginServerPage.ConnectServer(self)
	if self:IsCanConnect() then
		g_LoginCtrl:ShowLoginTips("正在连接服务器")
		g_LoginCtrl:ConnectServer(self.m_Server)
	end
end

function CLoginServerPage.ChangeAccount(self)
	g_LoginCtrl:InitValue()
	self.m_ParentView:ShowAccountPage()
end

return CLoginServerPage