WakanProperty = BaseClass(LuaUI)
function WakanProperty:__init(...)
	self.URL = "ui://jh3vd6rknkol1m";
	self:__property(...)
	self:Config()
end
function WakanProperty:SetProperty(...)
	
end
function WakanProperty:Config()
	
end
function WakanProperty:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wakan","WakanProperty");

	self.value1 = self.ui:GetChild("value1")
	self.value3 = self.ui:GetChild("value3")
	self.line = self.ui:GetChild("line")
end
function WakanProperty.Create(ui, ...)
	return WakanProperty.New(ui, "#", {...})
end
function WakanProperty:__delete()
end