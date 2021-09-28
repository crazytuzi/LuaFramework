TiantiLevelLogo =BaseClass(LuaUI)
function TiantiLevelLogo:__init( ... )
	self.URL = "ui://mrcfhfspt5hd2w";
	self:__property(...)
	self:Config()
end
function TiantiLevelLogo:SetProperty( ... )
	
end
function TiantiLevelLogo:Config()
	
end
function TiantiLevelLogo:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tianti","TiantiLevelLogo");

	self.n0 = self.ui:GetChild("n0")
	self.icon = self.ui:GetChild("icon")
	self.txtJifen = self.ui:GetChild("txtJifen")
	self.iconDuanwei = self.ui:GetChild("iconDuanwei")
	self.imgJindu = self.ui:GetChild("imgJindu")
end
function TiantiLevelLogo.Create( ui, ...)
	return TiantiLevelLogo.New(ui, "#", {...})
end
function TiantiLevelLogo:__delete()
	
end