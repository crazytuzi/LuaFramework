local CMapBookPEquipPage = class("CMapBookPEquipPage", CPageBase)

function CMapBookPEquipPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMapBookPEquipPage.OnInitPage(self)
	self.m_BackBtn = self:NewUI(1, CButton)
	self.m_BigIcon = self:NewUI(2, CTexture)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_IconBox = self:NewUI(4, CBox)
	self.m_DescLabel = self:NewUI(5, CLabel)
	self.m_NoGetSpr = self:NewUI(6, CSprite)
	self.m_ScrollView = self:NewUI(8, CScrollView)
	self.m_NameLabel = self:NewUI(9, CLabel)
	self.m_PosIconList = {}
	for i = 1, 4 do
		self.m_PosIconList[i] = self:NewUI(9+i, CBox)
	end

	self.m_LostBookBtn = self:NewUI(14, CButton)
	self.m_IconBox:SetActive(false)
	self.m_CurID = nil
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_LostBookBtn:AddUIEvent("click", callback(self, "OnShowLostBook"))

	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapBookEvent"))
	self:InitPosSpr()
	self:InitData()
	self:RefreshAll()
end

function CMapBookPEquipPage.OnShowPage(self)
	if g_MapBookCtrl:IsHasLostBookNotify() then
		self.m_LostBookBtn:AddEffect("RedDot")
	else
		self.m_LostBookBtn:DelEffect("RedDot")
	end
end

function CMapBookPEquipPage.InitData(self)
	local equiplist = g_PartnerCtrl:GetGetPartnerEquip()
	local type2pos = {}
	local d = data.partnerequipdata.ParSoulType
	for _, id in pairs(equiplist) do
		if d[id] then
			local equiptype = d[id]["equip_type"]
			if not type2pos[equiptype] then
				type2pos[equiptype] = {}
				type2pos[equiptype][d[id]["pos"]] = true
			else
				type2pos[equiptype][d[id]["pos"]] = true
			end
		end
	end
	self.m_Data = type2pos
	self.m_EquipList = self:GetEquipList()
	self.m_CurID = self.m_EquipList[1]["id"]
	self:RefreshDesc(self.m_CurID)
end

function CMapBookPEquipPage.InitPosSpr(self)
	for _, box in ipairs(self.m_PosIconList) do
		box.m_Icon = box:NewUI(1, CSprite)
	end
	for pos = 1, 4 do
		local box = self.m_PosIconList[pos]
		box:SetActive(false)
	end
end

function CMapBookPEquipPage.InitWrapValue(self)

end

function CMapBookPEquipPage.OnMapBookEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MapBook.Event.UpdateRedPoint then
		if g_MapBookCtrl:IsHasLostBookNotify() then
			self.m_LostBookBtn:AddEffect("RedDot")
		else
			self.m_LostBookBtn:DelEffect("RedDot")
		end
	end
end

function CMapBookPEquipPage.DefaultSelect(self, iType)
	self.m_CurID = iType
	self:OnClickEquip(iType)
end

function CMapBookPEquipPage.GetEquipList(self)
	local list = {}
	for _, v in pairs(data.partnerequipdata.ParSoulType) do
		table.insert(list, v)
	end
	table.sort(list, function(a, b)
		if a["id"] < b["id"] then
			return true
		end
		return false
	end)
	return list
end

function CMapBookPEquipPage.RefreshAll(self)
	local list = self:GetEquipList()
	self.m_Grid:Clear()
	for _, dData in ipairs(list) do
		local box = self:CreateEquipBox()
		self:UpdateBox(box, dData)
		self.m_Grid:AddChild(box)
	end
	self.m_Grid:Reposition()
end

function CMapBookPEquipPage.CreateEquipBox(self)
	local box = self.m_IconBox:Clone()
	box:SetActive(true)
	box.m_Spr = box:NewUI(1, CSprite)
	box.m_Label = box:NewUI(3, CLabel)
	box:SetGroup(self.m_Grid:GetInstanceID())
	return box
end

function CMapBookPEquipPage.UpdateBox(self, box, dData)
	box:SetActive(true)
	box.m_Spr:SpriteItemShape(dData["icon"])
	box:AddUIEvent("click", callback(self, "OnClickEquip", dData["id"]))
	if self.m_CurID == dData["id"] then
		box:ForceSelected(true)
	else
		box:ForceSelected(false)
	end
	if self:IsGetEquip(dData["id"]) then
		box.m_Label:SetActive(false)
	else
		box.m_Label:SetActive(true)
	end
end

function CMapBookPEquipPage.ShowPartnerPage(self)
	self.m_ParentView:ShowPartnerPage()
	-- body
end


function CMapBookPEquipPage.RefreshDesc(self, equipID)
	local pdata = data.partnerequipdata.ParSoulType[equipID]
	if not pdata then
		return
	end
	self.m_NameLabel:SetText(pdata["name"])
	local str = string.format("%s", pdata["skill_desc"])
	self.m_DescLabel:SetText(str)
	local sPath = string.format("Texture/PartnerEquip/bg_fw_"..pdata["icon"]..".png")
	self.m_BigIcon:SetActive(false)
	self.m_BigIcon:LoadPath(sPath , function() self.m_BigIcon:SetActive(true) end)
	if self:IsGetEquip(equipID) then
		self.m_NoGetSpr:SetActive(false)
		self.m_BigIcon:SetColor(Utils.HexToColor("ffffffff"))
	else
		self.m_NoGetSpr:SetActive(true)
		self.m_BigIcon:SetColor(Utils.HexToColor("464646ff"))
	end

	-- if self:IsGetEquip(equipID) then
	-- 	local str = string.format("2件套效果\n%s\n4件套效果\n%s", pdata["two_set_desc"], pdata["four_set_desc"])
	-- 	self.m_EffectLabel:SetText(str)
	-- 	self.m_EffectLabel:SetActive(true)
	-- 	self.m_GetTipLabel:SetActive(false)
	-- else
	-- 	self.m_GetTipLabel:SetActive(true)
	-- 	self.m_EffectLabel:SetActive(false)
	-- end
	self:RefreshPosGrid(equipID, pdata["icon"])
end

function CMapBookPEquipPage.RefreshPosGrid(self, equipID, shape)
	-- if self.m_Data[equipID] then
	-- 	for pos = 1, 4 do
	-- 		local box = self.m_PosIconList[pos]
	-- 		box.m_Icon:SpriteItemShape(shape)
	-- 		if not self.m_Data[equipID][pos] then
	-- 			box.m_Icon:SetActive(false)
	-- 		else
	-- 			box.m_Icon:SetActive(true)
	-- 		end
	-- 	end
	-- else
	-- 	for pos = 1, 4 do
	-- 		local box = self.m_PosIconList[pos]
	-- 		box.m_Icon:SetActive(false)
	-- 	end
	-- end
end

function CMapBookPEquipPage.IsGetEquip(self, equipID)
	return true
end

function CMapBookPEquipPage.OnBack(self)
	self.m_ParentView:ShowMainPage()
end

function CMapBookPEquipPage.OnShowLostBook(self)
	self.m_ParentView:ShowLostBookPage()
end

function CMapBookPEquipPage.OnRightMove(self)
	self.m_ScrollView:Scroll(1)
end

function CMapBookPEquipPage.OnLeftMove(self)
	self.m_ScrollView:Scroll(-1)
end

function CMapBookPEquipPage.OnClickEquip(self, equipID)
	self.m_CurID = equipID
	self:RefreshDesc(equipID)
end

return CMapBookPEquipPage