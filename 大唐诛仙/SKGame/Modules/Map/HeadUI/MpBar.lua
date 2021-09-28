MpBar =BaseClass(LuaUI)
function MpBar:__init()
	self.ui = UIPackage.CreateObject("Map","MpBar")
	self.bar = self.ui:GetChild("bar")
end
function MpBar:SetValue( v )
	self.ui.value = v
end
function MpBar:SetMax( v )
	self.ui.max = v
end