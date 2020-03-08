local tbNpc = Npc:GetClass("FubenDialog")

function tbNpc:OnDialog()
	local tbRet = Lib:SplitStr(him.szScriptParam, ",");
	local nTime = tonumber(tbRet[1])
	
	--if me.nFightState ~= 1 then
	--	--Dialog:CenterMsg(me, "您在休整中，不能参与。");
	--	return;
	--end
	if me.nFightMode == 2 then
		return;
	end
	
	if Fuben:IsInLock(him) ~= 1 then
		return;
	end
	
	if not nTime then
		self:EndProcess(me.dwID, him.nId);
	else
		local szMsg = tbRet[2] or "开启中...";
		GeneralProcess:StartProcessUniq(me, nTime * Env.GAME_FPS, him.nId, szMsg, self.EndProcess, self, me.dwID, him.nId, tbRet[3]);
	end
end

function tbNpc:EndProcess(nPlayerId, nNpcId, szMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("not player ??")
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		Log("not npc ??")
		return;
 	end
 	Fuben:NpcUnLock(pNpc);
 	pNpc.Delete();
 	if szMsg then
 		Dialog:SendBlackBoardMsg(me, szMsg);
 	end

 	if pPlayer.nMapTemplateId == Fuben.KinSecretMgr.Def.nMapTemplateId then
 		local tbFubenInst = Fuben.tbFubenInstance[pPlayer.nMapId]
 		if tbFubenInst then
 			tbFubenInst:OnOpenRewardBox(pPlayer)
 		end
 	end
end
