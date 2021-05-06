local CPartnerLinkView = class("CPartnerLinkView", CViewBase)

function CPartnerLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerLinkView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CPartnerLinkView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MainPart = self:NewUI(2, CBox)
	self:InitContent()
end

function CPartnerLinkView.InitContent(self)
	self:InitMain()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CPartnerLinkView.InitMain(self)
	local part = self.m_MainPart
	self.m_NameLabel = part:NewUI(1, CLabel)
	self.m_RareSpr = part:NewUI(2, CSprite)
	self.m_GradeLabel = part:NewUI(3, CLabel)
	self.m_PowerLabel = part:NewUI(4, CLabel)
	self.m_ActorTexture = part:NewUI(5, CActorTexture)
	
	self.m_SkillGrid = part:NewUI(6, CGrid)
	self.m_SkillBox = part:NewUI(7, CBox)
	self.m_EquipPart = part:NewUI(8, CBox)
	self.m_AttrBox = part:NewUI(9, CBox)
	self.m_PlayerName = part:NewUI(10, CLabel)
	self.m_StarBox = part:NewUI(11, CBox)
	self.m_BaseBtn = part:NewUI(13, CButton)
	self.m_EquipBtn = part:NewUI(14, CButton)
	self.m_BasePart = part:NewUI(15, CObject)
	self.m_AwakeObj = part:NewUI(16, CObject)
	self.m_SkillBox:SetActive(false)
	self.m_BaseBtn:SetGroup(self.m_BaseBtn:GetInstanceID())
	self.m_EquipBtn:SetGroup(self.m_BaseBtn:GetInstanceID())
	self.m_BaseBtn:AddUIEvent("click", callback(self, "OnChangePart"))
	self.m_EquipBtn:AddUIEvent("click", callback(self, "OnChangePart"))
	self:InitEquipPart()
	self:InitAttrGrid()
	self.m_BaseBtn:SetSelected(true)
	self:OnChangePart()
	self.m_StarList = {}
	for i = 1, 5 do
		self.m_StarList[i] = self.m_StarBox:NewUI(i, CBox)
		self.m_StarList[i].m_GreyObj = self.m_StarList[i]:NewUI(1, CObject)
		self.m_StarList[i].m_StarObj = self.m_StarList[i]:NewUI(2, CObject)
	end
end

function CPartnerLinkView.InitEquipPart(self)
	local oPart = self.m_EquipPart
	self.m_ParEquipBox = oPart:NewUI(1, CBox)
	self.m_ParSoulBox = oPart:NewUI(2, CBox)
	self.m_SoulGrid = oPart:NewUI(3, CGrid)
	self.m_SoulScrollView = oPart:NewUI(4, CScrollView)
	self.m_IconSpr = oPart:NewUI(5, CSprite)
	self.m_ParEquipList = {}
	for i = 1, 4 do
		local oBox = self.m_ParEquipBox:NewUI(i, CBox)
		oBox.m_ParEquipItem = oBox:NewUI(1, CParEquipItem)
		self.m_ParEquipList[i] = oBox
	end
	self.m_ParSoulList = {}
	for i = 1, 6 do
		self.m_ParSoulList[i] = self.m_ParSoulBox:NewUI(i, CParSoulItem)
	end
end

function CPartnerLinkView.InitAttrGrid(self)
	local t = {
		{k="气血",v="maxhp"},
		{k="攻击",v="attack"},
		{k="防御",v="defense"},
		{k="速度",v="speed"},
		{k="暴击",v="critical_ratio"},
		{k="暴击伤害", v="critical_damage"},
		{k="抗暴",v="res_critical_ratio"},
		{k="治疗暴击",v="cure_critical_ratio"},
		{k="异常命中",v="abnormal_attr_ratio"},
		{k="异常抵抗",v="res_abnormal_ratio"},
	}
	self.m_AttrBoxList = {}
	for k, v in ipairs(t) do
		local oBox = self.m_AttrBox:NewUI(k, CBox)
		oBox:SetActive(true)
		oBox.m_AttrName = oBox:NewUI(1, CLabel)
		oBox.m_AttrValue = oBox:NewUI(2, CLabel)
		oBox.m_LevelSpr = oBox:NewUI(3, CSprite)
		oBox.m_LevelSpr:SetActive(true)
		oBox.m_AttrName:SetText(v["k"])
		oBox.m_AttrKey = v["v"]
		oBox.m_Name = v["k"]
		self.m_AttrBoxList[k] = oBox
	end
end

function CPartnerLinkView.Refresh(self, linkpartner)
	local oPartner = CPartner.New(linkpartner.parinfo)
	local equiplist = 
	self.m_PlayerName:SetText("所属玩家："..linkpartner.name)
	self:UpdatePartner(oPartner)
	self:UpdateEquip(linkpartner.equip)
	self:UpdateSoul(linkpartner.soul)
end

function CPartnerLinkView.SetOwnerPartner(self, iPartnerID)
	local oPartner = g_PartnerCtrl:GetPartner(iPartnerID)
	if not oPartner then
		return
	end
	self.m_PlayerName:SetText("所属玩家："..g_AttrCtrl.name)
	self:UpdatePartner(oPartner)
	self:UpdateOwnerEquip(oPartner:GetCurEquipInfo())
	self:UpdateOwnerSoul(oPartner:GetParSoulList())

end

function CPartnerLinkView.UpdatePartner(self, oPartner)
	self.m_NameLabel:SetText(oPartner:GetValue("name"))
	self.m_NameLabel:ResetAndUpdateAnchors()
	local sRare = g_PartnerCtrl:GetPrintRareText(oPartner:GetValue("rare"))
	self.m_GradeLabel:SetText("LV."..tostring(oPartner:GetValue("grade")))
	self.m_PowerLabel:SetText(tostring(oPartner:GetValue("power")))
	
	local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
	self.m_ActorTexture:ChangeShape(shape, {})
	self.m_AwakeObj:SetActive(oPartner:GetValue("awake") == 1)
	self.m_IconSpr:SpriteAvatar(oPartner:GetIcon())
	self:UpdateStar(oPartner:GetValue("star"))
	self:UpdateSkill(oPartner)
	self:UpdateAttr(oPartner)
end

function CPartnerLinkView.UpdateEquip(self, equiplist)
	for i = 1, 4 do
		self.m_ParEquipList[i].m_ParEquipItem:SetActive(false)
	end
	for i, equipdata in ipairs(equiplist) do
		local pos = equipdata.pos
		local oItem = CItem.New(equipdata.equip)
		local itemobj = self.m_ParEquipList[pos]
		itemobj.m_ParEquipItem:SetActive(true)
		itemobj.m_ParEquipItem:SetItemData(oItem)
		itemobj.m_ParEquipItem:AddUIEvent("click", callback(self, "OnClickEquip"))
		itemobj.m_ParEquipItem.m_ItemData = oItem
	end
end

function CPartnerLinkView.UpdateOwnerEquip(self, equiplist)
	for i = 1, 4 do
		local itemid = equiplist[i]
		local oItem = g_ItemCtrl:GetItem(itemid)
		local itemobj = self.m_ParEquipList[i]
		if oItem then
			itemobj.m_ParEquipItem:SetActive(true)
			itemobj.m_ParEquipItem:SetItemData(oItem)
			itemobj.m_ParEquipItem:AddUIEvent("click", callback(self, "OnClickEquip"))
			itemobj.m_ItemData = oItem
		else
			itemobj.m_ParEquipItem:SetActive(false)
		end
	end
end

function CPartnerLinkView.UpdateStar(self, iStar)
	for i = 1, 5 do
		self.m_StarList[i].m_StarObj:SetActive(iStar >= i)
		self.m_StarList[i].m_GreyObj:SetActive(iStar < i)
	end
end

function CPartnerLinkView.UpdateSkill(self, oPartner)
	self.m_SkillGrid:Clear()
	if not oPartner then
		return
	end
	local skilllist = oPartner:GetValue("skill")
	local list = table.copy(skilllist)
	if oPartner:GetValue("awake_type") == 2 and oPartner:GetValue("awake") == 0 then
		local num = tonumber(oPartner:GetValue("awake_effect"))
		if num then
			local skillobj = {sk=num, level=0}
			table.insert(list, skillobj)
		end
	end
	
	local d = data.skilldata.PARTNERSKILL
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)
	for _, skillobj in ipairs(list) do
		local box = self.m_SkillBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_Icon:SpriteSkill(d[skillobj["sk"]]["icon"])
		local str = string.format("%d", skillobj["level"])
		box.m_Label:SetText(str)
		box.m_ID = skillobj["sk"]
		box.m_Level = skillobj["level"]
		box.m_IsAwake = oPartner:GetValue("awake") == 1
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_SkillGrid:AddChild(box)
	end
	self.m_SkillGrid:Reposition()
end

function CPartnerLinkView.UpdateAttr(self, oPartner)
	local funcGetAttrLevel = oPartner.GetAttrLevel
	if oPartner:GetValue("awake") == 1 then
		funcGetAttrLevel = oPartner.GetAwakeAttrLevel
	end

	for k, oItem in ipairs(self.m_AttrBoxList) do
		oItem.m_AttrName:SetText(oItem.m_Name)
		local iLevel = funcGetAttrLevel(oPartner, oItem.m_AttrKey)
		oItem.m_LevelSpr:SetSpriteName("text_level_"..tostring(iLevel))
		if string.endswith(oItem.m_AttrKey, "_ratio") or oItem.m_AttrKey == "critical_damage" then
			local value = math.floor(oPartner:GetValue(oItem.m_AttrKey)/10)/10
			if math.isinteger(value) then
				oItem.m_AttrValue:SetText(string.format("%d%%", value))
			else
				oItem.m_AttrValue:SetText(string.format("%.1f%%", value))
			end
		else
			oItem.m_AttrValue:SetText(string.format("%d", oPartner:GetValue(oItem.m_AttrKey)))
		end
	end
end

function CPartnerLinkView.UpdateSoul(self, dSoulList)
	for i = 1, 6 do
		self.m_ParSoulList[i]:SetActive(false)
	end
	for i, dSoulInfo in ipairs(dSoulList) do
		local pos = dSoulInfo.pos
		local oItem = CItem.New(dSoulInfo.soul)
		local itemobj = self.m_ParSoulList[pos]
		itemobj:SetActive(true)
		itemobj:SetItemData(oItem)
		itemobj:AddUIEvent("click", callback(self, "OnClickSoul"))
		itemobj.m_ItemData = oItem
	end
	self.m_SoulGrid:Reposition()
	self.m_SoulScrollView:ResetPosition()
end

function CPartnerLinkView.UpdateOwnerSoul(self, dSoulDict)
	for i = 1, 6 do
		self.m_ParSoulList[i]:SetActive(false)
	end
	for pos = 1, 6 do
		if dSoulDict[pos] then
			local oItem = g_ItemCtrl:GetItem(dSoulDict[pos])
			if oItem then
				local itemobj = self.m_ParSoulList[pos]
				itemobj:SetActive(true)
				itemobj:SetItemData(oItem)
				itemobj:AddUIEvent("click", callback(self, "OnClickSoul"))
				itemobj.m_ItemData = oItem
			end
		end
	end
	self.m_SoulGrid:Reposition()
	self.m_SoulScrollView:ResetPosition()
end

function CPartnerLinkView.OnClickEquip(self, oBox)
	local oItem = oBox.m_ItemData
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {hideui=true})
	end
end

function CPartnerLinkView.OnClickSoul(self, oBox)
	local oItem = oBox.m_ItemData
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {hideui=true})
	end
end

function CPartnerLinkView.OnClickSkill(self, oBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

function CPartnerLinkView.OnChangePart(self)
	self.m_BasePart:SetActive(self.m_BaseBtn:GetSelected())
	self.m_EquipPart:SetActive(self.m_EquipBtn:GetSelected())
end

return CPartnerLinkView