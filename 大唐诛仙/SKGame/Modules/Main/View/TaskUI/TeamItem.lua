TeamItem = BaseClass(LuaUI)

local urlMate = "ui://0tyncec1w6zznnf"
local urlLeader = "ui://0tyncec1g9qxnm4"

function TeamItem:__init(v)
	self.ui = UIPackage.CreateObject("Main","TeamItem")
	self.hpBar = self.ui:GetChild("hpBar")
	self.headIcon = self.ui:GetChild("headIcon")
	self.careerIcon = self.ui:GetChild("careerIcon")
	self.txtName = self.ui:GetChild("txtName")
	self.leadSign = self.ui:GetChild("leadSign")
	self.headIcon.grayed = false
	self:InitEvent()
	self:Update(v)
end

function TeamItem:Update(data)
	self.data = data
	if not data then return end

	self.txtName.text = data.playerName
	self.headIcon.icon = StringFormat("Icon/Head/r{0}",data.career)
	self.headIcon.title = data.level
	self.careerIcon.icon = StringFormat("Icon/Head/career_1{0}",data.career)
	-- self.leadSign.visible = data.captain == true
	if data.captain then
		self.leadSign.url = urlLeader
	else
		self.leadSign.url = urlMate
	end
	self.headIcon.grayed = data.online~=1
	self:UpdateHp(data.hp, data.maxHp)
end
function TeamItem:UpdateHp( hp, maxHp )
	self.hpBar.value = hp
	self.hpBar.max = maxHp
end
function TeamItem:InitEvent()
	self.ui.onClick:Add(function ()
		if self.data then
			if LoginModel:GetInstance():IsRole( self.data.playerId ) then
				if SceneModel:GetInstance():IsInNewBeeScene() then
					UIMgr.Win_FloatTip("通关彼岸村后可使用")
					return
				end
				ZDCtrl:GetInstance():Open()
				return
			end
			local data = {}
			data.playerId = self.data.playerId
			if ZDModel:GetInstance():IsLeader() then
				data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo, PlayerFunBtn.Type.Chat, PlayerFunBtn.Type.KickOffTeam}
			else
				data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo}
			end
			if data.funcIds then
				table.insert(data.funcIds, PlayerFunBtn.Type.AddFriend)
				table.insert(data.funcIds, PlayerFunBtn.Type.EnterFamily)
			end
			GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
		end
	end)
end

function TeamItem:__delete()

end