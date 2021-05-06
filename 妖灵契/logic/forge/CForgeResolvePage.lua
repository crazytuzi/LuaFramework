---------------------------------------------------------------
--打造界面的 分解 子界面


---------------------------------------------------------------
local CForgeResolvePage = class("CForgeResolvePage", CPageBase)

function CForgeResolvePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_CanList = {}
	self.m_CanBoxList = {}
	self.m_WaitList = {}
	self.m_WaitBoxList = {}
	self.m_GainList = {}
	self.m_GainBoxList = {}

end

function CForgeResolvePage.OnInitPage(self)
	self.m_ResolveBtn = self:NewUI(1, CButton)
	self.m_CanScrollView = self:NewUI(2, CScrollView)
	self.m_CanGrid = self:NewUI(3, CGrid)
	self.m_WaitScrollView = self:NewUI(4, CScrollView)
	self.m_WaitGrid = self:NewUI(5, CGrid)
	self.m_GainScrollView = self:NewUI(6, CScrollView)
	self.m_GainGrid = self:NewUI(7, CGrid)
	self.m_CanItemCloneBox = self:NewUI(8, CBox)
	self.m_WaitItemCloneBox = self:NewUI(9, CBox)
	self.m_GainItemCloneBox = self:NewUI(10, CItemTipsBox)
	self.m_TipsBtn = self:NewUI(11, CButton)
	self.m_NoneTipsLabel = self:NewUI(12, CLabel)
	self.m_ScrollView = self:NewUI(13, CScrollView)
	self.m_CanList = {}
	self.m_CanBoxList = {}
	self.m_WaitList = {}
	self.m_WaitBoxList = {}

	self:InitContent()
end

function CForgeResolvePage.InitContent(self)
	self.m_CanItemCloneBox:SetActive(false)
	self.m_WaitItemCloneBox:SetActive(false)
	self.m_GainItemCloneBox:SetActive(false)
	self.m_ResolveBtn:AddUIEvent("click", callback(self, "OnClickResolve"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_TipsBtn:AddHelpTipClick("forge_resolve")
	self:RefreshCanGroup()
end

function CForgeResolvePage.RefreshCanGroup(self)
	self.m_CanList = g_ItemCtrl:GetCanResolveEquip()
	for i = 1, #self.m_CanList do
		local oBox = self.m_CanBoxList[i]
		if not oBox then
			oBox = self:CreateCloneBox(self.m_CanItemCloneBox)
			self.m_CanGrid:AddChild(oBox)
			table.insert(self.m_CanBoxList, oBox)
		end
		oBox:SetActive(true)
		local oItem = self.m_CanList[i]
		oBox.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QualitySpr:SetItemQuality(oItem:GetValue("itemlevel"))
		oBox.m_NameLabel:SetText(oItem:GetValue("name"))
		oBox.m_CountLabel:SetText(string.format("Lv.%d", oItem:GetValue("level")))
		oBox.m_SelectSpr:SetActive(false)
		oBox:AddUIEvent("click", callback(self, "OnClickCanBox", i))
		oBox:AddUIEvent("longpress", callback(self, "OnLongPressCanBox", i))
	end
	if #self.m_CanList < #self.m_CanBoxList then
		for i = #self.m_CanList + 1, #self.m_CanBoxList do
			local oBox = self.m_CanBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
	self.m_NoneTipsLabel:SetActive(#self.m_CanList == 0)
end

function CForgeResolvePage.RefreshWiatGroup(self)
	for i = 1, #self.m_WaitList do
		local oBox = self.m_WaitBoxList[i]
		if not oBox then
			oBox = self:CreateCloneBox(self.m_WaitItemCloneBox)
			self.m_WaitGrid:AddChild(oBox)
			table.insert(self.m_WaitBoxList, oBox)
		end
		oBox:SetActive(true)
		local oItem = self.m_WaitList[i]
		oBox.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QualitySpr:SetItemQuality(oItem:GetValue("itemlevel"))
		oBox.m_NameLabel:SetText(oItem:GetValue("name"))
		oBox.m_CountLabel:SetActive(false)
		oBox.m_SelectSpr:SetActive(false)
		oBox:AddUIEvent("click", callback(self, "OnClickWaitBox", i))
		oBox:AddUIEvent("longpress", callback(self, "OnLongPressWaitBox", i))
	end
	if #self.m_WaitList < #self.m_WaitBoxList then
		for i = #self.m_WaitList + 1, #self.m_WaitBoxList do
			local oBox = self.m_WaitBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
	self:RefreshGainGroup()
	self.m_WaitGrid:Reposition()
	self.m_GainGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CForgeResolvePage.OnClickCanBox(self, idx)
	local oItem = self.m_CanList[idx]
	if oItem then
		local id = oItem:GetValue("id")
		local waitIdx = self:GetItemIdxInList(id, self.m_WaitList)
		local canIdx = self:GetItemIdxInList(id, self.m_CanList)
		local oBox = self.m_CanBoxList[canIdx]
		if oBox then
			if waitIdx == 0 then
				if table.count(self.m_WaitList) >= 6 then
					g_NotifyCtrl:FloatMsg("最多一次分解6件装备")
					return
				end
				oBox.m_SelectSpr:SetActive(true)
				table.insert(self.m_WaitList, oItem)				
			else
				oBox.m_SelectSpr:SetActive(false)
				table.remove(self.m_WaitList, waitIdx)
			end	
			self:RefreshWiatGroup()
		end
	end
end

function CForgeResolvePage.OnLongPressCanBox(self, idx)
	-- body
end

function CForgeResolvePage.OnClickWaitBox(self, idx)
	local oItem = self.m_WaitList[idx]
	if oItem then
		local id = oItem:GetValue("id")
		local idx = self:GetItemIdxInList(id, self.m_CanList)		
		if idx ~= 0 then
			self:OnClickCanBox(idx)
		end
	end
end

function CForgeResolvePage.OnLongPressCanBox(self, idx)
	local oItem = self.m_CanList[idx]
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemSell(oItem,
		{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), showCenterMaskWidget = true})
	end
end

function CForgeResolvePage.GetItemIdxInList(self, id, list)
	local idx = 0
	if list and next(list) then
		for i, v in ipairs(list) do
			if id == v:GetValue("id") then
				idx = i
				break
			end
		end
	end
	return idx
end

function CForgeResolvePage.OnLongPressWaitBox(self, idx)
	local oItem = self.m_WaitList[idx]
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemSell(oItem,
		{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), showCenterMaskWidget = true})
	end
end

function CForgeResolvePage.CreateCloneBox(self, clone)
	local oBox = clone:Clone()
	oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_NameLabel = oBox:NewUI(3, CLabel)
	oBox.m_ItemBg = oBox:NewUI(4, CSprite)
	oBox.m_SelectSpr = oBox:NewUI(5, CSprite)
	oBox.m_CountLabel = oBox:NewUI(6, CLabel)
	return oBox
end

function CForgeResolvePage.RefreshGainGroup(self)
	local sidList = {}
	for i, v in ipairs(self.m_WaitList) do
		local sid = v:GetValue("sid")
		local d = data.forgedata.DE_COMPOSITE[sid]		
		if d and d.sid_item_list then			
			for _i, _v in ipairs(d.sid_item_list) do				
				sidList[_v.sid] = sidList[_v.sid] or 0
				sidList[_v.sid] = sidList[_v.sid] + _v.amount
			end			
		end
	end
	self.m_GainList = {}
	for k,v in pairs(sidList) do
		local d = {sid = k, count = v}
		table.insert(self.m_GainList, d)
	end

	if #self.m_GainList > 1 then
		table.sort(self.m_GainList, function (a, b)
			return a.sid < b.sid
		end)
	end

	for i = 1, #self.m_GainList do
		local oBox = self.m_GainBoxList[i]
		if not oBox then
			oBox = self.m_GainItemCloneBox:Clone()
			self.m_GainGrid:AddChild(oBox)
			table.insert(self.m_GainBoxList, oBox)
		end
		local d = self.m_GainList[i]
		oBox:SetItemData(d.sid, d.count, nil ,{isLocal = true})
		oBox:SetActive(true)
	end
	if #self.m_GainList < #self.m_GainBoxList then
		for i = #self.m_GainList + 1, #self.m_GainBoxList do
			local oBox = self.m_GainBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
end

function CForgeResolvePage.OnClickResolve(self)
	local cnt = table.count(self.m_WaitList)
	if cnt == 0 then
		g_NotifyCtrl:FloatMsg("请选择需要分解的装备")
	else
		local str = self.m_WaitList[1]:GetValue("name")
		local cnt = #self.m_WaitList
		local windowConfirmInfo = {
			msg				= string.format("将分解【%s】等%d件装备\n分解后将失去该装备，是否继续？", str, cnt),
			okCallback		= function ()	
				self:SendResolve()
			end,
			okStr = "是",
			cancelStr = "否",			
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
	end
end

function CForgeResolvePage.SendResolve(self)
	local info = {}
	for i, v in ipairs(self.m_WaitList) do
		table.insert(info, {sid = v:GetValue("sid"), id = v:GetValue("id"), amount = 1})
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSDeCompose"]) then	
		netitem.C2GSDeCompose(info)
	end
end

function CForgeResolvePage.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.ForgerResolveSuccess or 
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self.m_WaitList = {}
		self:RefreshCanGroup()
		self:RefreshWiatGroup()
	end
end

function CForgeResolvePage.ShowPage(self)
	if self.m_IsInitPage then
		self.m_WaitList = {}
		self:RefreshCanGroup()
		self:RefreshWiatGroup()
	else
		self.m_IsInitPage = true
	end
	CPageBase.ShowPage(self)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
end

return CForgeResolvePage