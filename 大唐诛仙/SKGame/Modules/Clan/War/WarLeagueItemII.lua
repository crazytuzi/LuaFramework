WarLeagueItemII = BaseClass(LuaUI)
function WarLeagueItemII:__init(data)
	self.data = data
	local ui = UIPackage.CreateObject("Duhufu","WarLeagueItemII")
	self.ui = ui
	self.btn = ui:GetChild("btn")
	self.title = ui:GetChild("title")
	self:Update(data)

	self.btn.onClick:Add(function ()
		if not self.data then return end
		ClanCtrl:GetInstance():C_AgreeJoinUnion(self.data.guildId)
	end)
end
function WarLeagueItemII:Update( v )
	self.data = v
	if not v then return end
	-- v.guildId = 1;  // 都护府编号
	-- v.guildName = 2;  // 都护府名	d
	-- v.agreeFlag = 3;  // 是否有权操作同意 1：是
	self.title.text = v.guildName
	self.btn.enabled = v.agreeFlag == 1
end
function WarLeagueItemII:__delete()
end