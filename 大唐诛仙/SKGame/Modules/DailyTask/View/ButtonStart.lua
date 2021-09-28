ButtonStart = BaseClass(LuaUI)
function ButtonStart:__init(...)
	self.URL = "ui://1m5molo6kftjk";
	self:__property(...)
	self:Config()
end
function ButtonStart:SetProperty(...)
	
end
function ButtonStart:Config()
	
end
function ButtonStart:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("DailyTaskUI","ButtonStart");

	self.button = self.ui:GetController("button")
	self.n1 = self.ui:GetChild("n1")
	self.n2 = self.ui:GetChild("n2")
	self.n3 = self.ui:GetChild("n3")
	self.n4 = self.ui:GetChild("n4")
	self.title = self.ui:GetChild("title")
end
function ButtonStart.Create(ui, ...)
	return ButtonStart.New(ui, "#", {...})
end
function ButtonStart:__delete()
end