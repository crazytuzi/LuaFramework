CustomCheckLabel = BaseClass(LuaUI)
function CustomCheckLabel:__init(...)
	self.URL = "ui://0tyncec19u5tnlj";
	self:__property(...)
	self:Config()
end
function CustomCheckLabel:SetProperty(...)
	
end
function CustomCheckLabel:Config()
	
end
function CustomCheckLabel:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","CustomCheckLabel");

	self.button = self.ui:GetController("button")
	self.bg = self.ui:GetChild("bg")
	self.icon = self.ui:GetChild("icon")
	self.check = self.ui:GetChild("check")
	self.title = self.ui:GetChild("title")
end
function CustomCheckLabel.Create(ui, ...)
	return CustomCheckLabel.New(ui, "#", {...})
end
function CustomCheckLabel:__delete()
end