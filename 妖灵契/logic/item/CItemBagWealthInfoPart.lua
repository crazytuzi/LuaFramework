---------------------------------------------------------------
--背包界面 财富信息部分


---------------------------------------------------------------

local CItemBagWealthInfoPart = class("CItemBagWealthInfoPart", CBox)

function CItemBagWealthInfoPart.ctor(self, obj, parentView)
	CBox.ctor(self, obj)
	self.m_ParentView = parentView

	self.m_TabItemCountLabel = self:NewUI(1, CLabel)
	self.m_GoldCountLabel = self:NewUI(2, CLabel)
	self.m_GoldAddBtn = self:NewUI(3, CButton)
	self.m_ColorCountLabel = self:NewUI(4, CLabel)
	self.m_ColorAddBtn = self:NewUI(5, CButton)
	self.m_CoinCountLabel = self:NewUI(6, CLabel)
	self.m_CoinAddBtn = self:NewUI(7, CButton)
	self.m_InfoPart = self:NewUI(8, CChapterWealthInfoPart)

	self:InitContent()

	self:UpdateText()
end

function CItemBagWealthInfoPart.InitContent(self)
	self.m_GoldAddBtn:AddUIEvent("click", callback(self, "OnAddGold"))
	self.m_ColorAddBtn:AddUIEvent("click", callback(self, "OnAddColor"))
	self.m_CoinAddBtn:AddUIEvent("click", callback(self, "OnAddCoin"))
	self.m_ParentView:SetValueChangeCallback(self:GetInstanceID(), callback(self, "ValueChangeCallback"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CItemBagWealthInfoPart.OnAddGold(self)
	--g_NpcShopCtrl:ShowColor2GoldView()
	g_SdkCtrl:ShowPayView()
end

function CItemBagWealthInfoPart.OnAddColor(self)
	g_SdkCtrl:ShowPayView()
end

function CItemBagWealthInfoPart.OnAddCoin(self)
	g_NpcShopCtrl:ShowGold2CoinView()
end

function CItemBagWealthInfoPart.ValueChangeCallback(self, obj, tType, ...)
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

function CItemBagWealthInfoPart.UpdateText(self)
		
	local gold = g_AttrCtrl.goldcoin
	local colorCoin = g_AttrCtrl.color_coin
	local coin = g_AttrCtrl.coin

	local itemCount = #g_ItemCtrl.m_BagTabItemsCache

	self.m_GoldCountLabel:SetNumberString(gold)
	self.m_ColorCountLabel:SetNumberString(colorCoin)
	self.m_CoinCountLabel:SetNumberString(coin)
	
	--self.m_TabItemCountLabel:SetText(string.format("%d/%d",itemCount, CItemBagPropPart.Config.GridItemMax))
	self.m_TabItemCountLabel:SetActive(false)
end

function CItemBagWealthInfoPart.OnCtrlAttrEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:UpdateText()
	end
end

function CItemBagWealthInfoPart.OnCtrlItemEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or
	   oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:UpdateText()
	end
end


return CItemBagWealthInfoPart