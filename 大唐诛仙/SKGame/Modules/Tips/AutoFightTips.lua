AutoFightTips =BaseClass(LuaUI)
function AutoFightTips:__init( ... )
	self.URL = "ui://ixdopynl6rikz";
	self:__property(...)
	self:Config()
end
function AutoFightTips:SetProperty( ... )
	
end
function AutoFightTips:Config()
	
end
function AutoFightTips:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","AutoFightTips");

	self.n2 = self.ui:GetChild("n2")
end
function AutoFightTips.Create( ui, ...)
	return AutoFightTips.New(ui, "#", {...})
end
function AutoFightTips:__delete()
	
	self.n2 = nil
end