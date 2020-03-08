local szClass             = "Task_AsyncBattle_Fuben"
local tbBase              = AsyncBattle:CreateClass(szClass)
tbBase.PLAYER_STATE_SKILL = 1064		-- 无敌、不可移动
tbBase.TIME_OUT           = 600
tbBase.tbPos              = {2019, 1777}
tbBase.tbNpc              = {
	{3261, 3262, 3263, 3264},
	{3265, 3266, 3267, 3268},
	{3269, 3270, 3271},
	{3272, 3273, 3274},
	{3275, 3276, 3277},
}
function tbBase:Init(dwID, nRestrainType, nMapTID)
	self.nMapTemplateId = nMapTID
	self.nRestrainType  = nRestrainType
	self.nCloseTimer    = Timer:Register(Env.GAME_FPS * self.TIME_OUT, self.OnTimeOut, self)
	self.bHadStart      = false
end

function tbBase:OnTimeOut()
	self.nCloseTimer = nil
	self:End()
end

function tbBase:Client_OnMapLoaded()
	for nMapId, tbInst in pairs(AsyncBattle.tbBattleList) do
		if tbInst.szClassType == szClass then
			tbInst:Start()
		end
	end
end

function tbBase:OnEnterMap()
end

function tbBase:Start()
	if self.nStartTimer then
		return
	end

	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.AddSkillState(self.PLAYER_STATE_SKILL, 1, 0, Env.GAME_FPS * self.TIME_OUT);
		pNpc.SetPkMode(3, 1)
		pNpc.SetHideNpc(1)
	end

	local pAsync = KPlayer.GetAsyncData(me.dwID)
	local nMapId, nPosX, nPosY = me.GetWorldPos()
	local pNpc = pAsync.AddAsyncNpc(nMapId, nPosX, nPosY)
	pNpc.nFightMode = 0
	pNpc.SetDir(35)
	self.nPlayerNpcId = pNpc.nId
	Npc:RegNpcOnDeath(pNpc, self.OnPlayerDeath, self)

	me.SetDefaultDeathDisable(true)
	Ui.CameraMgr.PlayCameraAnimation("Scenes/Meshes/jj_jingjichang01/donghua/Main Camera.controller");
	self:CreateEnemy()
	self.nStartTimer = Timer:Register(Env.GAME_FPS * 3, self._Start, self)
end

function tbBase:OnPlayerDeath()
	self:End(0)
end

function tbBase:CreateEnemy()
	local nSeries = 1
	local tbInfo  = KPlayer.GetPlayerInitInfo(me.nFaction, me.nSex)
	if tbInfo then
		nSeries = tbInfo.nSeries
	end
	if self.nRestrainType == 2 then
		nSeries = Npc.tbSeriesRelation[nSeries][2]
	else
		nSeries = Npc.tbSeriesRelation[nSeries][1]
	end
	Log("Task_AsyncBattle_Fuben Enemy Series", nSeries)
	local tbEnemy = self.tbNpc[nSeries]
	local nEnemy  = tbEnemy[MathRandom(#tbEnemy)]
	local nMapId  = me.GetWorldPos()
	local nLevel  = self.nRestrainType == 2 and 30 or 1
	local pNpc    = KNpc.Add(nEnemy, nLevel, 0, nMapId, self.tbPos[1], self.tbPos[2], 0, 0)
	if not pNpc then
		Log("Task_AsyncBattle_Fuben CreateEnemy Error")
		return
	end
	self.nEnemyNpcId = pNpc.nId
	pNpc.SetAiActive(0)
	pNpc.nFightMode = 0
	Npc:RegNpcOnDeath(pNpc, self.OnNpcDeath, self)
end

function tbBase:_Start()
	Ui.CameraMgr.ResetMainCamera(true)
	BindCameraToNpc(self.nPlayerNpcId, 100)
	local pMe = KNpc.GetById(self.nPlayerNpcId)
	pMe.nFightMode = 1
	pMe.SetPkMode(3, 1)
	pMe.SetAi("Setting/Npc/Ai/AsyncPlayer.ini")
	pMe.SetAiActive(1);
	local pEnemy = KNpc.GetById(self.nEnemyNpcId)
	pEnemy.nFightMode = 1
	pEnemy.SetPkMode(3, 2)
	pEnemy.SetAiActive(1)
end

function tbBase:OnNpcDeath()
	self:End(1)
end

function tbBase:OnLeaveMap()
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.RemoveSkillState(self.PLAYER_STATE_SKILL)
		pNpc.SetPkMode(0)
		pNpc.SetHideNpc(0)
		pNpc.RestoreHP()
	end
	BindCameraToNpc(0, 0)
end

function tbBase:Close()
	local pPlayerNpc = me.GetNpc()
	if pPlayerNpc then
		pPlayerNpc.SetPkMode(0, 0)
		pPlayerNpc.nFightMode = 0
		me.Revive(1)
		pPlayerNpc.RestoreHP()
	end
	if self.nCloseTimer then
		Timer:Close(self.nCloseTimer)
		self.nCloseTimer = nil
	end
end

function tbBase:GetResultParams()
	return {nMapTemplateId = self.nMapTemplateId, nBattleKey = self.nBattleKey}
end

function tbBase:End(nResult)
	AsyncBattle:OnEndBattle(self.nMapTemplateId, 0, self)
	AsyncBattle:LeaveBattle()
end