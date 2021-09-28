CustomCheck = BaseClass(LuaUI)
function CustomCheck:__init(...)
	self.URL = "ui://0tyncec15v99nkg";
	self:__property(...)
	self:Config()
end
function CustomCheck:SetProperty(...)
	
end
function CustomCheck:Config()
	
end
function CustomCheck:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","CustomCheck");

	self.button = self.ui:GetController("button")
	self.icon = self.ui:GetChild("icon")
	self.check = self.ui:GetChild("check")
end
function CustomCheck.Create(ui, ...)
	return CustomCheck.New(ui, "#", {...})
end
function CustomCheck:__delete()
end