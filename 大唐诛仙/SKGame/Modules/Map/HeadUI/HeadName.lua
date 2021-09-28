HeadName =BaseClass(LuaUI)
function HeadName:__init()
	self.ui = UIPackage.CreateObject("Map","HeadName")
	self.title = self.ui:GetChildAt(0)
end
function HeadName:SetName(name)
	self.title.text = name
end
function HeadName:SetColor( color )
	self.title.color = newColorByString(color)
end
