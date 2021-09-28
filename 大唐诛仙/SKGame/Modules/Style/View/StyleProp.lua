StyleProp = BaseClass(LuaUI)
function StyleProp:__init(...)
	self.URL = "ui://jqof8qcoeiekb";
	self:__property(...)
	self:Config()
end
function StyleProp:SetProperty(...)
	
end
function StyleProp:Config()
	
end
function StyleProp:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Style","StyleProp");

	self.TitleName = self.ui:GetChild("TitleName")
	self.TitleValue = self.ui:GetChild("TitleValue")
	self.line = self.ui:GetChild("line")
end
function StyleProp.Create(ui, ...)
	return StyleProp.New(ui, "#", {...})
end
function StyleProp:__delete()
end