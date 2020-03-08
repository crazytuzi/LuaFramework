Require("CommonScript/ImperialTomb/ImperialTombDef.lua")

function ImperialTomb:LoadSetting()
	self.tbShowAwardSetting = {};

	local tbFileData = Lib:LoadTabFile("Setting/ImperialTomb/ShowAward.tab", {NpcTemplate = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbShowAwardSetting[tbInfo.NpcTemplate] = self.tbShowAwardSetting[tbInfo.NpcTemplate] or {};
		local szTimeFrame = tbInfo.TimeFrame or ""
		self.tbShowAwardSetting[tbInfo.NpcTemplate][szTimeFrame] = self.tbShowAwardSetting[tbInfo.NpcTemplate][szTimeFrame] or {}
		local tbList = self.tbShowAwardSetting[tbInfo.NpcTemplate][szTimeFrame]

		for nI = 1, 20 do
			if not Lib:IsEmptyStr(tbInfo["Award"..nI]) then
				local tbAllAward = Lib:GetAwardFromString(tbInfo["Award"..nI]);
				table.insert(tbList, tbAllAward[1]);
			end
		end
	end
end

function ImperialTomb:GetShowAward(nNpcTemplateId)
	local tbNpcAward = self.tbShowAwardSetting[nNpcTemplateId]
	if not tbNpcAward then
		return
	end

	local szTimeFrame = Lib:GetMaxTimeFrame(tbNpcAward)
	
	return tbNpcAward[szTimeFrame];
end

function ImperialTomb:SecretInvite(nType, szTitle)
	self.nSecretInviteType = nType;
	local tbMsgData =
	{
		szType = "ImperialTombSecretInvite",
		nTimeOut = GetTime() + self.SECRET_INVITE_TIME,
		szTitle = szTitle,
	};

	me.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
end

function ImperialTomb:EmperorInvite(bOpenFemaleEmperor)
	local tbMsgData =
	{
		szType = "ImperialTombEmperorInvite",
		nTimeOut = GetTime() + self.EMPEROR_INVITE_TIME,
		bOpenFemaleEmperor = bOpenFemaleEmperor,
	};

	me.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
end

function ImperialTomb:SecretEnterRequest()
	local ret, msg = self:CheckSecretEnter(me)
	if not ret then
		me.CenterMsg(msg)
		return false
	end

	RemoteServer.ImperialTombSecretEnter(self.nSecretInviteType)

	return true
end

function ImperialTomb:CheckSecretEnter(pPlayer)
	if not self.nSecretInviteType then
		return false, "你尚未获得进入资格"
	end

	if not self:IsNormalMapByTemplate(pPlayer.nMapTemplateId) then
		return false, "所在地图不可以进入"
	end

	return true
end

function ImperialTomb:EnterEmperorRequest(nDesMapId, nDesX, nDesY, nParam)
	if me.dwKinId == 0 then
		me.CenterMsg(XT("没有家族，无法参加活动"))
		return
	end

	local ret, msg = self:CheckEmperorTicket(me)
	if not ret then
		me.CenterMsg(msg)
		return
	end

	local  function _goEmperor ()
		local nDefaultMapType = self.MAP_TYPE.FIRST_FLOOR
		local bFemaleEmperor = Calendar:IsActivityInOpenState("ImperialTombFemaleEmperor")
		if bFemaleEmperor then
			nDefaultMapType = self.MAP_TYPE.FEMALE_EMPEROR_FLOOR
		end

		local nMapId = self.MAP_TEMPLATE_ID[nDefaultMapType]
		local tbPos = self.NOMAL_FLOOR_DEFAULT_POS[nDefaultMapType]

		AutoPath:GotoAndCall(nDesMapId or nMapId,
		 	nDesX or tbPos.nX, nDesY or tbPos.nY, nil, nil, nDesMapId or nMapId, nParam)

		Ui:CloseWindow("NotifyMsgList")
		Ui:CloseWindow("CalendarPanel")
		Ui:CloseWindow("ImperialTombPanel");
	end
	
	AutoFight:StopFollowTeammate();

	--[[if not self:IsTombMap(me.nMapTemplateId) and not self:IsPayEmperorTicket(me) then
		Ui:OpenWindow("MessageBox", XT("是否消耗一颗夜明珠前往?"), 
				{
					{function ()
						_goEmperor ()
					end}, {}
				}, {"确定", "取消"})
	else]]
		_goEmperor ()
	--end
end

function ImperialTomb:EnterTombRequest(bEmperor, bFemaleEmperor)
	local ret, msg = self:CheckEnterTomb(me, bEmperor, bFemaleEmperor)

	if not ret then
		local nMapTemplateId = me.nMapTemplateId
		if Map.tbFieldFightMap[nMapTemplateId] and me.nFightMode == 1 then
			local fnCallBack = function ()
				self:_EnterTombNotify(bEmperor)
			end
			me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
			local nX, nY = Map:GetDefaultPos(nMapTemplateId)
			AutoPath:GotoAndCall(nMapTemplateId, nX, nY, fnCallBack)
			Ui:CloseWindow("NotifyMsgList")
			return true
		else
			me.CenterMsg(msg)
			return false
		end
	end

	self:_EnterTombNotify(bEmperor)
	return true
end

function ImperialTomb:_EnterTombNotify(bEmperor, nParam)
	AutoFight:StopFollowTeammate();
	
	local szWndClass = "MessageBox"
	if Ui:WindowVisible(szWndClass) == 1 then
		szWndClass = "MessageBoxBig"
	end

	local bFemaleEmperor = Calendar:IsActivityInOpenState("ImperialTombFemaleEmperor")

	if bEmperor then
		if not self:IsPayEmperorTicket(me) then
			local nNeedCount = self.EMPEROR_TICKET_COUNT[bFemaleEmperor]
			local szTitle = "秦始皇陵"
			if bFemaleEmperor then
				szTitle = "女帝疑冢"
			end

			Ui:OpenWindow(szWndClass, string.format("是否消耗[FFFE0D]%s颗夜明珠[-]前往%s？", nNeedCount, szTitle), 
			{
				{function ()
					if bFemaleEmperor then
						RemoteServer.ImperialTombFemaleEmperorEnter(nParam)
					else
						RemoteServer.ImperialTombEnter()
					end
				end}, {}
			}, {"确定", "取消"})

			return
		end
	else
		Ui:OpenWindow(szWndClass, string.format(XT("进入后将消耗每日停留时间，是否确定进入秦始皇陵？（停留时间剩余%s）"), Lib:TimeDesc8(ImperialTomb:GetStayTime(me))), 
			{
				{function ()
					RemoteServer.ImperialTombEnter()
				end}, {}
			}, {"确定", "取消"})
		return
	end
	
	if bFemaleEmperor then
		RemoteServer.ImperialTombFemaleEmperorEnter(nParam)
	else
		RemoteServer.ImperialTombEnter()
	end
end

function ImperialTomb:SyncTransTime(nTime)

	if Ui:WindowVisible("ArenaChallengerInfoPanel") then
		Ui:CloseWindow("ArenaChallengerInfoPanel");
	end

	Ui:OpenWindow("ArenaChallengerInfoPanel","Default",{TopTitle = "地图关闭：", nTime = nTime})
end

function ImperialTomb:SyncRoomCloseTime(nTime, szBossName)
	if Ui:WindowVisible("ArenaChallengerInfoPanel") then
		Ui:CloseWindow("ArenaChallengerInfoPanel");
	end
	
	Ui:OpenWindow("ArenaChallengerInfoPanel","Default",{TopTitle = "挑战剩余：", nTime = nTime})
	self.szBossName = szBossName
end

function ImperialTomb:SyncSecretRoomTime(nTime)

	if self.nSecretStayTimer then
		Timer:Close(self.nSecretStayTimer)
		self.nSecretStayTimer = nil
	end

	if nTime > 0 then
		self.nSecretStayTimer = Timer:Register(Env.GAME_FPS * nTime, self.OnSecretStayTimer, self);

		if Ui:WindowVisible("ArenaChallengerInfoPanel") then
			Ui:CloseWindow("ArenaChallengerInfoPanel");
		end
		
		Ui:OpenWindow("ArenaChallengerInfoPanel","Default",
			{TopTitle = "剩余时间：", nTime = nTime, 
			 RightTitle= "下一轮刷新时间：",RightTitlePivot = Ui.Pivot.Center,
			 RightTime = self:GetSecretSpawnTime(), RightInfoPivot = Ui.Pivot.Center})
	end
end

function ImperialTomb:SyncSecretRoomProtectTime(nTime)

	if self.nSecretProtectTimer then
		Timer:Close(self.nSecretProtectTimer)
		self.nSecretProtectTimer = nil
	end

	if nTime > 0 then
		self.nSecretProtectTimer = Timer:Register(Env.GAME_FPS * nTime, self.OnSecretProtectTimer, self);

		local pNpc = me.GetNpc();
		if pNpc then
			pNpc.AddSkillState(self.PROTECT_TIME_BUFF, 1, 3, nTime * Env.GAME_FPS, 1, 1);
		end
	end
end

function ImperialTomb:SyncSecretRoomSpawnTime(nTime)

	if self.nSecretSpawnTimer then
		Timer:Close(self.nSecretSpawnTimer)
		self.nSecretSpawnTimer = nil
	end

	if nTime > 0 then
		self.nSecretSpawnTimer = Timer:Register(Env.GAME_FPS * nTime, self.OnSecretSpawnTimer, self);

		if Ui:WindowVisible("ArenaChallengerInfoPanel") then
			Ui:CloseWindow("ArenaChallengerInfoPanel");
		end

		Ui:OpenWindow("ArenaChallengerInfoPanel","Default",
			{TopTitle = "剩余时间：", nTime = self:GetSecretStayTime(), 
			 RightTitle= "下一轮刷新时间：",RightTitlePivot = Ui.Pivot.Center,
			 RightTime = nTime, RightInfoPivot = Ui.Pivot.Center})
	end
end

function ImperialTomb:SynEmperorDmgInfo(tbDmg)
	self.tbEmperorDmgInfo = tbDmg
	if Calendar:IsActivityInOpenState("ImperialTombFemaleEmperor") then
		self.tbEmperorDmgInfo.szTargetName = XT("武则天")
	else
		self.tbEmperorDmgInfo.szTargetName = XT("秦始皇")
	end

	self.nLastUpdateDmg = GetTime()
	UiNotify.OnNotify(UiNotify.emNOTIFY_DMG_RANK_UPDATE, self.tbEmperorDmgInfo)
end

function ImperialTomb:SynBossDmgInfo(nMapId, szTargetName, tbDmg)
	self.tbBossDmgInfo = self.tbBossDmgInfo or {}
	self.tbBossDmgInfo[nMapId] = tbDmg or {}
	self.tbBossDmgInfo[nMapId].nLastUpdateDmg = GetTime()
	self.tbBossDmgInfo[nMapId].szTargetName = szTargetName

	UiNotify.OnNotify(UiNotify.emNOTIFY_DMG_RANK_UPDATE, self.tbBossDmgInfo[nMapId])
end

function ImperialTomb:GetEmperorDmgInfo()
	if not self.tbEmperorDmgInfo or #self.tbEmperorDmgInfo <= 0 or self:IsEmperorDmgInfoTimeOut() then
		return nil
	end

	return self.tbEmperorDmgInfo
end

function ImperialTomb:GetBossDmgInfo(nMapId)
	if not self.tbBossDmgInfo or not self.tbBossDmgInfo[nMapId] or self:IsBossDmgInfoTimeOut(nMapId) then
		return nil
	end

	return self.tbBossDmgInfo[nMapId], self.tbBossDmgInfo[nMapId].szTargetName
end

function ImperialTomb:IsEmperorDmgInfoTimeOut()
	if not self.nLastUpdateDmg then
		return true
	end

	if (self.nLastUpdateDmg + 15) < GetTime() then
		return true
	end

	return false
end

function ImperialTomb:IsBossDmgInfoTimeOut(nMapId)
	if not self.tbBossDmgInfo or not self.tbBossDmgInfo[nMapId]  then
		return true
	end

	if (self.tbBossDmgInfo[nMapId].nLastUpdateDmg + 15) < GetTime() then
		return true
	end

	return false
end

function ImperialTomb:LeaveRequest()
	Ui:OpenWindow("MessageBox", XT("确定要离开吗?"), 
			{
				{function ()
					RemoteServer.ImperialTombLeave();
				end}, {}
			}, {"确定", "取消"})
end

function ImperialTomb:OnEnter(nMapTemplateId, nMapId, nType, bEmperor, bOpenFemaleEmperor, bCallEmperor, nMapParam, tbEnterPos, nEmperorRoomIndex)
	self.nMapParam = nMapParam
	self.tbEnterPos = tbEnterPos

	if self:IsNormalMapByTemplate(nMapTemplateId) then
		Ui:OpenWindow("QYHLeavePanel","ImperialTomb")
		Ui:RemoveNotifyMsg("ImperialTombEmperorInvite")

		if self:IsNormalMapReduceStayTimeByTemplate(nMapTemplateId) then
			for nRoomIndex=1,3 do
				if not bEmperor or bOpenFemaleEmperor then
					Map:SetMapNpcInfoCanAutoPath(nMapTemplateId, "ToBossRoom" .. nRoomIndex, 0)
					Map:SetMapTextPosInfoNotShow(nMapTemplateId, "BossRoom" .. nRoomIndex, 1)
				else
					if bCallEmperor then
						Map:SetMapTextPosInfoNotShow(nMapTemplateId, "EmperorRoom" .. nRoomIndex, 0)
						Map:SetMapNpcInfoCanAutoPath(nMapTemplateId, "ToEmperorRoom" .. nRoomIndex, 1)
						if nEmperorRoomIndex then
							if nRoomIndex == nEmperorRoomIndex then
								Map:SetMapTextPosInfoColor(nMapTemplateId, "EmperorRoom" .. nRoomIndex, "Green")
							else
								Map:SetMapTextPosInfoColor(nMapTemplateId, "EmperorRoom" .. nRoomIndex, "Red")
							end
						else
							Map:SetMapTextPosInfoColor(nMapTemplateId, "EmperorRoom" .. nRoomIndex, "Green")
						end
					end

					Map:SetMapTextPosInfoNotShow(nMapTemplateId, "BossRoom" .. nRoomIndex, 0)
					Map:SetMapNpcInfoCanAutoPath(nMapTemplateId, "ToBossRoom".. nRoomIndex, 1)
				end
			end

			if not bEmperor or bOpenFemaleEmperor then
				self:OpenStayTimer(self:GetStayTime(me))
			end
		end
	else
		if not self:IsEmperorMirrorMapByTemplate(nMapTemplateId) and not self:IsFemaleEmperorMirrorMapByTemplate(nMapTemplateId) then
			Ui:OpenWindow("QYHLeavePanel","ImperialTombBoss")
		end
		
		Ui:SetLoadShowUI({nMapTID = nMapTemplateId, tbUi = {["BattleTopButton"] = 1}})
		if self:IsSecretMapByTemplate(nMapTemplateId) then
			Ui:RemoveNotifyMsg("ImperialTombSecretInvite")
		end
	end

	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveMap, self)

	Timer:Register(Env.GAME_FPS, function () UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK); end);
	Ui:CloseWindow("NotifyMsgList")
end

function ImperialTomb:OnLeaveMap(nTemplateId, nMapId)
	if self:IsTombMap(nTemplateId) then
		self:OnLeave()
	end
end

function ImperialTomb:OnLeave()
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
	self:Clear()
	Ui:CloseWindow("QYHLeavePanel")
	Ui:CloseWindow("ArenaChallengerInfoPanel")
	Ui:CloseWindow("BossLeaderOutputPanel")
end

function ImperialTomb:OnLogout()
	self:Clear()
end

function ImperialTomb:Clear()

	--UiNotify:UnRegistNotify(UiNotify.emNOTIFY_CHANGE_FIGHT_STATE, self)

	self:CloseTimer()
	local pNpc = me.GetNpc();
	if pNpc then
		pNpc.RemoveSkillState(self.STAY_TIME_BUFF);
		pNpc.RemoveSkillState(self.PROTECT_TIME_BUFF);
	end
	self.szBossName = nil
end

function ImperialTomb:ChangeFightState(nFightState)
	if nFightState == 1 then
		self:OpenStayTimer(self:GetStayTime(me))
	else
		self:CloseStayTimer()
	end

end

function ImperialTomb:GetTransmitPath(nMapTemplateId, nMapId, nX, nY, nParam)
	if me.nMapTemplateId == nMapTemplateId then
		return nil
	end

	--只允许1，2，3层
	if not self:IsNormalMapByTemplate(nMapTemplateId) then
		return nil
	end

	local bInFieldMap = Fuben.tbSafeMap[me.nMapTemplateId] or Map:GetClassDesc(me.nMapTemplateId) == "fight"

	if not self:IsNormalMapByTemplate(me.nMapTemplateId) and not bInFieldMap then
		return nil
	end

	local tbPath = {}

	if nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR] then
		--目标点在第3层
		local nTmpX, nTmpY

		--自己在第1，2层,从2层到3层的路径
		if me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR] or 
			me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR] or 
			bInFieldMap then

			nTmpX, nTmpY = self:GetTemplatePath(tbPath, 
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR],
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR],
						nX, nY, nMapId)
		end

		--自己在第1层,从1层到2层的路径
		if me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR] or bInFieldMap then

			nTmpX, nTmpY = self:GetTemplatePath(tbPath, 
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR],
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR],
						nTmpX, nTmpY)
		end
	elseif nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR] then
		--目标点在第2层
		local nTmpX, nTmpY

		--自己在第3层或秦始皇房间,从3层到2层的路径
		if me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR] or 
			me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.EMPEROR_ROOM] then

			nTmpX, nTmpY = self:GetTemplatePath(tbPath, 
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR],
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR],
						nX, nY, nMapId)
		elseif me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR] or bInFieldMap then
			--自己在1层,从1层到2层的路径

			nTmpX, nTmpY = self:GetTemplatePath(tbPath, 
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR],
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR],
						nX, nY, nMapId)
		end
	elseif nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR] then
		local nTmpX, nTmpY

		--目标点在第1层, 自己在第2,3层秦始皇房间, 从2层到1层的路径
		if me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR] or 
		 me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR] or 
		 me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.EMPEROR_ROOM] then

			 nTmpX, nTmpY = self:GetTemplatePath(tbPath, 
							self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR],
							self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR],
							nX, nY, nMapId)
		else
			table.insert(tbPath, 1, {nMapId, nX, nY, nMapTemplateId});
		end

		--自己在第3层或秦始皇房间,从3层到2层的路径
		if me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR] or 
		me.nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.EMPEROR_ROOM] then

			nTmpX, nTmpY = self:GetTemplatePath(tbPath, 
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR],
						self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR],
						nTmpX, nTmpY)
		end

	elseif nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_FLOOR] then
		if self:IsNormalMapReduceStayTimeByTemplate(me.nMapTemplateId) then
			return nil
		end

		table.insert(tbPath, 1, {nMapId, nX, nY, nMapTemplateId});
		if not nParam then
			nParam = ImperialTomb:GetNearFemaleEmperorFloorEnterIndex(nX, nY)
		end
	end

	if bInFieldMap then
		--如果在野外地图,或者主城
		local fnCallBack = function ()
			local bEmperor = Calendar:IsActivityInOpenState("ImperialTombEmperor")
			local bFemaleEmperor = false;
			if nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_FLOOR] then
				bFemaleEmperor = Calendar:IsActivityInOpenState("ImperialTombFemaleEmperor")
			end
			
			local ret, msg = self:CheckEnterTomb(me, bEmperor, bFemaleEmperor);

			if ret then
				self:_EnterTombNotify(bEmperor or bFemaleEmperor, nParam)
			else
				me.CenterMsg(msg)
			end
		end

		local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)

		if me.nFightMode == 1 then
			me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
			table.insert(tbPath, 1, {me.nMapId, nX, nY, me.nMapTemplateId, fnCallBack});
		else
			local _,nX, nY = me.GetWorldPos();
			table.insert(tbPath, 1, {me.nMapId, nX, nY, me.nMapTemplateId, fnCallBack});
		end
	end

	return tbPath
end

function ImperialTomb:GetTemplatePath(tbPath, nFromTemplateId, nToTemplateId, nX, nY, nMapId)
	local _, nFromX, nFromY = me.GetWorldPos();
	if me.nMapTemplateId ~= nFromTemplateId  then
		nFromX, nFromY = Map:GetDefaultPos(nFromTemplateId)
	end
	
	local tbTrap = Map:GetNearestTransTrap(nFromTemplateId, nFromX, nFromY, nToTemplateId, nX, nY)
	if not tbTrap then
		return
	end

	if nMapId and nX and nY then
		table.insert(tbPath, 1, {nMapId, nX, nY, nToTemplateId});
	end

	table.insert(tbPath, 1, {tbTrap.nFromMapId, tbTrap.nFromX, tbTrap.nFromY, tbTrap.nFromMapId});

	return  tbTrap.nFromX, tbTrap.nFromY
end

function ImperialTomb:CloseTimer()
	self:CloseStayTimer()

	if self.nSecretStayTimer then
		Timer:Close(self.nSecretStayTimer)
		self.nSecretStayTimer = nil
	end

	if self.nSecretProtectTimer then
		Timer:Close(self.nSecretProtectTimer)
		self.nSecretProtectTimer = nil
	end
end

function ImperialTomb:CloseStayTimer()
	if self.nStayTimer then
		Timer:Close(self.nStayTimer)
		self.nStayTimer = nil
	end

	local pNpc = me.GetNpc();
	if pNpc then
		pNpc.RemoveSkillState(self.STAY_TIME_BUFF);
	end
end

function ImperialTomb:OpenStayTimer(nStayTime)
	if self.nStayTimer then
		Timer:Close(self.nStayTimer)
		self.nStayTimer = nil
	end

	--[[if me.nFightMode == 0 then
		return
	end]]

	if nStayTime > 0 then
		self.nStayTimer = Timer:Register(Env.GAME_FPS * nStayTime, self.OnStayTimer, self);

		local pNpc = me.GetNpc();
		if pNpc then
			pNpc.AddSkillState(self.STAY_TIME_BUFF, 1, 3, nStayTime * Env.GAME_FPS, 1, 1);
		end
	end
end

function ImperialTomb:OnStayTimeChange(nTime, nStayTime)
	self:OpenStayTimer(nStayTime)
	self:RefreshStayTimeNotify(me)
end

function ImperialTomb:OnStayTimer()
	self.nStayTimer = nil

	if not self:IsNormalMapByTemplate(me.nMapTemplateId) then
		return
	end

	RemoteServer.ImperialTombCheckStayTime()
end

function ImperialTomb:OnSecretStayTimer()
	self.nSecretStayTimer = nil

	if not self:IsSecretMapByTemplate(me.nMapTemplateId) then
		return
	end

	RemoteServer.ImperialTombCheckSecretRoomTime()
end

function ImperialTomb:OnSecretProtectTimer()
	self.nSecretProtectTimer = nil

	if not self:IsSecretMapByTemplate(me.nMapTemplateId) then
		return
	end

	RemoteServer.ImperialTombCheckSecretRoomTime()
end

function ImperialTomb:OnSecretSpawnTimer()
	self.nSecretSpawnTimer = nil
end

function ImperialTomb:GetSecretStayTime()
	if not self.nSecretStayTimer then
		return 0
	end

	return math.max(Timer:GetRestTime(self.nSecretStayTimer), 0) / Env.GAME_FPS
end

function ImperialTomb:GetSecretSpawnTime()
	if not self.nSecretSpawnTimer then
		return 0
	end

	return math.max(Timer:GetRestTime(self.nSecretSpawnTimer), 0) / Env.GAME_FPS
end

function ImperialTomb:SyncEmperorTicketState(bStatus)
	self.tbEmperorTikectList = self.tbEmperorTikectList or {}

	self.tbEmperorTikectList[me.dwID] = bStatus
end

function ImperialTomb:BossStatusRequest()
	RemoteServer.ImperialTombBossStatusRequest()
end

function ImperialTomb:OnSyncBossStatus(tbStatus)
	self.tbBossStatus = tbStatus
	UiNotify.OnNotify(UiNotify.emNOTIFY_IMPERIAL_TOMB_BOSS_STATUS)
end

function ImperialTomb:GetBossStatus(nMapType, nIndex)
	if not self.tbBossStatus or 
		not self.tbBossStatus[nMapType] or 
		not self.tbBossStatus[nMapType][nIndex] then

		return self.BOSS_STATUS.NONE
	end

	return self.tbBossStatus[nMapType][nIndex][1], self.tbBossStatus[nMapType][nIndex][2], self.tbBossStatus[nMapType][nIndex][3]
end

function ImperialTomb:GetAutoFightRadius(nMapTemplateId, nMapId)
	return self.AUTO_FIGHT_RADIUS
end

function ImperialTomb:GetBossNameByIndex(nIndex)
	if not nIndex then
		return
	end
	local bFemaleEmperor = Calendar:IsActivityInOpenState("ImperialTombFemaleEmperor")
	local tbBossInfoList = self.BOSS_INFO
	if bFemaleEmperor then
		tbBossInfoList = self.FEMALE_EMPEROR_BOSS_INFO
	end

	local tbBossInfo  = tbBossInfoList[nIndex]
	if not tbBossInfo then
		return
	end
	return KNpc.GetNameByTemplateId(tbBossInfo.nTemplate);
end

function ImperialTomb:GetCurRoomEnterPos()
	if not self.tbEnterPos then
		return
	end

	return unpack(self.tbEnterPos)

	--[[
	local nMapTemplateId = me.nMapTemplateId

	if self:IsEmperorMapByTemplate(nMapTemplateId) then
		return ImperialTomb.MAP_TEMPLATE_ID[ImperialTomb.MAP_TYPE.THIRD_FLOOR],
			ImperialTomb.EMPEROR_ROOM_TRAP_POS[self.nMapParam][1],
			ImperialTomb.EMPEROR_ROOM_TRAP_POS[self.nMapParam][2]
	end

	if self:IsBossMapByTemplate(nMapTemplateId) then

		local nMapType, nNpcIndex = self:GetBossEnterMapByIndex(self.nMapParam)

		return ImperialTomb.MAP_TEMPLATE_ID[nMapType],
			ImperialTomb.BOSS_ROOM_TRAP_POS[nMapType][nNpcIndex][1],
			ImperialTomb.BOSS_ROOM_TRAP_POS[nMapType][nNpcIndex][2]
	end

	if self:IsFemaleEmperorMapByTemplate(nMapTemplateId) then
		return ImperialTomb.MAP_TEMPLATE_ID[ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_FLOOR],
			ImperialTomb.EMPEROR_ROOM_TRAP_POS[self.nMapParam][1],
			ImperialTomb.EMPEROR_ROOM_TRAP_POS[self.nMapParam][2]
	end]]
end

function ImperialTomb:OnStayTimeFull(bFullTime)
	if bFullTime then
		local szNotifyDate = Client:GetFlag("ImperialTomb_FullTime")
		local nToday = Lib:GetLocalDay()
		if szNotifyDate and szNotifyDate == nToday then
			return
		end
		Ui:SetRedPointNotify("ImperialTomb_FullTime")
		Client:SetFlag("ImperialTomb_FullTime", nToday)
	else
		Ui:ClearRedPointNotify("ImperialTomb_FullTime")
	end
end

ImperialTomb:LoadSetting();