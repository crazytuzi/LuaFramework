ClanSkillCell = BaseClass(LuaUI)
function ClanSkillCell:__init( data,t )
	self.ui = UIPackage.CreateObject("Duhufu","SkillCell")
	self.txtLv = self.ui:GetChild("txtLv")
	self.icon = self.ui:GetChild("icon")
	self.paneType = t
	self:Update(data,0)
	self:SetActivited(false)
	self.ui.onClick:Add(function ()
		if self.func then
			self.func(self)
		end
	end)
end
function ClanSkillCell:SetActivited( b )
	self.activited = b
	self.icon.grayed = not b
	if  not b then
		if self.paneType == ClanJNPane.Learn then
			self.txtLv.text = "未学习"
		else
			self.txtLv.text = "未研发"
		end
	end
end

function ClanSkillCell:Update(data,owerLv)
	self.data = data
	self.owerLv = owerLv
	if self.paneType == ClanJNPane.Learn then
		self.txtLv.text = StringFormat("{0} 级", data.level)
	else
		self.txtLv.text = StringFormat("{0} 级", data.level)
	end
	
	self.ui.title= data.skillName
	self.ui.icon = "Icon/Skill/"..data.iconID
end
function ClanSkillCell:OnClickCallback( func )
	self.func = func
end

function ClanSkillCell:__delete()
	self.func=nil
	self.data=nil
	self.activited = false
	self.owerLv=0
end