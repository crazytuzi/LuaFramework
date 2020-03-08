local tbTaskNpc = Npc:GetClass("TaskNpc");

function tbTaskNpc:OnDialog()
	local szParam = string.gsub(him.szScriptParam, "\"", "");
	local tbRet = Lib:SplitStr(szParam, "|");
	local nTaskId = tonumber(tbRet[1])
	local nTime = tonumber(tbRet[2]);
	if not nTaskId or not nTime then
		return;
	end

	local tbPlayerTask = Task:GetPlayerTaskInfo(me, nTaskId);
	if not tbPlayerTask then
		return;
	end

	him.nTaskId = nTaskId;

	local szMsg = tbRet[3] or "检查中...";
	GeneralProcess:StartProcessUniq(me, nTime * Env.GAME_FPS, him.nId, szMsg, self.EndProcess, self, me.dwID, him.nId);
end

function tbTaskNpc:EndProcess(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or not pNpc.nTaskId then
		return;
	end

	Task:DoAddExtPoint(pPlayer, pNpc.nTaskId);
end

