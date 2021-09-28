ClanCYEventPane = BaseClass(LuaUI)
function ClanCYEventPane:__init(root)
	self.URL = "ui://lmxy2w9bjyjf1a";
	self:__property(root)
	self:Layout()
end
function ClanCYEventPane:SetProperty(root)
	self.parent = root
end
function ClanCYEventPane:Layout()
	self:AddTo(self.parent)
	self:SetXY(0, 0)
end
function ClanCYEventPane:SetVisible(v, isfirst)
	LuaUI.SetVisible(self, v)
	if v and not isfirst then
		print("申请事件消息")
	end
end
function ClanCYEventPane:Update()
	
end
function ClanCYEventPane:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Duhufu","CYEventPane");

	self.list = self.ui:GetChild("list")
end
function ClanCYEventPane.Create( ui, ...)
	return ClanCYEventPane.New(ui, "#", {...})
end
function ClanCYEventPane:__delete()
end