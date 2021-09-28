TiantiOwnerRankItem =BaseClass(LuaUI)
function TiantiOwnerRankItem:__init( ... )
	self.URL = "ui://mrcfhfspt5hd2u";
	self:__property(...)
	self:Config()
end
function TiantiOwnerRankItem:SetProperty( ... )
	
end
function TiantiOwnerRankItem:Config()
	
end
function TiantiOwnerRankItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tianti","TiantiOwnerRankItem");

	self.bg = self.ui:GetChild("bg")
	self.order = self.ui:GetChild("order")
	self.levelBg = self.ui:GetChild("levelBg")
	self.txtLv1 = self.ui:GetChild("txtLv1")
	self.txtName = self.ui:GetChild("txtName")
	self.txtCareer = self.ui:GetChild("txtCareer")
	self.icon = self.ui:GetChild("icon")
	self.txtLv2 = self.ui:GetChild("txtLv2")
	self.txtStarNum = self.ui:GetChild("txtStarNum")
	self.startIcon = self.ui:GetChild("startIcon")
	self.headComp = self.ui:GetChild("headComp")
end
function TiantiOwnerRankItem.Create( ui, ...)
	return TiantiOwnerRankItem.New(ui, "#", {...})
end
function TiantiOwnerRankItem:__delete()
end