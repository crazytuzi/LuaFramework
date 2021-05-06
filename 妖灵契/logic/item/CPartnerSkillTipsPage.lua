local CPartnerSkillTipsPage = class("CPartnerSkillTipsPage", CPageBase)

function CPartnerSkillTipsPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_CItem = nil

	self.m_BG = self:NewUI(1, CSprite)
	self.m_IconSpr = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_CostLabel = self:NewUI(4, CLabel)
	self.m_UpDescLabel = self:NewUI(5, CLabel)
	self.m_MainDescLabel = self:NewUI(6, CLabel)
	self.m_LevelLabel = self:NewUI(7, CLabel)
	self.m_TipLable = self:NewUI(8, CLabel)
	self.m_LineSpr = self:NewUI(10, CSprite)
	self:InitContent()
end

function CPartnerSkillTipsPage.InitContent(self)
end

function CPartnerSkillTipsPage.ShowPage(self, skid, level, isawake)
	CPageBase.ShowPage(self)
	self:SetSkill(skid, level, isawake)
end

function CPartnerSkillTipsPage.SetSkill(self, skid, level, isawake)
	self.m_LevelLabel:SetText(level)
	local d = data.skilldata.PARTNER
	local md = data.skilldata.PARTNERSKILL
	if d[skid] then
		self.m_NameLabel:SetText(string.format("技能%d", skid))
		if md[skid] then
			self.m_NameLabel:SetText(string.format("%s", md[skid]["name"]))
			self.m_CostLabel:SetText(string.format("%d", md[skid]["sp"]))
			self.m_IconSpr:SpriteSkill(md[skid]["icon"])
		else
			self.m_CostLabel:SetText("0")
		end
		if d[skid][1] then
			local maindesc = d[skid][1]["desc"]
			local otherdesc = md[skid]["otherdesc"]
			if isawake then
				local parid = md[skid]["partner"]
				local pdata = data.partnerdata.DATA[parid]
				if pdata and (pdata["awake_type"] == 3 or pdata["awake_type"] == 1) and tonumber(pdata["awake_effect_skill"]) == skid then
					maindesc = pdata["awake_desc"]
				end
			end
			self.m_MainDescLabel:SetText(otherdesc.."\n"..maindesc)
		end
		
		local strlist = {}
		if level == 0 then
			table.insert( strlist, "[7A7A7A]觉醒后解锁该技能[-]")
		
		elseif #d[skid] < 2 then
			table.insert( strlist, "[7A7A7A]该技能无法升级[-]")
		
		else
			for i, obj in ipairs(d[skid]) do
				if i > 1 then
					if i <= level then
						table.insert( strlist, string.format("[51E414]lv%d %s[-]", i, d[skid][i]["desc"]))
					else
						table.insert( strlist, string.format("[D9D256]lv%d %s[-]", i, d[skid][i]["desc"]))
					end
				end
			end
		end
		self.m_UpDescLabel:SetText(table.concat(strlist, "\n"))
	end
	local _, h1 = self.m_MainDescLabel:GetSize()
	local v = self.m_MainDescLabel:GetLocalPos()

	local _, h2 = self.m_UpDescLabel:GetSize()
	v.y = v.y - h1 - 10
	self.m_UpDescLabel:SetLocalPos(v)
	
	v.y = v.y - h2 - 5
	--self.m_LineSpr:SetLocalPos(v)
	v.y = v.y - 10
	self.m_TipLable:SetLocalPos(v) 
	self.m_BG:SetSize(350, h1+h2+160)
	-- self.m_TipLable:SetLocalPos(v)
	-- self.m_MidBG:SetSize(320, 140 + h2)
	-- local w, h = self.m_BG:GetSize()
	-- 
end

return CPartnerSkillTipsPage