Task.__AsyncBattle = Task.__AsyncBattle or {}
local tbBattle     = Task.__AsyncBattle
tbBattle.tbSafe    = {
	[9002] ={2017, 2557},
}

function tbBattle:CheckCanEnter(pPlayer, nMapTID)
	if not self.tbSafe[nMapTID] then
		return false, "不能由此进去地图"
	end
	-- if not AsyncBattle:CanStartAsyncBattle(pPlayer) then
	-- 	return false, "请在安全区域下参与活动"
	-- end
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
		return false, "当前状态不允许切换地图"
	end
	local pPlayerNpc = pPlayer.GetNpc()
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill)
	if nResult == 0 then
		return false, "当前状态不能参加";
	end
	return true
end

function tbBattle:TryEnter(pPlayer, nMapTID, nRestrainType)
	local bRet, szMsg = self:CheckCanEnter(pPlayer, nMapTID)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	if MODULE_GAMESERVER then
		if pPlayer.dwTeamID > 0 then
			TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID)
		end
		AsyncBattle:CreateClientAsyncBattle(pPlayer, nMapTID, self.tbSafe[nMapTID], "Task_AsyncBattle_Fuben", nRestrainType, GetTime())
	else
		RemoteServer.TryCreateAsyncBattle(nMapTID, nRestrainType)
	end

end