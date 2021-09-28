-- 主动邀请单元
ZDInviteItem = BaseClass(LuaUI)
function ZDInviteItem:__init(data)
	self.ui = UIPackage.CreateObject("Team","ZDInviteItem")
	self.bg = self.ui:GetChild("bg")
	self.txtName = self.ui:GetChild("txtName")
	self.headIcon = self.ui:GetChild("headIcon")
	self.txtCareer = self.ui:GetChild("txtCareer")
	self.iconCareer = self.ui:GetChild("iconCareer")
	self.btnInvite = self.ui:GetChild("btnInvite")
	self.clickMask = self.ui:GetChild("clickMask")

	self.btnInvite.onClick:Add(function ()
		if not self.data then return end
		self.btnInvite.enabled = false
		ZDCtrl:GetInstance():C_Invite(self.data.playerId)
	end)

	self.clickMask.onClick:Add(function ()
		if not self.data then return end
		local data = {}
		data.playerId = self.data.playerId
		data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo, PlayerFunBtn.Type.Chat}
		GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
	end)

	self:Update(data)
end

function ZDInviteItem:Update(data)
	self.data = data
	if not data then return end
	self.btnInvite.enabled = true
	self.txtName.text = data.playerName
	self.txtCareer.text = GetCfgData( "newroleDefaultvalue" ):Get(data.career).careerName
	self.headIcon.icon = "Icon/Head/r"..data.career
	self.headIcon.title = data.level
	self.iconCareer.url = "Icon/Head/career_0"..data.career
end

function ZDInviteItem:__delete()
end