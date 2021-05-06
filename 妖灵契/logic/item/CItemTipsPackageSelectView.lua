local CItemTipsPackageSelectView = class("CItemTipsPackageSelectView", CViewBase)

CItemTipsPackageSelectView.UIType = 
{
	Normal = 1,
	EquipFbSelect = 2,	
}

function CItemTipsPackageSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsPackageSelectView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
	self.m_UIType = CItemTipsPackageSelectView.UIType.Normal
end

function CItemTipsPackageSelectView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_ItemGird = self:NewUI(2, CGrid)
	self.m_ItemCloneBox = self:NewUI(3, CBox)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_BatUseWidget = self:NewUI(5, CBox)
	self.m_CountBtn = self:NewUI(6, CButton)
	self.m_IncreassBtn = self:NewUI(7, CButton)
	self.m_ReduceBtn = self:NewUI(8, CButton)
	self.m_MaxBtn = self:NewUI(9, CButton)
	self.m_CountLabel = self:NewUI(10, CLabel)
	self.m_WinBg = self:NewUI(11, CSprite)

	self.m_SelectMax = 1
	self.m_SelectIdx = {}
	self.m_SelectItemPool = {}
	self.m_Id = nil
	self.m_BatUseCount = 1
	self.m_ItemCount = 1

	--装备副本装备选择
	self.m_EquipSelectSid = nil
	self.m_Floor = nil
	self:InitContent()	
end

function CItemTipsPackageSelectView.InitContent(self)
	self.m_ItemCloneBox:SetActive(false)
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnClickOk"))
	self.m_ReduceBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "reduce"))
	self.m_IncreassBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "increass"))	
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnBtnClick", "max"))
	self.m_CountBtn:AddUIEvent("click", callback(self, "OnBtnClick", "count"))
end

function CItemTipsPackageSelectView.SetItem(self, itemId, id)
	self.m_ItemId = itemId
	self.m_Id = id
	self.m_BatUseCount = 1
	self.m_ItemCount = 1	
	g_ItemCtrl.m_CurUseItemId = id
	if self.m_ItemId then
		self:UpdatePackage()
	end
end

function CItemTipsPackageSelectView.UpdatePackage(self)
	local oItem = CItem.NewBySid(self.m_ItemId)
	local gift_choose_amount = oItem:GetValue("gift_choose_amount")
	local use_reward = oItem:GetValue("use_reward")
	local bat_use = oItem:GetValue("bat_use")
	self.m_SelectMax = gift_choose_amount
	self.m_SelectItemPool = use_reward
	if bat_use == 1 then
		self.m_ItemCount = g_ItemCtrl:GetTargetItemCountById(self.m_Id)
	end
	self:ShowBatUseBox(self.m_ItemCount > 1)
	if self.m_SelectMax == 1 then
		self.m_TitleLabel:SetText(oItem:GetValue("name"))
	else
		self.m_TitleLabel:SetText(string.format("%s(可选%d个奖励)", oItem:GetValue("name"), self.m_SelectMax))		
	end

	local idx = 1
	for _,v in ipairs(self.m_SelectItemPool) do
		local sid = nil
		local value = 1		
		if v.sid and string.find(v.sid, "value") then
			sid, value = g_ItemCtrl:SplitSidAndValue(v.sid)
		else
			sid = tonumber(v.sid)
		end
		local d = CItem.NewBySid(tonumber(sid))
		if d then
			local type = d:GetValue("type")
			if (type ~= define.Item.ItemType.EquipStone and 
				type ~= define.Item.ItemType.Equip) or d:IsFit(true) then

				local oBox = self.m_ItemCloneBox:Clone()
				oBox:SetActive(true)
				oBox.m_IconSprite = oBox:NewUI(1, CSprite)
				oBox.m_QualitySprite = oBox:NewUI(2, CSprite)
				oBox.m_NameLabel = oBox:NewUI(3, CLabel)
				oBox.m_CountLabel = oBox:NewUI(4, CLabel)
				oBox.m_SelectBox = oBox:NewUI(5, CBox)
				oBox.m_SelectSprite = oBox:NewUI(6, CSprite) 
				oBox.m_UseforLabel = oBox:NewUI(7, CLabel)
				oBox.m_SelectSprite:SetActive(false)
				oBox.m_IconSprite:SpriteItemShape(d:GetValue("icon"))
				oBox.m_QualitySprite:SetItemQuality(d:GetValue("quality"))
				oBox.m_NameLabel:SetQualityColorText(d:GetValue("quality"), d:GetValue("name"))
				oBox:AddUIEvent("click", callback(self, "OnClickItem", idx, v.sid, oBox))
				oBox.m_CountLabel:SetText(v.amount * value )		
				oBox.m_CountLabel:SetActive(v.amount * value ~= 1)		
				local useforStr = ""
				local introduction = d:GetValue("introduction") or ""
				useforStr = "[作用]" .. introduction
				local des = d:GetValue("description") or ""
				useforStr = useforStr .. "\n" .. des
				oBox.m_UseforLabel:SetText(useforStr)

				self.m_ItemGird:AddChild(oBox)
				idx = idx + 1
			end
		end
	end
	self.m_CountLabel:SetText(tostring(self.m_BatUseCount))
end

function CItemTipsPackageSelectView.OnClickOk( self )
	if self.m_UIType == CItemTipsPackageSelectView.UIType.EquipFbSelect then
		self:EquipSelectClickOk()
		return
	end

	local cnt = table.count(self.m_SelectIdx)
	if cnt == 0 or cnt < self.m_SelectMax then
		g_NotifyCtrl:FloatMsg(string.format("当前剩余可选次数%d次,请选择奖励内容", self.m_SelectMax - cnt))
	else
		local items = {}
		for k, v in pairs(self.m_SelectIdx) do
			table.insert(items, tostring(v))
		end
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSChooseItem"]) then
			netitem.C2GSChooseItem(self.m_Id, items, self.m_BatUseCount)
		end
		self:CloseView()
	end
end

function CItemTipsPackageSelectView.OnClickItem( self, idx, sid, oBox)
	if self.m_SelectMax == 1 then
		if self.m_SelectIdx[idx] ~= nil then
			self.m_SelectIdx[idx] = nil			
			if oBox then
				oBox.m_SelectSprite:SetActive(self.m_SelectIdx[idx] ~= nil)
			end				
		else
			self.m_SelectIdx = {}
			self.m_SelectIdx[idx] = sid
			for i = 1, self.m_ItemGird:GetCount() do
				local tBox = self.m_ItemGird:GetChild(i)
				if tBox then				
					tBox.m_SelectSprite:SetActive(idx == i)
				end
			end
		end	
	else
		if self.m_SelectIdx[idx] == nil then
			local cnt = table.count(self.m_SelectIdx)
			if cnt >= self.m_SelectMax then
				g_NotifyCtrl:FloatMsg(string.format("当前可选奖励数量已满，仅可选择%d个奖励", self.m_SelectMax))
				return		
			end
			self.m_SelectIdx[idx] = sid
		else
			self.m_SelectIdx[idx] = nil
		end

		if oBox then
			oBox.m_SelectSprite:SetActive(self.m_SelectIdx[idx] ~= nil)
		end
	end
end

function CItemTipsPackageSelectView.ShowBatUseBox(self, b)
	if b then
		self.m_WinBg:SetHeight(602)
		self.m_BatUseWidget:SetActive(true)
		self.m_OkBtn:SetLocalPos(Vector3.New(232, -280, 0))
	else
		self.m_WinBg:SetHeight(536)
		self.m_BatUseWidget:SetActive(false)
		self.m_OkBtn:SetLocalPos(Vector3.New(0, -238, 0))
	end
end

function CItemTipsPackageSelectView.OnRePeatPress(self, tKey , ...)

	local bPress = select(2, ...)
	if bPress ~= true then
			return
	end 

	if tKey == "reduce" then
		self:OnBtnClick("reduce")
	elseif tKey == "increass" then
		self:OnBtnClick("increass")
	end
end

function CItemTipsPackageSelectView.OnBtnClick(self, tKey )
	if tKey == "reduce" then
		self.m_BatUseCount = self.m_BatUseCount - 1
		if self.m_BatUseCount  < 1 then
			self.m_BatUseCount = 1
		end
		self.m_CountLabel:SetText(tostring(self.m_BatUseCount))

	elseif tKey == "increass" then
		self.m_BatUseCount = self.m_BatUseCount + 1
		if self.m_BatUseCount > self.m_ItemCount then
			self.m_BatUseCount = self.m_ItemCount
		end
		self.m_CountLabel:SetText(tostring(self.m_BatUseCount))

	elseif tKey == "max" then
		self.m_BatUseCount = self.m_ItemCount
		self.m_CountLabel:SetText(tostring(self.m_BatUseCount))

	elseif tKey == "count" then
		local function syncCallback(self, count)
				self.m_BatUseCount = count
				self.m_CountLabel:SetText(tostring(count))
		end
		g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_BatUseCount, min = 1, max = self.m_ItemCount, syncfunc = syncCallback , obj = self},
		{widget=  self, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, -75)})
	end
end

function CItemTipsPackageSelectView.SetEquipItem(self, sidList, floor)
	self.m_UIType = CItemTipsPackageSelectView.UIType.EquipFbSelect
	self.m_Id = 0
	self.m_BatUseCount = 1
	self.m_ItemCount = 1	
	self.m_Floor = floor
	g_ItemCtrl.m_CurUseItemId = nil
	self:UpdateEquipList(sidList)
	self:ShowBatUseBox(false)
end

function CItemTipsPackageSelectView.UpdateEquipList(self, sidList)
	local gift_choose_amount = 1
	local bat_use = 1
	self.m_SelectMax = 1
	self.m_SelectItemPool = sidList
	self.m_TitleLabel:SetText("选择装备")
	for idx, sid in ipairs(self.m_SelectItemPool) do
		local d = CItem.NewBySid(tonumber(sid))
		if d then
			local iType = d:GetValue("type")
			if (iType ~= define.Item.ItemType.EquipStone and 
				iType ~= define.Item.ItemType.Equip) or d:IsFit(true) then
				local oBox = self.m_ItemCloneBox:Clone()
				oBox:SetActive(true)
				oBox.m_IconSprite = oBox:NewUI(1, CSprite)
				oBox.m_QualitySprite = oBox:NewUI(2, CSprite)
				oBox.m_NameLabel = oBox:NewUI(3, CLabel)
				oBox.m_CountLabel = oBox:NewUI(4, CLabel)
				oBox.m_SelectBox = oBox:NewUI(5, CBox)
				oBox.m_SelectSprite = oBox:NewUI(6, CSprite) 
				oBox.m_UseforLabel = oBox:NewUI(7, CLabel)
				oBox.m_SelectSprite:SetActive(false)
				oBox.m_IconSprite:SpriteItemShape(d:GetValue("icon"))
				oBox.m_QualitySprite:SetItemQuality(d:GetValue("quality"))
				oBox.m_NameLabel:SetQualityColorText(d:GetValue("quality"), d:GetValue("name"))
				oBox:AddUIEvent("click", callback(self, "OnClickEquipSelectItem", idx, tonumber(sid), oBox))
				oBox.m_CountLabel:SetActive(false)	

				--副本选择装备的作用描述
				local AttrItem = data.itemdata.EQUIPSTONE[sid]
				local attrStr = ""
				local min, max = g_ItemCtrl:GetEquipWaveRange()
				min = min / 100
				max = max / 100
				local t = {}
				--获取装备的基本属性
				for k,v in pairs (AttrItem) do
					if define.Attr.String[k] ~= nil and type(v) == "number" and v ~= 0 then
						t[k] = v
					end
				end
				t = g_ItemCtrl:SortAttr(t)
				for k,v in pairs (t) do
					if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
						local sKey = define.Attr.String[v.key] or v.key
						attrStr = string.format("%s\n%s+%s~%s", attrStr, sKey, g_ItemCtrl:AttrStringConvert(v.key, v.value * min) , g_ItemCtrl:AttrStringConvert(v.key, v.value * max))			
					end
				end
				--副本选择装备的作用描述

				local useforStr = ""
				local introduction = d:GetValue("introduction") or ""
				useforStr = "[作用]" .. introduction
				useforStr = useforStr .. attrStr
				-- local desList =  string.split(d:GetValue("description"), "\n")				
				-- if desList and next(desList) and desList[#desList] then
				-- 	useforStr = useforStr .. "\n" .. desList[#desList] 
				-- end
				oBox.m_UseforLabel:SetText(useforStr)
				self.m_ItemGird:AddChild(oBox)
				
			end
		end
	end
end

function CItemTipsPackageSelectView.OnClickEquipSelectItem(self, idx, sid)
	for i = 1, self.m_ItemGird:GetCount() do
		local tBox = self.m_ItemGird:GetChild(i)
		if tBox then				
			tBox.m_SelectSprite:SetActive(idx == i)
		end
	end
	self.m_EquipSelectSid = sid
end

function CItemTipsPackageSelectView.EquipSelectClickOk(self)
	if not self.m_EquipSelectSid then
		g_NotifyCtrl:FloatMsg("请选择装备")
		return 
	end
	if self.m_Floor then
		nethuodong.C2GSGetEquipFBReward(self.m_Floor, self.m_EquipSelectSid)
	end
	self:CloseView()
end

return CItemTipsPackageSelectView