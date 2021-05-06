local CRechargeScorePage = class("CRechargeScorePage", CPageBase)

function CRechargeScorePage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CRechargeScorePage.OnInitPage(self)
	self.m_ScoreLabel = self:NewUI(1, CLabel)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_ItemBox = self:NewUI(4, CBox)
	self.m_MyPointLabel = self:NewUI(5, CLabel)
	self.m_TimeLabel = self:NewUI(6, CLabel)
	self.m_ChargeBtn = self:NewUI(7, CButton)
	self.m_RuleLabel = self:NewUI(8, CLabel)
	self:InitContent()
end

function CRechargeScorePage.InitContent(self)
	self.m_ChargeBtn.m_TweenScale = self.m_ChargeBtn:GetComponent(classtype.TweenScale)
	self.m_ItemBox:SetActive(false)
	self.m_MyPointLabel:SetText("")
	self.m_ChargeBtn:AddUIEvent("click",callback(self,"OnChargeBtn"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrlEvent"))
	self:InitItemData()
end

function CRechargeScorePage.OnWelfareCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnChargeScore then
		self:InitItemData()
	end
end

function CRechargeScorePage.OnShowPage(self)
	self.m_ChargeBtn.m_TweenScale.enabled = true
end

function CRechargeScorePage.SetRuleLabel(self, sTxt)
	sTxt = sTxt or self.m_RuleLabel:GetText()
	if sTxt then
		self.m_RuleLabel:SetText(sTxt)
	end
end

function CRechargeScorePage.InitItemData(self)
	local id = g_WelfareCtrl:GetChargeScoreID()
	local dInfo = g_WelfareCtrl:GetChargeScoreInfo() 
	local dConfig = data.welfaredata.RechargeScoreConfig[id]
	
	self.m_Point = dInfo.score or 0
	self.m_MyPointLabel:SetText(string.format("当前积分：%d", self.m_Point))

	local start_time = os.date("%Y/%m/%d", g_WelfareCtrl.m_ChargeStarTime)
	local end_time = os.date("%Y/%m/%d", g_WelfareCtrl.m_ChargeEndTime)
	self.m_TimeLabel:SetText(string.format("活动时间：%s-%s", start_time, end_time))

	local lSaleItem = {}
	for i,v in ipairs(dConfig.sale_item) do
		table.insert(lSaleItem, data.welfaredata.RechargeScoreData[v])
	end
	--table.print(lSaleItem,"________CRechargeScorePage.InitItemData_________")

	local dBuyInfo = dInfo.buyinfo
	self.m_Grid:Clear()
	for i,item in ipairs(lSaleItem) do
		item.buy_times = dBuyInfo[item.id] and dBuyInfo[item.id].buy_times or 0
		local itembox = self:CreateItemBox(item)
		--self:RefreshItemBox(itembox, dBuyInfo[item.id])
		self.m_Grid:AddChild(itembox)
	end
	self.m_Grid:Reposition()
end

function CRechargeScorePage.CreateItemBox(self, dData)
	local oBox = self.m_ItemBox:Clone()
	oBox:SetActive(true)
	oBox.m_BG = oBox:NewUI(1, CSprite)
	oBox.m_Item = oBox:NewUI(2, CItemTipsBox)
	oBox.m_CostLabel = oBox:NewUI(3, CLabel)

	oBox.m_Data = dData
	local iItemID = dData.reward.sid
	local config = {isLocal = true, uiType = 1}
	local iAmount = 0
	local bIsNoLimit = false
	if dData.buy_limit == 0 then
		iAmount = 1
		bIsNoLimit = true
	else
		iAmount = dData.buy_limit - dData.buy_times
	end
	if string.find(dData.reward.sid, "value") then
		local sid, value = g_ItemCtrl:SplitSidAndValue(iItemID)
		iItemID = sid
	end
	oBox.m_Item:SetItemData(iItemID, iAmount, nil, config)
	if iAmount <= 0 then
		oBox.m_Item.m_CountLabel:SetActive(true)
		oBox.m_Item.m_CountLabel:SetNumberString("0")
	end
	oBox.m_CostLabel:SetText(string.format("积分：%d", dData.point))
	if bIsNoLimit then
		iAmount = 200
	end
	oBox.m_Amount = iAmount
	oBox.m_Item:AddUIEvent("click", callback(self, "OnBuyItem", dData.id, iItemID, dData.point, oBox))
	oBox.m_BG:AddUIEvent("click", callback(self, "OnBuyItem", dData.id, iItemID, dData.point, oBox))
	return oBox
end

function CRechargeScorePage.UpdateCSBuyTimes(self, id, buy_times, score)
	self.m_Point = score or 0
	self.m_MyPointLabel:SetText(string.format("当前积分：%d", self.m_Point))
	if id then
		for i,oBox in ipairs(self.m_Grid:GetChildList()) do
			if oBox.m_Data.id == id then
				oBox.m_Data.buy_times = buy_times
				local iAmount = 0
				if oBox.m_Data.buy_limit == 0 then
					iAmount = 200 
				else
					iAmount = math.max(0, oBox.m_Data.buy_limit - buy_times)
				end
				oBox.m_Amount = iAmount
				oBox.m_Item.m_CountLabel:SetNumberString(iAmount)
			end
		end
	end
end

function CRechargeScorePage.OnBuyItem(self, id, iShape, iPrice, oBox)
	if oBox.m_Data.buy_limit ~= 0 then
		if oBox.m_Data.buy_limit - oBox.m_Data.buy_times <= 0 then
			g_NotifyCtrl:FloatMsg("该物品已经被兑换完了")
			return
		end
	end
	CCostScoreBuyView:ShowView(function (oView)
		oView:SetInfo(iShape, oBox.m_Amount, iPrice, self.m_Point)
		oView:SetBuyCb(function (times)
			if times > 0 then
				if self.m_Point < times * iPrice then
					g_NotifyCtrl:FloatMsg("积分不足请前往充值")
				else
					nethuodong.C2GSBuyCSItem(id, times)
				end
			end
		end)
	end)
end

function CRechargeScorePage.OnChargeBtn(self, obj)
	g_SdkCtrl:ShowPayView()
end

return CRechargeScorePage