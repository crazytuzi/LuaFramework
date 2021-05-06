local CPartnerGainView = class("CPartnerGainView", CViewBase)

function CPartnerGainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerGainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end


function CPartnerGainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Texture = self:NewUI(2, CActorTexture)
	self.m_AttrPart = self:NewUI(3, CBox)
	self.m_TipsLabel = self:NewUI(4, CLabel)
	self.m_Contanier = self:NewUI(5, CWidget)
	self.m_DescLabel = self:NewUI(6, CLabel)
	self.m_SkillGrid = self:NewUI(7, CGrid)
	self.m_SkillBox = self:NewUI(8, CBox)
	self:InitContent()
end

function CPartnerGainView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Contanier)
	self.m_SkillBox:SetActive(false)
	self:InitAttr()
	g_GuideCtrl:AddGuideUI("partner_gain_close_btn", self.m_CloseBtn)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CPartnerGainView.SetPartnerType(self, dPartner)
	local oPartner = g_PartnerCtrl:GetPartnerByType(dPartner.par_type)
	if oPartner then
		self:SetPartner(oPartner.m_ID, dPartner.desc)
	else
		self:OnClose()
	end
end

function CPartnerGainView.SetPartner(self, parid, desc)
	self.m_ParID = parid
	self:UpdateUI()
	self:UpdateAttr()
	self:UpdateSkill()
	self.m_TipsLabel:SetText(desc)
end

function CPartnerGainView.UpdateUI(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	self.m_DescLabel:SetText(oPartner:GetValue("name"))

	local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
	self.m_Texture:ChangeShape(shape, {})
end

function CPartnerGainView.InitAttr(self)
	local t = {
		{k="气血",v="maxhp"},
		{k="攻击",v="attack"},
		{k="防御",v="defense"},
		{k="速度",v="speed"},
		{k="暴击率",v="critical_ratio"},
		{k="暴击伤害", v="critical_damage"},
		{k="抗暴击率",v="res_critical_ratio"},
		{k="治疗暴击",v="cure_critical_ratio"},
		{k="异常命中",v="abnormal_attr_ratio"},
		{k="异常抵抗",v="res_abnormal_ratio"},
	}
	self.m_AttrBoxList = {}
	for i, v in ipairs(t) do
		local oBox = self.m_AttrPart:NewUI(i, CBox)
		oBox.m_AttrName = oBox:NewUI(1, CLabel)
		oBox.m_AttrValue = oBox:NewUI(2, CLabel)
		oBox.m_AttrLevel = oBox:NewUI(3, CLabel)
		oBox.m_AttrName:SetText(v.k)
		oBox.m_AttrKey = v.v
		self.m_AttrBoxList[i] = oBox
	end
end

function CPartnerGainView.UpdateAttr(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	if not oPartner then
		return
	end
	local funcGetAttrLevel = oPartner.GetAttrLevel
	for k, oItem in ipairs(self.m_AttrBoxList) do
		local iLevel = funcGetAttrLevel(oPartner, oItem.m_AttrKey)
		oItem.m_AttrLevel:SetText(define.Partner.AttrLevel[iLevel])
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

function CPartnerGainView.UpdateSkill(self)
	self.m_SkillGrid:Clear()
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
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
		box.m_LockSpr = box:NewUI(3, CSprite, false)
		if d[skillobj["sk"]] and d[skillobj["sk"]]["icon"] then
			box.m_Icon:SpriteSkill(d[skillobj["sk"]]["icon"])
		end
		local str = string.format("%d", skillobj["level"])
		box.m_Label:SetText(str)
		box.m_ID = skillobj["sk"]
		box.m_Level = skillobj["level"]
		box.m_IsAwake = oPartner:GetValue("awake") == 1
		if box.m_LockSpr then
			box.m_LockSpr:SetActive(skillobj["level"] == 0)
		end
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_SkillGrid:AddChild(box)
	end
	self.m_SkillGrid:Reposition()
end

function CPartnerGainView.OnClickSkill(self, oBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

--region 伙伴预览, 导表数据显示--
function CPartnerGainView.SetPartnerByType(self, partner_type)
	local attrlevel = data.partnerdata.DATA[partner_type]["attr_level"]
	local function GetOriAttr(partnertype)
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

	local attrdict = GetOriAttr(partner_type)

	local dData = data.partnerawakedata.Level
	local dict = dData[partner_type] or {}

	local t = {"maxhp", "attack", "defense", "speed", "critical_ratio", "res_critical_ratio", 
	"critical_damage", "cure_critical_ratio", "abnormal_attr_ratio", "res_abnormal_ratio"}
	for i, key in ipairs(t) do
		local oItem = self.m_AttrBoxList[i]
		oItem.m_AttrLevel:SetText(define.Partner.AttrLevel[dict[key]])
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			local value = math.floor(attrdict[key]/10)/10
			if math.isinteger(value) then
				oItem.m_AttrValue:SetText(string.format("%d%%", value))
			else
				oItem.m_AttrValue:SetText(string.format("%.1f%%", value))
			end
		else
			oItem.m_AttrValue:SetText(string.format("%d", attrdict[key]))
		end
	end

	local pdata = data.partnerdata.DATA[partner_type]
	self.m_SkillGrid:Clear()
	local skilllist = pdata["skill_list"]
	local d = data.skilldata.PARTNERSKILL
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)
	for _, skillid in ipairs(skilllist) do
		local box = self.m_SkillBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_LockSpr = box:NewUI(3, CSprite, false)
		box.m_Icon:SpriteSkill(d[skillid]["icon"])
		box.m_Label:SetText("1")
		box.m_ID = skillid
		box.m_Level = 1
		box.m_IsAwake = false
		box.m_LockSpr:SetActive(false)
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_SkillGrid:AddChild(box)
	end
	self.m_SkillGrid:Reposition()

	local shape = pdata.shape
	self.m_Texture:ChangeShape(shape, {})
	self.m_DescLabel:SetText(pdata.name)
	self.m_TipsLabel:SetText("")
end

--endregion 伙伴预览, 导表数据显示--
return CPartnerGainView