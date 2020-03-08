local tbNpc = Npc:GetClass("FubenDialogEvent")

function tbNpc:OnDialog()
	if me.nFightMode == 2 then
		return;
	end
	local szScriptParam = string.gsub(him.szScriptParam, "\"", "")
	local tbRet = Lib:SplitStr(szScriptParam, ",");
	local nTime = tonumber(tbRet[1])
	if not tbRet[3] then
		Log(him.nTemplateId, debug.traceback())
	end

	local szEvent, szParam = tbRet[3], tbRet[4]
	if not Fuben:NpcRaiseEventCheck(him, szEvent, me, szParam) then
		return
	end

	if not nTime then
		self:EndProcess(me.dwID, him.nId);
	else
		if not MODULE_GAMECLIENT then
			me.AddSkillState(2783, 1, 0, 1)
		end
		local szMsg = tbRet[2] or "开启中...";
		GeneralProcess:StartProcessUniq(me, nTime * Env.GAME_FPS, him.nId, szMsg, self.EndProcess, self, me.dwID, him.nId, szEvent, szParam);
	end
end

function tbNpc:EndProcess(nPlayerId, nNpcId, szEvent, szParam)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("not player ??")
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		pPlayer.CenterMsg("该目标已消失")
		return;
 	end
 	if pPlayer.nFightMode == 2 then
 		pPlayer.CenterMsg("您已死亡")
		return;
	end
	Fuben:NpcRaiseEvent(pNpc, szEvent, pPlayer, szParam) --在事件里删
end
