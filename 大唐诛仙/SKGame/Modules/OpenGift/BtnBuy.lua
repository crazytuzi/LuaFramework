BtnBuy = BaseClass(LuaUI)
function BtnBuy:__init( ... )
	self.URL = "ui://ls8mguzvrmqhf";
	self:__property(...)
	self:Config()
end
-- Set self property
function BtnBuy:SetProperty( ... )
end
-- start
function BtnBuy:Config()
	
end
-- wrap UI to lua
function BtnBuy:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("OpenGift","BtnBuy");

	self.btnState = self.ui:GetController("btnState")
end
-- Combining existing UI generates a class
function BtnBuy.Create( ui, ...)
	return BtnBuy.New(ui, "#", {...})
end
function BtnBuy:__delete()
end