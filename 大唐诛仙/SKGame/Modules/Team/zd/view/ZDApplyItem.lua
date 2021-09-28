-- 申请单元
ZDApplyItem = BaseClass(LuaUI)
function ZDApplyItem:__init(data)
	self.ui = UIPackage.CreateObject("Team","ZDApplyItem")
	self.bg = self.ui:GetChild("bg")
	self.txtName = self.ui:GetChild("txtName")
	self.headIcon = self.ui:GetChild("headIcon")
	self.txtCareer = self.ui:GetChild("txtCareer")
	self.iconCareer = self.ui:GetChild("iconCareer")
	self.btnRefuse = self.ui:GetChild("btnRefuse")
	self.btnAgree = self.ui:GetChild("btnAgree")
	self.clickMask = self.ui:GetChild("clickMask")

	self:InitEvent()
	self:Update(data)
end

function ZDApplyItem:InitEvent()
	self.btnAgree.onClick:Add(function ()
		if not self.data then return end
		self.btnAgree.enabled = false
		ZDCtrl:GetInstance():C_ApplyJoinTeamDeal(self.data.playerId, 1)
	end)
	self.btnRefuse.onClick:Add(function ()
		if not self.data then return end
		self.btnRefuse.enabled = false
		ZDCtrl:GetInstance():C_ApplyJoinTeamDeal(self.data.playerId, 0)
		
	end)

	self.clickMask.onClick:Add(function ()
		if not self.data then return end
		local data = {}
		data.playerId = self.data.playerId
		data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo, PlayerFunBtn.Type.Chat}
		GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
	end)
end

function ZDApplyItem:Update(data)
	self.data = data
	if not data then return end
	self.btnAgree.enabled = true
	self.btnRefuse.enabled = true
	self.txtName.text = data.playerName
	self.txtCareer.text = GetCfgData( "newroleDefaultvalue" ):Get(data.career).careerName
	self.headIcon.icon = "Icon/Head/r"..data.career
	self.headIcon.title = data.level
	self.iconCareer.url = "Icon/Head/career_0"..data.career
end
function ZDApplyItem:__delete()
end