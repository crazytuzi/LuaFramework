local tbNpc = Npc:GetClass("KinDefendPickNpc")

function tbNpc:OnCreate(szParam)
	if not Fuben.KinDefendMgr:IsDefendMap(him.nMapTemplateId) then
		return
	end
	local tbFubenInst = Fuben.tbFubenInstance[him.nMapId]
    if not tbFubenInst then
    	return
    end
	 if not tbFubenInst:CanRebornNpc(him.nTemplateId) then
    	Log("KinDefendPickNpc:OnCreate delete", him.nTemplateId, him.nMapTemplateId)
		him.Delete()
	end
end

function tbNpc:OnDialog(szParam)
	GeneralProcess:StartProcessUniq(me, 6 * Env.GAME_FPS, him.nId, "采集中...", self.EndProcess, self, me.dwID, him.nId)
end

function tbNpc:EndProcess(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return
	end

	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc or pNpc.IsDelayDelete() then
		Dialog:CenterMsg(pPlayer, "已被其他人抢先采走啦")
		return
 	end

 	local szTip = string.format("%s+1", pNpc.szName)
 	Dialog:SendBlackBoardMsg(pPlayer, szTip)
	Fuben:OnKillNpc(pNpc, pPlayer)
	pNpc.DoDeath()
end