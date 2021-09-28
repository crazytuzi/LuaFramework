ClanCYEventItem = BaseClass(LuaUI)
function ClanCYEventItem:__init( ... )
	self.URL = "ui://lmxy2w9bjyjf1d";
	self:__property(...)
	self:Config()
end
function ClanCYEventItem:SetProperty( ... )
end
function ClanCYEventItem:Config()
	
end
function ClanCYEventItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Duhufu","CYEventItem");

	self.bg = self.ui:GetChild("bg")
end
function ClanCYEventItem.Create( ui, ...)
	return ClanCYEventItem.New(ui, "#", {...})
end
function ClanCYEventItem:__delete()
end