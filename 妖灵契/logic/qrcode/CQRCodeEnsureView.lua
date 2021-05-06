local CQRCodeEnsureView = class("CQRCodeEnsureView", CViewBase)

function CQRCodeEnsureView.ctor(self, cb)
	CViewBase.ctor(self, "UI/QRCode/QRCodeEnsureView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CQRCodeEnsureView.OnCreateView(self)
	self.m_EnsureBtn = self:NewUI(1, CButton)
	self.m_TipLbl = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)

	self.m_CloseCallback = nil
	self.m_QRCodeToken = ""
	self.m_NoticeVer = 0
	
	self:InitContent()
end

function CQRCodeEnsureView.InitContent(self)
	self.m_EnsureBtn:AddUIEvent("click", callback(self, "OnEnsure"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CQRCodeEnsureView.SetData(self, cb, token, noticever)
	self.m_CloseCallback = cb
	self.m_QRCodeToken = token
	self.m_NoticeVer = noticever
end

function CQRCodeEnsureView.OnEnsure(self)
	local needList = {account_token = g_LoginCtrl.m_VerifyInfo.token, code_token = self.m_QRCodeToken, 
	notice_ver = self.m_NoticeVer, transfer_info = {platid= g_LoginCtrl:GetPlatformID(), channel_id=g_SdkCtrl:GetChannelId(), sub_channel_id=g_SdkCtrl:GetSubChannelId()}}
	g_QRCodeCtrl:PostLoginEnsure(needList, callback(self, "OnPostDone"))
end

function CQRCodeEnsureView.OnPostDone(self, sucess, tResult)
	if sucess and tResult then
		if tResult.errcode == 0 then
			g_NotifyCtrl:FloatMsg("你已成功登录PC端")
		elseif tResult.errcode == 402 then
			g_NotifyCtrl:FloatMsg("PC端二维码已过期,请重刷二维码")
		elseif tResult.errcode == 401 then
			g_NotifyCtrl:FloatMsg("账号登录失效,请手机端重新登录账号")
		elseif tResult.errcode == 403 then
			g_NotifyCtrl:FloatMsg("PC端二维码已过期,请重刷二维码")
		else
			g_NotifyCtrl:FloatMsg("登录失败,请手机端重新登录账号")
			
		end
	else
		g_NotifyCtrl:FloatMsg("登录失败,请手机端重新登录账号")
	end
	self:OnClose()
end

function CQRCodeEnsureView.OnClose(self)
	if self.m_CloseCallback then
		self.m_CloseCallback()
		self.m_CloseCallback = nil
	end
	self:CloseView()
end

return CQRCodeEnsureView