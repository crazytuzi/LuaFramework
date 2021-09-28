CommonSundryTeam =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function CommonSundryTeam:__init( ... )
	self.URL = "ui://0tyncec1n2cxeo";
	self:__property(...)
	self:Config()
end

-- Set self property
function CommonSundryTeam:SetProperty( ... )
	
end

-- Logic Starting
function CommonSundryTeam:Config()
	
end

-- Register UI classes to lua
function CommonSundryTeam:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","CommonSundryTeam");

	self.bg = self.ui:GetChild("bg")
	self.playerIcon = self.ui:GetChild("playerIcon")
	self.playerName = self.ui:GetChild("PlayerName")
	self.unionName = self.ui:GetChild("unionName")
	self.btnInvite = self.ui:GetChild("BtnInvite")
end

-- Combining existing UI generates a class
function CommonSundryTeam.Create( ui, ...)
	return CommonSundryTeam.New(ui, "#", {...})
end

-- Dispose use CommonSundryTeam obj:Destroy()
function CommonSundryTeam:__delete()
	
	self.bg = nil
	self.playerIcon = nil
	self.playerName = nil
	self.unionName = nil
	self.btnInvite = nil
end