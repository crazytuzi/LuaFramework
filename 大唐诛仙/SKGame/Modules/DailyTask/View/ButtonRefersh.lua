ButtonRefersh = BaseClass(LuaUI)
function ButtonRefersh:__init(...)
	self.URL = "ui://1m5molo6kftjg";
	self:__property(...)
	self:Config()
end
function ButtonRefersh:SetProperty(...)
	
end
function ButtonRefersh:Config()
	
end
function ButtonRefersh:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("DailyTaskUI","ButtonRefersh");

	self.button = self.ui:GetController("button")
	self.n1 = self.ui:GetChild("n1")
	self.n2 = self.ui:GetChild("n2")
	self.n3 = self.ui:GetChild("n3")
	self.n4 = self.ui:GetChild("n4")
	self.title = self.ui:GetChild("title")
end
function ButtonRefersh.Create(ui, ...)
	return ButtonRefersh.New(ui, "#", {...})
end
function ButtonRefersh:__delete()
end