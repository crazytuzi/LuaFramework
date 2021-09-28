AddFriItem = BaseClass(LuaUI)
function AddFriItem:__init(...)
	self.URL = "ui://jn83skxku3cyr";
	self:__property(...)
	self:Config()
end
function AddFriItem:SetProperty(...)
	
end
function AddFriItem:Config()
	
end
function AddFriItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Gay","AddFriItem");

	self.tabCtrlbtn = self.ui:GetController("tabCtrlbtn")
	self.headIcon = self.ui:GetChild("headIcon")
	self.txt_playerName = self.ui:GetChild("txt_playerName")
	self.icon_zhiye = self.ui:GetChild("icon_zhiye")
	self.txt_zhiye = self.ui:GetChild("txt_zhiye")
	self.btn_addFriend = self.ui:GetChild("btn_addFriend")
	self.btn_agree = self.ui:GetChild("btn_agree")
	self.btn_refuse = self.ui:GetChild("btn_refuse")
end
function AddFriItem.Create(ui, ...)
	return AddFriItem.New(ui, "#", {...})
end
function AddFriItem:__delete()
end