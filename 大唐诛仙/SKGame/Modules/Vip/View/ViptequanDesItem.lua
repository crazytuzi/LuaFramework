ViptequanDesItem = BaseClass(LuaUI)
function ViptequanDesItem:__init(...)
	self.URL = "ui://zhwzke4or8scp";
	self:__property(...)
	self:Config()
end
function ViptequanDesItem:SetProperty(...)
	
end
function ViptequanDesItem:Config()
	
end
function ViptequanDesItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Vip","ViptequanDesItem");

	self.sign = self.ui:GetChild("sign")
	self.tequanDes = self.ui:GetChild("tequanDes")
end

function ViptequanDesItem.Create(ui, ...)
	return ViptequanDesItem.New(ui, "#", {...})
end
function ViptequanDesItem:__delete()
end