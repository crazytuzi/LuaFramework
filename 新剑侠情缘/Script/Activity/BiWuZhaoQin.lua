BiWuZhaoQin.tbFinalData = {}

--[[
	 tbData.nFinalRound = nFinalRound
     tbData.tbPlayer = {
     [nFinalRound] = {[dwID] = GetTime()},
     [nRound] = {[dwID] = GetTime()},
     }
     tbData.tbFinalPlayer = {[dwID] = {nSeq = nSeq,...}}

	不一定是顺序表，8强进4强的时候有人弃权可以直接到2强
     BiWuZhaoQin.tbFinalData = 
     {
		[1] = {8强顺序表},
		[2] = {4强顺序表},
		[3] = {2强顺序表},
		[4] = {1强顺序表},
     }
]]

function BiWuZhaoQin:OnSynFinalData(tbData)
	BiWuZhaoQin.tbFinalData = {}
	if tbData and next(tbData) then
		BiWuZhaoQin.tbFinalData = self:FormatFinalData(tbData)
	end
end

function BiWuZhaoQin:FormatFinalData(tbData)
	local tbFinalData = {}
	local tbRoundPlayer = tbData.tbPlayer
	local tbFinalPlayer = tbData.tbFinalPlayer or {}
	local nFinalRound = tbData.nFinalRound
	
	local function fnSort(a,b)
		return a.nSeq < b.nSeq
	end

	for nRound,tbPlayer in pairs(tbRoundPlayer) do
		local nCount = Lib:CountTB(tbPlayer)
		local nPos = 0
		if nCount == 1 then
			nPos = 4
		elseif nCount <= 2 then
			nPos = 3
		elseif nCount <= 4 then
			nPos = 2
		elseif nCount <= 8 then
			nPos = 1
		end
		if nPos > 0 then
			tbFinalData[nPos] = {}
			for dwID,_ in pairs(tbPlayer) do
				local tbPlayerInfo = tbFinalPlayer[dwID]
				if tbPlayerInfo then
					table.insert(tbFinalData[nPos],tbPlayerInfo)
				end
			end
			if #tbFinalData[nPos] >= 2 then
				table.sort(tbFinalData[nPos],fnSort)
			end
			if nRound == nFinalRound and nCount % 2 > 0 and nCount ~= 1 then
				-- 伪造假数据制造空位
				table.insert(tbFinalData[nPos],1,{})
			end
		end
	end
	return tbFinalData
end

function BiWuZhaoQin:GetFinalData()
	return BiWuZhaoQin.tbFinalData
end

function BiWuZhaoQin:OnShowTeamInfo(nCampId, tbCampInfo,nWinCamp)
	Ui:OpenWindow("ArenaAccount",nCampId,tbCampInfo,nWinCamp);
end

function BiWuZhaoQin:SyncPlayerLeftInfo(nMyCampId, tbDmgInfo)
	local nOtherCampId = 3 - nMyCampId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_DMAGE_DATA,
						tbDmgInfo[nMyCampId].nKillCount,
						tbDmgInfo[nOtherCampId].nKillCount,
						tbDmgInfo[nMyCampId].nTotalDmg,
						tbDmgInfo[nOtherCampId].nTotalDmg,
						tbDmgInfo.szStateInfo);
end

function BiWuZhaoQin:SyncFightState(nTime)
	Ui:OpenWindow("ArenaBattleInfo",nTime)
	Timer:Register(Env.GAME_FPS, function () UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_TIME_DATA, nTime); end)
end

function BiWuZhaoQin:OnFightingState(nTime)
	self:FightingState()
	self:SyncFightState(nTime)
end

-- 战斗状态
function BiWuZhaoQin:FightingState()
	Ui:CloseWindow("RoleHeadPop");
end

-- 上台
function BiWuZhaoQin:OnEnterFightMap()
	Ui:CloseWindow("QYHLeavePanel")
	Ui:CloseWindow("QYHLeftInfo")
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"BiWuZhaoQin",{"BtnWitnessWar"})
end

-- 进入预备场
function BiWuZhaoQin:SynPreMapState(nTime, nType, nProcess, nFightState)
	local szProgress = BiWuZhaoQin.tbProcessDes[nProcess] or BiWuZhaoQin.szProcessEndDes
	local tbMatchSetting = BiWuZhaoQin.tbMatchSetting[nType]
	if tbMatchSetting then
		Ui:OpenWindow("QYHLeftInfo", tbMatchSetting.szUiKey, {szProgress, nTime or 0, BiWuZhaoQin.tbFightStateDes[nFightState] or "-"})
	else
		Ui:OpenWindow("QYHLeftInfo", "BiWuZhaoQinEnd", {szProgress})
	end
	Map:SetCloseUiOnLeave(me.nMapId, "QYHLeavePanel")
	Ui:CloseWindow("RoleHeadPop")
end

-- 离开擂台
function BiWuZhaoQin:OnLeaveArena()
	Ui:CloseWindow("ArenaBattleInfo")
end

-- 离开客户端预备场地图回调
function BiWuZhaoQin:OnClientMapLeave(nTemplateID)
	if nTemplateID ~= BiWuZhaoQin.nPreMapTID then
		return
	end
	BiWuZhaoQin.tbFinalData = {}
	Ui:CloseWindow("QYHLeavePanel")
	Ui:CloseWindow("QYHLeftInfo")
	Ui:CloseWindow("ArenaBattleInfo")
	Ui:CloseWindow("ArenaAccount")
	Ui:CloseWindow("FightTablePanel")
end

function BiWuZhaoQin:OnUsePlaceItem(nNpcId)
	if nNpcId then
		local nMapTID = me.nMapTemplateId == 15 and 15 or 10
		Ui.HyperTextHandle:Handle(string.format("[url=npc:招亲, %d, %d]", nNpcId, nMapTID), 0, 0)
	end
	Ui:CloseWindow("ItemTips")
	Ui:CloseWindow("ItemBox")
end
