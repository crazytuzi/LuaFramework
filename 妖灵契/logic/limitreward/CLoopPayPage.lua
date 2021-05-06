local CLoopPayPage = class("CLoopPayPage", CPageBase)
--限时消费

function CLoopPayPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CLoopPayPage.OnInitPage(self)
	self.m_InfoGrid = self:NewUI(1, CGrid)
	self.m_InfoBox = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_TimeLabel = self:NewUI(4, CLabel)
	self:InitContent()
end

function CLoopPayPage.InitContent(self)
	self.m_InfoBoxArr = {}
	self.m_InfoBox:SetActive(false)
	self:SetData()
	if g_WelfareCtrl.m_TotalLockSkin then
		for i,v in ipairs(self.m_InfoBoxArr) do
			if v.m_Data.id == 10006 then
				self.m_ScrollView:ResetPosition()
				self.m_ScrollView:MoveRelative(Vector3.New(0, 450, 0))
			end
		end
		g_WelfareCtrl.m_TotalLockSkin = false
	end
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
end

function CLoopPayPage.SetData(self)
	local oData = {}
	local dLoopList = {}
	for _, obj in ipairs(g_WelfareCtrl.m_LoopPayList) do
		table.insert(dLoopList, obj.id)
	end
	table.sort(dLoopList)
	for k,v in ipairs(dLoopList) do
		table.insert(oData, data.welfaredata.LoopPay[v])
	end

	self.m_InfoBoxArr = {}
	for i,v in ipairs(oData) do
		self.m_InfoBoxArr[i] = self:CreateInfoBox()
		self.m_InfoGrid:AddChild(self.m_InfoBoxArr[i])
		self:SetInfoBoxData(self.m_InfoBoxArr[i], v)
		self.m_InfoBoxArr[i]:SetActive(true)
	end
	self.m_TimeLabel:SetText(g_WelfareCtrl:GetLoopPayTime())
	self:Refresh()
end

function CLoopPayPage.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_TitleLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_Slider = oInfoBox:NewUI(2, CSlider)
	oInfoBox.m_Slider:SetActive(false)
	oInfoBox.m_ItemGrid = oInfoBox:NewUI(3, CGrid)
	oInfoBox.m_ItemTipsBox = oInfoBox:NewUI(4, CItemTipsBox)
	oInfoBox.m_ItemTipsBox:SetActive(false)
	oInfoBox.m_SubmitBtn = oInfoBox:NewUI(5, CButton)
	oInfoBox.m_GotMark = oInfoBox:NewUI(6, CBox)
	oInfoBox.m_SubmitBtn.m_IgnoreCheckEffect = true
	return oInfoBox
end

function CLoopPayPage.SetInfoBoxData(self, oInfoBox, oData)
	oInfoBox.m_Data = oData
	oInfoBox.m_TitleLabel:SetText(string.format("活动期间，累计充值%s天可领取", oData.day))
	oInfoBox.m_ItemGrid:Clear()
	for i,v in ipairs(oData.itemlist) do
		local oItemBox = oInfoBox.m_ItemTipsBox:Clone()
		oInfoBox.m_ItemGrid:AddChild(oItemBox)
		oItemBox:SetActive(true)
		oItemBox:SetSid(v.sid, v.amount, {isLocal = true,  uiType = 1})
	end
end

function CLoopPayPage.RefreshInfoBox(self, oInfoBox)
	local bGot = g_WelfareCtrl:GetLoopState(oInfoBox.m_Data.id, oInfoBox.m_Data.day)
	if bGot == 0 then
		oInfoBox.m_SubmitBtn:SetText("领取")
		oInfoBox.m_SubmitBtn:SetSpriteName("btn_erji_anniu")
		oInfoBox.m_SubmitBtn:AddUIEvent("click", callback(self, "OnGetReward", oInfoBox))
	elseif bGot == 2 then
		oInfoBox.m_SubmitBtn:SetText("充值")
		oInfoBox.m_SubmitBtn:SetSpriteName("btn_erji_xuanzhong")
		oInfoBox.m_SubmitBtn:AddUIEvent("click", callback(self, "OpenRechargeShop", oInfoBox))
	end
	if bGot ==1 then
		oInfoBox.m_SubmitBtn:SetActive(false)
		oInfoBox.m_GotMark:SetActive(true)
	else
		oInfoBox.m_SubmitBtn:SetActive(true)
		oInfoBox.m_GotMark:SetActive(false)
	end
end

function CLoopPayPage.Refresh(self)
	for i = 1, #self.m_InfoBoxArr do
		self:RefreshInfoBox(self.m_InfoBoxArr[i])
	end
end

function CLoopPayPage.OnShowSkinTip(self)
	UITools.MoveToTarget(self.m_ScrollView, self.m_InfoBoxArr[6])
end

function CLoopPayPage.OpenRechargeShop(self, oInfoBox)
	g_OpenUICtrl:OpenRechargeShop()
end

function CLoopPayPage.OnGetReward(self, oInfoBox)
	nethuodong.C2GSReceiveDayCharge(oInfoBox.m_Data.id, g_WelfareCtrl:GetLoopPayCode())
end

function CLoopPayPage.OnWelfareEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.UpdateLoopPay then
		self:Refresh()
	end
end

return CLoopPayPage