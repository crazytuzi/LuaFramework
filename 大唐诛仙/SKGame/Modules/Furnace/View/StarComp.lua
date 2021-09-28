StarComp = BaseClass(LuaUI)
function StarComp:__init( ... )
	self.URL = "ui://wt6b3levu156d";
	self:__property(...)
	self:Config()
end
function StarComp:SetProperty( ... )
end
function StarComp:Config()
end
function StarComp:Active( b )
	self.c_show.selectedIndex = b and 1 or 0
end
function StarComp:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Furnace","StarComp");
	self.c_show = self.ui:GetControllerAt(0)
end
function StarComp:__delete()
end