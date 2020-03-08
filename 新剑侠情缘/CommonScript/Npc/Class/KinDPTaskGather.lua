local tbNpc = Npc:GetClass("KinDPTaskGather")

function tbNpc:OnCreate(szParam)
	local bMature, nMatureId, nUnMatureId = KinDinnerParty:ResolveGatherParam(szParam);
	self.tbMatureTime = self.tbMatureTime or {};
	if not bMature then
		local nMatureTime = KinDinnerParty:GetRefreshInterval(nMatureId);
		self.tbMatureTime[him.nId] = GetTime() + nMatureTime;
		Timer:Register(Env.GAME_FPS * nMatureTime, self.EnterMature, self, him.nId, nMatureId);
	end
end

function tbNpc:EnterMature(nNpcId, nMatureId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or pNpc.IsDelayDelete() then
		Log("[KinDinnerParty EnterMature Fail], Npc Is Nil", nNpcId, nMatureId)
		return
	end

	local nMapID, nX, nY = pNpc.GetWorldPos();
	KNpc.Add(nMatureId, 1, 0, nMapID, nX, nY, 0, pNpc.GetDir());
	pNpc.Delete();
	self.tbMatureTime[pNpc.nId] = nil;
end

function tbNpc:OnDialog(szParam)
	local bMature, nMatureId, nUnMatureId = KinDinnerParty:ResolveGatherParam(szParam);
	if not KinDinnerParty:GatherThingInTask(me, nMatureId) then
		me.CenterMsg("没有该采集物的任务")
		return;
	end
	
	if bMature then
		GeneralProcess:StartProcessUniq(me, 6 * Env.GAME_FPS, him.nId, "采集中...", self.EndProcess, self, me.dwID, him.nId, nMatureId, nUnMatureId);
	else
		local nMatureTime = self.tbMatureTime[him.nId] or (KinDinnerParty:GetRefreshInterval(nMatureId) + GetTime())
		local nSurviveSec = nMatureTime - GetTime();
		nSurviveSec = math.max(nSurviveSec, 1)
		local szTip = string.format("%d分钟后成熟",  math.ceil(nSurviveSec / 60));
		me.CenterMsg(szTip);
	end
end

function tbNpc:EndProcess(nPlayerId, nNpcId, nMatureId, nUnMatureId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or pNpc.IsDelayDelete() then
		Dialog:CenterMsg(pPlayer, "已被其他人抢先采走啦");
		return;
 	end

	--采集完成 	
	local nMapID, nX, nY = pNpc.GetWorldPos();

	KNpc.Add(nUnMatureId, 1, 0, nMapID, nX, nY, 0, pNpc.GetDir());
	pNpc.Delete();
	self.tbMatureTime[pNpc.nId] = nil;

 	local szTip = string.format("%s+1", pNpc.szName);
 	Dialog:SendBlackBoardMsg(pPlayer, szTip);

 	local bFinish = KinDinnerParty:AddGatherTing(pPlayer, nMatureId);
 	KinDinnerParty:SyncTask(pPlayer);
 	if bFinish then
 		pPlayer.CallClientScript("Ui:OpenWindow", "KinDPTaskPanel");
 	end
end