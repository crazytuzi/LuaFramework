local CZhaoMuBaoLiuPage = class("CZhaoMuBaoLiuPage", CPageBase)

function CZhaoMuBaoLiuPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CZhaoMuBaoLiuPage.OnInitPage(self)
	self.m_SubmitBtn = self:NewUI(1, CButton)
	self.m_RareSpr = self:NewUI(2, CSprite)
	self.m_ActorTexture = self:NewUI(3, CActorTexture)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_SkillGrid = self:NewUI(5, CGrid)
	self.m_SkillBox = self:NewUI(6, CBox)
	self.m_NoPartnerMark = self:NewUI(7, CBox)
	self.m_SkillBg = self:NewUI(8, CSprite)
	self.m_TweenSprite = self:NewUI(9, CSprite)
	self.m_TweenObj = self.m_TweenSprite:GetComponent(classtype.TweenPosition)

	self:InitContent()
end

function CZhaoMuBaoLiuPage.InitContent(self)
	self.m_SkillBoxArr = {}
	self.m_SkillBox:SetActive(false)
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OpenChouKa"))
	self.m_ActorTexture:AddUIEvent("click", callback(self, "OnClickTexture"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvent"))
	self.m_CurrentPid = g_WelfareCtrl.m_BackPid
	self:SetPartnerID(self.m_CurrentPid)
end

function CZhaoMuBaoLiuPage.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnSetBackPartner then
		self:SetPartnerID(self.m_CurrentPid)
	end
end

function CZhaoMuBaoLiuPage.OnClickTexture(self)
	CWelfarePartnerChooseView:ShowView(function (oView)
		oView:SetConfirmCb(callback(self, "OnChangePartner"))
		oView:SetFilterCb(callback(self, "SetList"))
	end)
end

function CZhaoMuBaoLiuPage.SetList(self)
	local list = {}
	for k, oPartner in ipairs(partnerlist) do
		if (not g_EqualArenaCtrl:IsPartnerUsed(oPartner:GetValue("parid"))) and oPartner:IsEqualarenaPartner() then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CZhaoMuBaoLiuPage.OnChangePartner(self, parid)
	-- printc("OnChangePartner parid: " .. parid)
	self.m_CurrentPid = parid
	netfuli.C2GSSetBackPartner(parid)
end

function CZhaoMuBaoLiuPage.OpenChouKa(self)
	g_OpenUICtrl:OpenPartnerLuckyDrawView()
	self.m_ParentView:OnClose()
end

function CZhaoMuBaoLiuPage.SetPartnerID(self, parid)
	self.m_PartnerData = data.partnerdata.DATA[parid]
	self:UpdatePartner()
end

function CZhaoMuBaoLiuPage.UpdatePartner(self)
	local oPartnerData = self.m_PartnerData
	if oPartnerData then
		self.m_ActorTexture:SetActive(true)
		self.m_ActorTexture:ChangeShape(oPartnerData.shape)
		self.m_NameLabel:SetText(oPartnerData.name)
		self.m_RareSpr:SetSpriteName("text_rareda_" .. oPartnerData.rare)
		local wt = {41, 35, 61, 85}
		self.m_RareSpr:SetSize(wt[oPartnerData.rare] or 50, 41)
		self:UpdateSkill()
		self.m_NoPartnerMark:SetActive(false)
		self.m_SkillBg:SetActive(true)
		self.m_SkillGrid:SetActive(true)
	else
		self.m_ActorTexture:Clear()
		self.m_NameLabel:SetText("")
		self.m_RareSpr:SetSpriteName("")
		self.m_NoPartnerMark:SetActive(true)
		self.m_TweenObj.enabled = true
		self.m_SkillBg:SetActive(false)
		self.m_SkillGrid:SetActive(false)
	end
end

function CZhaoMuBaoLiuPage.UpdateSkill(self)
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

function CZhaoMuBaoLiuPage.CreateSkillBox(self)
	local oSkillBox = self.m_SkillBox:Clone()
	oSkillBox.m_Sprite = oSkillBox:NewUI(1, CSprite)
	oSkillBox:AddUIEvent("click", callback(self, "OnClickSkill", oSkillBox))

	function oSkillBox.SetData(self, iSkillID)
		oSkillBox.m_ID = iSkillID
		oSkillBox.m_Sprite:SpriteSkill(data.skilldata.PARTNERSKILL[iSkillID].icon)
	end
	return oSkillBox
end

function CZhaoMuBaoLiuPage.OnClickSkill(self, oSkillBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oSkillBox.m_ID, 1, false)
end

return CZhaoMuBaoLiuPage