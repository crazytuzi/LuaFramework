local CRecommendPart = class("CRecommendPart", CBox)

function CRecommendPart.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitContent()
end

function CRecommendPart.InitContent(self)
	self.m_ContentTable = self:NewUI(1, CTable)
	self.m_ContentScrollView = self:NewUI(2, CScrollView)
	self.m_AvatarTexture = self:NewUI(3, CTexture)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_SkillGrid = self:NewUI(5, CGrid)
	self.m_SkillBox = self:NewUI(6, CBox)
	self.m_EquipGrid = self:NewUI(7, CGrid)
	self.m_EquipBox = self:NewUI(8, CBox)
	self.m_BackBtn = self:NewUI(9, CButton)
	self.m_GroupGrid = self:NewUI(10, CGrid)
	self.m_GroupBox = self:NewUI(11, CBox)

	self.m_SkillBoxArr = {}
	self.m_EquipBoxArr = {}
	self.m_GroupBoxArr = {}
	self.m_SkillBox:SetActive(false)
	self.m_EquipBox:SetActive(false)
	self.m_GroupBox:SetActive(false)
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClickBack"))
end

function CRecommendPart.OnClickBack(self)
	self.m_PartnerView:ShowMain()
end

function CRecommendPart.SetData(self, oData)
	self.m_AvatarTexture:SetActive(false)
	self.m_AvatarTexture:LoadDialogPhoto(oData.shape, function ()
		self.m_AvatarTexture:SetActive(true)
		self.m_AvatarTexture:SetLocalScale(Vector3.New(0.01, 0.01, 0.01))
		local tween = DOTween.DOScale(self.m_AvatarTexture.m_Transform, Vector3.one, 0.3)
		DOTween.SetEase(tween, enum.DOTween.Ease.OutSine)
	end)
	self.m_NameLabel:SetText(oData.name)
	local oRecommendData = data.partnerrecommenddata.PartnerGongLue[oData.partner_type]
	
	self:InitSkill(oData)
	self:InitEquip(oRecommendData)
	self:InitGroup(oRecommendData)
	self.m_ContentTable:Reposition()
end

function CRecommendPart.InitGroup(self, oRecommendData)
	if not oRecommendData then
		self.m_GroupGrid:SetActive(false)
		return
	end
	for i,v in ipairs(oRecommendData.recommand_list) do
		if self.m_GroupBoxArr[i] == nil then
			self.m_GroupBoxArr[i] = self:CreateGroupBox()
			self.m_GroupGrid:AddChild(self.m_GroupBoxArr[i])
		end
		self.m_GroupBoxArr[i]:SetActive(true)
		self.m_GroupBoxArr[i]:SetData(data.partnerrecommenddata.PartnerRecommend[v], i)
	end

	for i = #oRecommendData.recommand_list + 1, #self.m_GroupBoxArr do
		self.m_GroupBoxArr[i]:SetActive(false)
	end
	self.m_GroupGrid:Reposition()
end

function CRecommendPart.CreateGroupBox(self)
	local oGroupBox = self.m_GroupBox:Clone()
	oGroupBox.m_DescLabel = oGroupBox:NewUI(1, CLabel)
	oGroupBox.m_PlayerGrid = oGroupBox:NewUI(2, CGrid)
	oGroupBox.m_IndexLabel = oGroupBox:NewUI(3, CLabel)
	oGroupBox.m_PlayerBoxArr = {}
	oGroupBox.m_ParentCls = self

	oGroupBox.m_PlayerGrid:InitChild(function (obj, idx)
		local oPlayerBox = CBox.New(obj)
		oPlayerBox.m_PlayerSprite = oPlayerBox:NewUI(1, CSprite)
		oPlayerBox.m_SchoolLabel = oPlayerBox:NewUI(2, CLabel)
		oPlayerBox.m_PartnerGrid = oPlayerBox:NewUI(3, CGrid)
		oGroupBox.m_PlayerBoxArr[idx] = oPlayerBox
		return oPlayerBox
	end)

	for i = 1, #oGroupBox.m_PlayerBoxArr do
		oGroupBox.m_PlayerBoxArr[i].PartnerBoxArr = {}
		oGroupBox.m_PlayerBoxArr[i].m_BranchData = self:GetBranchData(g_AttrCtrl.school, i)
		local oPlayerBox = oGroupBox.m_PlayerBoxArr[i]
		oPlayerBox.m_PartnerGrid:InitChild(function (obj, idx)
			local oPartnerBox = CBox.New(obj)
			oPlayerBox.PartnerBoxArr[idx] = oPartnerBox
			oPartnerBox.m_BgSprite = oPartnerBox:NewUI(1, CSprite)
			oPartnerBox.m_Sprite = oPartnerBox:NewUI(2, CSprite)
			oPartnerBox.m_NameLabel = oPartnerBox:NewUI(3, CLabel)
			oPartnerBox:AddUIEvent("click", callback(self, "OnClickPartner", oPartnerBox))
			return oPartnerBox
		end)
	end

	function oGroupBox.SetData(self, oData, index)
		oGroupBox.m_IndexLabel:SetText(tostring(index))
		oGroupBox.m_DescLabel:SetText(oData.desc)
		local count = 0
		for i=1,2 do
			local oPlayerBox = oGroupBox.m_PlayerBoxArr[i]
			oPlayerBox.m_PlayerSprite:SpriteAvatar(g_AttrCtrl.model_info.shape)
			oPlayerBox.m_SchoolLabel:SetText(oPlayerBox.m_BranchData.name)
			local parList = oData[string.format("partner_list%s%s", g_AttrCtrl.school, i)]
			if #parList > 0 then
				count = count + 1
				oPlayerBox:SetActive(true)
			else
				oPlayerBox:SetActive(false)
			end
			for i,v in ipairs(parList) do
				local partnerData = data.partnerdata.DATA[v]
				oPlayerBox.PartnerBoxArr[i].m_Data = partnerData
				oPlayerBox.PartnerBoxArr[i].m_BgSprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(partnerData.rare))
				oPlayerBox.PartnerBoxArr[i].m_Sprite:SpriteAvatar(partnerData.icon)
				oPlayerBox.PartnerBoxArr[i].m_NameLabel:SetText(partnerData.name)
				-- if oGroupBox.m_ParentCls:HasPartner(partnerData.partner_type) then
				-- 	oPlayerBox.PartnerBoxArr[i].m_Sprite:SetGrey(false)
				-- 	oPlayerBox.PartnerBoxArr[i].m_BgSprite:SetGrey(false)
				-- else
				-- 	oPlayerBox.PartnerBoxArr[i].m_Sprite:SetGrey(true)
				-- 	oPlayerBox.PartnerBoxArr[i].m_BgSprite:SetGrey(true)
				-- end
			end
		end
		if count == 0 then
			oGroupBox:SetActive(false)
		end
		oGroupBox.m_PlayerGrid:Reposition()
	end

	return oGroupBox
end

function CRecommendPart.OnClickPartner(self, oPartnerBox)
	-- printc("OnClickPartner: " .. oPartnerBox.m_Data.partner_type)
	CPartnerGuideView:ShowView(function (oView)
		oView:SetPartnerID(oPartnerBox.m_Data.partner_type)
	end)
end

function CRecommendPart.GetBranchData(self, iSchool, iBranch)
	if self.m_BranchData == nil then
		self.m_BranchData = {}
		for k,v in pairs(data.roletypedata.BRANCH_TYPE) do
			if self.m_BranchData[v.school] == nil then
				self.m_BranchData[v.school] = {}
			end
			self.m_BranchData[v.school][v.branch] = v
		end
	end
	return self.m_BranchData[iSchool][iBranch]
end

function CRecommendPart.InitEquip(self, oRecommendData)
	if not oRecommendData then
		self.m_EquipGrid:SetActive(false)
		return
	end
	self.m_EquipGrid:SetActive(true)

	for i,v in ipairs(oRecommendData.equip_list) do
		if self.m_EquipBoxArr[i] == nil then
			self.m_EquipBoxArr[i] = self:CreateEquipBox()
			self.m_EquipGrid:AddChild(self.m_EquipBoxArr[i])
		end
		self.m_EquipBoxArr[i]:SetActive(true)
		self.m_EquipBoxArr[i]:SetData(data.partnerequipdata.ParSoulType[v])
	end

	for i = #oRecommendData.equip_list + 1, #self.m_EquipBoxArr do
		self.m_EquipBoxArr[i]:SetActive(false)
	end
	self.m_EquipGrid:Reposition()
end

function CRecommendPart.CreateEquipBox(self)
	local oEquipBox = self.m_EquipBox:Clone()
	oEquipBox.m_NameLabel = oEquipBox:NewUI(1, CLabel)
	oEquipBox.m_DescLabel = oEquipBox:NewUI(2, CLabel)
	oEquipBox.m_Sprite = oEquipBox:NewUI(3, CSprite)

	function oEquipBox.SetData(self, oData)
		oEquipBox.m_Sprite:SpriteItemShape(oData.icon)
		oEquipBox.m_NameLabel:SetText(oData.name)
		oEquipBox.m_DescLabel:SetText(string.format("套装效果:%s", oData.skill_desc))
	end

	return oEquipBox
end

function CRecommendPart.InitSkill(self, oData)
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

function CRecommendPart.CreateSkillBox(self)
	local oSkillBox = self.m_SkillBox:Clone()
	oSkillBox.m_Sprite = oSkillBox:NewUI(1, CSprite)
	oSkillBox:AddUIEvent("click", callback(self, "OnClickSkill", oSkillBox))

	function oSkillBox.SetData(self, iSkillID)
		oSkillBox.m_ID = iSkillID
		oSkillBox.m_Sprite:SpriteSkill(data.skilldata.PARTNERSKILL[iSkillID].icon)
	end
	return oSkillBox
end

function CRecommendPart.OnClickSkill(self, oSkillBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oSkillBox.m_ID, 1, false)
end

function CRecommendPart.HasPartner(self, partnerType)
	if self.m_PartnerDic == nil then
		self.m_PartnerDic = {}
		local partnerList = g_PartnerCtrl:GetPartners()
		for k,v in pairs(partnerList) do
			self.m_PartnerDic[v:GetValue("partner_type")] = true
		end
	end
	return self.m_PartnerDic[partnerType]
end

return CRecommendPart