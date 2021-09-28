PlayerFunBtn = BaseClass(LuaUI)

PlayerFunBtn.Type = {
	CheckPlayerInfo = 1,	 --个人信息
	InviteTeam = 2,			 --邀请组队
	EnterTeam = 3,			 --加入组队
	KickOffTeam  = 4,		 --踢出队伍
	TransferTeamLeader = 5,	 --转让队长
	TransferFamily = 6,		 --转让族长
	EnterFamily = 7,		 --家族邀请
	KickOffFamily = 8,		 --请出家族
	Chat = 9,			 	 --发送消息
	AddFriend = 10,			 --添加好友
	DelFriend = 11,			 --删除好友
	Blacklist = 12,			 --拉黑
}

PlayerFunBtn.Width = 180
PlayerFunBtn.Height = 56

function PlayerFunBtn:__init(...)
	self.URL = "ui://0042gnitz03ee6";
	self:__property(...)
	self:Config()
end

function PlayerFunBtn:SetProperty(...)
	
end

function PlayerFunBtn:Config()
	
end

function PlayerFunBtn:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","PlayerFunBtn");

	self.n1 = self.ui:GetChild("n1")
	self.title = self.ui:GetChild("title")

	FriendController:GetInstance():C_FriendList(1)
	self:AddEvent()

end

function PlayerFunBtn:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)	
end

function PlayerFunBtn:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)	
end

function PlayerFunBtn:OnClickHandler()
	UIMgr.HidePopup()
	if self.type == PlayerFunBtn.Type.CheckPlayerInfo then --个人信息
		GlobalDispatcher:DispatchEvent(EventName.CheckOtherPlayerInfo, self.root.playerId)

	elseif self.type == PlayerFunBtn.Type.InviteTeam then --邀请组队
		if SceneModel:GetInstance():IsInNewBeeScene() then
			UIMgr.Win_FloatTip("通关彼岸村后可使用")
			return
		end
		ZDCtrl:GetInstance():C_Invite(self.root.playerId)
	elseif self.type == PlayerFunBtn.Type.EnterTeam then --加入组队
		if SceneModel:GetInstance():IsInNewBeeScene() then
			UIMgr.Win_FloatTip("通关彼岸村后可使用")
			return
		end
		if self.root.data.teamId and self.root.data.teamId ~= 0 then
			ZDCtrl:GetInstance():C_ApplyJoinTeam(self.root.data.teamId)
		else
			UIMgr.Win_FloatTip("加入失败，对方没有队伍!")
		end
	elseif self.type == PlayerFunBtn.Type.KickOffTeam then --踢出队伍
		ZDCtrl:GetInstance():C_KickTeamPlayer(self.root.playerId)
	elseif self.type == PlayerFunBtn.Type.TransferTeamLeader then --转让队长
		ZDCtrl:GetInstance():C_ChangeCaptain(self.root.playerId)
	elseif self.type == PlayerFunBtn.Type.TransferFamily then --转让族长

	elseif self.type == PlayerFunBtn.Type.EnterFamily then --家族邀请
		if SceneModel:GetInstance():IsInNewBeeScene() then
			UIMgr.Win_FloatTip("通关彼岸村后可使用")
			return
		else
			local id = self.root.data.playerId
			FamilyModel:GetInstance():JoinFamily( id )
		end
	elseif self.type == PlayerFunBtn.Type.KickOffFamily then --请出家族

	elseif self.type == PlayerFunBtn.Type.Chat then --发送私聊消息
		local chatVo = {}
		chatVo.sendPlayerLevel = self.root.data.playerLevel
		chatVo.sendPlayerCareer = self.root.data.career
		chatVo.sendPlayerId = self.root.data.playerId
		chatVo.online = 1
		chatVo.sendPlayerName = self.root.data.playerName
		chatVo.familyName = self.root.data.familyName
		FriendController:GetInstance():IsFriendChat(chatVo)
		--GlobalDispatcher:DispatchEvent(EventName.FriendChat, chatVo)
		

	elseif self.type == PlayerFunBtn.Type.AddFriend then --添加好友
		FriendController:GetInstance():C_ApplyAddFriend(self.root.data.playerId)   --+++++

	elseif self.type == PlayerFunBtn.Type.DelFriend then --删除好友
		FriendController:GetInstance():C_DeleteFriend(self.root.data.playerId)     --+++++

	elseif self.type == PlayerFunBtn.Type.Blacklist then --拉黑

	end

end

function PlayerFunBtn:ClosePrePanel()
	if BaseView.CurView then
		BaseView.CurView:Close()
	end
end

function PlayerFunBtn:SetType(type, root)
	self.type = type
	self.root = root
	if self.type == PlayerFunBtn.Type.CheckPlayerInfo then --个人信息
		self.title.text = "个人信息"

	elseif self.type == PlayerFunBtn.Type.InviteTeam then --邀请组队
		self.title.text = "邀请组队"

	elseif self.type == PlayerFunBtn.Type.EnterTeam then --加入组队
		self.title.text = "加入组队"

	elseif self.type == PlayerFunBtn.Type.KickOffTeam then --踢出队伍
		self.title.text = "踢出队伍"

	elseif self.type == PlayerFunBtn.Type.TransferTeamLeader then --转让队长
		self.title.text = "转让队长"

	elseif self.type == PlayerFunBtn.Type.TransferFamily then --转让族长
		self.title.text = "转让族长"

	elseif self.type == PlayerFunBtn.Type.EnterFamily then --家族邀请
		self.title.text = "家族邀请"

	elseif self.type == PlayerFunBtn.Type.KickOffFamily then --请出家族
		self.title.text = "请出家族"

	elseif self.type == PlayerFunBtn.Type.Chat then --私    聊
		self.title.text = "私    聊"

	elseif self.type == PlayerFunBtn.Type.AddFriend then --添加好友
		self.title.text = "添加好友"

	elseif self.type == PlayerFunBtn.Type.DelFriend then --删除好友
		self.title.text = "删除好友"

	elseif self.type == PlayerFunBtn.Type.Blacklist then --拉黑
		self.title.text = "拉黑"
	end
end

function PlayerFunBtn.Create(ui, ...)
	return PlayerFunBtn.New(ui, "#", {...})
end

function PlayerFunBtn:__delete()
	self:RemoveEvent()
end