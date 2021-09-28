ButtonSkip =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ButtonSkip:__init( ... )
	self.URL = "ui://y1al0f5qtjjeo";
	self:__property(...)
	self:Config()
end

-- Set self property
function ButtonSkip:SetProperty( ... )
	
end

-- Logic Starting
function ButtonSkip:Config()
	
end

-- Register UI classes to lua
function ButtonSkip:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("NPCDialog","ButtonSkip");

	self.icon = self.ui:GetChild("icon")
end

-- Combining existing UI generates a class
function ButtonSkip.Create( ui, ...)
	return ButtonSkip.New(ui, "#", {...})
end

-- Dispose use ButtonSkip obj:Destroy()
function ButtonSkip:__delete()
	
	self.icon = nil
end