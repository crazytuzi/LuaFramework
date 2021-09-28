AttrLabel = BaseClass(LuaUI)
function AttrLabel:__init( ... )
	self.URL = "ui://wt6b3lev9dy3s";
	self:__property(...)
	self:Config()
end
function AttrLabel:SetProperty( ... )
end
function AttrLabel:Config()
	
end
function AttrLabel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Furnace","AttrLabel");

	self.label = self.ui:GetChild("label")
	self.icon = self.ui:GetChild("icon")

end
function AttrLabel:SetContent( label, value, up, upvalue)
	self.label.text = label
	if not upvalue then
		self.ui.title = value
	else
		self.ui.title = StringFormat("{0} [COLOR=#006633](+{1})[/COLOR]", value , upvalue) 
	end
	self.icon.visible = up==true
end
function AttrLabel.Create( ui, ...)
	return AttrLabel.New(ui, "#", {...})
end
function AttrLabel:__delete()
end