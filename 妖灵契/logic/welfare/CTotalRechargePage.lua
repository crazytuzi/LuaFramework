local CTotalRechargePage = class("CTotalRechargePage", CPageBase)

function CTotalRechargePage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end
--tzq弃用
function CTotalRechargePage.OnInitPage(self)
	self:SetActive(false)

	-- self.m_InfoGrid = self:NewUI(1, CGrid)
	-- self.m_InfoBox = self:NewUI(2, CBox)
	-- self.m_ScrollView = self:NewUI(3, CScrollView)

	-- self:InitContent()
end

function CTotalRechargePage.InitContent(self)
	-- self.m_InfoBoxArr = {}
	-- self.m_InfoBox:SetActive(false)
	-- self:SetData()
	-- g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
end

function CTotalRechargePage.SetData(self)
	-- local oData = {}
	-- for k,v in pairs(data.welfaredata.TotalRecharge) do
	-- 	table.insert(oData, v)
	-- end
	-- local function sortFunc(v1, v2)
	-- 	return v1.condition < v2.condition
	-- end
	-- table.sort(oData, sortFunc)
	-- self.m_InfoBoxArr = {}
	-- for i,v in ipairs(oData) do
	-- 	self.m_InfoBoxArr[i] = self:CreateInfoBox()
	-- 	self.m_InfoGrid:AddChild(self.m_InfoBoxArr[i])
	-- 	self.m_InfoBoxArr[i]:SetData(v)
	-- 	self.m_InfoBoxArr[i]:SetActive(true)
	-- end
	-- self:Refresh()
end

function CTotalRechargePage.CreateInfoBox(self)
	-- local oInfoBox = self.m_InfoBox:Clone()
	-- oInfoBox.m_TitleLabel = oInfoBox:NewUI(1, CLabel)
	-- oInfoBox.m_Slider = oInfoBox:NewUI(2, CSlider)
	-- oInfoBox.m_ItemGrid = oInfoBox:NewUI(3, CGrid)
	-- oInfoBox.m_ItemTipsBox = oInfoBox:NewUI(4, CItemTipsBox)
	-- oInfoBox.m_SubmitBtn = oInfoBox:NewUI(5, CButton)
	-- oInfoBox.m_GotMark = oInfoBox:NewUI(6, CBox)
	-- oInfoBox.m_SubmitBtn.m_IgnoreCheckEffect = true
	-- oInfoBox.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit", oInfoBox))

	-- function oInfoBox.SetData(self, oData)
	-- 	oInfoBox.m_Data = oData
	-- 	oInfoBox.m_TitleLabel:SetText(string.format("充值%s彩晶", oData.condition))
	-- 	oInfoBox.m_ItemGrid:Clear()
	-- 	if oData.title ~= 0 then
	-- 		local oItemBox = oInfoBox.m_ItemTipsBox:Clone()
	-- 		oItemBox:SetTitle(oData.title)
	-- 		oInfoBox.m_ItemGrid:AddChild(oItemBox)
	-- 		oItemBox:SetActive(true)
	-- 	end
	-- 	for i,v in ipairs(oData.reward) do
	-- 		local oItemBox = oInfoBox.m_ItemTipsBox:Clone()
	-- 		oInfoBox.m_ItemGrid:AddChild(oItemBox)
	-- 		oItemBox:SetActive(true)
	-- 		oItemBox:SetSid(v.sid, v.num, {isLocal = true, uiType = 2})
	-- 	end
	-- end

	-- function oInfoBox.Refresh(self)
	-- 	local bGot = g_WelfareCtrl.m_HistoryGotList[oInfoBox.m_Data.id]
	-- 	local value = g_WelfareCtrl.m_HistoryChargeDegree
	-- 	if value >= oInfoBox.m_Data.condition then
	-- 		value = oInfoBox.m_Data.condition
	-- 		oInfoBox.m_SubmitBtn:AddEffect("RedDot")
	-- 	else
	-- 		oInfoBox.m_SubmitBtn:DelEffect("RedDot")
	-- 	end
	-- 	oInfoBox.m_Slider:SetValue(value/oInfoBox.m_Data.condition)
	-- 	oInfoBox.m_Slider:SetSliderText(string.format("%s/%s", value, oInfoBox.m_Data.condition))
	-- 	if bGot then
	-- 		oInfoBox.m_SubmitBtn:SetActive(false)
	-- 		oInfoBox.m_GotMark:SetActive(true)
	-- 	else
	-- 		oInfoBox.m_SubmitBtn:SetActive(true)
	-- 		oInfoBox.m_GotMark:SetActive(false)
	-- 	end
	-- end

	-- return oInfoBox
end

function CTotalRechargePage.Refresh(self)
	-- for i = 1, #self.m_InfoBoxArr do
	-- 	self.m_InfoBoxArr[i]:Refresh()
	-- end
end

function CTotalRechargePage.OnSubmit(self, oInfoBox)
	-- if g_WelfareCtrl.m_HistoryChargeDegree >= oInfoBox.m_Data.condition then
	-- 	netfuli.C2GSChargeReward(oInfoBox.m_Data.id)
	-- else
	-- 	g_NotifyCtrl:FloatMsg("现在还不能领取这个奖励")
	-- end
end

function CTotalRechargePage.OnWelfareEvnet(self, oCtrl)
	-- if oCtrl.m_EventID == define.Welfare.Event.OnHistoryRecharge then
	-- 	self:Refresh()
	-- end
end

return CTotalRechargePage