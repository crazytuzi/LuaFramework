MapBtn =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function MapBtn:__init( ... )
	self.URL = "ui://rkrzdlw3elj8v";
	self:__property(...)
	self:Config()
end

-- Set self property
function MapBtn:SetProperty( ... )
	
end

-- Logic Starting
function MapBtn:Config()
	
end

-- Register UI classes to lua
function MapBtn:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("WorldMaps","MapBtn");

	self.button = self.ui:GetController("button")
	self.icon = self.ui:GetChild("icon")
	self.bg = self.ui:GetChild("bg")
	self.title = self.ui:GetChild("title")
end

-- Combining existing UI generates a class
function MapBtn.Create( ui, ...)
	return MapBtn.New(ui, "#", {...})
end

-- Dispose use MapBtn obj:Destroy()
function MapBtn:__delete()
	
	self.button = nil
	self.icon = nil
	self.bg = nil
	self.title = nil
end