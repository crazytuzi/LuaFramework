CommonRightBtn =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function CommonRightBtn:__init( ... )
	self.URL = "ui://0tyncec1u0dhc8";
	self:__property(...)
	self:Config()
end

-- Set self property
function CommonRightBtn:SetProperty( ... )
	
end

-- Logic Starting
function CommonRightBtn:Config()
	
end

-- Register UI classes to lua
function CommonRightBtn:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","CommonRightBtn");

	self.button = self.ui:GetController("button")
	self.Line = self.ui:GetChild("Line")
	self.DownIconBg = self.ui:GetChild("DownIconBg")
	self.icon = self.ui:GetChild("icon")
end

-- Combining existing UI generates a class
function CommonRightBtn.Create( ui, ...)
	return CommonRightBtn.New(ui, "#", {...})
end

-- Dispose use CommonRightBtn obj:Destroy()
function CommonRightBtn:__delete()
	
	self.button = nil
	self.Line = nil
	self.DownIconBg = nil
	self.icon = nil
end