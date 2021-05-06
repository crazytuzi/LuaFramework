---------------------------------------------------------------
--剧情副本界面 财富信息部分
---------------------------------------------------------------

local CChapterWealthInfoPart = class("CChapterWealthInfoPart", CBox)

function CChapterWealthInfoPart.ctor(self, obj, parentView)
	CBox.ctor(self, obj)
	--self.m_ParentView = parentView
	self.m_EnergyLabel = self:NewUI(1, CLabel)
	self.m_EnergyAddBtn = self:NewUI(2, CButton)
	self.m_SweepLabel = self:NewUI(3, CLabel)
	self.m_SweepAddBtn = self:NewUI(4, CButton)
	self.m_GoldCoinLabel = self:NewUI(5, CLabel)
	self.m_GoldCoinAddBtn = self:NewUI(6, CButton)
	self.m_ColorCoinLabel = self:NewUI(7, CLabel)
	self.m_ColorCoinAddBtn = self:NewUI(8, CButton)

	self:InitContent()
	self:UpdateText()
end

function CChapterWealthInfoPart.InitContent(self)
	self.m_SweepAddBtn:SetActive(false) --关闭购买扫荡卷
	self.m_EnergyAddBtn:AddUIEvent("click", callback(self, "OnAddEnergy"))
	self.m_SweepAddBtn:AddUIEvent("click", callback(self, "OnAddSweep"))
	self.m_GoldCoinAddBtn:AddUIEvent("click", callback(self, "OnAddGoldCoin"))
	self.m_ColorCoinAddBtn:AddUIEvent("click", callback(self, "OnAddColorCoin"))
	--self.m_ParentView:SetValueChangeCallback(self:GetInstanceID(), callback(self, "ValueChangeCallback"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CChapterWealthInfoPart.OnAddEnergy(self)
	local cur = tonumber(g_ChapterFuBenCtrl:GetEnergyBuytime())
	local max = tonumber(data.globaldata.GLOBAL.buyenergy_maxtime.value)
	if cur == max then
		g_NotifyCtrl:FloatMsg("今日可兑换次数已达到最大值")
	else
		g_NpcShopCtrl:ShowGold2EnergyView()
	end
end

function CChapterWealthInfoPart.OnAddSweep(self)
	g_NotifyCtrl:FloatMsg("暂时没有接口")
end

function CChapterWealthInfoPart.OnAddGoldCoin(self)
	g_SdkCtrl:ShowPayView()
end

function CChapterWealthInfoPart.OnAddColorCoin(self)
	g_SdkCtrl:ShowPayView()
end

function CChapterWealthInfoPart.ValueChangeCallback(self, obj, tType, ...)
	if obj:GetInstanceID() ~= self.m_ParentView:GetInstanceID() then
		return
	end
	local arg1 = select(1, ...)
	if tType == "SwitchTab" then
		self:UpdateText()

	elseif tType == "OnRefreshBagItem" then
		self:UpdateText()

	elseif tType == "ShowSellInfo" then		
		--self.m_TabItemCountLabel:SetActive(not arg1)
	end
end

function CChapterWealthInfoPart.UpdateText(self)
	local max_energy = data.globaldata.GLOBAL.max_energy.value
	if g_WelfareCtrl:HasYueKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].yk
	end
	if g_WelfareCtrl:HasZhongShengKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].zsk
	end
	local energy = string.format("%d/%d", g_AttrCtrl.energy, max_energy)
	local goldcoin = g_AttrCtrl.goldcoin
	local colorcoin = g_AttrCtrl.color_coin
	local Sweep = g_ItemCtrl:GetTargetItemCountBySid(10030) --扫荡卷暂时用宝图取代
	self.m_EnergyLabel:SetText(energy)
	self.m_SweepLabel:SetNumberString(Sweep)
	self.m_GoldCoinLabel:SetNumberString(goldcoin)
	self.m_ColorCoinLabel:SetNumberString(colorcoin)
end

function CChapterWealthInfoPart.OnCtrlAttrEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:UpdateText()
	end
end

function CChapterWealthInfoPart.OnCtrlItemEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or
	   oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:UpdateText()
	end
end


return CChapterWealthInfoPart