Require("CommonScript/AsyncBattle/BasePvp.lua");

local tbParent = AsyncBattle:GetClass("BasePvp")
local tbBase = AsyncBattle:CreateClass("BossFightBattle", "BasePvp");

local nBossSkillId = 1751;
local tbDelBuffIds = {4348};

function tbBase:InitFakeAsyncData(tbBossData, nNpcLevel)
	local tbFakeAsyncData = {}
	local tbBattleObj = self;
	tbFakeAsyncData.AddAsyncNpc =
	function (nMapId, nX, nY)
		local pNpc = KNpc.Add(tbBossData.nNpcId, nNpcLevel, -1, nMapId, nX, nY);
		if not pNpc then
			Log("Create Boss Npc Fail");
			return;
		end

		pNpc.SetMaxLife(tbBossData.nMaxHp);
		pNpc.SetCurLife(tbBossData.nCurHp);

		tbBattleObj.nBossId = pNpc.nId;
		return pNpc;
	end;
	tbFakeAsyncData.AddPartnerNpc =
	function (nAddPos, nMapId, nX, nY)
		return;
	end;
	tbFakeAsyncData.GetPlayerInfo =
	function ()
		local szName = KNpc.GetNameByTemplateId(tbBossData.nNpcId)
		return szName, {tbBossData.nNpcId}, nNpcLevel, nil;
	end;
	tbFakeAsyncData.GetPartnerInfo =
	function (nPartnerIdx)
		return;
	end;
	tbFakeAsyncData.GetBattleArray =
	function (nIdx)
		local tbPartnerPos = {2,1,3,4,6};
		return tbPartnerPos[nIdx]
	end

	return tbFakeAsyncData;
end

function tbBase:Init(nPlayerId, tbBossData, nMapId)
	tbParent.Init(self, nPlayerId, tbBossData.nNpcId, nMapId);
	self.tbBossData = tbBossData;
	self.tbNpcPos = Boss.Def.tbNPC_POS;
	local pPlayer = self:GetSelfPlayer()
	if pPlayer then
		self.tbFakeAsyncData = self:InitFakeAsyncData(self.tbBossData, pPlayer and pPlayer.nLevel)
	end
end

function tbBase:GetEnemyAsyncData()
	return self.tbFakeAsyncData;
end

function tbBase:Start()
	tbParent.Start(self)
	if not self.nHitTimer then
		self.nHitTimer = Timer:Register(Env.GAME_FPS * 30, self.BossHit, self);
	end
end

function tbBase:BossHit()
	if self.nState == AsyncBattle.ASYNC_BATTLE_END then
		return;
	end
	self.nHitTimer = nil;
	local pBossNpc = KNpc.GetById(self.nBossId);
	if not pBossNpc then
		return;
	end

	pBossNpc.AddFightSkill(nBossSkillId, 1);

	Timer:Register(1, function ()
		if not self.nTimer then
			return;
		end

		local pMainNpc = KNpc.GetById(self.nMainNpcId);
		if pMainNpc then
			for _, nBuffId in ipairs(tbDelBuffIds) do
				pMainNpc.RemoveSkillState(nBuffId);
			end
		end

		local bSkilled = pBossNpc.UseSkill(nBossSkillId, -1, self.nMainNpcId);
		if bSkilled then
			Timer:Register(Env.GAME_FPS * 4, self.End, self);
		end
		return not bSkilled;
	end);
end


function tbBase:End()
	local pBoss = KNpc.GetById(self.nBossId);
	if pBoss then
		local tbInfo = pBoss.GetDamageCounter();
		self.nDamage = tbInfo.nReceiveDamage;
	else
		self.nDamage = 1;
	end

	tbParent.End(self);
end

function tbBase:CalcResult()
	if self.tbNpcCount[2] == 0 then
		return 1;
	else
		return 0;
	end
end

function tbBase:CloseBossBattle()
	self:End();
	local pPlayer = self:GetSelfPlayer()
	if pPlayer then
		pPlayer.CenterMsg("挑战武林盟主已结束, 现强制结束本轮挑战");
	end
end

function tbBase:OnEnterMap()
	tbParent.OnEnterMap(self);

	me.CallClientScript("Boss:EnterBossBattle", Ui.STATE_ASYNC_BATTLE);
end

function tbBase:OnLeaveMap()
	tbParent.OnLeaveMap(self);
	me.CallClientScript("Boss:LeaveBossBattle");
end




--function tbBase:OnMapLoaded()
--	local pMeAsync = KPlayer.GetAsyncData(me.dwID);
--	if not pMeAsync then
--		print("not pMeAsync");
--		return;
--	end
--
--	self:CreateNpcTeamByAsyncData(pMeAsync, 1, [1]);
--	self:CreateBossNpc(self.tbBossData, 2, Boss.Def.tbNPC_POS[2]);
--
--	self:InitLockTarget(1, 2, RankBattle.LOCK_TARGET);
--
--	self.nEnemyCount = self.tbNpcCount[2];
--
--	local pNpc = me.GetNpc()
--	if pNpc then
--		pNpc.SetHideNpc(1)
--	end
--	Ui:ChangeUiState(Ui.STATE_ASYNC_BATTLE);
--end

--function tbBase:CreateBossNpc(tbBossData, nCamp, tbPos)
--	local pNpc = KNpc.Add(tbBossData.nNpcId, me.nLevel, -1, 0, unpack(tbPos[2]));
--	if not pNpc then
--		Log("create boss npc fail");
--		return;
--	end
--
--	pNpc.SetMaxLife(tbBossData.nMaxHp);
--	pNpc.SetCurLife(tbBossData.nCurHp);
--
--	self.nBossId = pNpc.nId;
--	self:InitNpcByIndex(pNpc, nCamp, 1, 1);
--end


--	if self.nTimer then
--		self.nTimer = nil;
--
--		for nCustomMode, tbInfo in pairs(self.tbNpc) do
--			for nNpcId, _ in pairs(tbInfo) do
--				local pNpc = KNpc.GetById(nNpcId)
--				if pNpc and self.tbDamageIdx[nNpcId] then
--					pNpc.StopDamageCounter();
--					local tbInfo = pNpc.GetDamageCounter()
--					self.tbDamageCounter[self.tbDamageIdx[nNpcId]] = tbInfo.nDamage;
--				end
--			end
--		end
--
--
--
--		AsyncBattle:OnEndBattle(bBeated and 1 or 0, self.nBattleKey, nDamage);
--	end
--
--	if self.nHitTimer then
--		Timer:Close(self.nHitTimer);
--		self.nHitTimer = nil;
--	end
--end

--function tbBase:GetBattleInfo()
--	local pBossNpc = KNpc.GetById(self.nBossId);
--	local nFaceId = KNpc.GetNpcShowInfo(self.nEnemy or 0);
--    local IconSmallAtlas, IconSmall = Npc:GetFace(nFaceId);
--	local tbBossInfo = {{pBossNpc.szName, {IconSmall, IconSmallAtlas}, nil, pBossNpc.nLevel}};
--
--	return me.dwID, tbBossInfo, self.tbDamageCounter;
--end

