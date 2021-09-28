PlayerIcon = BaseClass(LuaUI)
function PlayerIcon:__init( ... )
	self.URL = "ui://rkrzdlw3bag31w";
	self:__property(...)
	self:Config()
end
-- Set self property
function PlayerIcon:SetProperty( ... )
end
-- start
function PlayerIcon:Config()
	
end
-- wrap UI to lua
function PlayerIcon:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("WorldMaps","PlayerIcon");

	self.ziIcon = self.ui:GetChild("ziIcon")
end
-- Combining existing UI generates a class
function PlayerIcon.Create( ui, ...)
	return PlayerIcon.New(ui, "#", {...})
end
function PlayerIcon:__delete()
end