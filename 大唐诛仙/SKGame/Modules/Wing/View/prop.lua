prop = BaseClass(LuaUI)
function prop:__init(...)
	self.URL = "ui://d3en6n1nnhrf1d";
	self:__property(...)
	self:Config()
end
function prop:SetProperty(...)
	
end
function prop:Config()
	
end
function prop:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","prop");

	self.titleName = self.ui:GetChild("TitleName")
	self.TitleValue = self.ui:GetChild("TitleValue")
end
function prop.Create(ui, ...)
	return prop.New(ui, "#", {...})
end
function prop:__delete()
end