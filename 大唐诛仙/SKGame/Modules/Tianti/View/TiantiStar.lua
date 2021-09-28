TiantiStar =BaseClass(LuaUI)
function TiantiStar:__init( ... )
	self.URL = "ui://mrcfhfspt5hd2s";
	self:__property(...)
	self:Config()
end
function TiantiStar:SetProperty( ... )
	
end
function TiantiStar:Config()
	
end
function TiantiStar:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tianti","TiantiStar");

	self.c1 = self.ui:GetController("c1")
	self.n1 = self.ui:GetChild("n1")
	self.n0 = self.ui:GetChild("n0")
	self.n2 = self.ui:GetChild("n2")
end
function TiantiStar.Create( ui, ...)
	return TiantiStar.New(ui, "#", {...})
end
function TiantiStar:__delete()
	
	self.c1 = nil
	self.n1 = nil
	self.n0 = nil
	self.n2 = nil
end