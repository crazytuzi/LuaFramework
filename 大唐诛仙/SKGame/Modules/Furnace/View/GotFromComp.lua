GotFromComp = BaseClass(LuaUI)
function GotFromComp:__init( ... )
	self.URL = "ui://wt6b3levu156i"
	self:__property(...)
	self:Config()
end
function GotFromComp:SetProperty( ... )
end
function GotFromComp:Config()
	
end
function GotFromComp:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Furnace","GotFromComp");

	self.tlink = self.ui:GetChild("tlink")
end
function GotFromComp:AddEvent( ... )
	-- self.tlink.htmlText
end
function GotFromComp.Create( ui, ...)
	return GotFromComp.New(ui, "#", {...})
end
function GotFromComp:__delete()
end