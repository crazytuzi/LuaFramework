
--门派竞技
local RepresentMgr = luanet.import_type("RepresentMgr");

Require("CommonScript/FactionBattle/FactionBattleDef.lua")

FactionBattle.tb16thPlayer = FactionBattle.tb16thPlayer or {}
FactionBattle.nSession = FactionBattle.nSession or 0
FactionBattle.tbWinnerInfo = FactionBattle.tbWinnerInfo or {}
FactionBattle.nWatchNpcId = FactionBattle.nWatchNpcId or 0
FactionBattle.tbWatchInfo = FactionBattle.tbWatchInfo or {}

-------------------------------------------------------------------

function FactionBattle:Join()
	if not Calendar:IsActivityInOpenState("FactionBattle") then
		me.SendBlackBoardMsg(XT("活动尚未开启"), true)
		return
	end
	self.tb16thPlayer = {}
	RemoteServer.FactionBattleTryJoin()
end

function FactionBattle:OnTrapIn()
	self.tb16thPlayer = {}
end

function FactionBattle:OnEnter()
	if self.bEnter then
		return
	end
	self.bEnter = true
	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap, self)
	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveMap, self)
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self.OnConnectLost, self)
	Ui:ChangeUiState(Ui.STATE_FACTION_BATTLE, false)
end

function FactionBattle:OnLeave()
	if not self.bEnter then
		return
	end
	self.bEnter = false
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self)

	self:EndWatch()
	RepresentMgr.ClearShowRepNpc()
	Ui:ChangeUiState(0, true)
	if Ui:WindowVisible("FactionReportPanel") then
		Ui:CloseWindow("FactionReportPanel")
	end
	if Ui:WindowVisible("FactionBattlePanel") then
		Ui:CloseWindow("FactionBattlePanel")
	end
	if Ui:WindowVisible("QYHLeftInfo") then
		Ui:CloseWindow("QYHLeftInfo")
	end

	if Ui:WindowVisible("QYHLeavePanel") then
		Ui:CloseWindow("QYHLeavePanel")
	end
end

function FactionBattle:OnEnterMap(nMapTemplateId)
	if nMapTemplateId ~= FactionBattle.PREPARE_MAP_TAMPLATE_ID and
	nMapTemplateId ~= FactionBattle.FREEPK_MAP_TAMPLATE_ID then

	 	self:OnLeave()
	end

	if nMapTemplateId == FactionBattle.PREPARE_MAP_TAMPLATE_ID or
	nMapTemplateId == FactionBattle.FREEPK_MAP_TAMPLATE_ID then
		Ui:ChangeUiState(Ui.STATE_FACTION_BATTLE, false)
	end
end

function FactionBattle:OnLeaveMap(nMapTemplateId)

end

function FactionBattle:OnConnectLost()
	self:DoEndWatch()
end

function FactionBattle:OnSyncLeftInfo(szType, tbParam)
	if not self.bEnter then
		return
	end

	if not Ui:WindowVisible("QYHLeftInfo") then
		Ui:OpenWindow("QYHLeftInfo", szType, tbParam)
	else
		Ui("QYHLeftInfo"):UpdateInfo(tbParam, szType);
	end
end

function FactionBattle:Is16thDataReady()
	return self.bEnter and self.tb16thPlayer and next(self.tb16thPlayer)
end

function FactionBattle:OnSync16thInfo(tb16thPlayer)
	self.tb16thPlayer = tb16thPlayer

	if not self.bEnter then
		return
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_FACTION_TOP_CHANGE)
end

function FactionBattle:OnWatchTrapOut()
	RepresentMgr.ClearShowRepNpc()
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"FactionBattle",{"BtnWitnessWar"})
end

function FactionBattle:OnSyncWatchInfo(tbPlayer1, tbPlayer2)
	if not self.bEnter then
		return
	end

	local pid1 = tbPlayer1[2]
	local pid2 = tbPlayer2[2]
	self.tbWatchInfo.players = {
		[1] = {name=tbPlayer1[1], id=pid1},
		[2] = {name=tbPlayer2[1], id=pid2},
	}
	RepresentMgr.AddShowRepNpc(pid1)
	RepresentMgr.AddShowRepNpc(pid2)

	if Ui:WindowVisible("QYHLeavePanel") then
		UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"FactionBattle",{"BtnWitnessWar"},true)
	else
		Ui:OpenWindow("QYHLeavePanel","FactionBattle",{BtnWitnessWar = true})
	end
end

function FactionBattle:EndWatch(nNpcId, keepBtn)
	local bCanEndWatch = not nNpcId
	if nNpcId then
		for _, tb in ipairs(self.tbWatchInfo.players or {}) do
			if nNpcId==tb.id then
				bCanEndWatch = true
				break
			end
		end
	end
	if not bCanEndWatch then
		return
	end
	if not keepBtn then
		UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"FactionBattle",{"BtnWitnessWar"})
		Ui:CloseWindow("WatchMenuPanel")
	end
	self:DoEndWatch()
end

function FactionBattle:DoEndWatch()
	if not self.nWatchNpcId or self.nWatchNpcId<=0 then
		return
	end

	BindCameraToNpc(0, 0)
	Ui:ChangeUiState(Ui.STATE_FACTION_BATTLE, false)
	self.nWatchNpcId = 0
	Operation:EnableWalking()

	if Ui:WindowVisible("QYHLeftInfo") then
		Ui("QYHLeftInfo"):UpdateLeavePanel()
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH,self:GetWatchData())
end

function FactionBattle:StartWatch(nNpcId)
	Operation:DisableWalking()
	Ui:ChangeUiState(Ui.STATE_WATCH_FIGHT)
	BindCameraToNpc(nNpcId, 220)
	self.nWatchNpcId = nNpcId

	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH,self:GetWatchData())
end

function FactionBattle:OnEliminationStart(nNextStateTime)
	self:DoEndWatch()
	Ui:CloseWindow("QYHLeftInfo")
	Ui:CloseWindow("FactionReportPanel")
	Ui:OpenWindow("QYHbattleInfo", nNextStateTime)
	Ui:OpenWindow("ReadyGo")
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"FactionBattle",{"BtnWitnessWar"})
end

function FactionBattle:GetWatchData()
	local tbWatch = {}
	tbWatch[1] = {FactionBattle.tbWatchInfo.players[1] or {}}
	tbWatch[2] = {FactionBattle.tbWatchInfo.players[2] or {}}

	local tbData = {
		nCurWatchId = FactionBattle.nWatchNpcId,
		szType = "FactionBattleWatch",
		tbPlayer = tbWatch,
	}

	return tbData
end

function FactionBattle:IsCanStart()
	if KinEncounter:IsOpenToday() then
		return false
	end
	--如果华山论剑活动开启，关闭周四的场次
	return not ((HuaShanLunJian:IsOpenPreGameUi() or HuaShanLunJian:IsOpenFinalsGameUi() or QunYingHuiCross:CheckOpen()) and Lib:GetLocalWeekDay() == 4)
end

function FactionBattle:SyncJoinMonthBattle(bCanJoin )
	self.bCanJoinMonthBattle = bCanJoin
end

function FactionBattle:SyncJoinSeasonBattle(bCanJoin)
	self.bCanJoinSeasonBattle = bCanJoin
end

function FactionBattle:IsCanJoinMonthBattle()
	return self.bCanJoinMonthBattle;
end

function FactionBattle:IsCanJoinSeasonBattle()
	return self.bCanJoinSeasonBattle;
end
