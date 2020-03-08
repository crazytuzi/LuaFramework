
local tbBase = AsyncBattle:CreateClass("BasePvp")

local tbDir = {32, 0}

tbBase.PLAYER_STATE_SKILL = 1064;		-- 无敌、不可移动

function tbBase:Init(nPlayerId, nEnemy, nMapId)
	self.nMapId = nMapId
	self.nPlayerId = nPlayerId;
	self.nEnemy = nEnemy;
	self.tbNpcCount = {}

	self.tbNpc = {}
	self.tbNpcPosIdx = {}

	self.tbDamageCounter = {};
	self.tbDamageIdx = {};
	
	self.tbNpcList = {}
	
	self.tbNpcPos = RankBattle.tbNPC_POS
	
	self.nState = AsyncBattle.ASYNC_BATTLE_NONE;
	
	self.nBattleTime = RankBattle.BATTLE_TIME;
end

function tbBase:GetSelfPlayer()
	if MODULE_GAMESERVER then
		return KPlayer.GetPlayerObjById(self.nPlayerId);
	else
		return me;
	end
end

function tbBase:GetEnemyAsyncData()
	return KPlayer.GetRankAsyncData(self.nEnemy);
end

function tbBase:GetSelfAsyncData()
	return KPlayer.GetAsyncData(self.nPlayerId)
end


function tbBase:InitNpcByIndex(pNpc, nCustomMode, nPosIdx, nDamageCountPos)
	local nId = pNpc.nId
	self.tbNpc[nCustomMode] = self.tbNpc[nCustomMode] or {};
	self.tbNpc[nCustomMode][nId] = nPosIdx

	self.tbNpcPosIdx[nCustomMode] = self.tbNpcPosIdx[nCustomMode] or {};
	self.tbNpcPosIdx[nCustomMode][nPosIdx] = nId
	-- self.tbNpc[nIdx].nNpcId = pNpc.nId;

	self.tbDamageIdx[nId] = nCustomMode * 10 + nDamageCountPos;

	pNpc.SetDir(tbDir[nCustomMode]);
	if MODULE_GAMESERVER then
		pNpc.bFlyCharBroad = 1
	else
		pNpc.ShowFlyChar(1)
	end
	pNpc.SetPkMode(3, nCustomMode);
	pNpc.nFightMode = 1;
	pNpc.SetAiActive(0);
	pNpc.SetActiveForever(1);
	-- pNpc.SetBloodType(nCustomMode)
	pNpc.AddFightSkill(1251, 1)		-- 免疫被击动作
	pNpc.StartDamageCounter();		-- 开启伤害计算

	self.tbNpcCount[nCustomMode] = (self.tbNpcCount[nCustomMode] or 0) + 1;
	Npc:RegNpcOnDeath(pNpc, self.OnNpcDeath, self, nCustomMode, nPosIdx);
	
	self.tbNpcList[nId] = true;
end

function tbBase:InitLockTarget(nCustomMode, nTargetMode, tbLockTarget)
	if not self.tbNpc[nCustomMode] or not self.tbNpc[nTargetMode] then
		print("tbBase:InitLockTarget", self.tbNpc[nCustomMode], self.tbNpc[nTargetMode])
		return;
	end
	for nNpcId, nPosIdx in pairs(self.tbNpc[nCustomMode]) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc and tbLockTarget[nPosIdx] then
			for _, nTargetPosIdx in ipairs(tbLockTarget[nPosIdx]) do
				if self.tbNpcPosIdx[nTargetMode][nTargetPosIdx] then
					pNpc.AddAiLockTarget(self.tbNpcPosIdx[nTargetMode][nTargetPosIdx])
				end
			end
		end
	end
end

function tbBase:OnNpcDeath(nCustomMode, nPosIdx)
	local pPlayer = self:GetSelfPlayer()
	self.tbNpcCount[nCustomMode] = (self.tbNpcCount[nCustomMode] or 0) - 1
	self.tbNpc[nCustomMode][him.nId] = nil;

	if self.tbDamageIdx[him.nId] then
		him.StopDamageCounter();
		local tbInfo = him.GetDamageCounter()
		self.tbDamageCounter[self.tbDamageIdx[him.nId]] = tbInfo.nDamage
	end

	if self.tbNpcCount[nCustomMode] == 0 then
		self:End();
	end
	if nCustomMode == 1 and pPlayer then
		pPlayer.CenterMsg(string.format("「%s」已身受重伤！", him.szName));
	end
	if self.nMainNpcId == him.nId then
		for nId, _ in pairs(self.tbNpc[nCustomMode]) do
			self.nMainNpcId = nId
			if pPlayer then
				self:BindCameraToNpc(pPlayer, self.nMainNpcId, 220)
			end
			break;
		end
	end
end

function tbBase:CreateNpcTeamByAsyncData(pAsync, nCamp, tbPos)
	local nPlayerPosIdx = pAsync.GetBattleArray(1);		-- 玩家自身位置
	local nMasterId;
	if tbPos[nPlayerPosIdx] then
		local pNpc = pAsync.AddAsyncNpc(self.nMapId, unpack(tbPos[nPlayerPosIdx]))
		if not pNpc then
			Log("[RankBattle]Create Player Npc Failed!!")
			return;
		end
		nMasterId = pNpc.nId;
		if nCamp == 1 then
			self.nMainNpcId = nMasterId
		end
		
		pNpc.SetAi(RankBattle.NPC_AI)
		self:InitNpcByIndex(pNpc, nCamp, nPlayerPosIdx, 1)
	end

	for i = 1, 4 do		-- 4名同伴的位置
		local nPartnerPosIdx = pAsync.GetBattleArray(1 + i)
		if tbPos[nPartnerPosIdx] then
			local pNpc = pAsync.AddPartnerNpc(i, self.nMapId, unpack(tbPos[nPartnerPosIdx]))
			if pNpc then
				self:InitNpcByIndex(pNpc, nCamp, nPartnerPosIdx, i + 1)
				if nMasterId then
					pNpc.AI_SetFollowNpc(nMasterId)
					pNpc.SetMasterNpcId(nMasterId);
					pNpc.nIgnoreMasterDeath = 1;
					pNpc.AI_SetFollowDistance(3000);
				end
			end
		end
	end
end

function tbBase:OnEnterMap()
	
	if not self.bEnter then
		self.bEnter = true
		local pMeAsync = self:GetSelfAsyncData();
		if not pMeAsync then
			print("not pMeAsync")
			return;
		end
	
		local pEnemyAsync = self:GetEnemyAsyncData();
		if not pEnemyAsync then
			print("not pEnemyAsync")
			return;
		end
	
		self:CreateNpcTeamByAsyncData(pMeAsync, 1, self.tbNpcPos[1]);
		self:CreateNpcTeamByAsyncData(pEnemyAsync, 2, self.tbNpcPos[2]);
		
		self:InitLockTarget(1, 2, RankBattle.LOCK_TARGET);
		
		self:InitLockTarget(2, 1, RankBattle.LOCK_TARGET);
		
	end
	
	local pPlayer = self:GetSelfPlayer();
	if pPlayer then
		local pNpc = pPlayer.GetNpc()
		if pNpc then
			pNpc.AddSkillState(self.PLAYER_STATE_SKILL, 1, 0, Env.GAME_FPS * 180);
			pNpc.SetPkMode(3, 1);
			pNpc.SetHideNpc(1)
			pPlayer.CallClientScript("AsyncBattle:DoFun", self.szClassType, "ShowMe", 1);
		end
	end
	
	
	self.nState = AsyncBattle.ASYNC_BATTLE_READY;

	self.nWaittingTimer = Timer:Register(Env.GAME_FPS * 10, self.OnPlayerReady, self);		-- 玩家在loading, 最多等玩家10秒
end

function tbBase:OnLeaveMap()
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.RemoveSkillState(self.PLAYER_STATE_SKILL);
		pNpc.SetPkMode(0)
		pNpc.SetHideNpc(0)
		pNpc.RestoreHP()
	end
	me.CallClientScript("AsyncBattle:DoFun", self.szClassType, "ShowMe");
	self:BindCameraToNpc(me, 0, 0)
end

function tbBase:OnLogin()
	if self.nState == AsyncBattle.ASYNC_BATTLE_END then
		me.MsgBox("战斗已结束，请确认离开", 
			{
				{"离开", function () AsyncBattle:RequireLeaveBattle(me) end},
			})
		return;
	end
	me.CallClientScript("AsyncBattle:DoFun", self.szClassType, "ShowMe", 1, Env.GAME_FPS, me.nMapId)
	if self.nMainNpcId then
		self:BindCameraToNpc(me, self.nMainNpcId, 0)
	end
	
	self:SyncBattleTimeInfo(me)
end

function tbBase:OnPlayerReady()
	if self.nState ~= AsyncBattle.ASYNC_BATTLE_READY then
		return;
	end
	
	if self.nWaittingTimer then
		Timer:Close(self.nWaittingTimer);
	end
	
	--BindCameraToPos(unpack(RankBattle.ENTER_POINT));
	--Ui.CameraMgr.PlayCameraAnimation("Scenes/Meshes/jj_jingjichang01/donghua/Main Camera.controller");
	Timer:Register(Env.GAME_FPS * 4, self.Start, self);

	if MODULE_GAMESERVER then
		local pPlayer = KPlayer.GetPlayerObjById(self.nPlayerId)
		pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
	else
		Ui:OpenWindow("ReadyGo")
	end
	--self:Start();
end

function tbBase:Start()
	if self.nState ~= AsyncBattle.ASYNC_BATTLE_READY then
		return;
	end
	self.nState = AsyncBattle.ASYNC_BATTLE_GO;
	
	for nCustomMode, tbInfo in pairs(self.tbNpc) do
		for nNpcId, _ in pairs(tbInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.SetAiActive(1);
			end
		end
	end
	
	self.nTimer = Timer:Register(Env.GAME_FPS * self.nBattleTime, self.End, self);
		
	local pPlayer = self:GetSelfPlayer();
	if self.nMainNpcId and pPlayer then
		self:BindCameraToNpc(pPlayer, self.nMainNpcId, 220)
		self:OpenSmallChat(pPlayer)
	end
	
	if pPlayer then
		self:SyncBattleTimeInfo(pPlayer);
	end
end

function tbBase:CalcResult()
	if self.tbNpcCount[2] == 0 then
		return 1;
	elseif self.tbNpcCount[1] > self.tbNpcCount[2] then
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
	elseif self.nState == AsyncBattle.ASYNC_BATTLE_READY then
		AsyncBattle:OnEndBattle(self.nMapId, 0, self);
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

function tbBase:BindCameraToNpc(pPlayer, nNpcId, nCrossTime)
	pPlayer.CallClientScript("AsyncBattle:DoFun", self.szClassType, "LookNpc", nNpcId, nCrossTime)
end

function tbBase:OpenSmallChat(pPlayer)
	pPlayer.CallClientScript("AsyncBattle:DoFun", self.szClassType, "OpenSmallChatC")
end

function tbBase:ShowResultUi(nResult)
	local pPlayer = self:GetSelfPlayer()
	local tbMe = {}
	local pMeAsyncData = self:GetSelfAsyncData()
	if pMeAsyncData then
		local szName, nPortrait, nLevel, nFaction = pMeAsyncData.GetPlayerInfo();
		tbMe[1] = {szName, nPortrait, nFaction, nLevel}
		for nPartnerIdx = 1, 4 do
			local nPartnerId, nPartnerLevel, nFightPower = pMeAsyncData.GetPartnerInfo(nPartnerIdx);
			if nPartnerId and nPartnerId ~= 0 then
				tbMe[nPartnerIdx + 1] = {nPartnerId, nFightPower, nPartnerLevel}
			end
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
	
	pPlayer.CallClientScript("Ui:OpenWindow", "RankBattleResult", nResult, tbMe, tbEnemy, self.tbDamageCounter, nil, self.szClassType)
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
	Ui.CameraMgr.PlayCameraAnimation("Scenes/Meshes/jj_jingjichang01/donghua/Main Camera.controller");
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(1)
	end
end

function tbBase:ShowMe(bHide, nTime, nMapId)
	bHide = bHide or 0
	local fnDo = function(dwID, bHide, nMapId)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
       	if not pPlayer then
        	return 
       	end
       	local pNpc = pPlayer.GetNpc()
       	if not pNpc then
       		return 
       	end
   		-- 有传值时保证值正确
       	if nMapId and nMapId ~= pPlayer.nMapId then
       		return
       	end
       	pNpc.SetHideNpc(bHide)
	end
	if nTime then
		Timer:Register(nTime, fnDo, me.dwID, bHide, nMapId)
	else
		fnDo(me.dwID, bHide, nMapId)
	end
end

function tbBase:LookNpc(nNpcId, nCrossTime)
	if nNpcId > 0 then
		Ui.CameraMgr.ResetMainCamera(true);
		BindCameraToNpc(nNpcId, nCrossTime)
	else
		BindCameraToNpc(0, nCrossTime)
	end
end

function tbBase:OpenSmallChatC()
	Ui:OpenWindow("ChatSmall");
end
