local CPartnerGainView2 = class("CPartnerGainView2", CViewBase)

function CPartnerGainView2.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerGainView2.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end


function CPartnerGainView2.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_FullTexture = self:NewUI(2, CTexture)
	self.m_ActorTexture = self:NewUI(3, CActorTexture)
	self.m_TipsLabel = self:NewUI(4, CLabel)
	self.m_Contanier = self:NewUI(5, CWidget)
	self.m_NameLabel = self:NewUI(6, CLabel)
	self.m_DescLabel = self:NewUI(7, CLabel)
	self:InitContent()
end

function CPartnerGainView2.InitContent(self)
	self.m_PartnerList = table.keys(data.partnerhiredata.DATA)
	self.m_OriPos = self.m_FullTexture:GetLocalPos()
	UITools.ResizeToRootSize(self.m_Contanier)
	g_GuideCtrl:AddGuideUI("partner_gain_close_btn", self.m_CloseBtn)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_Idx = 1
end

function CPartnerGainView2.SetPartnerType(self, dPartner)
	local oPartner = g_PartnerCtrl:GetPartnerByType(dPartner.par_type)
	if oPartner then
		self:SetPartner(oPartner.m_ID, dPartner.desc)
	else
		self:OnClose()
	end
end

function CPartnerGainView2.SetPartner(self, parid, desc)
	self.m_ParID = parid
	self:UpdateUI()
	self.m_TipsLabel:SetText(desc)
end

function CPartnerGainView2.UpdateUI(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	self.m_NameLabel:SetText(oPartner:GetValue("name"))
	self.m_DescLabel:SetText(string.gsub(oPartner:GetValue("explain"), "\n", "    "))
	local iShape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
	self.m_ActorTexture:ChangeShape(iShape, {})
	local iFlip = enum.UIBasicSprite.Nothing
	local iDirect = 1
	if data.npcdata.DIALOG_NPC_CONFIG[iShape] then
		iDirect = data.npcdata.DIALOG_NPC_CONFIG[iShape]["direct"]
		if iDirect == 2 then
			iFlip = enum.UIBasicSprite.Horizontally
			iDirect = -1
		end
	end
	local v = self.m_OriPos
	self.m_FullTexture:LoadFullPhoto(iShape, 
		objcall(self, function (obj) 
			local w = g_DialogueCtrl:GetFullTextureSize(iShape)[1]
			local w2 = data.partnerhiredata.DATA[iShape]["full_size"][1]
			local k = w2 / w
			obj.m_FullTexture:SnapFullPhoto(iShape, k)
			local ox, oy = obj.m_FullTexture:GetFullPhotoOffSet(iShape, k)
			obj.m_FullTexture:SetFlip(iFlip)
			obj.m_FullTexture:SetLocalPos(Vector3.New(v.x-ox*iDirect, v.y+oy, v.z))
			obj.m_FullTexture:SetActive(true)
		end))
end

function CPartnerGainView2.SetPartnerByType(self, partner_type)
	local dPartner = data.partnerdata.DATA[partner_type]
	self.m_NameLabel:SetText(dPartner["name"])
	self.m_DescLabel:SetText(dPartner["explain"])
	local iShape = oPartner["shape"]
	self.m_ActorTexture:ChangeShape(iShape, {})
	local iFlip = enum.UIBasicSprite.Nothing
	local iDirect = 1
	if data.npcdata.DIALOG_NPC_CONFIG[iShape] then
		iDirect = data.npcdata.DIALOG_NPC_CONFIG[iShape]["direct"]
		if iDirect == 2 then
			iFlip = enum.UIBasicSprite.Horizontally
			iDirect = -1
		end
	end
	local v = self.m_OriPos
	self.m_FullTexture:LoadFullPhoto(iShape, 
		objcall(self, function (obj) 
			local w = g_DialogueCtrl:GetFullTextureSize(iShape)[1]
			local w2 = data.partnerhiredata.DATA[partner_type]["full_size"][1]
			local k = w2 / w
			obj.m_FullTexture:SnapFullPhoto(iShape, k)
			local ox, oy = obj.m_FullTexture:GetFullPhotoOffSet(iShape, k)
			obj.m_FullTexture:SetFlip(iFlip)
			obj.m_FullTexture:SetLocalPos(Vector3.New(v.x-ox*iDirect, v.y+oy, v.z))
			obj.m_FullTexture:SetActive(true)
		end))
end

return CPartnerGainView2