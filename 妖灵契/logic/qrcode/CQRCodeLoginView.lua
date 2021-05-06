local CQRCodeLoginView = class("CQRCodeLoginView", CViewBase)

function CQRCodeLoginView.ctor(self, cb)
	CViewBase.ctor(self, "UI/QRCode/QRCodeLoginView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CQRCodeLoginView.OnCreateView(self)
	self.m_WaitScanBox = self:NewUI(1, CBox)
	self.m_WaitEnsureBox = self:NewUI(2, CBox)

	self.m_WaitScanBox.m_QRTexture = self.m_WaitScanBox:NewUI(1, CTexture)
	self.m_WaitScanBox.m_OverTimeBox = self.m_WaitScanBox:NewUI(2, CBox)
	self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl = self.m_WaitScanBox.m_OverTimeBox:NewUI(1, CLabel)
	self.m_WaitScanBox.m_OverTimeBox.m_RefreshBtn = self.m_WaitScanBox.m_OverTimeBox:NewUI(2, CButton)
	-- self.m_WaitScanBox.m_DescLbl1 = self.m_WaitScanBox:NewUI(3, CLabel)
	-- self.m_WaitScanBox.m_DescLbl2 = self.m_WaitScanBox:NewUI(4, CLabel)
	-- self.m_WaitScanBox.m_ClickLbl1 = self.m_WaitScanBox:NewUI(5, CLabel)
	-- self.m_WaitScanBox.m_ClickLbl2 = self.m_WaitScanBox:NewUI(6, CLabel)
	self.m_WaitScanBox.m_TipsBox = self.m_WaitScanBox:NewUI(7, CBox)
	self.m_WaitScanBox.m_TipsBg = self.m_WaitScanBox:NewUI(8, CSprite)
	self.m_WaitScanBox.m_TipsTex = self.m_WaitScanBox:NewUI(9, CTexture)

	self.m_WaitEnsureBox.m_RefreshScanBtn = self.m_WaitEnsureBox:NewUI(1, CButton)
	self.m_QRCodeToken = ""
	self:InitContent()
end

function CQRCodeLoginView.InitContent(self)
	self.m_WaitScanBox:SetActive(true)
	self.m_WaitScanBox.m_QRTexture:SetActive(false)
	self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl:SetText("请检查网络哦")
	self.m_WaitScanBox.m_OverTimeBox:SetActive(true)
	self.m_WaitEnsureBox:SetActive(false)

	self.m_WaitScanBox.m_OverTimeBox.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRequestQRCode"))
	self.m_WaitEnsureBox.m_RefreshScanBtn:AddUIEvent("click", callback(self, "OnEnsureRequestQRCode"))
	-- self.m_WaitScanBox.m_ClickLbl1:AddUIEvent("click", callback(self, "OnClickQRTips", 1))
	-- self.m_WaitScanBox.m_ClickLbl2:AddUIEvent("click", callback(self, "OnClickQRTips", 2))
	self.m_WaitScanBox.m_TipsBg:AddUIEvent("click", callback(self, "OnClickQRTipsBg"))

	g_QRCodeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlQREvent"))
	g_QRCodeCtrl:ResetQRLeftTimer()
	g_QRCodeCtrl:ConnectServer()
end

function CQRCodeLoginView.OnCtrlQREvent(self, oCtrl)
	if oCtrl.m_EventID == define.QRCode.Event.QRToken then
		self.m_WaitScanBox:SetActive(true)
		self.m_WaitScanBox.m_OverTimeBox:SetActive(false)
		self.m_WaitEnsureBox:SetActive(false)
		self.m_QRCodeToken = oCtrl.m_EventData.token
		self:UpdateQRCodeTexture()
	elseif oCtrl.m_EventID == define.QRCode.Event.QRCScanSuccess then
		--停止二维码超时计算
		g_QRCodeCtrl:ResetQRLeftTimer()
		self.m_WaitScanBox:SetActive(false)
		self.m_WaitEnsureBox:SetActive(true)
	elseif oCtrl.m_EventID == define.QRCode.Event.QRCodeInvalid then
		--停止二维码超时计算
		g_QRCodeCtrl:ResetQRLeftTimer()
		self.m_WaitScanBox:SetActive(true)
		self.m_WaitScanBox.m_QRTexture:SetActive(false)
		self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl:SetText("二维码失效")
		self.m_WaitScanBox.m_OverTimeBox:SetActive(true)
		self.m_WaitEnsureBox:SetActive(false)
	elseif oCtrl.m_EventID == define.QRCode.Event.QRTimeOut then
		self.m_WaitScanBox:SetActive(true)
		self.m_WaitScanBox.m_QRTexture:SetActive(false)
		self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl:SetText("二维码超时")
		self.m_WaitScanBox.m_OverTimeBox:SetActive(true)
		self.m_WaitEnsureBox:SetActive(false)
	end
end

function CQRCodeLoginView.UpdateQRCodeTexture(self)
	--这里没有版本号比对
	local jsonStr = cjson.encode({sid = self.m_QRCodeToken, notice_ver = 0})
	local tex = C_api.AntaresQRCodeUtil.Encode(jsonStr, self.m_WaitScanBox.m_QRTexture.m_UIWidget.width)
	self.m_WaitScanBox.m_QRTexture:SetActive(true)
	self.m_WaitScanBox.m_QRTexture:SetMainTexture(tex)
end

function CQRCodeLoginView.OnRequestQRCode(self)
	g_QRCodeCtrl:ConnectServer()
end

function CQRCodeLoginView.OnEnsureRequestQRCode(self)
	g_QRCodeCtrl:ConnectServer()
end

function CQRCodeLoginView.OnClickQRTips(self, index)
	self.m_WaitScanBox.m_TipsBox:SetActive(true)
	local sTextureName
	if index == 1 then
		sTextureName = "Texture/Login/logo.png"
	else
		sTextureName = "Texture/Login/logo.png"
	end
	g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTipsTexture"))
end

function CQRCodeLoginView.SetTipsTexture(self, texture, errcode)
	if texture then
		self.m_WaitScanBox.m_TipsTex:SetMainTexture(texture)
	end
end

function CQRCodeLoginView.OnClickQRTipsBg(self)
	self.m_WaitScanBox.m_TipsBox:SetActive(false)
	self.m_WaitScanBox.m_TipsTex:SetMainTexture(nil)
end

return CQRCodeLoginView