local CPartnerComposePage = class("CPartnerComposePage", CPageBase)

function CPartnerComposePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerComposePage.SetChipID(self, parid)
	self.m_CurParID = parid
	self:SetType(parid)
end

function CPartnerComposePage.OnInitPage(self)
	self.m_ComposeBtn = self:NewUI(3, CButton)
	self.m_CostLabel = self:NewUI(4, CLabel)
	self.m_Texture = self:NewUI(5, CTexture)
	self.m_RareSpr = self:NewUI(6, CSprite)
	self.m_RightPart = self:NewUI(7, CBox)
	self.m_LeftBtn = self:NewUI(8, CButton)
	self.m_RightBtn = self:NewUI(9, CButton)

	self:InitRight()
	self.m_LeftBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", 1))
	self.m_RightBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", -1))
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnCompose"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))

	g_GuideCtrl:AddGuideUI("partner_chip_compose_tips_btn", self.m_ComposeBtn)
	local guide_ui = {"partner_chip_compose_tips_btn",}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)	
end

function CPartnerComposePage.InitRight(self)
	self.m_NameLabel = self.m_RightPart:NewUI(1, CLabel)
	self.m_AttrBox = self.m_RightPart:NewUI(2, CBox)
	self.m_SkillGrid = self.m_RightPart:NewUI(3, CGrid)
	self.m_SkillBox = self.m_RightPart:NewUI(4, CBox)
	self.m_AmountLabel = self.m_RightPart:NewUI(5, CLabel)
	self.m_GetWayBtn = self.m_RightPart:NewUI(6, CButton)
	self.m_SkillBox:SetActive(false)
	self:InitAttrGrid()
end

function CPartnerComposePage.InitAttrGrid(self)
	local t = {
		{k="气血",v="maxhp"},
		{k="攻击",v="attack"},
		{k="防御",v="defense"},
		{k="速度",v="speed"},
		{k="暴击",v="critical_ratio"},
		{k="抗暴",v="res_critical_ratio"},
		{k="暴击伤害", v="critical_damage"},
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
		oBox.m_AttrName:SetText(v["k"])
		oBox.m_AttrKey = v["v"]
		oBox.m_Name = v["k"]
		self.m_AttrBoxList[k] = oBox
	end
end

function CPartnerComposePage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdateChip then
		self:SetType(self.m_ChipType)
	end
end

function CPartnerComposePage.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:UpdateChipAmount()

	elseif oCtrl.m_EventID == define.Item.Event.DelItem then
		self:UpdateChipAmount()

	elseif oCtrl.m_EventID == define.Item.Event.AddItem then
		self:UpdateChipAmount()
	end
end

function CPartnerComposePage.SetType(self, chiptype)
	if not chiptype then
		return
	end
	self.m_ChipType = chiptype
	local chipinfo = g_PartnerCtrl:GetSingleChipInfo(chiptype)
	self.m_NameLabel:SetText(chipinfo:GetValue("name"))
	self.m_RareSpr:SetSpriteName("text_rareda_"..tostring(chipinfo:GetValue("rare")))
	local wt = {41, 35, 61, 85}
	self.m_RareSpr:SetSize(wt[chipinfo:GetValue("rare")] or 50, 41)

	local k = 0.8
	self.m_Texture:SetActive(false)
	self.m_Texture:LoadFullPhoto(chipinfo:GetValue("shape"), function()
		self.m_Texture:SnapFullPhoto(chipinfo:GetValue("shape"), k)
		self.m_Texture:SetActive(true)
		end)
	self:UpdateChipAmount()
	self:UpdateSkill()
	self:UpdateAttr()
	local cost = chipinfo:GetValue("coin_cost")
	if g_AttrCtrl.coin > cost then
		self.m_CostLabel:SetText(string.format("#w1%s", string.numberConvert(cost)))
	else
		self.m_CostLabel:SetText(string.format("#R#w1%s", string.numberConvert(cost)))
	end
end

function CPartnerComposePage.UpdateChipAmount(self)
	if self.m_ChipType == nil then
		return
	end
	local chipinfo = g_PartnerCtrl:GetSingleChipInfo(self.m_ChipType)
	self.m_HaveAmount = chipinfo:GetValue("amount")
	self.m_NeedAmount = chipinfo:GetValue("compose_amount")
	self.m_AmountLabel:SetText(string.format("拥有碎片%d/%d", self.m_HaveAmount, self.m_NeedAmount))
	if self.m_HaveAmount >= self.m_NeedAmount then
		self.m_ComposeBtn:SetActive(true)
		self.m_CostLabel:SetActive(true)
		self.m_GetWayBtn:SetActive(false)
	else
		self.m_ComposeBtn:SetActive(false)
		self.m_CostLabel:SetActive(false)
		self.m_GetWayBtn:SetActive(true)
		self.m_GetWayBtn:AddUIEvent("click", function ()
			CItemTipsSimpleInfoView:ShowView(function (oView)
				oView:SetInitBox(self.m_ChipType, nil, {})
				oView:ForceShowFindWayBox(true)
			end)
		end)
	end
	local oView = CPartnerChipInputView:GetView()
	if oView then
		local maxamount, _ = math.modf(self.m_HaveAmount / self.m_NeedAmount)
		oView:SetType(self.m_ChipType, maxamount)
	end
end

function CPartnerComposePage.UpdateSkill(self)
	local chipinfo = g_PartnerCtrl:GetSingleChipInfo(self.m_ChipType)
	local pdata = data.partnerdata.DATA[chipinfo:GetValue("partner_type")]
	self.m_SkillGrid:Clear()
	local skilllist = pdata["skill_list"]
	local d = data.skilldata.PARTNERSKILL
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)
	for _, skillid in ipairs(skilllist) do
		local box = self.m_SkillBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_Icon:SpriteSkill(d[skillid]["icon"])
		box.m_Label:SetText("1")
		box.m_ID = skillid
		box.m_Level = 1
		box.m_IsAwake = false
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_SkillGrid:AddChild(box)
	end
	self.m_SkillGrid:Reposition()
end

function CPartnerComposePage.UpdateAttr(self)
	local chipinfo = g_PartnerCtrl:GetSingleChipInfo(self.m_ChipType)
	local partnertype = chipinfo:GetValue("partner_type")
	local attrdict = self:GetOriAttr(partnertype)
	local leveldict = data.partnerawakedata.Level[partnertype]

	for k, oItem in ipairs(self.m_AttrBoxList) do
		local iLevel = leveldict[oItem.m_AttrKey]
		oItem.m_LevelSpr:SetSpriteName("text_level_"..tostring(iLevel))
		oItem.m_AttrName:SetText(oItem.m_Name)
		if string.endswith(oItem.m_AttrKey, "_ratio") or oItem.m_AttrKey == "critical_damage" then
			local value = math.floor(attrdict[oItem.m_AttrKey]/10)/10
			if math.isinteger(value) then
				oItem.m_AttrValue:SetText(string.format("%d%%", value))
			else
				oItem.m_AttrValue:SetText(string.format("%.1f%%", value))
			end
		else
			oItem.m_AttrValue:SetText(string.format("%d", attrdict[oItem.m_AttrKey]))
		end
	end
end

function CPartnerComposePage.GetOriAttr(self, partnertype)
	local grade = 1
	for _, attrdata in pairs(data.partnerdata.ATTR) do
		if attrdata["partner_type"] == partnertype and attrdata["star"] == 1 
			and grade >= attrdata["grade_range"]["min"]
			and grade <= attrdata["grade_range"]["max"] then
			local result = {}
			for key, value in pairs(attrdata) do
				if type(value) == "string" then
					result[key] = math.floor(string.eval(value, {lv = grade}))
				end
			end
			return result
		end
	end
	return nil
end

function CPartnerComposePage.GetAttrLevel(self, partnertype, attrkey)
	return attrdict[attrkey]
end

function CPartnerComposePage.OnClickSkill(self, oBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

function CPartnerComposePage.OnShowPartnerScroll(self)
	self.m_ParentView:ShowPartnerScroll()
end

function CPartnerComposePage.OnShowPartner(self)
	self.m_ParentView:ShowMainPage()
end

function CPartnerComposePage.OnCompose(self)
	g_GuideCtrl:ReqTipsGuideFinish("partner_chip_compose_tips_btn")
	local maxamount, _ = math.modf(self.m_HaveAmount / self.m_NeedAmount)
	if maxamount > 0 then
		if self.m_ChipType == 20008 then
			netpartner.C2GSComposePartner(self.m_ChipType, maxamount)
		else
			netpartner.C2GSComposePartner(self.m_ChipType, 1)
		end
	end
end

function CPartnerComposePage.OnLeftOrRightBtn(self, idx)
	local list = self.m_ParentView.m_PartnerList:GetDataList()
	if #list > 1 then
		local curIdx = 1
		for i, oItem in ipairs(list) do
			if oItem:GetValue("sid") == self.m_ChipType then
				curIdx = i
				break
			end
		end
		curIdx = curIdx + idx
		if curIdx <= 0 then
			curIdx = #list
		elseif curIdx > #list then
			curIdx = 1
		end
		if self.m_ParentView then
			self.m_ParentView:OnChangePartner(list[curIdx]:GetValue("sid"))
		end
	end
end

return CPartnerComposePage