VipLvItem = BaseClass(LuaUI)
function VipLvItem:__init(...)
	self.URL = "ui://zhwzke4or8sco";
	self:__property(...)
	self:Config()
end
function VipLvItem:SetProperty(...)
	
end
function VipLvItem:Config()
	
end
function VipLvItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Vip","VipLvItem");

	--self.payIcon = self.ui:GetChild("payIcon")
	self.resNum = self.ui:GetChild("resNum")
end
function VipLvItem.Create(ui, ...)
	return VipLvItem.New(ui, "#", {...})
end
function VipLvItem:__delete()
end