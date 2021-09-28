HpBarOther =BaseClass(LuaUI)
function HpBarOther:__init()
	self.ui = UIPackage.CreateObject("Map","HpBarOther")
	self.bar = self.ui:GetChild("bar")
	self.bg = self.ui:GetChild("bg")
end
function HpBarOther:SetValue( v )
	self.ui.value = v
end
function HpBarOther:SetMax( v )
	self.ui.max = v
end