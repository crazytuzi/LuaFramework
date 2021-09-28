WeekTabBtn = BaseClass(LuaUI)
function WeekTabBtn:__init(...)
	self.URL = "ui://oa3ahys9mfyid";
	self:__property(...)
	self:Config()
end
function WeekTabBtn:SetProperty(...)
	
end
function WeekTabBtn:Config()
	
end
function WeekTabBtn:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Activity","WeekTabBtn");

	self.n1 = self.ui:GetChild("n1")
	self.name = self.ui:GetChild("name")
end
function WeekTabBtn.Create(ui, ...)
	return WeekTabBtn.New(ui, "#", {...})
end
function WeekTabBtn:__delete()
end