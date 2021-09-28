GodFightRuneEffect = BaseClass(LuaUI)

function GodFightRuneEffect:__init(...)
	self.URL = "ui://s210esy7jci2m";
	self:__property(...)
	self:Config()
end

function GodFightRuneEffect:SetProperty(...)
	
end

function GodFightRuneEffect:Config()
	self:CleanUI()
end

function GodFightRuneEffect:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("GodFightRune","GodFightRuneEffect")
	self.bg = self.ui:GetChild("bg")
	self.loader = self.ui:GetChild("loader")
	self.labelTitle = self.ui:GetChild("labelTitle")
	self.labelContent = self.ui:GetChild("labelContent")
end

function GodFightRuneEffect.Create(ui, ...)
	return GodFightRuneEffect.New(ui, "#", {...})
end

function GodFightRuneEffect:__delete()
end

function GodFightRuneEffect:CleanUI()
	self.labelTitle.text = ""
	self.labelContent.text = ""
end

function GodFightRuneEffect:SetTitleUI(strTitle)
	self.labelTitle.text = strTitle or ""
end

function GodFightRuneEffect:SetContentUI(strContent)
	self.labelContent.text = strContent or ""
end

