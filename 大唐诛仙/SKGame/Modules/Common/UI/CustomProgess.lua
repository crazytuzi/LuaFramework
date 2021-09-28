CustomProgess = BaseClass(LuaUI)

function CustomProgess:__init(...)
	self.URL = "ui://0tyncec15v99nkb";
	self:__property(...)
	self:Config()
end
function CustomProgess:SetProperty(...)
end
function CustomProgess:Config()
end
function CustomProgess:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","CustomProgess")
	self.bg = self.ui:GetChild("bg")
	self.bar = self.ui:GetChild("bar")
end
function CustomProgess.Create(ui, ...)
	return CustomProgess.New(ui, "#", {...})
end
function CustomProgess:SetProgess(cur, max)
	self.ui.value = cur
	self.ui.max = max
end
function CustomProgess:__delete()
end