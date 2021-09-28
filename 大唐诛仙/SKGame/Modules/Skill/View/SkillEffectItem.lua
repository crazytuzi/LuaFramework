SkillEffectItem = BaseClass(LuaUI)

function SkillEffectItem:__init(...)
	self.URL = "ui://tv6313j0l6nqo";
	self:__property(...)
	self:Config()
end

function SkillEffectItem:SetProperty(...)
	
end

function SkillEffectItem:Config()
	self:CleanUI()
end

function SkillEffectItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Skill","SkillEffectItem");

	self.label_name = self.ui:GetChild("label_name")
	self.label_value = self.ui:GetChild("label_value")
	self.image_split = self.ui:GetChild("image_split")
end

function SkillEffectItem.Create(ui, ...)
	return SkillEffectItem.New(ui, "#", {...})
end

function SkillEffectItem:__delete()
end


function SkillEffectItem:SetUI(strName , strValue)
	self.label_name.text = strName or ""
	self.label_value.text = strValue or ""
end

function SkillEffectItem:CleanUI()
	self.label_name.text = ""
	self.label_value.text = ""
end
