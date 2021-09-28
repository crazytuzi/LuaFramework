UpProp = BaseClass(LuaUI)
function UpProp:__init(...)
	self.URL = "ui://d3en6n1n5v991g";
	self:__property(...)
	self:Config()
end
function UpProp:SetProperty(...)
	
end
function UpProp:Config()
	
end
function UpProp:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","UpProp");

	self.titleName = self.ui:GetChild("TitleName")
	self.titleName_2 = self.ui:GetChild("TitleName")
	self.titleName_3 = self.ui:GetChild("TitleName")
	self.line = self.ui:GetChild("line")
end
function UpProp.Create(ui, ...)
	return UpProp.New(ui, "#", {...})
end
function UpProp:__delete()
end