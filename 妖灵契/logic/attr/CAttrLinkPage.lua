local CAttrLinkPage = class("CAttrLinkPage", CPageBase)

function CAttrLinkPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CAttrLinkPage.OnInitPage(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_IdLabel = self:NewUI(4, CLabel)
	self.m_EquipmentGrid = self:NewUI(5, CGrid)
	self.m_EquipmentBox = self:NewUI(6, CAttrEquipItemBox)
	self.m_AttrGrid = self:NewUI(7, CGrid)
	self.m_BadgeGrid = self:NewUI(9, CGrid)
	self.m_BadgeBox = self:NewUI(10, CBox)
	self.m_SchoolIcon = self:NewUI(13, CSprite)
	self.m_ScoreLabel = self:NewUI(14, CLabel)
	self.m_GradeLabel = self:NewUI(15, CLabel)
	self.m_MainBgTextrue = self:NewUI(16, CTexture)
	self.m_DelayTimer = nil
	self:InitContent()
end

function CAttrLinkPage.InitContent(self)
	self:InitAttrGrid()
end

function CAttrLinkPage.InitAttrGrid(self)
	local t = {
		{k = "职业", v = "school"},
		{k = "等级", v = "grade", unhavekey = true,},
		{k = "称谓", v = "title_info"},
		{k = "公会", v = "orgname"},
		{k = "气血", v = "max_hp"},
		{k = "攻击", v = "attack"},
		{k = "防御", v = "defense"},
		{k = "速度", v = "speed"},
		{k = "暴击", v = "critical_ratio"},
		{k = "抗暴", v = "res_critical_ratio"},
		{k = "暴击伤害",v = "critical_damage"},
		{k = "治疗暴击",v = "cure_critical_ratio"},
		{k = "异常命中",v = "abnormal_attr_ratio"},
		{k = "异常抵抗", v = "res_abnormal_ratio"},		
	}

	local function init(obj, idx)
		local oBox = CBox.New(obj)
		if oBox:GetName() ~= "Badge" then
			oBox.m_NameLabel = oBox:NewUI(1, CLabel)
			oBox.m_AttrLabel = oBox:NewUI(2, CLabel)
			local info = t[idx]
			if info then
				if info.unhavekey ~= nil then
					oBox.m_NameLabel:SetText(info.k)
				end
				oBox.m_AttrKey = info.v
				oBox.m_AttrValue = info.value
			end
		end
		return oBox
	end
	self.m_AttrGrid:InitChild(init)
end

function CAttrLinkPage.RefreshData(self, playerinfo)
	self.m_Data = playerinfo
	self:RefreshAttr()
	self.m_ActorTexture:ChangeShape(playerinfo.model_info.shape, playerinfo.model_info)
	local path = string.format("Texture/Common/bg_juese_%d.png", playerinfo.model_info.shape)
	self.m_MainBgTextrue:LoadPath(path)
	
	local tSchoolData = data.schooldata.DATA
	self.m_SchoolIcon:SetSpriteName(tostring(tSchoolData[playerinfo.school].icon))
	self.m_IdLabel:SetText("ID: "..tostring(playerinfo.pid))
	self:RefershEquipmentGrid()
	table.print(playerinfo.equip)
end

function CAttrLinkPage.RefreshAttr(self)
	local mdata = self.m_Data
	self.m_NameLabel:SetText(mdata.name)
	self.m_ScoreLabel:SetText(mdata.warpower)
	self.m_GradeLabel:SetText(string.format("%d", mdata.grade))
	for i, oBox in ipairs(self.m_AttrGrid:GetChildList()) do
		if oBox:GetName() ~= "Badge" then
			if oBox.m_AttrValue ~= nil then
				oBox.m_AttrLabel:SetText(oBox.m_AttrValue)
			else
				local v = mdata[oBox.m_AttrKey]
				if oBox.m_AttrKey == "school" then
					oBox.m_AttrLabel:SetText(g_AttrCtrl:GetSchoolStr(v))
				elseif string.find(oBox.m_AttrKey, "ratio") or oBox.m_AttrKey == "critical_damage" then
					--保留1位小数
					v = math.floor(v / 10)
					local value = v / 10
					oBox.m_AttrLabel:SetText(tostring(value).."%")
				elseif oBox.m_AttrKey == "title_info" then
					oBox.m_AttrLabel:SetText(g_TitleCtrl:GetTitleName(v))
				else
					oBox.m_AttrLabel:SetText(tostring(v))
				end
			end
		end
	end
end

function CAttrLinkPage.InitBadgeGrid(self)
	self.m_BadgeGrid:Clear()
	for i = 1 , 5 do 
		local badgeBox = self.m_BadgeBox:Clone()
		badgeBox:SetActive(true)
		self.m_BadgeGrid:AddChild(badgeBox)
	end
end

function CAttrLinkPage.RefershEquipmentGrid(self)
	local equiplist = self.m_Data.equip
	self.m_EquipmentGrid:InitChild(function (obj, index)
		local oBox = CAttrEquipItemBox.New(obj)
		local equipData = equiplist[index].equip
		local oItem = CItem.New(equipData)
		oBox:SetGroup(self.m_EquipmentGrid:GetInstanceID())
		oBox:SetMainEquipItem(oItem , index)
		oBox:AddUIEvent("click", callback(self, "OnClickMainEuqip", oBox))
		return oBox
	end)
end

function CAttrLinkPage.OnClickMainEuqip(self, box)
	g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(box.m_MainEquipItem,
		{isLink = true, widget= box, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0)})
end

return CAttrLinkPage
