local CSkillUpGradeView = class("CSkillUpGradeView", CViewBase)

function CSkillUpGradeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/UpSkillResultView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CSkillUpGradeView.OnCreateView(self)
	self.m_BG = self:NewUI(2, CSprite)
	self.m_SkillBox = self:NewUI(3, CBox)
	self.m_Grid = self:NewUI(4, CGrid)
	self:InitContent()
end

function CSkillUpGradeView.InitContent(self)
	self.m_SkillBox:SetActive(false)
	self:UpdateData(1, {{id=30101,old_level=1,new_level=3},{id=30302,old_level=1,new_level=3},{id=30302,old_level=1,new_level=3}})
end

function CSkillUpGradeView.UpdateData(self, iParID, skillList)
	self.m_Grid:Clear()
	local iMax = #skillList
	local sdata = data.skilldata.PARTNERSKILL
	for i, oSKill in ipairs(skillList) do
		local t = sdata[oSKill.id]
		if t then
			local box = self.m_SkillBox:Clone()
			box.m_Icon = box:NewUI(1, CSprite)
			box.m_Name = box:NewUI(2, CLabel)
			box.m_Grade = box:NewUI(3, CLabel)
			box.m_Line = box:NewUI(4, CSprite)
			box.m_Line:SetActive(i < iMax)
			box.m_Name:SetText(t.name)
			box.m_Icon:SpriteSkill(t.icon)
			box.m_Grade:SetText(string.format("[654A33]Lv.%d        [159A80]Lv.%d", oSKill.old_level, oSKill.new_level))
			box:SetActive(true)
		self.m_Grid:AddChild(box)
		end
	end
	local n = self.m_Grid:GetCount()
	self.m_BG:SetHeight(n*132+5)
	self.m_Grid:Reposition()
end

return CSkillUpGradeView