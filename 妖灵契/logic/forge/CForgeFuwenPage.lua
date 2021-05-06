---------------------------------------------------------------
--打造界面的 符文 子界面


---------------------------------------------------------------
local CForgeFuwenPage = class("CForgeFuwenPage", CPageBase)

CForgeFuwenPage.EnumIsCanResetFuwen =
{
	Can = {str = ""} ,
	NotMaterial = {str = "材料不足"} ,
	NotGoldCoin = {str = "水晶不足"} ,
}

function CForgeFuwenPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_EquipType = nil
	self.m_AutoFill = g_ItemCtrl.m_ForgeFuwenAutoFill
	self.m_IsCanReset = CForgeFuwenPage.EnumIsCanResetFuwen.Can
	self.m_FuwenResetInfo = {}
	self.m_FromBoxList = {}
	self.m_ToBoxList = {}
	self.m_MainAttrLAbelList = {}
end

function CForgeFuwenPage.OnInitPage(self)
	self.m_ResetBtn = self:NewUI(1, CButton)
	self.m_SaveBtn = self:NewUI(2, CButton)
	self.m_AutoLabel = self:NewUI(3, CLabel)
	self.m_AutoSprite = self:NewUI(4, CSprite)
	self.m_AutoSelectSprite = self:NewUI(5, CSprite)
	self.m_AttrFromGrid = self:NewUI(6, CGrid)
	self.m_AttrFromGridBox = self:NewUI(7, CBox)
	self.m_UseItemSprite = self:NewUI(8, CSprite)
	self.m_UseItemCountLabel = self:NewUI(9, CLabel)
	self.m_FromWidget = self:NewUI(10, CBox)
	self.m_ToWidget = self:	NewUI(11, CBox)
	self.m_AttrToGrid = self:NewUI(12, CGrid)
	self.m_AttrToGridBox = self:NewUI(13, CBox)
	self.m_MainAttrGrid = self:NewUI(14, CGrid)
	self.m_MainAttrLabel = self:NewUI(15, CLabel)
	self.m_SelectBtn = self:NewUI(16, CButton)
	self.m_EquipIconSpr = self:NewUI(17, CSprite)
	self.m_EquipItemLevelSpr = self:NewUI(18, CSprite)
	self.m_TipsBtn = self:NewUI(19, CButton)
	self.m_CanResetQualityPoolLabel = self:NewUI(20, CLabel)
	self.m_EquipBox = self:NewUI(21, CBox)
	self.m_AttrPreviewBtn = self:NewUI(23, CButton)
	self.m_AttrPreBox = self:NewUI(24, CBox)
	self.m_AttrPreGrid = self:NewUI(25, CGrid)
	self.m_AttrPreTitleLabel = self:NewUI(26, CLabel)

	self.m_AttrFromGridBox:SetActive(false)
	self.m_AttrToGridBox:SetActive(false)
	self.m_MainAttrLabel:SetActive(false)
	self.m_AttrPreBox:SetActive(false)
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnReset"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSave"))	
	self.m_AutoSprite:AddUIEvent("click", callback(self, "OnAutoFill"))
	self.m_SelectBtn:AddUIEvent("longpress", callback(self, "OnSelectLongPress"))
	self.m_SelectBtn:AddUIEvent("click", callback(self, "OnSelectClick"))
	self.m_EquipBox:AddUIEvent("click", callback(self, "OnShowEquip"))
	self.m_AttrPreviewBtn:AddUIEvent("click", callback(self, "OnAttrPreview", true))
	self.m_AttrPreBox:AddUIEvent("click", callback(self, "OnAttrPreview", false))
	
	self.m_TipsBtn:AddHelpTipClick("forge_fuwen")
	self.m_SelectBtn:SetLongPressTime(2)
	self:ResetButtonPos()

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self:InitAttrGrid()
	self:InitAutoFill()
	self:RefreshAll()
end

function CForgeFuwenPage.ShowPage(self, pos)

	self.m_EquipType = pos

	if  self.m_IsInit then
		self:RefreshAll()
	end
	
	CPageBase.ShowPage(self)
end


function CForgeFuwenPage.UpdateEquip(self, pos)
	self.m_EquipType = pos
	self:RefreshAll()
end

function CForgeFuwenPage.RefreshAll(self)
	self:RefreshAttrGrid()
	self:RefreshUseItem()
	self.m_SelectBtn:SetText(g_ItemCtrl:GetFuwenPlanName( g_ItemCtrl:GetFuwenPlan()))
end

function CForgeFuwenPage.ResetButtonPos(self)
	local isShow = g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.fuwenswitch.open_grade
	self.m_SelectBtn:SetActive(isShow)
end

function CForgeFuwenPage.OnAutoFill(self)
	self.m_AutoFill = not self.m_AutoFill
	if self.m_AutoFill then
		g_NotifyCtrl:FloatMsg("设置自动水晶代替材料")
	else
		g_NotifyCtrl:FloatMsg("取消设置水晶代替材料")
	end
	g_ItemCtrl.m_ForgeFuwenAutoFill = self.m_AutoFill
	self:RefreshUseItem()
end

function CForgeFuwenPage.OnReset(self)
	if self.m_IsCanReset == CForgeFuwenPage.EnumIsCanResetFuwen.Can then
		local t = self.m_FuwenResetInfo
		g_ItemCtrl:C2GSResetFuWen(t.pos, t.price)
	else
		if self.m_IsCanReset ==  CForgeFuwenPage.EnumIsCanResetFuwen.NotMaterial then
			self:ShowMaterailTips(tonumber(data.globaldata.GLOBAL.attr_fuwen_itemid.value), self.m_UseItemSprite)
		end
		g_NotifyCtrl:FloatMsg(self.m_IsCanReset.str)
	end
end

function CForgeFuwenPage.OnSave(self)
	g_ItemCtrl:C2GSSaveFuWen(self.m_EquipType)
end

function CForgeFuwenPage.RefreshAttrGrid(self)
	local oItem = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	local tOldAttr = oItem:GetEquipAttrFuWen()
	local tNewAttr = oItem:GetEquipAttrFuWenBackup()

	tOldAttr = self:SortAttr(tOldAttr)
	tNewAttr = self:SortAttr(tNewAttr)

	--符文波动系数
	local minWave, maxWave = g_ItemCtrl:GetFuwenWaveRange()
	minWave = minWave / 100
	maxWave = maxWave / 100
	local tEuqipData = oItem
	local tFuwenData = g_ItemCtrl:GetEquipFuwenDataByPosAndLevel(tEuqipData:GetValue("pos"), tEuqipData:GetValue("equip_level"))	

	for i = 1, 4 do
		local oBox = self.m_FromBoxList[i]
		local oMainAttr = self.m_MainAttrLAbelList[i]
		if i <= #tOldAttr then
			oBox:SetActive(true)
			--暂时隐藏波动属性
			oMainAttr:SetActive(false)
			local sKey = define.Attr.String[tOldAttr[i].key] or tOldAttr[i].key			
			local sAttr = ""
			local minAttr = ""
			local maxAttr = ""

			if tOldAttr[i].value ~= nil then
				sAttr = g_ItemCtrl:AttrStringConvert(tOldAttr[i].key, tOldAttr[i].value)			
			else
				sAttr = g_ItemCtrl:AttrStringConvert(tOldAttr[i].key, 0)
			end
			local color = g_ItemCtrl:GetFuwenQualityColor(tOldAttr[i].quality)
			oBox.m_KeyLabel:SetText(color..sKey)
			oBox.m_AttrLabel:SetText(color..sAttr)

			--符文波动属性			
			-- minAttr = g_ItemCtrl:AttrStringConvert(tOldAttr[i].key, tonumber(tFuwenData[tOldAttr[i].key]) * minWave, true)
			-- maxAttr = g_ItemCtrl:AttrStringConvert(tOldAttr[i].key, tonumber(tFuwenData[tOldAttr[i].key]) * maxWave, true)
			oMainAttr:SetText(string.format("%s:%s~%s", sKey, minAttr, maxAttr))
		else
			oBox:SetActive(false)
			oMainAttr:SetActive(false)
		end
	end

	if next(tNewAttr) ~= nil then
		self.m_ToWidget:SetActive(true)
		for i = 1, 4 do
			local oBox = self.m_ToBoxList[i]
			if i <= #tNewAttr then
				oBox:SetActive(true)
				local sKey = define.Attr.String[tNewAttr[i].key] or tNewAttr[i].key
				local sAttr = ""
				if tNewAttr[i].value ~= nil then
					sAttr = g_ItemCtrl:AttrStringConvert(tNewAttr[i].key, tNewAttr[i].value)
				else
					sAttr = g_ItemCtrl:AttrStringConvert(tNewAttr[i].key, 0)
				end						
					--重置的属性平直平直为5， 测试
				local color = g_ItemCtrl:GetFuwenQualityColor(tNewAttr[i].quality)		
				oBox.m_KeyLabel:SetText(color..sKey)
				oBox.m_AttrLabel:SetText(color..sAttr)
			else
				oBox:SetActive(false)
			end
		end
	else
		self.m_ToWidget:SetActive(false)
	end

	self.m_AttrFromGrid:Reposition()
	self.m_AttrToGrid:Reposition()
	self.m_MainAttrGrid:Reposition()
end

function CForgeFuwenPage.RefreshUseItem(self)
	self.m_IsCanReset = CForgeFuwenPage.EnumIsCanResetFuwen.Can
	self.m_FuwenResetInfo = {}
	local tEuqipData = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	local tFuwenData = g_ItemCtrl:GetEquipFuwenDataByPosAndLevel(tEuqipData:GetValue("pos"), tEuqipData:GetValue("equip_level"))
	local fuwenSid = tonumber(data.globaldata.GLOBAL.attr_fuwen_itemid.value)
	local oFuWenItem = CItem.NewBySid(fuwenSid)
	local ownCount = g_ItemCtrl:GetTargetItemCountBySid(fuwenSid)
	local tPrice = g_ItemCtrl.m_MaterailPriceCache[fuwenSid] or 0
	local needCount = tFuwenData.count
	local cost = 0
	local str = ""
	self.m_UseItemSprite:SpriteItemShape(oFuWenItem:GetValue("icon"))
	self.m_UseItemSprite:AddUIEvent("click", callback(self, "ShowMaterailTips", fuwenSid))
	if ownCount >= needCount then
		str = string.format("#G%d/%d", ownCount, needCount)		
	else
		str = string.format("#R%d[8A6029]/%d", ownCount, needCount)	
		cost = (needCount - ownCount) * tPrice
	end
	self.m_UseItemCountLabel:SetText(str)

	--自动填充材料暂时隐藏
	self.m_AutoLabel:SetActive(false)
	--self.m_AutoLabel:SetActive(cost > 1)

	self.m_AutoLabel:SetText("自动"..string.numberConvert(cost).."水晶代替材料")

	--客户的判断是否能重置
	if cost ~= 0 then
		if self.m_AutoFill then
			if g_AttrCtrl.goldcoin < cost then
				self.m_IsCanReset = CForgeFuwenPage.EnumIsCanResetFuwen.NotGoldCoin
			end
		else
			self.m_IsCanReset = CForgeFuwenPage.EnumIsCanResetFuwen.NotMaterial
		end
	end
	
	--发送符文重置协议所需参数
	local argCount = ownCount > needCount and needCount or ownCount
	local argPrice = self.m_AutoFill and tPrice or 0
	self.m_FuwenResetInfo = {pos = self.m_EquipType, price = argPrice}

end

function CForgeFuwenPage.InitAttrGrid( self )
	self.m_AttrFromGrid:Clear()
	self.m_FromBoxList = {}
	for i = 1 , 4 do
		local oBox = self.m_AttrFromGridBox:Clone()
		oBox:SetActive(true)
		oBox.m_KeyLabel = oBox:NewUI(1, CLabel)
		oBox.m_AttrLabel = oBox:NewUI(2, CLabel)
		self.m_AttrFromGrid:AddChild(oBox)
		table.insert(self.m_FromBoxList, oBox)
	end
	self.m_AttrToGrid:Clear()
	self.m_ToBoxList = {}
	for i = 1 , 4 do
		local oBox = self.m_AttrToGridBox:Clone()
		oBox:SetActive(true)
		oBox.m_KeyLabel = oBox:NewUI(1, CLabel)
		oBox.m_AttrLabel = oBox:NewUI(2, CLabel)
		self.m_AttrToGrid:AddChild(oBox)
		table.insert(self.m_ToBoxList, oBox)
	end	

	self.m_MainAttrGrid:Clear()
	self.m_MainAttrLAbelList = {}
	for i = 1 , 4 do
		local oBox = self.m_MainAttrLabel:Clone()
		oBox:SetActive(true)
		self.m_MainAttrGrid:AddChild(oBox)
		table.insert(self.m_MainAttrLAbelList, oBox)
	end		
end

function CForgeFuwenPage.InserKey( self, t, key)

	for k, v in pairs(t) do
		if v == key then
			return 
		end
	end
	table.insert(t, key)
end

function CForgeFuwenPage.OnCtrlItemEvent( self, oCtrl)
	if self:GetActive() ~= true then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem or
		oCtrl.m_EventID == define.Item.Event.RefreshItemPrice then
		self:RefreshUseItem()

	elseif oCtrl.m_EventID == define.Item.Event.RefreshFuwen then		
		self:RefreshAttrGrid()
		self.m_SelectBtn:SetText(g_ItemCtrl:GetFuwenPlanName( g_ItemCtrl:GetFuwenPlan()))

	elseif oCtrl.m_EventID == define.Item.Event.RefreshFuwenName then	
		self.m_SelectBtn:SetText(g_ItemCtrl:GetFuwenPlanName( g_ItemCtrl:GetFuwenPlan()))
		
	end
end

function CForgeFuwenPage.OnCtrlAttrEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshUseItem()
		self:ResetButtonPos()
	end
end

function CForgeFuwenPage.SortAttr( self, tData)
	local t = {}
	for _k, _v in pairs(define.Attr.AttrKey) do 
		for k,v in pairs(tData) do
			if define.Attr.String[v.key] ~= nil and v.value ~= 0 and _v == v.key then
				table.insert(t,v)
			end
		end
	end
	return t
end

function CForgeFuwenPage.ShowMaterailTips(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid,
	{widget=  oBox, openView = self.m_ParentView}, nil, {showQuickBuy = true, ignoreCloseOwnerView = true})
end

function CForgeFuwenPage.InitAutoFill(self)
	if self.m_AutoFill == true then
		self.m_AutoSprite:SetSelected(true)
	end
end

function CForgeFuwenPage.OnSelectLongPress(self, oBox, bPress)
	-- if bPress then
	-- 	CForgeFuwenTipsView:ShowView()
	-- end
end

function CForgeFuwenPage.OnSelectClick(self)
	--if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSUseFuWenPlan"]) then
	--	netitem.C2GSUseFuWenPlan()
	--end
	CForgeFuwenTipsView:ShowView()
end

function CForgeFuwenPage.OnAttrPreview(self, b)
	if b then
		self.m_AttrPreBox:SetActive(true)
		local t = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
		local level = t:GetValue("equip_level")
		local min, max = g_ItemCtrl:GetFuwenCanResetQuality(t:GetValue("pos"), level)
		local minWave, maxWave = g_ItemCtrl:GetFuwenWaveRange()
		local dMin = g_ItemCtrl:GetFuwenCanResetAttrPool(min, level) 
		local dMax = g_ItemCtrl:GetFuwenCanResetAttrPool(max, level) 

		minWave = minWave / 100
		maxWave = maxWave / 100
		local attr = 
		{
			[1] = {key="maxhp",  				str="气血"},
			[2] = {key="attack",  				str="攻击"},
			[3] = {key="defense", 				str="防御"},
			[4] = {key="critical_ratio", 		str="暴击率"},
			[5] = {key="res_critical_ratio", 	str="抗暴率"},
			[6] = {key="critical_damage",		str="暴击伤害"},
			[7] = {key="abnormal_attr_ratio", 	str="异常命中率"},
			[8] = {key="res_abnormal_ratio", 	str="异常抵抗率"},
			[9] = {key="speed", 				str="速度"},		
		}
		self.m_AttrPreTitleLabel:SetText(string.format("%d级淬灵属性范围", t:GetValue("equip_level")))
		if not self.m_AttrPreGrid.m_Init then
			self.m_AttrPreGrid:InitChild(function (obj, idx)
				local oBox = CBox.New(obj)
				oBox.m_KeyLabel = oBox:NewUI(1, CLabel)
				oBox.m_ValueLabel = oBox:NewUI(2, CLabel)
				return oBox
			end)
			self.m_AttrPreGrid.m_Init = true
		end
		for i, v in ipairs(attr) do
			local oBox = self.m_AttrPreGrid:GetChild(i)
			local minStr = g_ItemCtrl:AttrStringConvert(v.key, dMin[v.key] * minWave)
			local maxStr = g_ItemCtrl:AttrStringConvert(v.key, dMax[v.key] * maxWave)
			oBox.m_KeyLabel:SetText(v.str)
			oBox.m_ValueLabel:SetText(string.format("%s-%s", minStr, maxStr))
		end	
	else
		self.m_AttrPreBox:SetActive(false)
	end
end

function CForgeFuwenPage.RefreshEquip(self, equipPos)
	local tData = g_ItemCtrl:GetEquipedByPos(equipPos)
	local shape = tData:GetValue("icon") or 0
	local itemLevel = tData:GetValue("itemlevel")	
	self.m_EquipIconSpr:SpriteItemShape(shape)
	self.m_EquipItemLevelSpr:SetItemQuality(itemLevel)
	local level = tData:GetValue("equip_level") or 0
	local str = string.format("%s", g_ItemCtrl:GetFuwenCanResetQualityPoolString(equipPos, level))
	self.m_CanResetQualityPoolLabel:SetText(str)
end

function CForgeFuwenPage.OnShowEquip(self)
	local oItem = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem)
	end	
end

return CForgeFuwenPage