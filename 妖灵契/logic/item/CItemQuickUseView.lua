local CItemQuickUseView = class("CItemQuickUseView", CViewBase)

function CItemQuickUseView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/QuickUseView.prefab", cb)
	self.m_DepthType = "Notify"  --层次
end

CItemQuickUseView.BatUseCount = 100

function CItemQuickUseView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_FunctionBtn = self:NewUI(4, CButton)
	self.m_NameBtn = self:NewUI(5, CLabel)
	self.m_ItemBorderSpr = self:NewUI(6, CSprite)
	self.m_CountLabel = self:NewUI(7, CLabel)
	self.m_Container = self:NewUI(8, CWidget)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FunctionBtn:AddUIEvent("click", callback(self, "OnClickFunction"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))
	UITools.ResizeToRootSize(self.m_Container)
	self.m_Item = nil
	g_GuideCtrl:AddGuideUI("quickusew_use_btn", self.m_FunctionBtn)
end

function CItemQuickUseView.OnClickFunction(self)
	if not g_ActivityCtrl:ActivityBlockContrl("item", true, self.m_Item:GetValue("sid")) then
		return
	end
	if self.m_UseType == "bag" then
		if self.m_SubType == define.Item.ItemSubType.EquipStone then
			local pos = self.m_Item:GetValue("pos")
			g_ItemCtrl:C2GSPromoteEquipLevel(pos, self.m_Item:GetValue("id"))

		else
			local gift_choose_amount = self.m_Item:GetValue("gift_choose_amount") or 0
			local sid = self.m_Item:GetValue("sid")
			if sid == 13270 or sid == 13271 or sid == 13269  then
				CItemPartnerEquipSoulSelectView:ShowView(function (oView)
					oView:SetItem(self.m_Item)
				end)
				self:CloseView()
			elseif sid == 13281 then
				CItemPartnertSelectPackageView:ShowView(function (oView)
					oView:SetData(sid, false, self.m_Item:GetValue("id"))
				end)	
				self:CloseView()			
			elseif gift_choose_amount ~= 0 then
				local sid = self.m_Item:GetValue("sid")
				local id = self.m_Item:GetValue("id")
				CItemTipsPackageSelectView:ShowView(function (oView)
					oView:SetItem(sid, id)
				end)
				self:CloseView()
			else
				if self.m_Amount > CItemQuickUseView.BatUseCount then
					g_ItemCtrl:C2GSItemUse(self.m_Item:GetValue("id"), g_AttrCtrl.pid, CItemQuickUseView.BatUseCount)
				else
					g_ItemCtrl:C2GSItemUse(self.m_Item:GetValue("id"), g_AttrCtrl.pid, self.m_Amount)
				end	

			end		
		end
	else
		g_ItemCtrl:ItemUseSwitchTo(self.m_Item)
		self:CloseView()
	end
end

function CItemQuickUseView.SetItem(self, oItem)
	self.m_Item = oItem
	self.m_Id = self.m_Item:GetValue("id")
	self.m_Amount = self.m_Item:GetValue("amount")
	self.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
	self.m_NameLabel:SetText(oItem:GetValue("name"))
	self.m_UseType = oItem:GetValue("use_type")
	self.m_SubType = oItem:GetValue("sub_type")
	self.m_ItemBorderSpr:SetItemQuality(oItem:GetValue("quality"))
	self:RefeshText()
end

function CItemQuickUseView.RefeshText(self)
	if self.m_Amount <= 1 then
		self.m_CountLabel:SetActive(false)
	else
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetText(tostring(self.m_Amount))
	end
	if self.m_UseType == "bag" then
		--如果是装备
		if self.m_SubType == define.Item.ItemSubType.EquipStone then
			self.m_NameBtn:SetText("装备")
		else
			--礼包处理
			local gift_choose_amount = self.m_Item:GetValue("gift_choose_amount") or 0
			local sid = self.m_Item:GetValue("sid")
			local bat_use = self.m_Item:GetValue("bat_use")
		
			if sid == 13270 or sid == 13271 or sid == 13269 then
				self.m_NameBtn:SetText("使用")				
			elseif gift_choose_amount ~= 0 then
				self.m_NameBtn:SetText("使用")
			elseif bat_use == 0 then
				self.m_NameBtn:SetText("使用1次")
			else
				if self.m_Amount > CItemQuickUseView.BatUseCount then
					self.m_NameBtn:SetText(string.format("使用%d次", CItemQuickUseView.BatUseCount))
				else
					self.m_NameBtn:SetText("使用全部")
				end	
			end
		end
	else
		self.m_NameBtn:SetText("使用")
	end
end

function CItemQuickUseView.OnCtrlItemlEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		local oItem = oCtrl.m_EventData
		if oItem:GetValue("id") == self.m_Id then		
			self:SetItem(oItem)
		end
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		local count = g_ItemCtrl:GetTargetItemCountById(self.m_Id)
		if count == 0 then
			local cacheItem = g_ItemCtrl.m_QuickUseIdCache
			if #cacheItem > 0 then
				local id = cacheItem[1]
				local item = g_ItemCtrl:GetItem(id)
				table.remove(g_ItemCtrl.m_QuickUseIdCache, 1)
				if item then
					self:SetItem(item)				
				else
					self:CloseView()	
				end
			else
				self:CloseView()
			end		
		end
	end
end

function CItemQuickUseView.OnClose(self)
	g_ItemCtrl.m_QuickUseIdCache = {}
	CViewBase.OnClose(self)
end

return CItemQuickUseView