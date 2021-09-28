PrivateChatBtn = BaseClass(LuaUI)
function PrivateChatBtn:__init( ... )
	self.URL = "ui://m2d8gld1lnqz3n";
	self:__property(...)
	self:Config()
end
-- Set self property
function PrivateChatBtn:SetProperty( ... )
end
-- start
function PrivateChatBtn:Config()
	
end
-- wrap UI to lua
function PrivateChatBtn:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("ChatNew","PrivateChatBtn");

	self.btn_siliao = self.ui:GetChild("btn_siliao")
	self.btnClose = self.ui:GetChild("btnClose")
end
-- Combining existing UI generates a class
function PrivateChatBtn.Create( ui, ...)
	return PrivateChatBtn.New(ui, "#", {...})
end
function PrivateChatBtn:__delete()
end