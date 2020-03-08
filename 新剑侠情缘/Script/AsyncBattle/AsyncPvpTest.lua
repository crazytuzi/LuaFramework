
local tbBase = AsyncBattle:CreateClass("PvpAutoTest")

local tbNPC_POS = 
{
	{	-- 我方点		
		{1900,	1516},
		{1731,	1588},
		{1592,	1718},
		{1532,	1847},
		{1499,	1989},
		{1487,	2182},
		{1532,	2369},
		{1574,	2480},
		{1667,	2574},
		{1761,	2655},
	}, 
	{	-- 敌方点	
		{2150,	1492},
		{2282,	1600},
		{2409,	1703},
		{2448,	1823},
		{2454,	1968},
		{2436,	2170},
		{2400,	2336},
		{2340,	2450},
		{2270,	2544},
		{2243,	2640},
	}
}

function tbBase:Init(nPlayerId, nFaction, nMapId, nAutoSkill)
	print("tbBase:Init", nPlayerId, nFaction, nMapId, nAutoSkill)
	self.nMapId = nMapId
	self.nPlayerId = nPlayerId;
	self.nFaction = nFaction
	self.nAutoSkill = nAutoSkill
	self.tbNpcCount = {}
		
	self.tbNpc = {}
end

function tbBase:InitNpcByIndex(pNpc, nCustomMode, nPosIdx)
	self.tbNpc[nCustomMode] = self.tbNpc[nCustomMode] or {};
	table.insert(self.tbNpc[nCustomMode], pNpc.nId)
	
	-- self.tbNpc[nIdx].nNpcId = pNpc.nId;
	
	--pNpc.ShowFlyChar(1);
	pNpc.SetPkMode(3, nCustomMode);
	pNpc.nFightMode = 1;
	if self.nAutoSkill == 1 then
		pNpc.SetAi(RankBattle.NPC_AI)
	else
		pNpc.SetAi("Setting/Npc/Ai/CommonActive.ini")
	end
	pNpc.SetAiActive(0);
		
	self.tbNpcCount[nCustomMode] = (self.tbNpcCount[nCustomMode] or 0) + 1;
end

function tbBase:CreateNpcTeamByAsyncData(nCamp, tbPos)
	for nPosIdx, tbOnePos in ipairs(tbPos) do
		local nCurFaction = self.nFaction;
		if self.nFaction <= 0 then
			nCurFaction = MathRandom(1, 4)
		end
		local nSex = Player:Faction2Sex(nCurFaction);
		local pNpc = KPlayer.AddFakePlayer(nCurFaction, nSex, 30, self.nMapId, unpack(tbOnePos))
		if not pNpc then
			Log("[RankBattle]Create Fake Player Npc Failed!!")
			return;
		end
		self:AddFakePlayerSkill(pNpc, nCurFaction, 30)
		self:InitNpcByIndex(pNpc, nCamp, nPosIdx)
	end
end

function tbBase:OnEnterMap()
	
	self:CreateNpcTeamByAsyncData(1, tbNPC_POS[1]);
	self:CreateNpcTeamByAsyncData(2, tbNPC_POS[2]);
		
	--BindCameraToPos(2054, 2084);
	--Ui.CameraMgr.MoveCameraTo(1, unpack(RankBattle.CAMERA_PARAM));
	
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(1)
	end
end

function tbBase:Client_OnMapLoaded()
	if AsyncBattle.tbBattleList then
		--BindCameraToPos(2054, 2084);
		for _, tbBattle in pairs(AsyncBattle.tbBattleList) do
			tbBattle:Start();
			--Timer:Register(Env.GAME_FPS * 4, AsyncBattle.tbBattle.Start, AsyncBattle.tbBattle);
		end
	end
end

function tbBase:Start()
	--BindCameraToPos(unpack(RankBattle.ENTER_POINT));
	BindCameraToPos(2054, 2084);
	self.nTimer = Timer:Register(Env.GAME_FPS * 1, self.StartNpc, self);
end

function tbBase:StartNpc()
	self.nStartIdx = (self.nStartIdx or 0) + 1;
	print("tbBase:StartNpc", self.nStartIdx)
	for nCustomMode, tbInfo in pairs(self.tbNpc) do
		if tbInfo[self.nStartIdx] then
			local pNpc = KNpc.GetById(tbInfo[self.nStartIdx]);
			if pNpc then
				pNpc.SetAiActive(1);
			end
		else
			return false;
		end
	end
	
	return true;
end

function tbBase:AddFakePlayerSkill(pNpc, nFaction, nLevel)
	print("AddFakePlayerSkill", pNpc, nFaction, nLevel)
	local tbSkillList = FightSkill:GetFakePlayerSkillList(nFaction, nLevel)
	for _, tbInfo in ipairs(tbSkillList) do
		local nSkillId, nLevel = unpack(tbInfo);
		pNpc.AddFightSkill(nSkillId, nLevel)
	end
	pNpc.AddFightSkill(1251, 1)		-- 免疫被击动作
	
	local tbAttribList = 
	{
		{szAttribType = "lifemax_v", tbValue = {300000, 0, 0}}
	}
	for _, tbAttrib in pairs(tbAttribList) do
		pNpc.ChangeAttribValue(tbAttrib.szAttribType, unpack(tbAttrib.tbValue))
	end
	pNpc.SetCurLife(pNpc.nMaxLife);
	pNpc.AddSkillState(5, 1, 0, 1000000);  -- 自动回血
end
