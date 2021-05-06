---------------------------------------------------------------
--打造界面主界面


---------------------------------------------------------------

local CForgeMainView = class("CForgeMainView", CViewBase)

CForgeMainView.TabIndex = 
{
	Strength = 1,
	Gem = 2,
	Fuwen = 3,		
	Composite = 4,
}

function CForgeMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeMainView.prefab", cb)
	--界面设置
	--self.m_GroupName = "main"
	self.m_KeyPageList = {}
	self.m_TabType = "IntensifyPage"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
	self.m_EquipType = 1
	self.m_LockType = nil
	self.m_TabIndex = nil
	self.m_CompositeTabIndex = 1
end

function CForgeMainView.OnCreateView(self)
	self.m_BackBtn = self:NewUI(1, CButton)
	self.m_CloseBtn = self:NewUI(2, CButton)

	self.m_CompositeTapBtn = self:NewUI(3, CBox)

	self.m_IntensifyPage = self:NewPage(4, CForgeStrengthPage)
	self.m_RunePage = self:NewPage(5, CForgeFuwenPage)		
	self.m_GemPage = self:NewPage(6, CForgeGemPage)
	self.m_BaseEquipGroup = self:NewUI(7, CBox)

	self.m_IntensifyTabBtn = self:NewUI(8, CBox)
	self.m_RuneTabBtn = self:NewUI(9, CBox)
	self.m_GemTabBtn = self:NewUI(10, CBox)

	self.m_WeaponTabBtn = self:NewUI(11, CBox)
	self.m_ClothTabBtn = self:NewUI(12, CBox)
	self.m_RingTabBtn = self:NewUI(13, CBox)
	self.m_NeckLaceTabBtn = self:NewUI(14, CBox)
	self.m_BeltTabBtn = self:NewUI(15, CBox)
	self.m_ShoeTabBtn = self:NewUI(16, CBox)

	self.m_MainEquipTipsBtn = self:NewUI(19, CButton)
	self.m_TypeTabBtnGrid = self:NewUI(20, CTabGrid)
	self.m_EquipTabBtnGrid = self:NewUI(21, CGrid)
	self.m_CompositeGroup = self:NewUI(22, CBox)
	self.m_CompositeBtnGrid = self:NewUI(23, CGrid)
	self.m_CompositePage = self:NewPage(24, CForgeCompositePage)
	self.m_ExchangePage = self:NewPage(25, CForgeExchangePage)
	self.m_ResolvePage = self:NewPage(26, CForgeResolvePage)

	self:InitContent()
	self:RefreshEquip()
end

function CForgeMainView.InitContent(self)
	self.m_LockType = {}
	self.m_LockType[1] = data.globalcontroldata.GLOBAL_CONTROL.forge_strength.open_grade
	self.m_LockType[2] = data.globalcontroldata.GLOBAL_CONTROL.forge_gem.open_grade
	self.m_LockType[3] = data.globalcontroldata.GLOBAL_CONTROL.forge_fuwen.open_grade
	self.m_LockType[4] = data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade

	self.m_TypeTabBtnGrid:InitChild(function(obj, idx)
			local oBtn = CBox.New(obj)
			oBtn.m_Type = idx
			oBtn.m_LockBox = oBtn:NewUI(1, CBox)
			oBtn.m_SelectBox = oBtn:NewUI(2, CBox)
			oBtn.m_RedDot = oBtn:NewUI(3, CBox)
			if self.m_LockType[idx] and  g_AttrCtrl.grade < self.m_LockType[idx] then
				oBtn.m_LockBox:SetActive(true)
			else
				oBtn.m_LockBox:SetActive(false)
			end
			oBtn.m_RedDot:SetActive(false)
			oBtn.m_IgnoreCheckEffect = true
			return oBtn
		end)
	self.m_EquipTabBtnGrid:InitChild(function(obj, idx)
		local oBtn = CBox.New(obj)
		oBtn.m_EquipIconSprite = oBtn:NewUI(1, CSprite)
		oBtn.m_Effect = oBtn:NewUI(3, CUIEffect)
		oBtn.m_QulitySprite = oBtn:NewUI(4, CSprite)
		oBtn.m_NameLabel = oBtn:NewUI(5, CLabel)
		oBtn.m_LevelLabel = oBtn:NewUI(6, CLabel)
		oBtn.m_Pos = idx
		oBtn:SetGroup(self.m_EquipTabBtnGrid:GetInstanceID())

		local tData = g_ItemCtrl:GetEquipedByPos(idx)
		if tData then
			oBtn.m_EquipIconSprite:SpriteItemShape(tData:GetValue("icon"))
			local itemlevel = tData:GetValue("itemlevel") or 1
			oBtn.m_QulitySprite:SetItemQuality(itemlevel)	
			oBtn.m_Effect:SetActive(itemlevel == 4 or itemlevel == 5)
			oBtn.m_Effect:Above(oBtn)
			oBtn.m_NameLabel:SetQualityColorText(itemlevel, string.format("%s+%d", tData:GetValue("name"), tData:GetStrengthLevel()))
			oBtn.m_LevelLabel:SetQualityColorText(itemlevel, string.format("Lv.%d", tData:GetValue("equip_level")))
		end		
		oBtn:AddUIEvent("click", callback(self, "OnEquipClick",idx))
		oBtn.m_IgnoreCheckEffect = true
		if idx == define.Equip.Pos.Weapon then
			g_GuideCtrl:AddGuideUI("forge_equip_pos_1", oBtn)
		end
		return oBtn
	end)

	self.m_CompositeBtnGrid:InitChild(function (obj, idx)
		local oBtn = CBox.New(obj)
		oBtn:SetGroup(self.m_CompositeBtnGrid:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnShowCompositePage", idx, false))
		return oBtn
	end)

	self.m_KeyPageList = 
	{
		["IntensifyPage"] = self.m_IntensifyPage,
		["RunePage"] = self.m_RunePage,
		["GemPage"] = self.m_GemPage		
	}
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	self.m_IntensifyTabBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
	self.m_RuneTabBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
	self.m_GemTabBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
	self.m_CompositeTapBtn:SetClickSounPath(define.Audio.SoundPath.Tab)

	self.m_IntensifyTabBtn:AddUIEvent("click", callback(self, "ShowIntensifyPage"))
	self.m_RuneTabBtn:AddUIEvent("click", callback(self, "ShowRunePage"))
	self.m_GemTabBtn:AddUIEvent("click", callback(self, "ShowGemPage"))
	self.m_CompositeTapBtn:AddUIEvent("click", callback(self, "ShowComposite", 0))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self:ShowDefaultPage()
end

function CForgeMainView.ShowIntensifyPage(self)
	if self.m_LockType[1] and g_AttrCtrl.grade < self.m_LockType[1] then
		g_NotifyCtrl:FloatMsg(string.format("%d级开启突破功能哦", self.m_LockType[1]))
		return 
	end
	if data.globalcontroldata.GLOBAL_CONTROL.forge_strength.is_open == "n" then
		g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
		return
	end
	self:ResetTab(1)
	self.m_TabIndex = CForgeMainView.TabIndex.Strength
	self:ShowSubPage(self.m_IntensifyPage, self.m_EquipType)
	self.m_TabType = "IntensifyPage"
	self.m_MainEquipTipsBtn:AddHelpTipClick("forge_strength")
	self:RefreshEquipList()
	self:RefreshEquip()
end

function CForgeMainView.ShowRunePage(self)
	if self.m_LockType[3] and g_AttrCtrl.grade < self.m_LockType[3] then
		g_NotifyCtrl:FloatMsg(string.format("%d级开启淬灵功能哦", self.m_LockType[3]))
		return 
	end	
	if data.globalcontroldata.GLOBAL_CONTROL.forge_fuwen.is_open == "n" then
		g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
		return
	end
	self:ResetTab(3)
	self.m_TabIndex = CForgeMainView.TabIndex.Fuwen
	self:ShowSubPage(self.m_RunePage, self.m_EquipType)
	self.m_TabType = "RunePage"
	self.m_MainEquipTipsBtn:AddHelpTipClick("forge_fuwen")
	self:RefreshEquipList()
	self:RefreshEquip()
end

function CForgeMainView.ShowGemPage(self)
	if self.m_LockType[2] and g_AttrCtrl.grade < self.m_LockType[2] then
		g_NotifyCtrl:FloatMsg(string.format("%d级开启宝石功能哦", self.m_LockType[2]))
		return 
	end	
	if data.globalcontroldata.GLOBAL_CONTROL.forge_gem.is_open == "n" then
		g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
		return
	end	
	self:ResetTab(2)
	self.m_TabIndex = CForgeMainView.TabIndex.Gem
	--self.m_GemTabBtn.m_SelectBox:SetActive(true)
	self:ShowSubPage(self.m_GemPage, self.m_EquipType)
	self.m_TabType = "GemPage"
	self.m_MainEquipTipsBtn:AddHelpTipClick("forge_gem")
	self:RefreshEquipList()
	self:RefreshEquip()
end

function CForgeMainView.ShowComposite(self, compositeIdx)
	if self.m_LockType[4] and g_AttrCtrl.grade < self.m_LockType[4] then
		g_NotifyCtrl:FloatMsg(string.format("%d级开启打造功能哦", self.m_LockType[4]))
		return 
	end	
	if data.globalcontroldata.GLOBAL_CONTROL.forge_composite.is_open == "n" then
		g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
		return
	end

	self:ResetTab(4)
	self.m_TabIndex = CForgeMainView.TabIndex.Composite	

	if compositeIdx ~= 0 then
		self:OnShowCompositePage(compositeIdx, true)
	else
		self:OnShowCompositePage(self.m_CompositeTabIndex, true)
	end
	
	self.m_TabType = "CompositePage"
end

function CForgeMainView.OnShowCompositePage(self, idx, isMainTab)
	if isMainTab == true and self.m_TabType == "CompositePage" then
		return
	end
	if isMainTab or self.m_CompositeTabIndex ~= idx  then
		self.m_CompositeTabIndex = idx
		if idx == 1 then
			self.m_MainEquipTipsBtn:AddHelpTipClick("forge_composite")
			self:ShowSubPage(self.m_CompositePage)

		elseif idx == 2 then
			self.m_MainEquipTipsBtn:AddHelpTipClick("forge_exchange")
			self:ShowSubPage(self.m_ExchangePage)

		elseif idx == 3 then
			self.m_MainEquipTipsBtn:AddHelpTipClick("forge_resolve")
			self:ShowSubPage(self.m_ResolvePage)
		end		
	end
	for i = 1, self.m_CompositeBtnGrid:GetCount() do
		local oBtn = self.m_CompositeBtnGrid:GetChild(i)
		if i == idx then
			oBtn:SetSelected(true)
		else
			oBtn:SetSelected(false)
		end
	end
end

function CForgeMainView.ShowDefaultPage( self)
	self:UpdateEquipBtn(self.m_EquipType)
	self:ShowIntensifyPage()
end

function CForgeMainView.UpdateEquipBtn(self, pos)
	local btn = self.m_EquipTabBtnGrid:GetChild(pos)
	if btn then
		self:ResetTab(self.m_TabIndex)
		btn:SetSelected(true)
	end
end

function CForgeMainView.OnEquipClick(self, pos)
	if  self.m_EquipType == pos then 
		return 
	end
	self.m_EquipType = pos
	self:DelayCall(0.1, "UpdateEquipBtn", pos)
	self:RefreshEquip()
	local func = self.m_KeyPageList[self.m_TabType].UpdateEquip
	if func then
		func(self.m_KeyPageList[self.m_TabType], pos)
	end 
end

function CForgeMainView.RefreshEquip(self)
	if self.m_CurPage and self.m_CurPage.RefreshEquip then
		self.m_CurPage:RefreshEquip(self.m_EquipType)
	end
end

function CForgeMainView.OnCtrlItemEvent( self, oCtrl)
	if self:GetActive() ~= true then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or
	oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
	oCtrl.m_EventID == define.Item.Event.RefreshEquip then
		self:RefreshEquip()
		self:RefreshEquipList()
	end
end

function CForgeMainView.ShowView( self, cb)
	--每次进入打造界面，请求一次材料的价格
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade then
		g_ItemCtrl:RequestForgeMaterailPrice()
		CViewBase.ShowView(self, cb)	
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启装备功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade))
	end
end

function CForgeMainView.RefreshEquipList(self)
	for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
		local btn = self.m_EquipTabBtnGrid:GetChild(i)
		if btn then
			local b = g_ItemCtrl:ShowForgeRedDotByPos(i, self.m_TabIndex)			
			if b == true then			
				btn.m_EquipIconSprite:AddEffect("RedDot", 24, Vector2.New(-30, -30))
			else
				btn.m_EquipIconSprite:DelEffect("RedDot")
			end

			local tData = g_ItemCtrl:GetEquipedByPos(i)
			if tData then
				btn.m_EquipIconSprite:SpriteItemShape(tData:GetValue("icon"))
				local itemlevel = tData:GetValue("itemlevel") or 1
				btn.m_QulitySprite:SetItemQuality(itemlevel)	
				btn.m_NameLabel:SetQualityColorText(itemlevel, string.format("%s+%d", tData:GetValue("name"), tData:GetStrengthLevel()))
				btn.m_LevelLabel:SetQualityColorText(itemlevel, string.format("Lv.%d", tData:GetValue("equip_level")))
			end					
		end
	end

	for k = 1, 3 do 
		local tab = self.m_TypeTabBtnGrid:GetChild(k)
		if tab then
			local b = g_ItemCtrl:ShowForgeRedDotByType(k)			
			if b == true and self.m_LockType[k] and g_AttrCtrl.grade >= self.m_LockType[k] then
				tab.m_RedDot:SetActive(true)
			else
				tab.m_RedDot:SetActive(false)
			end
		end
	end
end

function CForgeMainView.RefeshLock(self)
	for k = 1, 3 do 
		local tab = self.m_TypeTabBtnGrid:GetChild(k)
		if tab then		
			if self.m_LockType[k] and g_AttrCtrl.grade < self.m_LockType[k] then
				tab.m_LockBox:SetActive(true)
			else
				tab.m_LockBox:SetActive(false)
			end
		end
	end
end

function CForgeMainView.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefeshLock()
	end
end

function CForgeMainView.ResetTab(self, index)
	for k = 1, self.m_TypeTabBtnGrid:GetCount() do 
		local tab = self.m_TypeTabBtnGrid:GetChild(k)
		if tab and tab.m_SelectBox then		
			if index == k then
				tab.m_SelectBox:SetActive(true)
			else
				tab.m_SelectBox:SetActive(false)
			end			
		end
	end

	if index == 4 then
		self.m_BaseEquipGroup:SetActive(false)
		self.m_CompositeGroup:SetActive(true)
	else
		self.m_BaseEquipGroup:SetActive(true)
		self.m_CompositeGroup:SetActive(false)
	end
end

function CForgeMainView.CloseView(cls)
	CViewBase.CloseView(cls)
end

return CForgeMainView