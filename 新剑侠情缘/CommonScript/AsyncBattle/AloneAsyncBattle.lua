
Require("CommonScript/AsyncBattle/AsyncBattle.lua")

-- 同步VS异步
local tbBase = AsyncBattle:CreateClass("AloneAsyncBattle")

local tbDir = {32, 0}

tbBase.tbCenterPoint = {1900, 2450}

tbBase.tbEnemyPos =
{
	{2047, 1225,},

	{1800, 1225,},
	{2300, 1225,},
}

tbBase.tbSelfPos =
{
	{2047, 3078,},

	{2300, 3087,},
	{1800, 3052,},
}

tbBase.PLAYER_AI = "Setting/Npc/Ai/AsyncPlayer.ini"

function tbBase:Init(nPlayerId, nEnemy, nMapId)
	self.nMapId = nMapId
	self.nPlayerId = nPlayerId;
	self.nEnemy = nEnemy;
	self.tbNpcCount = {}

	self.tbNpc = {}
	self.tbNpcList = {}
	--self.tbNpcPosIdx = {}

	self.tbDamageCounter = {};
	self.tbDamageIdx = {};
	self.tbTotalDamage = {};

	self.tbSubstitute = {};		-- 替补
	self.tbParnerNpcList = {};
	self.tbDeathList = {};

	self.nState = AsyncBattle.ASYNC_BATTLE_NONE;
	self.nBattleTime = 90
end

function tbBase:GetNpcDir(nCustomMode)
	return tbDir[nCustomMode]
end

function tbBase:GetSelfPlayer()
	if MODULE_GAMESERVER then
		return KPlayer.GetPlayerObjById(self.nPlayerId);
	else
		return me;
	end
end

function tbBase:GetEnemyAsyncData()
	return KPlayer.GetAsyncData(self.nEnemy);
end

function tbBase:InitNpcByIndex(pNpc, nCustomMode, nPosIdx, bProtected, szAI)
	pNpc.SetDir(self:GetNpcDir(nCustomMode));
	--pNpc.ShowFlyChar(1);
	pNpc.bFlyCharBroad = 1
	pNpc.SetPkMode(3, nCustomMode);
	pNpc.nFightMode = 1
	if szAI then
		pNpc.SetAi(szAI)
	end

	pNpc.SetProtected(bProtected)
	pNpc.AddFightSkill(1251, 1)		-- 免疫被击动作
	pNpc.StartDamageCounter();		-- 开启伤害计算
	pNpc.nIgnoreMasterDeath = 1;

	Npc:RegNpcOnDeath(pNpc, self.OnNpcDeath, self, nCustomMode, nPosIdx);

	self:RecordNpc(pNpc.nId, nCustomMode, nPosIdx)
end

function tbBase:RecordNpc(nId, nCustomMode, nPosIdx)
	if self.nPlayerNpcId ~= nId then
		self.tbNpcList[nId] = true;
	end
	self.tbNpc[nCustomMode] = self.tbNpc[nCustomMode] or {};
	self.tbNpc[nCustomMode][nId] = nPosIdx
	self.tbDamageIdx[nId] = nCustomMode * 10 + nPosIdx;
	self.tbNpcCount[nCustomMode] = (self.tbNpcCount[nCustomMode] or 0) + 1;
end

function tbBase:_OnDeath(nNpcId, pNpc, nCustomMode, nPosIdx)
	local pPlayer = self:GetSelfPlayer()
	self.tbNpcCount[nCustomMode] = (self.tbNpcCount[nCustomMode] or 0) - 1
	self.tbNpc[nCustomMode][nNpcId] = nil;

	if self.tbDamageIdx[nNpcId] then
		pNpc.StopDamageCounter();
		local tbInfo = pNpc.GetDamageCounter()
		self.tbDamageCounter[self.tbDamageIdx[nNpcId]] = tbInfo.nDamage
		self.tbTotalDamage[nCustomMode] = (self.tbTotalDamage[nCustomMode] or 0) + tbInfo.nDamage;
	end

	if nPosIdx ~= 1 then	-- 非玩家死亡，替补上阵
		self:AddSubstitute(nCustomMode)
	end

	if self.tbNpcCount[nCustomMode] == 0 then
		self:End();
	end
	if nCustomMode == 1 and pPlayer then
		pPlayer.CenterMsg(string.format("「%s」已身受重伤！", pNpc.szName));
		self.tbDeathList[nNpcId] = true;
		self:SyncPartnerInfo(pPlayer);
	end
end

function tbBase:OnNpcDeath(nCustomMode, nPosIdx)
	self:_OnDeath(him.nId, him, nCustomMode, nPosIdx)
end

function tbBase:OnPlayerDeath()
	local pNpc = me.GetNpc()
	local nNpcId = pNpc.nId;
	self:_OnDeath(nNpcId, pNpc, 1, 1)
end

function tbBase:OnEnterMap()

	if not self.bEnter then
		self.bEnter = true
		local pPlayer = self:GetSelfPlayer()
		local pEnemyAsync = self:GetEnemyAsyncData();
		if not pEnemyAsync then
			return;
		end
		if not pPlayer then
			return;
		end

		self:CreateEnemyByAsyncData(pEnemyAsync, 2, self.tbEnemyPos);
		self:CreateSelfPartner(pPlayer);
	end

	self.nState = AsyncBattle.ASYNC_BATTLE_READY;

	self.nWaittingTimer = Timer:Register(Env.GAME_FPS * 10, self.OnPlayerReady, self);		-- 玩家在loading, 最多等玩家10秒
end


function tbBase:OnLeaveMap()
	if self.nDeathCallbackId then
		PlayerEvent:UnRegister(me, "OnDeath", self.nDeathCallbackId);
		me.SetDefaultDeathDisable(false);
	end
	local pPlayerNpc = me.GetNpc();
	if pPlayerNpc then
		pPlayerNpc.SetPkMode(0, 0);
		pPlayerNpc.nFightMode = 0;
		me.Revive(1);
		pPlayerNpc.RestoreHP()
	end
end

function tbBase:OnLogin()
	me.CallClientScript("Ui:OpenWindow", "AsyncPartner")
	self:SyncPartnerInfo(me);
	self:SyncBattleTimeInfo(me);
	if self.nState == AsyncBattle.ASYNC_BATTLE_END then
		me.MsgBox("战斗已结束，请确认离开",
			{
				{"离开", function () AsyncBattle:RequireLeaveBattle(me) end},
			})
	end
end

function tbBase:CreateEnemyByAsyncData(pAsync, nCamp, tbPos)
	-- 玩家NPC
	local pNpc = pAsync.AddAsyncNpc(self.nMapId, unpack(tbPos[1]))
	if not pNpc then
		Log("[RankBattle]Create Player Npc Failed!!")
		return;
	end
	self.nEnemyMasterId = pNpc.nId;
	self:InitNpcByIndex(pNpc, nCamp, 1, 1, self.PLAYER_AI)
	--pNpc.AI_SetTarget(me.GetNpc().nId)
	pNpc.AI_AddMovePos(unpack(self.tbCenterPoint));
	pNpc.SetActiveForever(1);

	local nCount = 1;
	for i = 1, 4 do
		if tbPos[1 + nCount] then
			local pNpc = pAsync.AddPartnerNpc(i, self.nMapId, unpack(tbPos[1 + nCount]))
			if pNpc then
				self:InitNpcByIndex(pNpc, nCamp, 1 + i, 1)
				pNpc.AI_SetFollowNpc(self.nEnemyMasterId)
				pNpc.SetMasterNpcId(self.nEnemyMasterId);
				pNpc.SetActiveForever(1);
				pNpc.AI_SetFollowDistance(3000);
				pNpc.nIgnoreMasterDeath = 1
				nCount = nCount + 1
			end
		else
			self.tbSubstitute[nCamp] = self.tbSubstitute[nCamp] or {}
			table.insert(self.tbSubstitute[nCamp], i);
		end
	end
end

function tbBase:CreateSelfPartner(pPlayer)
	local pPlayerNpc = pPlayer.GetNpc();
	self.nPlayerNpcId = pPlayer.GetNpc().nId
	local tbSelfPos = self.tbSelfPos
	pPlayer.SetPosition(unpack(tbSelfPos[1]))
	pPlayerNpc.SetDir(self:GetNpcDir(1))
	pPlayerNpc.SetPkMode(3, 1);
	pPlayerNpc.nFightMode = 1;
	pPlayerNpc.StartDamageCounter();		-- 开启伤害计算
	self.nDeathCallbackId = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self);
	pPlayer.SetDefaultDeathDisable(true);
	self:RecordNpc(self.nPlayerNpcId, 1, 1);

	local nCount = 1;
	local nCamp = 1;
	for i = 1, 4 do		-- 前两名同伴的位置
		if tbSelfPos[1 + nCount] then
			local pNpc = pPlayer.CreatePartnerByPos(i);
			if pNpc then
				pNpc.SetPosition(unpack(tbSelfPos[1 + nCount]))
				self:InitNpcByIndex(pNpc, nCamp, 1 + i, 1)
				pNpc.AI_SetFollowNpc(self.nPlayerNpcId)
				pNpc.SetMasterNpcId(self.nPlayerNpcId);
				pNpc.AI_SetFollowDistance(3000);
				pNpc.SetActiveForever(1);
				pNpc.nIgnoreMasterDeath = 1
				nCount = nCount + 1

				self.tbParnerNpcList[i] = pNpc.nId
			end
		else
			self.tbSubstitute[nCamp] = self.tbSubstitute[nCamp] or {}
			table.insert(self.tbSubstitute[nCamp], i);
		end
	end

	self:SyncPartnerInfo(pPlayer)
end

function tbBase:AddSubstitute(nCamp)
	local pPlayer = self:GetSelfPlayer()
	while self.tbSubstitute[nCamp] and self.tbSubstitute[nCamp][1] do
		local nAddPos = self.tbSubstitute[nCamp][1];
		table.remove(self.tbSubstitute[nCamp], 1);
		if nCamp == 1 then
			if not pPlayer then
				return;
			end
			local pNpc = pPlayer.CreatePartnerByPos(nAddPos);
			--local pNpc = pAsync.AddPartnerNpc(i, self.nMapId, unpack(tbPos[1+i]))
			if pNpc then
				pNpc.SetPosition(unpack(self.tbSelfPos[2]))
				self:InitNpcByIndex(pNpc, nCamp, 1 + nAddPos, 0)
				pNpc.AI_SetFollowNpc(self.nPlayerNpcId)
				pNpc.SetMasterNpcId(self.nPlayerNpcId);
				pNpc.AI_SetFollowDistance(3000);
				pNpc.nIgnoreMasterDeath = 1;

				self.tbParnerNpcList[nAddPos] = pNpc.nId
				pPlayer.CallClientScript("Ui:PlayEffect", 9008, unpack(self.tbSelfPos[2]));
				return true
			end
		else
			local pAsync = self:GetEnemyAsyncData(self.nEnemy)
			local pNpc = pAsync.AddPartnerNpc(nAddPos, self.nMapId, unpack(self.tbEnemyPos[2]))
			if pNpc then
				self:InitNpcByIndex(pNpc, nCamp, 1 + nAddPos, 0)
				pNpc.AI_SetFollowNpc(self.nEnemyMasterId)
				pNpc.SetMasterNpcId(self.nEnemyMasterId);
				pNpc.AI_SetFollowDistance(3000);
				pNpc.nIgnoreMasterDeath = 1

				if pPlayer then
					pPlayer.CallClientScript("Ui:PlayEffect", 9008, unpack(self.tbEnemyPos[2]));
				end
				return true
			end
		end
	end
end

function tbBase:OnPlayerReady()
	if self.nState ~= AsyncBattle.ASYNC_BATTLE_READY then
		return;
	end
	if self.nWaittingTimer then
		Timer:Close(self.nWaittingTimer);
		self.nWaittingTimer = nil;
	end
	Timer:Register(Env.GAME_FPS * 4, self.Start, self);

	if MODULE_GAMESERVER then
		local pPlayer = KPlayer.GetPlayerObjById(self.nPlayerId)
		pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
		pPlayer.CallClientScript("Ui:OpenWindow", "AsyncPartner");
	else
		Ui:OpenWindow("ReadyGo")
	end
	--self:Start();
end


function tbBase:GetDmgResult()
	local tbCurDmg = {}
	for nCustomMode, nCurDamage in pairs(self.tbTotalDamage) do
		tbCurDmg[nCustomMode] = nCurDamage;
	end

	for nCustomMode, tbInfo in pairs(self.tbNpc) do
		for nNpcId, _ in pairs(tbInfo) do
			local pNpc = KNpc.GetById(nNpcId)
			if pNpc then
				local tbInfo = pNpc.GetDamageCounter()
				tbCurDmg[nCustomMode] = (tbCurDmg[nCustomMode] or 0) + tbInfo.nDamage;
			end
		end
	end
	local tbResult =
	{
		[self.nPlayerId] = tbCurDmg[1];
		[0] = tbCurDmg[2];
	}
	return tbResult;
end

--function tbBase:UpdateDmg()
--	local pPlayer = self:GetSelfPlayer();
--	if pPlayer then
--		local tbResult = self:GetDmgResult();
--		if MODULE_GAMESERVER then
--			pPlayer.CallClientScript("Player:SetActiveRunTimeData", "QYHbattleInfo", tbResult)
--		else
--			Player:SetActiveRunTimeData("QYHbattleInfo", tbResult)
--		end
--	end
--end

function tbBase:Start()
	if self.nState ~= AsyncBattle.ASYNC_BATTLE_READY then
		return;
	end
	self.nState = AsyncBattle.ASYNC_BATTLE_GO;

	for nCustomMode, tbInfo in pairs(self.tbNpc) do
		for nNpcId, _ in pairs(tbInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.SetProtected(0);
			end
		end
	end

	-- 限时结束
	self.nTimer = Timer:Register(Env.GAME_FPS * self.nBattleTime, self.End, self);
	local pPlayer = self:GetSelfPlayer()
	if pPlayer then
		self:SyncBattleTimeInfo(pPlayer);
	end
end

function tbBase:CalcResult()
	local nSubstitute1 = self.tbSubstitute[1] and #self.tbSubstitute[1] or 0
	local nSubstitute2 = self.tbSubstitute[2] and #self.tbSubstitute[2] or 0
	if self.tbNpcCount[1] == 0 then
	elseif self.tbNpcCount[2] == 0 then
		return 1;
	elseif self.tbNpcCount[1] + nSubstitute1 > self.tbNpcCount[2] + nSubstitute2 then
		return 1;
	else	-- 攻方败
		return 0;
	end
end

function tbBase:End()
	if self.nState == AsyncBattle.ASYNC_BATTLE_END then
		return;
	end
	if self.nTimer then
		self.nTimer = nil;
		for nCustomMode, tbInfo in pairs(self.tbNpc) do
			for nNpcId, _ in pairs(tbInfo) do
				local pNpc = KNpc.GetById(nNpcId)
				if pNpc and self.tbDamageIdx[nNpcId] then
					pNpc.StopDamageCounter();
					local tbInfo = pNpc.GetDamageCounter()
					self.tbDamageCounter[self.tbDamageIdx[nNpcId]] = tbInfo.nDamage;
				end
			end
		end

		local nResult = self:CalcResult();
		AsyncBattle:OnEndBattle(self.nMapId, nResult, self)
	end
	self:Close();
end

function tbBase:Close()
	if self.nState == AsyncBattle.ASYNC_BATTLE_END then
		return;
	end

	self.nState = AsyncBattle.ASYNC_BATTLE_END;
	for nNpcId, _ in pairs(self.tbNpcList) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			pNpc.Delete();
		end
	end
end

function tbBase:ShowResultUi(nResult)
	local pPlayer = self:GetSelfPlayer()
	local tbMe = {}
	tbMe[1] = {pPlayer.szName, pPlayer.nPortrait, pPlayer.nFaction, pPlayer.nLevel};
	local tbMyPartner = pPlayer.GetPartnerPosInfo()
	for nPartnerIdx = 1, 4 do
		local nPartnerId = tbMyPartner[nPartnerIdx]
		if nPartnerId and nPartnerId ~= 0 then
			local tbPartnerInfo = pPlayer.GetPartnerInfo(nPartnerId)
			tbMe[nPartnerIdx + 1] = {tbPartnerInfo.nTemplateId, tbPartnerInfo.nFightPower, tbPartnerInfo.nLevel}
		end
	end

	local tbEnemy = {}
	local pAsyncData = self:GetEnemyAsyncData()
	if pAsyncData then
		local szName, nPortrait, nLevel, nFaction = pAsyncData.GetPlayerInfo();
		tbEnemy[1] = {szName, nPortrait, nFaction, nLevel}
		for nPartnerIdx = 1, 4 do
			local nPartnerId, nPartnerLevel, nFightPower = pAsyncData.GetPartnerInfo(nPartnerIdx);
			if nPartnerId and nPartnerId ~= 0 then
				tbEnemy[nPartnerIdx + 1] = {nPartnerId, nFightPower, nPartnerLevel}
			end
		end
	end

	pPlayer.CallClientScript("Ui:OpenWindow", "RankBattleResult", nResult, tbMe, tbEnemy, self.tbDamageCounter)
end

function tbBase:SyncPartnerInfo(pPlayer)
	pPlayer.CallClientScript("Player:SetActiveRunTimeData", "AsyncBattle", {self.tbParnerNpcList, self.tbDeathList});
end

function tbBase:SyncBattleTimeInfo(pPlayer)
	if self.nTimer then
		local nResTime = Timer:GetRestTime(self.nTimer)
		if nResTime > 0 then
			pPlayer.CallClientScript("Ui:OpenWindow", "QYHbattleInfo", nResTime / Env.GAME_FPS, true);
		end
	end
end

-------------------------- 客户端部分 -----------------------------------------

function tbBase:Client_OnMapLoaded()
	local pPlayerNpc = me.GetNpc();
	if pPlayerNpc then
		pPlayerNpc.SetDir(self:GetNpcDir(1));
	end
end

