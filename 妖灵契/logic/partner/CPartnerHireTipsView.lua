local CPartnerHireTipsView = class("CPartnerHireTipsView", CViewBase)

function CPartnerHireTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerHireAwakeTips.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CPartnerHireTipsView.OnCreateView(self)
	self.m_BGSpr = self:NewUI(1, CSprite)
	self.m_SkillSpr = self:NewUI(2, CSprite)
	self.m_SkillLabel = self:NewUI(3, CLabel)
	self.m_DescLabel = self:NewUI(4, CLabel)
	self.m_SprObj = self:NewUI(5, CObject)
	self:InitContent()
end

function CPartnerHireTipsView.InitContent(self)

end

function CPartnerHireTipsView.SetPartner(self, iType)
	local skillname = nil
	--觉醒类型 1-加技能，2-解锁技能，3-加强技能，4-加属性
	local oPartner = CPartner.New({partner_type = iType, parid=0})
	local awaketype = oPartner:GetValue("awake_type")
	self.m_SprObj:SetActive(false)
	if awaketype < 4 then
		local skid = tonumber(oPartner:GetValue("awake_effect_skill"))
		if awaketype ~= 3 then
			skid = tonumber(oPartner:GetValue("awake_effect"))
		end
		if skid then
			local d = data.skilldata.PARTNERSKILL[skid]
			self.m_SkillSpr:SetActive(true)
			self.m_DescLabel:SetActive(true)
			self.m_SkillLabel:SetActive(true)
			self.m_SkillSpr:SpriteSkill(d["icon"])
			skillname = d["name"]
			local text = ""
			local sdata = data.skilldata.PARTNER[skid]
			if awaketype == 2 then
				self.m_SkillLabel:SetText("技能解锁")
				text = sdata[1]["desc"]
				self.m_DescLabel:SetText("[ded65b]"..text)
			else
				self.m_SkillLabel:SetText("技能加强")
				local s = string.format("[ded65b]觉醒前：%s[-]\n\n[e1a113]觉醒后：%s", sdata[1]["desc"], oPartner:GetValue("awake_desc"))
				self.m_DescLabel:SetText(s)
			end
		end
	end

	if awaketype == 4 then
		self.m_SprObj:SetActive(true)
		self.m_SkillSpr:SetActive(false)
		self.m_DescLabel:SetActive(true)
		self.m_SkillLabel:SetActive(false)
	end
	local showdesc = nil
	if skillname then
		--showdesc = string.format("[%s] %s", skillname, oPartner:GetValue("awake_desc"))
	else
		showdesc = oPartner:GetValue("awake_desc")
		local t = string.split(showdesc, "：")
		if t[2] then
			self.m_SkillLabel:SetActive(true)
			self.m_SkillLabel:SetText(t[1])
			self.m_DescLabel:SetText(t[2])
			return
		end
		self.m_DescLabel:SetText(showdesc)
	end
	local iH = self.m_DescLabel:GetHeight()
	self.m_BGSpr:SetHeight(200-24+iH)
end

return CPartnerHireTipsView