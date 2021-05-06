local CLimitPayPage = class("CLimitPayPage", CPageBase)
--限时消费

function CLimitPayPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CLimitPayPage.OnInitPage(self)
	self.m_InfoGrid = self:NewUI(1, CGrid)
	self.m_InfoBox = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_RestTimeLabel = self:NewUI(4, CLabel)
	self:InitContent()
end

function CLimitPayPage.InitContent(self)
	self.m_InfoBoxArr = {}
	self.m_InfoBox:SetActive(false)
	self:SetData()
	self:SetTime()
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
end

function CLimitPayPage.SetData(self)
	local oData = {}
	local iPlanID = g_WelfareCtrl:GetLimitPayPlanID() or 1
	local dPlanList = {}
	if data.welfaredata.LimitPayPlan[iPlanID] then
		dPlanList = data.welfaredata.LimitPayPlan[iPlanID]["item_list"]
	end
	local d = data.welfaredata.LimitPay
	for _, id in ipairs(dPlanList) do
		table.insert(oData, d[id])
	end
	local function sortFunc(v1, v2)
		return v1.condition < v2.condition
	end
	table.sort(oData, sortFunc)

	--table.print(oData)
	self.m_InfoBoxArr = {}
	for i,v in ipairs(oData) do
		self.m_InfoBoxArr[i] = self:CreateInfoBox()
		self.m_InfoGrid:AddChild(self.m_InfoBoxArr[i])
		self:SetInfoBoxData(self.m_InfoBoxArr[i], v)
		self.m_InfoBoxArr[i]:SetActive(true)
	end
	self:Refresh()
end

function CLimitPayPage.SetTime(self)
	self.m_RestTimeLabel:SetText(g_WelfareCtrl:GetLimitPayRestTime())
end

function CLimitPayPage.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_TitleLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_Slider = oInfoBox:NewUI(2, CSlider)
	oInfoBox.m_ItemGrid = oInfoBox:NewUI(3, CGrid)
	oInfoBox.m_ItemTipsBox = oInfoBox:NewUI(4, CItemTipsBox)
	oInfoBox.m_ItemTipsBox:SetActive(false)
	oInfoBox.m_SubmitBtn = oInfoBox:NewUI(5, CButton)
	oInfoBox.m_GotMark = oInfoBox:NewUI(6, CBox)
	oInfoBox.m_SubmitBtn.m_IgnoreCheckEffect = true
	return oInfoBox
end

function CLimitPayPage.SetInfoBoxData(self, oInfoBox, oData)
	oInfoBox.m_Data = oData
	oInfoBox.m_TitleLabel:SetText(string.format("消费#w2%d", oData.condition))
	local iFull = oData.condition
	local iCur = g_WelfareCtrl:GetLimitPayAmount()
	oInfoBox.m_Slider:SetValue(iCur / iFull)
	oInfoBox.m_Slider:SetSliderText(string.format("%d/%d", iCur, iFull))
	oInfoBox.m_ItemGrid:Clear()
	for i,v in ipairs(oData.reward) do
		local oItemBox = oInfoBox.m_ItemTipsBox:Clone()
		oInfoBox.m_ItemGrid:AddChild(oItemBox)
		oItemBox:SetActive(true)
		oItemBox:SetSid(v.sid, v.num, {isLocal = true,  uiType = 1})
	end
end

function CLimitPayPage.RefreshInfoBox(self, oInfoBox)
	local iCurAmount = g_WelfareCtrl:GetLimitPayAmount()
	local iFullAmount = oInfoBox.m_Data.condition
	local bGot = g_WelfareCtrl:GetLimitPayState(oInfoBox.m_Data.id)
	--1领取 0 未领取
	oInfoBox.m_Slider:SetValue(iCurAmount / iFullAmount)
	oInfoBox.m_Slider:SetSliderText(string.format("%d/%d", iCurAmount, iFullAmount))
	if bGot == 0 then
		oInfoBox.m_SubmitBtn:SetActive(true)
		oInfoBox.m_GotMark:SetActive(false)
		if iCurAmount >= iFullAmount then
			oInfoBox.m_SubmitBtn:AddEffect("RedDot")
			oInfoBox.m_SubmitBtn:SetText("领取")
			oInfoBox.m_SubmitBtn:SetSpriteName("btn_erji_anniu")
			oInfoBox.m_SubmitBtn:AddUIEvent("click", callback(self, "OnGetReward", oInfoBox))
		else
			oInfoBox.m_SubmitBtn:DelEffect("RedDot")
			oInfoBox.m_SubmitBtn:SetText("消费")
			oInfoBox.m_SubmitBtn:SetSpriteName("btn_erji_xuanzhong")
			oInfoBox.m_SubmitBtn:AddUIEvent("click", callback(self, "OpenRechargeShop", oInfoBox))
		end
	else
		oInfoBox.m_SubmitBtn:SetActive(false)
		oInfoBox.m_GotMark:SetActive(true)
	end
end

function CLimitPayPage.Refresh(self)
	for i = 1, #self.m_InfoBoxArr do
		self:RefreshInfoBox(self.m_InfoBoxArr[i])
	end
end

function CLimitPayPage.OnShowSkinTip(self)
	UITools.MoveToTarget(self.m_ScrollView, self.m_InfoBoxArr[6])
end

function CLimitPayPage.OpenRechargeShop(self, oInfoBox)
	g_NpcShopCtrl:OpenShop(define.Store.Page.LiBaoShop)
end

function CLimitPayPage.OnGetReward(self, oInfoBox)
	nethuodong.C2GSGetTimeResumeReward(oInfoBox.m_Data.id)
end

function CLimitPayPage.OnWelfareEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.UpdateLimitPay then
		self:Refresh()
	end
end

return CLimitPayPage