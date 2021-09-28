SkillUpgradeConsume = BaseClass(LuaUI)

function SkillUpgradeConsume:__init(...)
	self.URL = "ui://tv6313j0w5h8k";
	self:__property(...)
	self:Config()
end

function SkillUpgradeConsume:SetProperty(...)
	
end

function SkillUpgradeConsume:Config()
	
end

function SkillUpgradeConsume:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Skill","SkillUpgradeConsume");

	self.label_title = self.ui:GetChild("label_title")
	self.loader_icon = self.ui:GetChild("loader_icon")
	self.label_cnt = self.ui:GetChild("label_cnt")
end

function SkillUpgradeConsume.Create(ui, ...)
	return SkillUpgradeConsume.New(ui, "#", {...})
end

function SkillUpgradeConsume:__delete()
end

function SkillUpgradeConsume:SetUI(iconId, strCnt)
	self.loader_icon.url = StringFormat("Icon/Goods/{0}", iconId or "")
	self.label_cnt.text = strCnt or ""
end

