local CRushPayPage = class("CRushPayPage", CPageBase)
--限时累充
function CRushPayPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CRushPayPage.OnInitPage(self)
	self.m_InfoGrid = self:NewUI(1, CGrid)
	self.m_InfoBox = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_TimeLabel = self:NewUI(4, CLabel)
	self:InitContent()
end

function CRushPayPage.InitContent(self)
	self.m_InfoBox:SetActive(false)
	self.m_InfoBoxArr = {}
	self:SetData()
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
end

function CRushPayPage.SetData(self)
	local sStart = os.date("%Y年%m月%d日", g_WelfareCtrl.m_RushRechargeStartTime)
	local sEnd = os.date("%Y年%m月%d日", g_WelfareCtrl.m_RushRechargeEndTime)
	self.m_TimeLabel:SetText(string.format("%s-%s", sStart, sEnd))
	local oData = {}
	for k,v in pairs(g_WelfareCtrl.m_RushRechargeInfo) do
		if data.welfaredata.RushRecharge[v.id] then
			table.insert(oData, data.welfaredata.RushRecharge[v.id])
		end
	end
	local function sortFunc(v1, v2)
		return v1.progress < v2.progress
	end
	table.sort(oData, sortFunc)

	self.m_InfoBoxDic = {}
	for i,v in ipairs(oData) do
		if self.m_InfoBoxArr[i] == nil then
			self.m_InfoBoxArr[i] = self:CreateInfoBox()
			self.m_InfoGrid:AddChild(self.m_InfoBoxArr[i])
		end
		self.m_InfoBoxArr[i]:SetData(v)
		self.m_InfoBoxDic[v.id] = self.m_InfoBoxArr[i]
		self.m_InfoBoxArr[i]:SetActive(true)
	end
	for i=#oData + 1, #self.m_InfoBoxArr do
		self.m_InfoBoxArr:SetActive(false)
	end
	self:Refresh()
end

function CRushPayPage.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_TitleLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_Slider = oInfoBox:NewUI(2, CSlider)
	oInfoBox.m_ItemGrid = oInfoBox:NewUI(3, CGrid)
	oInfoBox.m_ItemTipsBox = oInfoBox:NewUI(4, CItemTipsBox)
	oInfoBox.m_GetBtn = oInfoBox:NewUI(5, CButton)
	oInfoBox.m_GotMark = oInfoBox:NewUI(6, CBox)
	oInfoBox.m_RechargeBtn = oInfoBox:NewUI(7, CButton)
	oInfoBox.m_GetBtn.m_IgnoreCheckEffect = true
	oInfoBox.m_GetBtn:AddUIEvent("click", callback(self, "OnSubmit", oInfoBox))
	oInfoBox.m_RechargeBtn:AddUIEvent("click", callback(self, "OnRecharge", oInfoBox))

	oInfoBox.m_ItemBoxArr = {}
	function oInfoBox.SetData(self, oData)
		oInfoBox.m_Data = oData
		oInfoBox.m_TitleLabel:SetText(string.format("累计充值满%s元即可领取", oData.progress))
		for i,v in ipairs(oData.itemlist) do
			if oInfoBox.m_ItemBoxArr[i] == nil then
				oInfoBox.m_ItemBoxArr[i] = oInfoBox.m_ItemTipsBox:Clone()
				oInfoBox.m_ItemGrid:AddChild(oInfoBox.m_ItemBoxArr[i])
			end
			oInfoBox.m_ItemBoxArr[i]:SetActive(true)
			oInfoBox.m_ItemBoxArr[i]:SetSid(v.sid, v.amount, {isLocal = true,  uiType = 1})
		end
		for i=#oData.itemlist + 1,#oInfoBox.m_ItemBoxArr do
			oInfoBox.m_ItemBoxArr[i]:SetActive(false)
		end
	end

	function oInfoBox.Refresh(self)
		local bGot = (g_WelfareCtrl.m_RushRechargeInfo[oInfoBox.m_Data.id].receive == 1)
		local value = g_WelfareCtrl.m_RushRechargeProgress
		if bGot then
			oInfoBox.m_GetBtn:AddEffect("RedDot")
			oInfoBox.m_RechargeBtn:SetActive(false)
			oInfoBox.m_GetBtn:SetActive(false)
			oInfoBox.m_GotMark:SetActive(true)
			oInfoBox.m_Slider:SetActive(false)
		elseif value >= oInfoBox.m_Data.progress then
			value = oInfoBox.m_Data.progress
			oInfoBox.m_GetBtn:SetActive(true)
			oInfoBox.m_RechargeBtn:SetActive(false)
			oInfoBox.m_GotMark:SetActive(false)
			oInfoBox.m_Slider:SetActive(true)
		else
			oInfoBox.m_RechargeBtn:SetActive(true)
			oInfoBox.m_GetBtn:SetActive(false)
			oInfoBox.m_GotMark:SetActive(false)
			oInfoBox.m_Slider:SetActive(true)
		end
		oInfoBox.m_Slider:SetValue(value/oInfoBox.m_Data.progress)
		oInfoBox.m_Slider:SetSliderText(string.format("%s/%s", value, oInfoBox.m_Data.progress))
	end

	return oInfoBox
end

function CRushPayPage.Refresh(self)
	for i = 1, #self.m_InfoBoxArr do
		if self.m_InfoBoxArr[i]:GetActive() then
			self.m_InfoBoxArr[i]:Refresh()
		end
	end
end

function CRushPayPage.OnSubmit(self, oInfoBox)
	nethuodong.C2GSReceiveAddCharge(oInfoBox.m_Data.id)
end

function CRushPayPage.OnRecharge(self)
	g_OpenUICtrl:OpenRechargeShop()
end

function CRushPayPage.OnWelfareEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.UpdateRushRecharge then
		self:SetData()
	elseif oCtrl.m_EventID == define.Welfare.Event.UpdateRushRechargeList then
		if self.m_InfoBoxDic[oCtrl.m_EventData.id] then
			self.m_InfoBoxDic[oCtrl.m_EventData.id]:Refresh()
		end
	end
end

return CRushPayPage