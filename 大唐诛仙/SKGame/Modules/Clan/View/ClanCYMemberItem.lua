ClanCYMemberItem = BaseClass(LuaUI)
function ClanCYMemberItem:__init( v )
	self.ui = UIPackage.CreateObject("Duhufu","CYMemberItem")
	self.txt1 = self.ui:GetChild("txt1")
	self.txt2 = self.ui:GetChild("txt2")
	self.txt3 = self.ui:GetChild("txt3")
	self.txt4 = self.ui:GetChild("txt4")
	self.txt5 = self.ui:GetChild("txt5")
	self.txt6 = self.ui:GetChild("txt6")
	self.txt7 = self.ui:GetChild("txt7")
	self:Update(v)

	self.ui.onClick:Add(function ()
		if self.func then
			self.func(self.ui, self.data)
		end
	end)
end

function ClanCYMemberItem:Update(data)
	self.data = data
	self.txt1.text = GetCfgData("newroleDefaultvalue"):Get(data.career).careerName
	self.txt2.text = data.playerName
	self.txt3.text = data.level
	self.txt4.text = ClanConst.clanJob[data.roleId+1]
	self.txt5.text = data.battleValue
	self.txt6.text = data.contribution
	if data.exitTime ==0 then
		self.txt7.text = "在线"
		self.txt7.color = newColorByString("44ff44")
	else
		self.txt7.text = StringFormat("已离线\n{0}",TimeTool.GetTimeOutTime(data.exitTime))
		self.txt7.color = newColorByString("2e3144")
	end

	-- data.weekMoney
	-- data.weekBuildNum
	-- data.ticket
	-- data.joinTime
end

function ClanCYMemberItem:SetClickCallback(func)
	self.func = func
end

function ClanCYMemberItem:__delete()
end