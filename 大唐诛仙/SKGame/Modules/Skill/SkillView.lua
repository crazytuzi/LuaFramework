SkillView =BaseClass()

function SkillView:__init()
	self:Config()
	self:InitEvent()
	self:LayoutUI()
end

function SkillView:Config()
	self.model = SkillModel:GetInstance()
	self.skillPanel = nil
	self.skillBookUI = nil
end

function SkillView:InitEvent()

end

function SkillView:LayoutUI()
	if self.isInited then return end
	resMgr:AddUIAB("Skill")
	self.isInited = true
end

function SkillView:OpenSkillPanel(tabType)
	if not self.skillPanel or (not self.skillPanel.isInited) then
		self.skillPanel = SkillMainPanel.New()
	end
	if self.skillPanel == nil then return end
	self.skillPanel:Open(tabType)
	SkillController:GetInstance():C_GetPlayerSkills()
end

function SkillView:OpenSkillPanelById(skillId)
	if skillId then
		self:OpenSkillPanel(SkillConst.TabType.Skill)
		self.skillPanel:OnSkillItemClickById(skillId)
	end
end

function SkillView:OpenSkillBookUI()
	if self.skillBookUI == nil then
		self.skillBookUI = SkillBook.New()
	end
	UIMgr.ShowPopup(self.skillBookUI , false, -300 , 0 , function() 
		self.skillBookUI = nil
	end , true , false)
end

function SkillView:CloseSkillBookUI()
	if self.skillBookUI and  self.skillBookUI.ui then
		UIMgr.HidePopup(self.skillBookUI.ui)
		self.skillBookUI:Destroy()
		self.skillBookUI = nil
	end
end

function SkillView:__delete()
	self.isInited = false
	if self.skillBookUI then
		self.skillBookUI:Destroy()
	end
	self.skillBookUI = nil

	if self.model then
		self.model:Destroy()
	end
	self.model = nil

	if self.skillPanel and self.skillPanel.isInited then
		self.skillPanel:Destroy()
	end
	self.skillPanel = nil
end


