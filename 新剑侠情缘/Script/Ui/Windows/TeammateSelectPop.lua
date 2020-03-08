local tbUi = Ui:CreateClass("TeammateSelectPop");

function tbUi:OnOpen(tbTeammateData)
	self.tbTeammateData = tbTeammateData;
	local nFollowNpcId = AutoFight:GetFollowingNpcId();
	local bCaptain = TeamMgr:IsCaptain(me.dwID);
	local nForbidMap = Player:GetServerSyncData("ForbidTeamSelectPopCaptain") or 0;
	if nForbidMap == me.nMapTemplateId then
		bCaptain = false;
	end

	local bTeammateCaptain = TeamMgr:IsCaptain(tbTeammateData.nPlayerID);

	if me.dwID == tbTeammateData.nPlayerID then
		self.pPanel:SetActive("LeaderPop", false);
		self.pPanel:SetActive("MemberPop", false);
		self.pPanel:SetActive("MyselfPop", true);
		self.pPanel:SetActive("BtnGroup1", not bCaptain);
		self.pPanel:SetActive("BtnGroup2", bCaptain);

		if InDifferBattle.bRegistNotofy then
			self.pPanel:SetActive("BtnSendPos1", false)
			self.pPanel:SetActive("BtnSendPos2", false)
		else
			self.pPanel:SetActive("BtnSendPos1", true)
			self.pPanel:SetActive("BtnSendPos2", true)
		end

	elseif bCaptain then
		self.pPanel:SetActive("LeaderPop", true);
		self.pPanel:SetActive("MemberPop", false);
		self.pPanel:SetActive("MyselfPop", false);
		self.pPanel:SetActive("BtnFollowAttackL", nFollowNpcId ~= tbTeammateData.nNpcID);
		self.pPanel:SetActive("BtnStopFollowAttackL", nFollowNpcId == tbTeammateData.nNpcID);
	else
		self.pPanel:SetActive("LeaderPop", false);
		self.pPanel:SetActive("MyselfPop", false);
		self.pPanel:SetActive("MemberPop", true);
		self.pPanel:SetActive("MemberGroup1", not bTeammateCaptain);
		self.pPanel:SetActive("MemberGroup2", bTeammateCaptain);
		self.pPanel:SetActive("BtnFollowAttack1", nFollowNpcId ~= tbTeammateData.nNpcID);
		self.pPanel:SetActive("BtnStopFollowAttack1", nFollowNpcId == tbTeammateData.nNpcID);
		self.pPanel:SetActive("BtnFollowAttack2", nFollowNpcId ~= tbTeammateData.nNpcID);
		self.pPanel:SetActive("BtnStopFollowAttack2", nFollowNpcId == tbTeammateData.nNpcID);
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnKickOut()
	if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) then
		me.CenterMsg("当前地图不允许组队操作");
		return;
	end
	local fnConfirm = function ()
		TeamMgr:KickOutMember(self.tbTeammateData.nPlayerID);
		Ui:CloseWindow(self.UI_NAME);
	end
	me.MsgBox(string.format("是否将%s踢出队伍?", self.tbTeammateData.szName), {{"确定", fnConfirm}, {"取消"}});
end

function tbUi.tbOnClick:BtnFollowAttack1()
	local nNpcId = self.tbTeammateData.nNpcID;
	local tbTeammate = TeamMgr:GetMemberData(nNpcId);
	if not tbTeammate then
		me.CenterMsg("无法找到队友");
		return;
	end

	if InDifferBattle:IsDeathInBattle() then
		return
	end

	if me.nMapId ~= tbTeammate.nMapId then
		me.MsgBox("队友不在本地图，是否确定继续跟战前往？", { {"确定", function ()
			AutoFight:StartFollowTeammate(self.tbTeammateData.nNpcID);
		end}, {"取消"}});

		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	AutoFight:StartFollowTeammate(self.tbTeammateData.nNpcID);
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnStopFollowAttack1()
	if InDifferBattle:IsDeathInBattle() then
		return
	end
	AutoFight:StopFollowTeammate();
	AutoFight:ResetFightState();
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT);
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnTransmit1()
	if InDifferBattle:IsDeathInBattle() then
		return
	end

	local tbMember = self.tbTeammateData;

	if InDifferBattle.bRegistNotofy then
		InDifferBattle:GotoTeamateRoom(tbMember)
	else
		AutoPath:GotoAndCall(tbMember.nMapId, tbMember.nPosX, tbMember.nPosY, nil, nil, tbMember.nMapTemplateId);
	end

	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnTransferLeader()
	if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) then
		me.CenterMsg("当前地图不允许组队操作");
		return;
	end
	local fnConfirm = function ()
		TeamMgr:ChangeCaptain(self.tbTeammateData.nPlayerID);
		Ui:CloseWindow(self.UI_NAME);
	end
	me.MsgBox(string.format("是否将%s设为队长?", self.tbTeammateData.szName), {{"确定", fnConfirm}, {"取消"}});
end

function tbUi.tbOnClick:BtnSendPos1()
	local nNow = GetTime();
	if self.nNextSendPosTime and self.nNextSendPosTime > nNow then
		me.CenterMsg("发送坐标过于频繁");
		return;
	end
	self.nNextSendPosTime = nNow + 5;

	local nMapId, nPosX, nPosY = Decoration:GetPlayerSettingOrgPos(me);
	local nMapTemplateId = me.nMapTemplateId
	local szMapName = Map:GetMapDescInChat(nMapTemplateId);
	--秦始皇陵特殊处理
	if ImperialTomb:IsEmperorMapByTemplate(nMapTemplateId) or
	 ImperialTomb:IsBossMapByTemplate(nMapTemplateId) or
	ImperialTomb:IsFemaleEmperorMapByTemplate(nMapTemplateId) or
	ImperialTomb:IsFemaleEmperorBossMapByTemplate(nMapTemplateId) then

		local nTmpMapId
	 	nMapTemplateId, nTmpMapId, nPosX, nPosY = ImperialTomb:GetCurRoomEnterPos();
	 	nMapId = nMapTemplateId
	 	szMapName = Map:GetMapDescInChat(nMapTemplateId)
	end

	if House.nHouseMapId and nMapId == House.nHouseMapId then
		szMapName = string.format("%s的家", House.szName);
	end

	local szLocaltion = string.format("<%s(%d,%d)>我在这里#36#36#36", szMapName, nPosX*Map.nShowPosScale, nPosY*Map.nShowPosScale);
	ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {nMapId, nPosX, nPosY, nMapTemplateId});
	ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szLocaltion);
end

function tbUi.tbOnClick:BtnLeaveTeam1()
	if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) then
		me.CenterMsg("当前地图不允许组队操作");
		return;
	end
	local fnConfirm = function ()
		TeamMgr:Quite();
		Ui:CloseWindow(self.UI_NAME);
	end
	me.MsgBox("是否退出队伍?", {{"确定", fnConfirm}, {"取消"}});
end

function tbUi.tbOnClick:BtnTeammateBack()
	local nNow = GetTime();
	if self.nNextTeammateBackTime and self.nNextTeammateBackTime > nNow then
		me.CenterMsg("队员召回操作过于频繁，请稍后再试");
		return;
	end
	self.nNextTeammateBackTime = nNow + 5;
	TeamMgr:AskTeammate2Follow();
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnCancelBack()
	local nNow = GetTime();
	if self.nNextTeammateCancelBackTime and self.nNextTeammateCancelBackTime > nNow then
		me.CenterMsg("取消跟战操作过于频繁，请稍后再试");
		return;
	end
	self.nNextTeammateCancelBackTime = nNow + 5;
	TeamMgr:AskTeammateNot2Follow();
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnApply2()
	if  Player:IsInCrossServer() then
		me.CenterMsg("当前地图无法进行此操作")
		return
	end
	if not FriendShip:IsFriend(Player:GetMyRoleId(), self.tbTeammateData.nPlayerID) then
		me.CenterMsg("你们不是好友，不可以申请成为队长");
		return;
	end

	if not me.CanTeamOpt() then
		me.CenterMsg("当前地图无法进行此操作");
		return
	end

	local nNow = GetTime();
	if self.nNextApplyBeCaptainTime and self.nNextApplyBeCaptainTime > nNow then
		me.CenterMsg("正在等待对方确认，请稍后再试");
		return;
	end

	self.nNextApplyBeCaptainTime = nNow + TeamMgr.Def.nApplyBeCaptainWaitingTime;
	TeamMgr:Apply2BeCaptain(self.tbTeammateData.nPlayerID);
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnFollowAttack2     = tbUi.tbOnClick.BtnFollowAttack1;
tbUi.tbOnClick.BtnFollowAttackL     = tbUi.tbOnClick.BtnFollowAttack1;
tbUi.tbOnClick.BtnTransmit2         = tbUi.tbOnClick.BtnTransmit1;
tbUi.tbOnClick.BtnTransmitL         = tbUi.tbOnClick.BtnTransmit1;
tbUi.tbOnClick.BtnStopFollowAttack2 = tbUi.tbOnClick.BtnStopFollowAttack1;
tbUi.tbOnClick.BtnStopFollowAttackL = tbUi.tbOnClick.BtnStopFollowAttack1;
tbUi.tbOnClick.BtnSendPos2          = tbUi.tbOnClick.BtnSendPos1;
tbUi.tbOnClick.BtnLeaveTeam2        = tbUi.tbOnClick.BtnLeaveTeam1;