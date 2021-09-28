AutoRunTips =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function AutoRunTips:__init( ... )
	self.URL = "ui://ixdopynlm24po";
	self:__property(...)
	self:Config()
end

-- Set self property
function AutoRunTips:SetProperty( ... )
	
end

-- Logic Starting
function AutoRunTips:Config()
	
end

-- Register UI classes to lua
function AutoRunTips:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","AutoRunTips");

	self.icon = self.ui:GetChild("icon")
end

-- Combining existing UI generates a class
function AutoRunTips.Create( ui, ...)
	return AutoRunTips.New(ui, "#", {...})
end

-- Dispose use AutoRunTips obj:Destroy()
function AutoRunTips:__delete()
	
	self.icon = nil
end