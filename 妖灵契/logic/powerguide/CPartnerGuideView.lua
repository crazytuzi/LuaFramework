local CPartnerGuideView = class("CPartnerGuideView", CViewBase)

function CPartnerGuideView.ctor(self, cb)
	CViewBase.ctor(self, "UI/PowerGuide/PartnerGuideView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CPartnerGuideView.OnCreateView(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_RareSpr = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_SkillGrid = self:NewUI(4, CGrid)
	self.m_SkillBox = self:NewUI(5, CBox)
	self.m_GradeLabel = self:NewUI(6, CLabel)
	self.m_StarGrid = self:NewUI(7, CGrid)
	self.m_AttrBox = self:NewUI(8, CBox)
	self.m_InfoGrid = self:NewUI(9, CGrid)
	self.m_InfoBox = self:NewUI(10, CBox)
	self.m_CloseBtn = self:NewUI(11, CBox)

	self.m_SkillBox:SetActive(false)
	self.m_SkillBoxArr = {}
	self:InitStarGrid()
	self:InitAttrGrid()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_InfoBox:SetActive(false)
	g_ViewCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnViewEvent"))
end

function CPartnerGuideView.InitStarGrid(self)
	self.m_StarGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Idx = idx
		oBox.m_StarBg = oBox:NewUI(1, CSprite)
		oBox.m_StarSpr = oBox:NewUI(2, CSprite)
		return oBox
	end)
end

function CPartnerGuideView.UpdateStar(self)
	local count = self.m_StarGrid:GetCount()
	local oBox
	for i=1,count do
		oBox = self.m_StarGrid:GetChild(i)
		oBox.m_StarSpr:SetActive(i <= self.m_PartnerData.star)
	end
end

function CPartnerGuideView.InitAttrGrid(self)
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

function CPartnerGuideView.SetPartnerID(self, parid)
	self.m_CurParID = parid
	self.m_PartnerData = data.partnerdata.DATA[parid]
	self:UpdatePartner()
end

function CPartnerGuideView.UpdatePartner(self)
	local oPartnerData = self.m_PartnerData
	self.m_ActorTexture:ChangeShape(oPartnerData.shape)
	self.m_NameLabel:SetText(oPartnerData.name)
	self.m_RareSpr:SetSpriteName("text_rareda_" .. oPartnerData.rare)
	local wt = {41, 35, 61, 85}
	self.m_RareSpr:SetSize(wt[oPartnerData.rare] or 50, 41)
	self.m_GradeLabel:SetText("Lv:1")
	self:UpdateStar()
	self:UpdateAttr()
	self:UpdateSkill()
	self:UpdateGetWay()
end

function CPartnerGuideView.UpdateAttr(self)
	local attrData = self:GetOriAttr()

	for k, oItem in ipairs(self.m_AttrBoxList) do
		local attrdict = data.partnerawakedata.Level[self.m_CurParID]
		local iLevel = attrdict[oItem.m_AttrKey]
		oItem.m_LevelSpr:SetSpriteName("text_level_"..tostring(iLevel))
		oItem.m_AttrName:SetText(oItem.m_Name)
		if string.endswith(oItem.m_AttrKey, "_ratio") or oItem.m_AttrKey == "critical_damage" then
			local value = math.floor(attrData[oItem.m_AttrKey]/10)/10
			if math.isinteger(value) then
				oItem.m_AttrValue:SetText(string.format("%d%%", value))
			else
				oItem.m_AttrValue:SetText(string.format("%.1f%%", value))
			end
		else
			oItem.m_AttrValue:SetText(string.format("%d", attrData[oItem.m_AttrKey]))
		end
	end
end

function CPartnerGuideView.UpdateSkill(self)
	local oData = self.m_PartnerData
	for i,v in ipairs(oData.skill_list) do
		if self.m_SkillBoxArr[i] == nil then
			self.m_SkillBoxArr[i] = self:CreateSkillBox()
			self.m_SkillGrid:AddChild(self.m_SkillBoxArr[i])
		end
		self.m_SkillBoxArr[i]:SetActive(true)
		self.m_SkillBoxArr[i]:SetData(v)
	end

	for i = #oData.skill_list + 1, #self.m_SkillBoxArr do
		self.m_SkillBoxArr[i]:SetActive(false)
	end
end

function CPartnerGuideView.CreateSkillBox(self)
	local oSkillBox = self.m_SkillBox:Clone()
	oSkillBox.m_Sprite = oSkillBox:NewUI(1, CSprite)
	oSkillBox:AddUIEvent("click", callback(self, "OnClickSkill", oSkillBox))

	function oSkillBox.SetData(self, iSkillID)
		oSkillBox.m_ID = iSkillID
		oSkillBox.m_Sprite:SpriteSkill(data.skilldata.PARTNERSKILL[iSkillID].icon)
	end
	return oSkillBox
end

function CPartnerGuideView.OnClickSkill(self, oSkillBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oSkillBox.m_ID, 1, false)
end

function CPartnerGuideView.GetOriAttr(self)
	local grade = 1
	for _, attrdata in pairs(data.partnerdata.ATTR) do
		if attrdata["partner_type"] == self.m_PartnerData.partner_type and attrdata["star"] == self.m_PartnerData.star 
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

function CPartnerGuideView.UpdateGetWay(self)
	local oData = data.partnerrecommenddata.PartnerGongLue[self.m_PartnerData.partner_type]
	if oData then
		local lWay = {}
		for i,v in ipairs(oData.get_way) do
			table.insert(lWay, v)
		end
		local oControlData = data.globalcontroldata.GLOBAL_CONTROL
		local function sortFunc(v1, v2)
			return oControlData[data.partnerrecommenddata.PartnerSource[v1].control_key].open_grade < oControlData[data.partnerrecommenddata.PartnerSource[v2].control_key].open_grade
		end
		table.sort(lWay, sortFunc)
		for i,v in ipairs(lWay) do
			local oInfoBox = self:CreateInfoBox()
			self.m_InfoGrid:AddChild(oInfoBox)
			oInfoBox:SetActive(true)
			oInfoBox:SetData(data.partnerrecommenddata.PartnerSource[v])
		end
	end
end

function CPartnerGuideView.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_TitleLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_DescLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_GoBtn = oInfoBox:NewUI(4, CButton)
	oInfoBox.m_OpenGradeLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_GoBtn:AddUIEvent("click", callback(self, "OnClickGo", oInfoBox))
	
	function oInfoBox.SetData(self, oData)
		oInfoBox.m_Data = oData
		oInfoBox.m_TitleLabel:SetText(oData.name)
		oInfoBox.m_DescLabel:SetText(oData.desc)
		-- oInfoBox.m_IconSprite:SetSpriteName(oData.icon)
		local openGrade = data.globalcontroldata.GLOBAL_CONTROL[oData.control_key].open_grade
		if openGrade > g_AttrCtrl.grade then
			oInfoBox.m_OpenGradeLabel:SetText(string.format("%s级开启", openGrade))
			oInfoBox.m_OpenGradeLabel:SetActive(true)
			oInfoBox.m_GoBtn:SetActive(false)
		else
			oInfoBox.m_OpenGradeLabel:SetActive(false)
			oInfoBox.m_GoBtn:SetActive(true)
		end
	end
	return oInfoBox
end

function CPartnerGuideView.OnViewEvent(self, oCtrl)
	if oCtrl.m_EventID == define.View.Event.OnShowView then
		if oCtrl.m_EventData == self.m_OpeningCls then
			if self.m_ClosePower then
				CPowerGuideMainView:CloseView()
			end
			self:OnClose()
		end
	end
end

function CPartnerGuideView.OnClickGo(self, oInfoBox)
	self.m_OpeningCls = oInfoBox.m_Data.cls_name
	self.m_ClosePower = true
	-- printc("OnClickGo: " .. oInfoBox.m_Data.open_id)

	--活动跳转屏蔽
	if not g_ActivityCtrl:ActivityBlockContrl("store_resource") then
    	return
   	end
	
   	if g_ChoukaCtrl:IsInChouka() then
   		g_NotifyCtrl:FloatMsg("请先退出招募")
   		return
   	end

 	if oInfoBox.m_Data.blockkey and oInfoBox.m_Data.blockkey ~= "" and not g_ActivityCtrl:ActivityBlockContrl(oInfoBox.m_Data.blockkey) then
    	return
   	end

	local openID = oInfoBox.m_Data.open_id
	g_OpenUICtrl:OpenUI(openID)
end

return CPartnerGuideView