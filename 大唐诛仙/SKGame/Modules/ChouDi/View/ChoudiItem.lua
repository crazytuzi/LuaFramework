ChoudiItem = BaseClass(LuaUI)
function ChoudiItem:__init(...)
	self.URL = "ui://uqy8k45w9jou0";
	self:__property(...)
	self:Config()
end
function ChoudiItem:SetProperty(...)
	
end
function ChoudiItem:Config()
	
end
function ChoudiItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ChouDi","ChoudiItem");

	self.headIcon = self.ui:GetChild("headIcon")
	self.playerName = self.ui:GetChild("playerName")
	self.iconZhiye = self.ui:GetChild("iconZhiye")
	self.textZhiye = self.ui:GetChild("textZhiye")
	self.familyName = self.ui:GetChild("familyName")
	self.isOnlineTxt = self.ui:GetChild("isOnlineTxt")
	self.btnZhuizong = self.ui:GetChild("btnZhuizong")
	self.btnDelete = self.ui:GetChild("btnDelete")
end
function ChoudiItem.Create(ui, ...)
	return ChoudiItem.New(ui, "#", {...})
end
function ChoudiItem:__delete()
end