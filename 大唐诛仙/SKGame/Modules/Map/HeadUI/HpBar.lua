HpBar =BaseClass(LuaUI)
function HpBar:__init()
	self.ui = UIPackage.CreateObject("Map","HpBar")
	self.bar = self.ui:GetChild("bar")
	self.bg = self.ui:GetChild("bg")
end

function HpBar:SetValue( v )
	self.ui.value = v
end
function HpBar:SetMax( v )
	self.ui.max = v
end