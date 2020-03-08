
-- 手动重载会重置

local RepresentMgr = luanet.import_type("RepresentMgr");
ArenaBattle.tbArenaData = {}
ArenaBattle.tbApply = {}
ArenaBattle.tbWatchData = {}
ArenaBattle.nWatchNpcId = ArenaBattle.nWatchNpcId or 0
ArenaBattle.nWatchArenaId = 0
ArenaBattle.tbArenaState = {}

-- 擂主的申请者数据
function ArenaBattle:OnSynChallengerData(tbData)
	ArenaBattle.tbApplyData = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_APPLY_DATA)
end

-- 各擂台擂主信息
function ArenaBattle:OnSynArenaData(tbData)
	ArenaBattle.tbArenaData = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_DATA)
end

-- 已申请擂台挑战的数据
function ArenaBattle:OnSynApplyData(tbData)
	ArenaBattle.tbApply = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_PLAYER_APPLY_ARENA_DATA,"ArenaBattle",{ChallengeInfo = ArenaBattle.tbApply})
end

-- 同步我的已申请擂台挑战的数据
function ArenaBattle:SynMyApplyData()
	RemoteServer.SynMyApplyData();
end

-- 同步擂主的申请者信息
function ArenaBattle:SynChallengerData()
	RemoteServer.SynChallengerData();
end

-- 同步擂台擂主信息
function ArenaBattle:SynArenaData()
	RemoteServer.SynArenaData();
end

-- 申请挑战
function ArenaBattle:ApplyChallenge(nArenaId)

	if not ArenaBattle:CheckIsArenaBattleMap() then
		me.CenterMsg("请前往比武场再进行挑战")
		return 
	end

	if TeamMgr:HasTeam() and not TeamMgr:IsCaptain() then
		me.CenterMsg("队长才可以申请上擂台或挑战")
		return
	end

	RemoteServer.ApplyChallenge(nArenaId);
end

-- 手动挑选挑战者
function ArenaBattle:PickChallenger(tbData)

	if not ArenaBattle:CheckIsArenaBattleMap() then
		me.CenterMsg("请前往比武场再进行选择挑战者")
		return 
	end

	if TeamMgr:HasTeam() and not TeamMgr:IsCaptain() then
		me.CenterMsg("擂主队伍队长才可挑选挑战者")
		return
	end

	RemoteServer.ArenaChallenge(tbData);
end

function ArenaBattle:GetArenaData()
	return self.tbArenaData
end

function ArenaBattle:GetApplyData()
	return self.tbApplyData
end

-- 状态切换回调
function ArenaBattle:SyncFightState(nTime)
	Ui:OpenWindow("ArenaBattleInfo",nTime)
	Timer:Register(Env.GAME_FPS, function () UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_TIME_DATA, nTime); end)
end

function ArenaBattle:SyncPlayerLeftInfo(nMyCampId, tbDmgInfo)
	local nOtherCampId = 3 - nMyCampId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_DMAGE_DATA,
						tbDmgInfo[nMyCampId].nKillCount,
						tbDmgInfo[nOtherCampId].nKillCount,
						tbDmgInfo[nMyCampId].nTotalDmg,
						tbDmgInfo[nOtherCampId].nTotalDmg,
						tbDmgInfo.szStateInfo);
end

function ArenaBattle:OnLogin()
	if me.nMapTemplateId ~= ArenaBattle.nArenaMapId then
		return
	end
	self:OnMainState()
	self:RefreshArenaState()
	ArenaBattle:SynMyApplyData()
end

function ArenaBattle:OnMainState()
	self:EndWatch(nil)
	Ui:OpenWindow("ArenaChallengerInfoPanel","ArenaBattle",{ChallengeInfo = ArenaBattle.tbApply})

	Ui:ChangeUiState(Ui.STATE_ArenaBattleMain,true);
end

function ArenaBattle:OnConnectLost()
	self:DoEndWatch()
end

function ArenaBattle:OnMapEnter(nTemplateID)
	if nTemplateID ~= ArenaBattle.nArenaMapId then
		return 
	end
	self:OnMainState()
	self:RefreshArenaState()
	self:SynMyApplyData()
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self.OnConnectLost, self)
end

function ArenaBattle:OnMapLeave(nTemplateID)
	if nTemplateID ~= ArenaBattle.nArenaMapId then
		return 
	end
	Ui:CloseWindow("QYHLeavePanel")
	Ui:CloseWindow("ArenaChallengerInfoPanel")
	Ui:CloseWindow("ArenaPanel")
	Ui:CloseWindow("ChallengerPanel")
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self)
	Ui:DestroyLoadShowUi()
end

-- 上擂台回调
function ArenaBattle:Go2Arena()
	self:DoEndWatch()
	Ui:CloseWindow("WatchMenuPanel")
	Ui:CloseWindow("RoleHeadPop");
	Ui:CloseWindow("WelfareActivity");
	Ui:CloseWindow("CalendarPanel");
	Ui:CloseWindow("StrongerPanel");
	Ui:CloseWindow("NewInformationPanel");
	Ui:CloseWindow("HomeScreenCommunity");
end

-- 直接上台成为擂主时回调
function ArenaBattle:TurnArenaManDirect()
	self:WaitingState()
end

-- 玩家离开擂台时回调
function ArenaBattle:OnPlayerLeave()
	Ui:CloseWindow("ArenaBattleInfo")
	Ui:OpenWindow("ArenaChallengerInfoPanel","ArenaBattle",{ChallengeInfo = ArenaBattle.tbApply})
	Ui:CloseWindow("HomeScreenBattleInfo")
	Ui:CloseWindow("RoleHeadPop");
	Ui:CloseWindow("ChallengerPanel")
	Ui:ChangeUiState(Ui.STATE_ArenaBattleMain,true)
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"ArenaBattle",{"BtnLeave","BtnWitnessWar","BtnChallenge"})
end

-- 开始进入流程显示对战信息回调
function ArenaBattle:OnShowTeamInfo(nCampId, tbCampInfo,nWinCamp)
	Ui:OpenWindow("ArenaAccount",nCampId,tbCampInfo,nWinCamp);
	self:FightingState()
end

function ArenaBattle:OnFightingState(nTime)
	self:FightingState()
	self:SyncFightState(nTime)
end

-- 等待挑选挑战者状态
function ArenaBattle:WaitingChooseState(nTime)
	self:WaitingState()
	Ui:OpenWindow("ArenaChallengerInfoPanel","ArenaBattle",{["ChallengeTitle"] = {szText = "请选择挑战者：",nTime = nTime}})
	Timer:Register(Env.GAME_FPS, function () UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN_TEXIAO,{"BtnChallenge"},true); end)
end

-- 等待挑战者状态
function ArenaBattle:WaitingState()
	if Ui.nChangeUiState ~= Ui.STATE_ArenaBattleWait then
		Ui:ChangeUiState(Ui.STATE_ArenaBattleWait)
	end
	Ui:CloseWindow("ArenaChallengerInfoPanel")
	Ui:CloseWindow("ArenaPanel")
	Ui:CloseWindow("ArenaBattleInfo")
	Ui:CloseWindow("RoleHeadPop");
	Ui:OpenWindow("QYHLeavePanel","ArenaBattle",{BtnLeave=true,BtnChallenge=true})
	Ui:SetLoadShowUI({nMapTID = ArenaBattle.nArenaMapId, tbUi = {["BattleTopButton"] = 1}}) 				-- 单独的背包按钮
end

-- 战斗状态
function ArenaBattle:FightingState()
	Ui:ChangeUiState(Ui.STATE_ArenaBattleFight)
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"ArenaBattle",{"BtnLeave","BtnWitnessWar","BtnChallenge"})
	Ui:CloseWindow("ArenaPanel")
	Ui:CloseWindow("ArenaChallengerInfoPanel")
	Ui:CloseWindow("ChallengerPanel")
	Ui:CloseWindow("RoleHeadPop");
end

function ArenaBattle:OnWaitingState()
	self:WaitingState()
	Ui:OpenWindow("ArenaChallengerInfoPanel","ArenaBattle",{["ChallengeTitle"] = {szText = "等待挑战者..."}})
	Timer:Register(Env.GAME_FPS, function () UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN_TEXIAO,{"BtnChallenge"}); end)
end

-- 玩家死亡回调
function ArenaBattle:OnPlayerDeath()
	Ui:CloseWindow("HomeScreenBattleInfo")
end

function ArenaBattle:OnSynArenaState(nArenaId,bState)
	if not nArenaId then
		return
	end
	ArenaBattle.tbArenaState[nArenaId] = bState
end

function ArenaBattle:CheckWatchArenaIsFighting()
	return self.tbArenaState[self.nWatchArenaId]
end

function ArenaBattle:RefreshArenaState()
	RemoteServer.RefreshArenaState();
end

-- 刷新各擂台状态
function ArenaBattle:OnRefreshArenaState(tbFightingArena)
	ArenaBattle.tbArenaState = {}
	for _,nArenaId in ipairs(tbFightingArena) do
		ArenaBattle.tbArenaState[nArenaId] = true
	end
end

function ArenaBattle:ForceStopWatch()
	self:DoEndWatch()
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"ArenaBattle",{"BtnLeave","BtnWitnessWar","BtnChallenge"})
	Ui:CloseWindow("WatchMenuPanel")
end

function ArenaBattle:CheckIsArenaBattleMap()
	if me.nMapTemplateId == ArenaBattle.nArenaMapId then
        return true
    end
end

function ArenaBattle:SendResultTip(szTip)
	if szTip and szTip ~= "" then
		me.Msg(szTip)
		local nNpcId = AutoAI.GetNpcIdByTemplateId(ArenaBattle.nArenaManagerNpcId)
		if nNpcId then
			local pNpc = KNpc.GetById(nNpcId)
			if pNpc then
				pNpc.BubbleTalk(szTip, ArenaBattle.szArenaManagerNpcBubbleTalkTime);
			end
		end
	end
end

function ArenaBattle:OnNoFightingEnterMap()
	Ui:CloseWindow("HomeScreenBattleInfo")
	Ui:CloseWindow("ArenaBattleInfo")
	Ui:CloseWindow("ArenaAccount")
	Ui:CloseWindow("WatchMenuPanel")
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"ArenaBattle",{"BtnLeave","BtnWitnessWar","BtnChallenge"})
end

function ArenaBattle:ShowComboKillCount(nComboCount, bNotHide)
	Ui:OpenWindow("HomeScreenBattleInfo",nil,nil,nComboCount,bNotHide);
end

function ArenaBattle:OnAutoChooseStop()
	self:OnWaitingState()
end

------------------------------------------------------------------------------------------------

--[[
	tbData = {
		[nArenaId] = 
		{
			[ArenaBattle.tbForeachType.ARENA_MAN] = {[1] = {szName,nNpcId},...}	
			[ArenaBattle.tbForeachType.CHALLENGER] = {[1] = {szName,nNpcId},...}	
		}
	}
]]


function ArenaBattle:SyncWatchInfo(tbData,nArenaId)
	ArenaBattle.tbWatchData = tbData
	self.nWatchArenaId = nArenaId

	self:AddShowRepNpc()
	-- trap in的时候打开观战按钮
	Ui:OpenWindow("QYHLeavePanel","ArenaBattle",{BtnWitnessWar = true})
end

function ArenaBattle:OnWatchTrapOut()
	RepresentMgr.ClearShowRepNpc()
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"ArenaBattle",{"BtnWitnessWar"})
end

function ArenaBattle:AddShowRepNpc()
	local tbPlayerData = self.nWatchArenaId and ArenaBattle.tbWatchData[self.nWatchArenaId]
	if not tbPlayerData then
		return tbData
	end
	for nCamp,tbPlayer in ipairs(tbPlayerData) do
		for _,tbPlayerInfo in ipairs(tbPlayer) do
			if tbPlayerInfo[2] then
				RepresentMgr.AddShowRepNpc(tbPlayerInfo[2])
			end
		end
	end
end

function ArenaBattle:StartWatch(nNpcId)
	if not self:CheckWatchArenaIsFighting() then
		me.CenterMsg("该擂台已经结束或者阵容改变")
		return
	end
	Operation:DisableWalking()
	Ui:ChangeUiState(Ui.STATE_WATCH_FIGHT)
	BindCameraToNpc(nNpcId, 220)
	self.nWatchNpcId = nNpcId

	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH,self:GetWatchData())
	return true
end

function ArenaBattle:GetWatchData()
	local tbData = {}

	local tbPlayerData = self.nWatchArenaId and ArenaBattle.tbWatchData[self.nWatchArenaId]
	if not tbPlayerData then
		return tbData
	end

	local tbWatch = {}
	for nCamp,tbPlayer in ipairs(tbPlayerData) do
		tbWatch[nCamp] = {}
		for _,tbPlayerInfo in ipairs(tbPlayer) do
			table.insert(tbWatch[nCamp],{name = tbPlayerInfo[1],id = tbPlayerInfo[2]})
		end
	end
	
	tbData = {
		nCurWatchId = ArenaBattle.nWatchNpcId,
		szType = "ArenaBattleWatch",
		tbPlayer = tbWatch,
	}

	return tbData
end

function ArenaBattle:EndWatch(nNpcId, keepBtn)
	if nNpcId and nNpcId ~= self.nWatchNpcId then
		return
	end
	if not keepBtn then
		-- 关闭观战按钮
		UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"ArenaBattle",{"BtnWitnessWar"})
	end
	self:DoEndWatch()
end

function ArenaBattle:DoEndWatch()
	if not self.nWatchNpcId or self.nWatchNpcId<=0 then
		return
	end

	BindCameraToNpc(0, 0)
	Ui:ChangeUiState(Ui.STATE_ArenaBattleMain, true)
	self.nWatchNpcId = 0
	Operation:EnableWalking()

	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH,self:GetWatchData())
end

function ArenaBattle:SynAllWatchingState(nNpcId)
	if nNpcId and nNpcId == self.nWatchNpcId then
		self:EndWatch(nNpcId, true)
		me.CenterMsg("您观战的玩家已经死亡或者掉线，请选择其他玩家进行观战",true)
	else
		UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH,self:GetWatchData())
	end
end

