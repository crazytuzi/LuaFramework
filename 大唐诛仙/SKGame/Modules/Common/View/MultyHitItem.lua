MultyHitItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function MultyHitItem:__init( ... )
	self.URL = "ui://0tyncec1rdc8bv";
	self:__property(...)
	self:Config()
end

-- Set self property
function MultyHitItem:SetProperty( ... )
	
end

-- Logic Starting
function MultyHitItem:Config()
	
end

-- Register UI classes to lua
function MultyHitItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","MultyHitItem");

	self.hit = self.ui:GetChild("hit")
	self.title = self.ui:GetChild("title")
	self.hitAnimation = self.ui:GetTransition("hitAnimation")
end

-- Combining existing UI generates a class
function MultyHitItem.Create( ui, ...)
	return MultyHitItem.New(ui, "#", {...})
end

-- Dispose use MultyHitItem obj:Destroy()
function MultyHitItem:__delete()
	
	self.hit = self.ui:GetChild("hit")
	self.title = self.ui:GetChild("title")
	self.hitAnimation = self.ui:GetTransition("hitAnimation")
end