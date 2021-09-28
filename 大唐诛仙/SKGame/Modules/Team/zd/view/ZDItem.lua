-- 大厅可申请队伍单元
ZDItem = BaseClass(LuaUI)
function ZDItem:__init(data)
	self.ui = UIPackage.CreateObject("Team","ZDItem")
	self.bg = self.ui:GetChild("bg")
	self.selected = self.ui:GetChild("selected")
	self.txtName = self.ui:GetChild("txtName")
	self.headIcon = self.ui:GetChild("headIcon")
	self.txtCareer = self.ui:GetChild("txtCareer")
	self.iconCareer = self.ui:GetChild("iconCareer")
	self.progress = self.ui:GetChild("progress")
	self.txtLimitLev = self.ui:GetChild("txtLimitLev")
	self.btnApply = self.ui:GetChild("btnApply")
	self.clickMask = self.ui:GetChild("clickMask")
	self:InitEvent()
	self:Update(data)
end

function ZDItem:InitEvent()
	self.btnApply.onClick:Add(function ()
		if self.data then
			self.btnApply.enabled = false
			ZDCtrl:GetInstance():C_ApplyJoinTeam(self.data.teamId)
		end
	end)
	self.clickMask.onClick:Add(function ()
		if self.cb then self.cb(self) end
		if self.data then
			local data = {}
			data.playerId = self.data.playerId
			data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo, PlayerFunBtn.Type.Chat}
			GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
		end
	end)
end
function ZDItem:Update(data)
	self.data = data
	if not data then return end
	self.btnApply.enabled = true
	self.txtName.text = data.playerName
	self.txtLimitLev.UBBEnabled = true
	--self.txtLimitLev.text = StringFormat("等级限制：{0}级",data.minLevel)

	local id = data.activityId or 0
	local strTarget = ""
	if id == 0 then
		strTarget = "自由"
	else
		for i = 2, #ZDConst.teamTargets do
			local bigT = ZDConst.teamTargets[i]
			for j = 1, #bigT[3] do
				if bigT[3][j][1] == id then
					strTarget = StringFormat("{0}-{1}", bigT[2], bigT[3][j][2])
					break
				end
			end
		end
	end
	self.txtLimitLev.text = StringFormat("[color=#006600]目标[/color]:{0}  [color=#006600]等级限制[/color]:{1}级", strTarget, data.minLevel)

	local role = GetCfgData( "newroleDefaultvalue" ):Get(data.career)
	if role then
		self.txtCareer.text = role.careerName
	end
	self.headIcon.icon = StringFormat("Icon/Head/r{0}",data.career)
	self.headIcon.title = data.level
	self.iconCareer.url = StringFormat("Icon/Head/career_0{0}",data.career)

	self.progress.max = 4
	self.progress.value = data.playerNum or 0
end

function ZDItem:SetSelectCallback( cb )
	self.cb = cb
end

function ZDItem:__delete()
	self.data = nil
end