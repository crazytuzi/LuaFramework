Require("CommonScript/Fuben/BaseLock.lua");

-- 副本内容基础

Fuben.tbBase = {}
local tbBase = Fuben.tbBase;
local tbEventLock = Lib:NewClass(Fuben.Lock.tbBaseLock);

function tbEventLock:InitEventLock(tbFuben, nTime, nMultiNum, tbStartEvent, tbUnLockEvent)
	self:InitLock(nTime, nMultiNum);
	self.tbFuben 		= tbFuben;
	self.tbUnLockEvent 	= tbUnLockEvent;
	self.tbStartEvent 	= tbStartEvent;
end

function tbEventLock:OnUnLock()
	if self.tbFuben and self.tbUnLockEvent then
		self.tbFuben.nCurLockId = self.nLockId;
		for i = 1, #self.tbUnLockEvent do
			self.tbFuben:OnEvent(unpack(self.tbUnLockEvent[i]));
		end
	end
end

function tbEventLock:OnStartLock()
	if self.tbFuben and self.tbStartEvent then
		self.tbFuben.nCurLockId = self.nLockId;
		for i = 1, #self.tbStartEvent do
			self.tbFuben:OnEvent(unpack(self.tbStartEvent[i]));
		end
	end
end

tbBase.EVENT_PROC  =
{
	AddNpc					= "AddNpc",
	DelNpc					= "DelNpc",
	SetAiActive             = "SetAiActive",
	SetNpcAi                = "SetNpcAi";
	ChangeTrap				= "ChangeTrap",
	TrapUnlock				= "TrapUnlock",
	CloseLock				= "CloseLock",
	ChangeNpcAi				= "ChangeNpcAi",
	GameWin					= "GameWin",
	GameLost				= "GameLost",
	RaiseEvent 				= "RaiseEvent",
	SetPos 					= "SetPos",
	BlackMsg				= "BlackMsg",
	UseSkill				= "UseSkill",
	CastSkill 				= "CastSkill",
	OpenDynamicObstacle		= "OpenDynamicObstacle",
	PlayCameraAnimation		= "PlayCameraAnimation",
	MoveCamera				= "MoveCamera",
	MoveCameraByTarget		= "MoveCameraByTarget",
	LeaveAnimationState		= "LeaveAnimationState",
	SetTargetPos			= "SetTargetPos",
	ClearTargetPos			= "ClearTargetPos",
	ChangeFightState		= "ChangeFightState",
	SetFubenProgress		= "SetFubenProgress",
	SetGameWorldScale		= "SetGameWorldScale",
	RestoreCameraRotation 	= "RestoreCameraRotation",
	PlayEffect				= "PlayEffect",
	PlayFactionEffect       = "PlayFactionEffect";
	PlayCGAnimation         = "PlayCGAnimation",
	ShowAllRepresentObj     = "ShowAllRepresentObj";
	PlayCameraEffect		= "PlayCameraEffect",
	OpenWindow              = "OpenWindow";
	OpenWindowAutoClose     = "OpenWindowAutoClose";
	CloseWindow             = "CloseWindow";
	PreLoadWindow 			= "PreLoadWindow";
	PlaySound               = "PlaySound";
	ShowTaskDialog			= "ShowTaskDialog",
	PlaySceneAnimation		= "PlaySceneAnimation",
	PlaySceneAnimationWithPlayer = "PlaySceneAnimationWithPlayer",
	BatchPlaySceneAnimation = "BatchPlaySceneAnimation",
	SetForbiddenOperation	= "SetForbiddenOperation",
	ChangeNpcCamp 			= "ChangeNpcCamp",
	SetHeadVisiable			= "SetHeadVisiable",
	SetNpcBloodVisable		= "SetNpcBloodVisable",
	SetNpcPos				= "SetNpcPos",
	SetAllUiVisiable		= "SetAllUiVisiable",
	Random 					= "Random",
	IfCase 					= "DoIfCase",
	IfPlayer 				= "DoIfPlayer",
	IfTrapCount 			= "DoIfTrapCount",
	TrapAddSkillState		= "TrapAddSkillState",
	PauseLock 				= "PauseLock",
	ResumeLock				= "ResumeLock",
	SetShowTime				= "SetShowTime",
	StopEndTime				= "StopEndTime",
	SetTargetInfo			= "SetTargetInfo",
	NpcBubbleTalk 			= "NpcBubbleTalk",
	TrapCastSkill			= "TrapCastSkill",
	AddAnger				= "AddAnger",
	DoDeath					= "DoDeath",
	UnLock 					= "UnLock",
	CastSkillCycle			= "CastSkillCycle",
	CloseCycle 				= "CloseCycle",
	ChangeCameraSetting		= "ChangeCameraSetting",
	NpcHpUnlock				= "NpcHpUnlock",
	SetBossBlood			= "SetBossBlood",
	ChangeNpcFightState		= "ChangeNpcFightState",
	AddSimpleNpc			= "AddSimpleNpc",
	SetNpcProtected			= "SetNpcProtected",
	SetPlayerProtected		= "SetPlayerProtected",
	RemovePlayerSkillState	= "RemovePlayerSkillState",
	SaveNpcInfo				= "SaveNpcInfo",
	AddBuff					= "AddBuff",
	NpcAddBuff				= "NpcAddBuff",
	NpcRemoveBuff			= "NpcRemoveBuff",
	NpcFindEnemyUnlock 		= "NpcFindEnemyUnlock",
	NpcFindEnemyRaiseEvent	= "NpcFindEnemyRaiseEvent",
	OpenGuide               = "OpenGuide",
	SetSceneSoundScale     = "SetSceneSoundScale";
	SetDialogueSoundScale   = "SetDialogueSoundScale";
	SetEffectSoundScale     = "SetEffectSoundScale";
	SetGuidingJoyStick      = "SetGuidingJoyStick",
	SetNpcRange				= "SetNpcRange",
	SetNpcDir				= "SetNpcDir",
	SetPlayerDir			= "SetPlayerDir",
	StartTimeCycle			= "StartTimeCycle",
	DropBuffer				= "DropBuffer",
	MoveCameraToPosition	= "MoveCameraToPosition",
	DoCommonAct				= "DoCommonAct",
	SetNearbyRange			= "SetNearbyRange",
	SetDynamicRevivePoint	= "SetDynamicRevivePoint",
	PlayerBubbleTalk		= "PlayerBubbleTalk",
	HomeScreenTip			= "HomeScreenTip",
	CastSkillMulti			= "CastSkillMulti",
	SetKickoutPlayerDealyTime     = "SetKickoutPlayerDealyTime",
	NpcRandomTalk     		= "NpcRandomTalk",
	SetPlayerDeathDoRevive	= "SetPlayerDeathDoRevive";
	AddFurniture			= "AddFurniture";
	DeleteFurniture			= "DeleteFurniture";
	AddFurnitureGroup		= "AddFurnitureGroup";
	SetKickOutToKinMapDelayTime = "SetKickOutToKinMapDelayTime";
	SetNpcLife				= "SetNpcLife";
	PlayHelpVoice				= "PlayHelpVoice";
	DoPlayerCommonAct		= "DoPlayerCommonAct";
	PlaySceneCameraAnimation = "PlaySceneCameraAnimation";
	DoFinishTaskExtInfo		= "DoFinishTaskExtInfo";
	SetNumber = "SetNumber";
	SetActiveForever = "SetActiveForever";
}

function tbBase:init()
	self.tbTimeLock = {};		-- 当前给玩家显示的时间锁及描述
	self.tbPlayer = {};			-- 当前在副本的所有玩家ID
	self.tbNpcGroup = {};		-- npc分组，为了以群体为单位控制NPC的行为
	self.tbNpcPointCache = {};	-- npc死亡时，记录坐标Cache，预防GetPoint错误。
	self.tbFurnitureGroup = {}; -- 家具分组，为了以群体为单位控制家具的行为
	self.bClose = 0;
	self.nAnimationLockId = 0;
end

function tbBase:OnCreate(...)		-- 创建副本时的回调，参数任意
	if self.OnPreCreate then
		self:OnPreCreate(...);
	end

	self:Start()
end

function tbBase:LoadSetting(szRoadFile, szNpcPointFile)
	self.tbRoad = {};			-- AI 寻路点
	self.tbNpcPoint = {};		-- NPC 刷点
	local tbToLoad =
	{
		{self.tbRoad, szRoadFile},
		{self.tbNpcPoint, szNpcPointFile},
	}
	for i, tbData in ipairs (tbToLoad) do
		local tbNumColName = { X = 1, Y = 1 };
		local tbFile = Lib:LoadTabFile(tbData[2] or "", tbNumColName);
		if tbFile then
			for _, tbItem in pairs(tbFile) do
				local szClassName = tbItem.ClassName;
				if not tbData[1][szClassName] then
					tbData[1][szClassName] = {}
				end
				table.insert(tbData[1][szClassName], {tbItem.X, tbItem.Y});
			end
		end
	end
end

function tbBase:InitFuben(nMapId, tbRoomSetting, nFubenLevel)
	if not tbRoomSetting.LOCK then
		Log("InitFuben Failed!", nMapId, debug.traceback())
		return;
	end

	self.tbSetting = Lib:CopyTB(tbRoomSetting);				-- 房间配置
	self.nFubenLevel = nFubenLevel;				-- 敌人等级，不存在则即时计算所有玩家的平均等级

	self.tbLock = {};
	for i, tbLockSetting in pairs(tbRoomSetting.LOCK) do
		self.tbLock[i] = Lib:NewClass(tbEventLock);
		self.tbLock[i].nLockId = i;

		local nTime = self:GetNumber(tbLockSetting.nTime);
		local nNum = self:GetNumber(tbLockSetting.nNum);
		self.tbLock[i]:InitEventLock(self, nTime * Env.GAME_FPS, nNum, tbLockSetting.tbStartEvent, tbLockSetting.tbUnLockEvent);
	end
	for i, tbLockSetting in pairs(tbRoomSetting.LOCK) do -- 保证解锁顺序
		for _, verPreLock in pairs(tbLockSetting.tbPrelock) do
			if type(verPreLock) == "number" then	-- 串锁
				self.tbLock[i]:AddPreLock(self.tbLock[verPreLock]);
			elseif type(verPreLock) == "table" then -- 并锁
				local tbPreLock = {}
				for j = 1, #verPreLock do
					if self.tbLock[verPreLock[j]] then
						table.insert(tbPreLock, self.tbLock[verPreLock[j]]);
					end
				end
				self.tbLock[i]:AddPreLock(tbPreLock);
			else
				return 0;
			end
		end
	end

	self.nMapId = nMapId;

	if self.OnInitRoom then
		self:OnInitRoom();
	end

	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in ipairs(tbPlayer or {}) do
		self:JoinFuben(pPlayer);
	end
end

function tbBase:SetNumber(szKey, nValue)
	if type(nValue) ~= "number" then
		assert(false, string.format("Fuben tbBase:SetNumber(szKey, nValue) ERR ?? value NAN: %s, %s, %s",
			self.tbSetting.szFubenClass, szKey, tostring(nValue)))
		return
	end

	self.tbSetting.NUM = self.tbSetting.NUM or {}
	if self.tbSetting.NUM[szKey] then
		assert(false, string.format("Fuben tbBase:SetNumber(szKey, nValue) ERR ?? key existed: %s, %s, %s",
			self.tbSetting.szFubenClass, szKey, nValue))
		return
	end
	self.tbSetting.NUM[szKey] = nValue
end

function tbBase:GetNumber(value)
	if type(value) == "number" then
		return value;
	end

	self.tbSetting.NUM = self.tbSetting.NUM or {};
	if not self.tbSetting.NUM[value] then
		assert(false, "Fuben tbBase:GetNumber(value) ERR ?? self.tbSetting.NUM[value] is nil !! " .. self.tbSetting.szFubenClass .. "  " .. value);
		return 0;
	end

	if type(self.tbSetting.NUM[value]) == "number" then
		return self.tbSetting.NUM[value];
	end

	if not self.tbSetting.NUM[value][self.nFubenLevel] then
		assert(false, string.format("Fuben tbBase:GetNumber(value) ERR ?? szFubenClass %s, value %s, nFubenLevel %s", self.tbSetting.szFubenClass, value, self.nFubenLevel));
		return 0;
	end

	return self.tbSetting.NUM[value][self.nFubenLevel];
end

function tbBase:OnLoginBase(bReConnect)
	if self.bClose ~= 1 and self.tbCacheProgressInfo then
		me.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo));
	end
end

function tbBase:JoinFuben(pPlayer)
	if self.tbSetting.tbBeginPoint and not self.tbMultiBeginPoint then
		pPlayer.SetPosition(unpack(self.tbSetting.tbBeginPoint))
	end

	if self.tbSetting.tbMultiBeginPoint then
		self.nBPIdx = self.nBPIdx or 1;
		self.nBPIdx = self.nBPIdx > #self.tbSetting.tbMultiBeginPoint and 1 or self.nBPIdx;

		pPlayer.SetPosition(unpack(self.tbSetting.tbMultiBeginPoint[self.nBPIdx]));
		self.nBPIdx = self.nBPIdx + 1;
	end

	if self.tbSetting.nStartDir then
		pPlayer.CallClientScript("Client:SetPlayerDir", self.tbSetting.nStartDir, self.tbSetting.nMapTemplateId);
	end

	local nPlayerId = pPlayer.dwID;
	if not self.tbPlayer[nPlayerId] then
		self.tbPlayer[nPlayerId] = { szName = pPlayer.szName, nRoleId = pPlayer.dwID};
		self:OnFirstJoin(pPlayer)
	end

	if pPlayer.nMapId == self.nMapId then
		self.tbPlayer[nPlayerId].bInFuben = 1;
	end

	if self.tbDynamicRevivePoint then
		pPlayer.SetTempRevivePos(pPlayer.nMapId, unpack(self.tbDynamicRevivePoint));
	elseif self.tbSetting.tbTempRevivePoint then
		pPlayer.SetTempRevivePos(pPlayer.nMapId, unpack(self.tbSetting.tbTempRevivePoint));
	end
	self.tbPlayer[nPlayerId].nDeathCallbackId = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self);

	self:OnJoin(pPlayer);

	if self.bClose ~= 1 and self.tbCacheProgressInfo then
		pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo));
	end

	if self.tbCacheCmd then
		pPlayer.CallClientScript("Fuben:OnSyncCacheCmd", self.nMapId, self.tbCacheCmd);
	end
end

function tbBase:OnEnter(nMapId)
	self:JoinFuben(me);
end

function tbBase:OnLeave(nMapId)
	self:LeaveFuben(me);
	self:OnLeaveMap(me);
	self:PlayerDoRevive(me.dwID, true);

end

function tbBase:OnNpcDeathFubenBase(pNpc, pKiller)
	if self.szSaveNpcGroup and self.szSaveNpcGroup == pNpc.szFubenNpcGroup then
		local _, nX, nY = pNpc.GetWorldPos();
		self.SAVE_POS = {nX, nY};
		self.SAVE_DIR = pNpc.GetDir();
	end

	if self.OnKillNpc then
		self:OnKillNpc(pNpc, pKiller);
	end
	--缓存坐标，覆盖。
	if pNpc.szFubenNpcGroup then
		local _, nX, nY = pNpc.GetWorldPos();
		self.tbNpcPointCache[pNpc.szFubenNpcGroup] = {nX , nY};
	end
end

function tbBase:OnNpcTrap(szClassName)
	--npc: him
	if not self.tbTrap or not self.tbTrap[szClassName] then
		return
	end
end

function tbBase:OnPlayerTrap(szClassName)
	if self.tbTrap and self.tbTrap[szClassName] then
		if self.tbTrap[szClassName].szEvent then
			self:RaiseEvent(self.tbTrap[szClassName].szEvent)
		elseif self.tbTrap[szClassName].bExit == 1 then
			return;
		elseif self.tbTrap[szClassName].tbPoint then
			local nX, nY = unpack(self.tbTrap[szClassName].tbPoint);
			if nX and nY then
				me.SetPosition(nX, nY);
			end
		elseif self.tbTrap[szClassName].tbJump then
			local nX, nY, nSkillKind = unpack(self.tbTrap[szClassName].tbJump);
			if nX and nY then
				local nJumpSkillID = Faction:GetJumpSkillId(me.nFaction, nSkillKind or 2);
				if nJumpSkillID > 0 and not Npc.tbForbidTrapDoing[me.GetDoing()] then
					local pNpc = me.GetNpc();
					ActionMode:DoForceNoneActMode(me, "当前不能骑马！");
					ActionInteract:UnbindLinkInteract(me);
					pNpc.DelayCastSkill(nJumpSkillID, 1, nX, nY);
				end
				--me.CallClientScript("Operation:ForceJump", nX, nY, nSkillKind);
			end
		end

		if self.tbTrap[szClassName].bSyncOther then
			if self.SyncOther then
				self:SyncOther(me);
			end
		end

		if self.tbTrap[szClassName].tbSkillInfo then
			local tbSkillInfo = self.tbTrap[szClassName].tbSkillInfo;

			if tbSkillInfo.nParam1 then
				me.GetNpc().CastSkill(tbSkillInfo.nSkillId, tbSkillInfo.nSkilLevel, tbSkillInfo.nParam1, tbSkillInfo.nParam2);
			else
				self:OnUseSkillState(tbSkillInfo.nSkillId);
				me.GetNpc().AddSkillState(tbSkillInfo.nSkillId, tbSkillInfo.nSkilLevel, 0, tbSkillInfo.nTime * Env.GAME_FPS, tbSkillInfo.bSaveDeath, tbSkillInfo.bForce);
			end

			if tbSkillInfo.nUsableTime then
				tbSkillInfo.nUsableTime = tbSkillInfo.nUsableTime - 1;
			end

			if not tbSkillInfo.nUsableTime or tbSkillInfo.nUsableTime <= 0 then
				local pNpc = KNpc.GetById(tbSkillInfo.nNpcId or 0);
				if pNpc then
					pNpc.Delete();
				end
				self.tbTrap[szClassName].tbSkillInfo = nil;
			end
		end

		if self.tbTrap[szClassName].nFightState then
			me.nFightMode = self.tbTrap[szClassName].nFightState;
		end

		if self.tbTrap[szClassName].nLockId and self.tbLock[self.tbTrap[szClassName].nLockId] then
			self.tbLock[self.tbTrap[szClassName].nLockId]:UnLockMulti();
		end

		if self.tbTrap[szClassName].tbTrapCountEvent then
			self:OnTrapCount(szClassName, me.dwID);
		end
	end
end

function tbBase:OnPlayerDeath()
	-- 可重载
	self:DoAddDevive()
end

-- OnPlayerDeath 被重载需手动调用才生效
function tbBase:DoAddDevive()
	if self.tbPlayerDeathDoRevive then
		local nTime = self.tbPlayerDeathDoRevive.nTime
		local szMsg = self.tbPlayerDeathDoRevive.szMsg

		if nTime <= 0 then
			self:PlayerDoRevive(me.dwID)
		else
			me.CallClientScript("Ui:OpenWindow", "CommonDeathPopup", "AutoRevive", szMsg, nTime);
			self.tbPlayerReviveTimer = self.tbPlayerReviveTimer or {}
			self.tbPlayerReviveTimer[me.dwID] = Timer:Register(nTime * Env.GAME_FPS, self.PlayerDoRevive, self, me.dwID);
		end
	end
end

function tbBase:PlayerDoRevive(nPlayerId, bIsOut)
	self.tbPlayerReviveTimer = self.tbPlayerReviveTimer or {}
	if bIsOut and self.tbPlayerReviveTimer[nPlayerId] then
		Timer:Close(self.tbPlayerReviveTimer[nPlayerId]);
	end
	self.tbPlayerReviveTimer[nPlayerId] = nil;

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local bReviveHere = true;
	if not bIsOut and self.tbPlayerDeathDoRevive then
		bReviveHere = self.tbPlayerDeathDoRevive.bReviveHere;
	end

	local tbInfo = self.tbPlayer[nPlayerId]
	if bIsOut or (tbInfo and tbInfo.bInFuben == 1 and pPlayer.nMapId == self.nMapId) then
		pPlayer.Revive(bReviveHere and 1 or 0);
	end
end


function tbBase:OnFirstJoin(pPlayer)
	-- 可重载,第一次join到副本里会调
end

function tbBase:OnJoin(pPlayer)
	-- 可重载，每次join到副本里都会调
end

-- 此处为逻辑上离开副本
function tbBase:OnOut(pPlayer)
	-- 可重载
end

-- 此处为玩家真正离开副本，如果玩家离开副本会 先 OnOut 然后 OnLeaveMap
function tbBase:OnLeaveMap(pPlayer)
	-- 可重载
end

function tbBase:GameWin()
	-- 可重载
	self:Close();
end

function tbBase:GameLost()
	-- 可重载
	self:Close();
end

function tbBase:OnAddNpc(pNpc, ...)

end

function tbBase:LeaveFuben(pPlayer)
	local nPlayerId = pPlayer.dwID;
	if not self.tbPlayer[nPlayerId] or self.tbPlayer[nPlayerId].bInFuben ~= 1 then
		return;
	end

	self:OnOut(pPlayer);

	for szWnd in pairs(self.tbCacheWnd or {}) do
		pPlayer.CallClientScript("Ui:CloseWindow", szWnd);
	end

	for nSkillId in pairs(self.tbUsedSkillState or {}) do
		pPlayer.GetNpc().RemoveSkillState(nSkillId);
	end

	pPlayer.ClearTempRevivePos();
	if self.tbPlayer[nPlayerId].nDeathCallbackId then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbPlayer[nPlayerId].nDeathCallbackId);
		self.tbPlayer[nPlayerId].nDeathCallbackId = nil;
	end

	pPlayer.CallClientScript("Ui:SetAllUiVisable", true);
	pPlayer.CallClientScript("Ui:SetForbiddenOperation", false);

	self.tbPlayer[nPlayerId].bInFuben = 0;

	self:PlayerDoRevive(nPlayerId, true);
end

function tbBase:Start()
	self.nStartTime = GetTime();
	if self.OnBeforeStart then
		self:OnBeforeStart();
	end
	self.tbLock[1]:StartLock();
end

-- 关闭房间
function tbBase:Close()
	if self.nDealyKickOutAllMapPlayerTime then
		self:_KickOutAllMapPlayer(self.nDealyKickOutAllMapPlayerTime)
		self.nDealyKickOutAllMapPlayerTime = nil
	elseif self.nKickOutToKinMapDelayTime then
		self:_KickOutAllPlayerToKinMap(self.nKickOutToKinMapDelayTime);
		self.nKickOutToKinMapDelayTime = nil;
	end

	-- 删除循环任务
	for szType in pairs(self.tbCycleInfo or {}) do
		self:CloseCycle(szType);
	end

	-- 删除剩余的NPC
	for szGroup, _ in pairs(self.tbNpcGroup) do
		self:DelNpc(szGroup);
	end

	-- 删除家具
	for szGroup, _ in pairs(self.tbFurnitureGroup) do
		self:DeleteFurniture(szGroup);
	end

	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if tbInfo.bInFuben == 1 and pPlayer and pPlayer.nMapId == self.nMapId then
			self:LeaveFuben(pPlayer)
		end
	end

	for _, tbLock in pairs(self.tbLock) do
		local nClose = tbLock.nClose or 0
		if nClose == 0 then
			local tbSetting = self.tbSetting or {}
			local nMapTemplateId = tbSetting.nMapTemplateId
			local szFubenClass = tbSetting.szFubenClass
			Log("[FubenBase] Room Close Lock Not Close.. ", nMapTemplateId, szFubenClass, self.nFubenLevel, tbLock.nPreLockNum, tbLock.nLockId, tbLock.nStartState, tbLock.nLockState, tbLock.nTimerId, tbLock.nTime, tbLock.nMultiNum)
		end
		tbLock:Close();
	end

	if self.OnClose then
		self:OnClose();
	end

	self.bClose = 1;
	-- TODO:踢出所有玩家离开副本 or 事后?
end

-- 遍历房间所有玩家
function tbBase:AllPlayerExcute(fnExcute)
	for nPlayerId, _ in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and self.tbPlayer[nPlayerId] and self.tbPlayer[nPlayerId].bInFuben == 1 then
			fnExcute(pPlayer);
		end
	end
end

function tbBase:AllPlayerInMapExcute(fnExcute)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in ipairs(tbPlayer or {}) do
		fnExcute(pPlayer);
	end
end

-- 计算玩家等级平均值
function tbBase:GetAverageLevel()
	local nLevel = 69;
	-- 计算房间内玩家平均等级
	local nTotalLevel = 0;
	local nTotalPlayer = 0;
	for nPlayerId, _ in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			nTotalLevel = nTotalLevel + pPlayer.nLevel;
			nTotalPlayer = nTotalPlayer + 1
		end
	end
	if (nTotalPlayer ~= 0) then
		nLevel = math.ceil(nTotalLevel / nTotalPlayer);
	end
	return nLevel;
end

function tbBase:OnEvent(szEventType, ...)
	if self.EVENT_PROC[szEventType] then
		self[self.EVENT_PROC[szEventType]](self, ...);
	else
		Log("[Fuben]Undefind EventType ", szEventType, ...);
	end
end

function tbBase:RaiseEvent(szEventName, ...)
	local funProcEvent = self["On" .. szEventName];
	if not funProcEvent then
		Log(XT("[Fuben]事件") .. szEventName .. XT("没处理"))
		return;
	end

	funProcEvent(self, ...)
end

function tbBase:OnAddSkillState(pPlayer, pNpc, szParam)
	local tbRet = Lib:SplitStr(szParam or "", "|");
	local nSkillId = tonumber(tbRet[1] or 0);
	local nSkillLevel = tonumber(tbRet[2] or 1);
	local nTime = tonumber(tbRet[3] or 3600);
	if nSkillId <= 0 then
		return;
	end

	self:OnUseSkillState(nSkillId);
	pPlayer.GetNpc().AddSkillState(nSkillId, nSkillLevel, 0, nTime * Env.GAME_FPS);
	pNpc.Delete();
end

function tbBase:OnUseSkillState(nSkillId)
	self.tbUsedSkillState = self.tbUsedSkillState or {};
	self.tbUsedSkillState[nSkillId] = true;
end

function tbBase:GetPlayerPos() --获取副本上随机玩家的位置。 3秒内调用接口返回相同位置坐标
	local tbPlayer, nPlayerCount = KPlayer.GetMapPlayer(self.nMapId);
	if self.CACHE_POS then return unpack(self.CACHE_POS) end

	if not tbPlayer or nPlayerCount <= 0 then
		Log("[Fuben] use SAVE_POS ERR ?? Map NO Player !!!");
		return 1,1;
	end
	local nRandom = MathRandom(1,nPlayerCount);
	local pPlayer = tbPlayer[nRandom];
	local nMapId,nX,nY = pPlayer.GetWorldPos();
	self.CACHE_POS = {nX ,nY};
	Timer:Register(Env.GAME_FPS * 3,function() self.CACHE_POS = nil; end, self);
	return nX,nY;
end

function tbBase:GetPoint(szPointName)
	if szPointName == "SAVE_POS" then
		if not self.SAVE_POS then
			Log("[Fuben] use SAVE_POS ERR ?? self.SAVE_POS is nil !!!");
		end
		return unpack(self.SAVE_POS or {1, 1});
	end
	if szPointName == "PLAYER_POS" then
		return self:GetPlayerPos();
	end

	local szGroup = string.match(szPointName, "^%[NpcGroup%=(.+)%]$");
	if szGroup then
		local tbNewPoint = {};
		for _, nId in pairs(self.tbNpcGroup[szGroup] or {}) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				local _, x, y = pNpc.GetWorldPos();
				table.insert(tbNewPoint, {x, y});
			end
		end
		table.sort(tbNewPoint, function (a, b)
			return a[1] > b[1];
		end)
		if #tbNewPoint ~= (self.tbNpcPoint[szPointName] or {}) then
			self.tbPointFunc[szPointName] = nil;
		end
		self.tbNpcPoint[szPointName] = tbNewPoint;
	end

	local tbNpcPoint = self.tbNpcPoint[szPointName];
	if not tbNpcPoint or #tbNpcPoint <= 0 then
		tbNpcPoint = self.tbNpcPointCache[szPointName];
		if tbNpcPoint == nil and szGroup ~= nil then
			tbNpcPoint = self.tbNpcPointCache[szGroup];
		end
		if tbNpcPoint then
			return unpack(tbNpcPoint or {1,1});
		end
	end
	if not tbNpcPoint or #tbNpcPoint <= 0 then
		Log("[FubenBase] GetPoint Error, tbNpcPoint is nil !!", szPointName, self.nMapId);
		Log(debug.traceback());
		return;
	end

	self.tbPointFunc = self.tbPointFunc or {};
	if not self.tbPointFunc[szPointName] then
		self.tbPointFunc[szPointName] = Lib:GetRandomSelect(#tbNpcPoint);
	end

	local nCurPos = self.tbPointFunc[szPointName]();
	return unpack(tbNpcPoint[nCurPos]);
end

function tbBase:AddFurniture(nIndex, szGroup)
	if not self.tbSetting.FurnitureItem or not self.tbSetting.FurnitureItem[nIndex] then
		Log("[Fuben]AddFurniture Failed!"..tostring(nIndex).."FurnitureItemIndex is unexist!");
		return 0;
	end

	local tbFurnitureInfo = self.tbSetting.FurnitureItem[nIndex];
	local bRet, szMsg, nId = Decoration:NewDecoration(self.nMapId, tbFurnitureInfo.nPosX, tbFurnitureInfo.nPosY, tbFurnitureInfo.nRotation, tbFurnitureInfo.nTemplate, tbFurnitureInfo.bNotSync)
	if not bRet then
		Log("[Fuben]Do AddFurniture Failed!"..tostring(nIndex).. (szMsg or ""));
	else
		szGroup = szGroup or "Default"
		if not self.tbFurnitureGroup[szGroup] then
			self.tbFurnitureGroup[szGroup] = {};
		end
		table.insert(self.tbFurnitureGroup[szGroup], nId);
	end
end

function tbBase:DeleteFurniture(szGroup)
	if not self.tbFurnitureGroup[szGroup] then
		Log("[Fuben]DeleteFurniture Failed!"..(tostring(szGroup or "")).."szGroup is unexist!");
		return 0;
	end
	for _, nId in pairs(self.tbFurnitureGroup[szGroup]) do
		Decoration:DeleteDecoration(nId)
	end
	self.tbFurnitureGroup[szGroup] = nil;
end

function tbBase:AddFurnitureGroup(szGroup)
	if not self.tbSetting.FurnitureItemGroup or not self.tbSetting.FurnitureItemGroup[szGroup] then
		Log("[Fuben]AddFurnitureGroup Failed!"..tostring(szGroup).."FurnitureItemGroup is unexist!");
		return 0;
	end
	local tbFurnitureIndex = self.tbSetting.FurnitureItemGroup[szGroup];
	for _, nIndex in ipairs(tbFurnitureIndex) do
		self:AddFurniture(nIndex, szGroup)
	end
end

function tbBase:AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime)
	self:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime);
end

function tbBase:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, ...)
	if type(nDir) == "string" and nDir == "SAVE_DIR" then
		nDir = self.SAVE_DIR or -1;
	end

	nIndex = self:GetNumber(nIndex);
	nNum = self:GetNumber(nNum);
	if not self.tbSetting.NPC or not self.tbSetting.NPC[nIndex] then
		Log("[Fuben]AddNpc Failed!"..tostring(nIndex).."NpcIndex is unexist!");
		return 0;
	end

	local tbNpcInfo = self.tbSetting.NPC[nIndex];
	local nLevel = tbNpcInfo.nLevel;
	if not tbNpcInfo.nLevel or tbNpcInfo.nLevel <= 0 then
		nLevel = self.nEnemyLevel and self.nEnemyLevel or self:GetAverageLevel();
	end

	local nNpcTemplate = tbNpcInfo.nTemplate;
	if type(tbNpcInfo.nTemplate) ~= "number" then
		if not Fuben.tbNpcTemplateIdx[tbNpcInfo.nTemplate] then
			Log("FubenBase._AddNpc ERR ?? unknow npc template ", tbNpcInfo.nTemplate or "nil");
			return;
		end

		nNpcTemplate = Fuben.tbNpcTemplateIdx[tbNpcInfo.nTemplate][self.nFubenLevel];
	end

	nLevel = nLevel > 0 and nLevel or 50;
	for i = 1, nNum do
		local x, y = self:GetPoint(szPointName);
		if not x or not y then
			Log("[Fuben]AddNpc Failed!"..tostring(szPointName).." NpcPoint is unexist")
		    Log("[DDDDDDDDDD]AddNpc Failed!!!", nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime)
			return 0;
		end

		if type(bRevive) == "boolean" then
			bRevive = bRevive and 1 or 0
		end
		local tbNpc = {
			nTemplateId = nNpcTemplate,
			nLevel = nLevel,
			nSeries = tbNpcInfo.nSeries,
			nMapId = self.nMapId,
			nX = x,
			nY = y,
			bRevive = bRevive or 0,
			nDir = nDir,
		};

		local tbEffectInfo;
		if nEffectId and nEffectId > 0 then
			tbEffectInfo = {
				nEffectId = nEffectId,
				nEffectTime = nEffectTime,
			};
		end

		if not nDealyTime or nDealyTime <= 0 then
			self:DoAddNpc(tbNpc, tbEffectInfo, nLock, szGroup, ...);
		else
			Timer:Register(Env.GAME_FPS * nDealyTime, self.DoAddNpc, self, tbNpc, tbEffectInfo, nLock, szGroup, ...);
		end
	end
end

function tbBase:DoAddNpc(tbNpcInfo, tbEffectInfo, nLock, szGroup, ...)
	if self.bClose == 1 then
		return;
	end

	if tbEffectInfo and tbEffectInfo.nEffectId then
		self:PlayEffect(tbEffectInfo.nEffectId, tbNpcInfo.nX, tbNpcInfo.nY, 0);
		if tbEffectInfo.nEffectTime and tbEffectInfo.nEffectTime > 0 then
			Timer:Register(Env.GAME_FPS * tbEffectInfo.nEffectTime, self.DoAddNpc, self, tbNpcInfo, nil, nLock, szGroup, ...);
			return;
		end
	end

	local pNpc = KNpc.Add(tbNpcInfo.nTemplateId, tbNpcInfo.nLevel, tbNpcInfo.nSeries or -1, tbNpcInfo.nMapId, tbNpcInfo.nX, tbNpcInfo.nY, 0, tbNpcInfo.nDir);

	if pNpc then
		self:AddNpcInLock(pNpc, nLock);
		self:AddNpcInGroup(pNpc, szGroup);
		self:OnAddNpc(pNpc, ...);
	else
		Log("[Fuben]AddNpc Failed!", tbNpcInfo.nTemplate, nLevel, tbNpcInfo.nSeries, self.nMapId, x, y, nDir)
	end
end

-- 把NPC加到锁里
function tbBase:AddNpcInLock(pNpc, nLock)
	if not nLock or nLock <= 0 then
		return 0;
	end

	pNpc.tbFubenNpcData = pNpc.tbFubenNpcData or {};

	local tbTmp = pNpc.tbFubenNpcData;
	tbTmp.tbFuben = self;
	tbTmp.nLock = nLock;
end

-- 把NPC加到组里
function tbBase:AddNpcInGroup(pNpc, szGroup)
	if not self.tbNpcGroup[szGroup] then
		self.tbNpcGroup[szGroup] = {};
	end
	if pNpc then
		pNpc.szFubenNpcGroup = szGroup;
		table.insert(self.tbNpcGroup[szGroup], pNpc.nId);
	end
end

function tbBase:GetNpcGroup(pNpc)
	for szGroup, tbNpcs in pairs(self.tbNpcGroup or {}) do
		if Lib:IsInArray(tbNpcs, pNpc.nId) then
			return szGroup
		end
	end
	return nil
end

function tbBase:GetNpcCountInGroup(szGroup)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end

	local nCount = 0;
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc and pNpc.nCurLife > 0 then
			nCount = nCount + 1;
		end
	end

	return nCount;
end

-- 删除特定组的NPC
function tbBase:DelNpc(szGroup)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]DelNpc szGroup is not Exist", szGroup);
		return;
	end

	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbNpcGroup[szGroup] = nil;
end

function tbBase:SetAiActive(szGroup, bActive)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]SetAiActive szGroup is not Exist", szGroup);
		return;
	end

	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.SetAiActive(bActive);
		end
	end
end

function tbBase:SetNpcAi(szGroup, szFileAi)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]SetNpcAi szGroup is not Exist", szGroup);
		return;
	end

	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.SetAi(szFileAi);
		end
	end
end

-- 改变Trap点传送位置
function tbBase:ChangeTrap(szClassName, tbPoint, tbJump, bFight, bExit, szEvent, bSyncOther)
	if not self.tbTrap then
		self.tbTrap = {}
	end

	self.tbTrap[szClassName] = self.tbTrap[szClassName] or {};
	self.tbTrap[szClassName].tbPoint = tbPoint;
	self.tbTrap[szClassName].tbJump = tbJump;
	self.tbTrap[szClassName].nFightState = bFight;
	self.tbTrap[szClassName].bExit = bExit;
	self.tbTrap[szClassName].szEvent = szEvent;
	self.tbTrap[szClassName].bSyncOther = bSyncOther;
end

function tbBase:TrapCastSkill(szClassName, nSkillId, nSkilLevel, nParam1, nParam2, nUsableTime, nNpcTemplateId, nX, nY)
	self.tbTrap = self.tbTrap or {}
	self.tbTrap[szClassName] = self.tbTrap[szClassName] or {}
	self.tbTrap[szClassName].tbSkillInfo = {
		nSkillId = nSkillId,
		nSkilLevel = nSkilLevel,
		nParam1 = nParam1,
		nParam2 = nParam2,
		nUsableTime = nUsableTime,
	};

	local pNpc = self:AddNpcToTrap(nNpcTemplateId, nX, nY);
	if pNpc then
		self.tbTrap[szClassName].tbSkillInfo.nNpcId = pNpc.nId
	end
end

function tbBase:TrapAddSkillState(szClassName, nSkillId, nSkilLevel, nTime, bSaveDeath, bForce, nUsableTime, nNpcTemplateId, nX, nY)
	self.tbTrap = self.tbTrap or {}
	self.tbTrap[szClassName] = self.tbTrap[szClassName] or {}
	self.tbTrap[szClassName].tbSkillInfo = {
		nSkillId = nSkillId,
		nSkilLevel = nSkilLevel,
		nTime = nTime,
		bSaveDeath = bSaveDeath,
		bForce = bForce,
		nUsableTime = nUsableTime,
	};

	local pNpc = self:AddNpcToTrap(nNpcTemplateId, nX, nY);
	if pNpc then
		self.tbTrap[szClassName].tbSkillInfo.nNpcId = pNpc.nId
	end
end

function tbBase:AddNpcToTrap(nNpcTemplateId, nX, nY)
	local pNpc;
	if nNpcTemplateId and nNpcTemplateId > 0 and nX and nX > 0 and nY and nY > 0 then
		pNpc = KNpc.Add(nNpcTemplateId, 1, -1, self.nMapId, nX, nY, 0);
	end

	return pNpc;
end

function tbBase:TrapUnlock(szClassName, nLockId)
	if not self.tbTrap then
		self.tbTrap = {}
	end
	self.tbTrap[szClassName] = self.tbTrap[szClassName] or {}
	self.tbTrap[szClassName].nLockId = nLockId;
end

function tbBase:SetPos(nX, nY)
	local fnExcute = function (pPlayer)
		pPlayer.SetPosition(nX, nY);
	end
	self:AllPlayerExcute(fnExcute);
end

function tbBase:RemovePlayerSkillState(nSkillId)
	local fnExcute = function (pPlayer)
		pPlayer.GetNpc().RemoveSkillState(nSkillId);
	end
	self:AllPlayerExcute(fnExcute);
end


tbBase.AI_MODE_PROC =
{
	Move 		= "SetNpcMove",
	AttackType  = "SetAttackType",
	AddAiLockTarget = "AddAiLockTarget",
	RandomAiTarget = "RandomAiTarget",
}

function tbBase:ChangeNpcAi(szNpcGroup, szAiMode, ...)
	if not self.tbNpcGroup[szNpcGroup] then
		Log("[Fuben]ChangeNpcAi NpcGroup is not Exist", szNpcGroup);
		return 0
	end
	if self.AI_MODE_PROC[szAiMode] and self[self.AI_MODE_PROC[szAiMode]] then
		for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				self[self.AI_MODE_PROC[szAiMode]](self, pNpc, ...);
			end
		end
	else
		Log("[Fuben]ChangeNpcAi Undefin AiModeType ", szAiMode, ...);
	end
end

function tbBase:RandomAiTarget(pNpc)
	local tbAllPlayerNpcId = {};
	local fnExcute = function (pPlayer)
		table.insert(tbAllPlayerNpcId, pPlayer.GetNpc().nId);
	end
	self:AllPlayerExcute(fnExcute);

	if #tbAllPlayerNpcId > 0 then
		pNpc.AI_SetTarget(tbAllPlayerNpcId[MathRandom(#tbAllPlayerNpcId)]);
	end
end

function tbBase:AddAiLockTarget(pNpc, szTargetGroup)
	for i, nNpcId in pairs(self.tbNpcGroup[szTargetGroup]) do
		pNpc.AddAiLockTarget(nNpcId);
	end
end

function tbBase:SetAttackType(pNpc, nAttact, bRetort)
	pNpc.AI_SetAttackType(nAttact or 0, bRetort or 0);
end

-- 寻路
function tbBase:SetNpcMove(pNpc, szRoad, nLockId, nAttact, bRetort, bArriveDel, bCycle)
	pNpc.tbOnArrive = {self.OnArrive, self, nLockId, bArriveDel, bCycle};
	self:_SetNpcMove(pNpc, szRoad, nLockId, nAttact, bRetort, bCycle);
end

function tbBase:_SetNpcMove(pNpc, szRoad, nLockId, nAttact, bRetort, bCycle)
	if not self.tbRoad or not self.tbRoad[szRoad] then
		return 0;
	end

	local bOldGiveWay = pNpc.AI_SetGiveWay(0);
	local nOldAttactType, nOldRetort = pNpc.AI_SetAttackType(nAttact or 0, bRetort or 0);
	pNpc.nOldAttactType = nOldAttactType;
	pNpc.nOldRetort = nOldRetort;
	pNpc.nOldGiveWay = bOldGiveWay and 1 or 0;

	pNpc.AI_ClearMovePathPoint();
	for _,Pos in ipairs(self.tbRoad[szRoad]) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(Pos[1], Pos[2]);
		end
	end

	pNpc.AI_StartPath(bCycle or 0);
end

function tbBase:OnArrive(nLockId, bArriveDel, bCycle)
	-- 如果是循环寻路的，不会被删除
	if bCycle and bCycle == 1 then
		return 0;
	end

	-- 要先删除NPC~
	if bArriveDel == 1 then
		him.Delete();
	else
		if him.nOldAttactType and him.nOldRetort and him.nOldGiveWay then
			him.AI_SetGiveWay(him.nOldGiveWay);
			him.AI_SetAttackType(him.nOldAttactType, him.nOldRetort);
			him.nOldGiveWay = nil;
			him.nOldRetort = nil;
			him.nOldAttactType = nil;
		end
	end

	if not nLockId then
		return 0;
	end

	if not self.tbLock[nLockId] then
		return 0;
	end
	self.tbLock[nLockId]:UnLockMulti();
end

function tbBase:CloseLock(nBeginLockId, nEndLockId)
	nEndLockId = nEndLockId or nBeginLockId;
	for i = nBeginLockId, nEndLockId do
		if self.tbLock[i] then
			self.tbLock[i]:Close();
		end
	end
end

function tbBase:CloseAllLock()
	for _, tbLock in pairs(self.tbLock) do
		tbLock:Close();
	end
end

function tbBase:UseSkill(szGroup, nSkillId, nMpsX, nMpsY)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]UseSkill szGroup is not Exist", szGroup);
		return;
	end

	for _, nNpcId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.UseSkill(nSkillId, nMpsX, nMpsY);
		end
	end
end

function tbBase:CastSkillMulti(szGroup, nSkillId, nSkillLevel, szParamName, nCount)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]CastSkill szGroup is not Exist", szGroup);
		return;
	end

	for i = 1, nCount do
		local nX, nY = self:GetPoint(szParamName);
		if not nX then
			Log("[Fuben] CastSkillMulti szParamName ERR ?? nX is nil !!", szParamName);
			return;
		end
		self:CastSkill(szGroup, nSkillId, nSkillLevel, nX, nY);
	end
end

function tbBase:CastSkill(szGroup, nSkillId, nSkillLevel, nParam1, nParam2)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]CastSkill szGroup is not Exist", szGroup);
		return;
	end

	for _, nNpcId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.CastSkill(nSkillId, nSkillLevel, nParam1, nParam2);
		end
	end
end

-- 打开动态障碍
function tbBase:OpenDynamicObstacle(szObsName)
	OpenDynamicObstacle(self.nMapId, szObsName);
end

function tbBase:PlayCameraAnimation(nAnimationId, nLockId)
	self.tbSetting.ANIMATION = self.tbSetting.ANIMATION or {};
	local szAnimationPath = self.tbSetting.ANIMATION[nAnimationId];
	if not szAnimationPath then
		Log("[Fuben] ERR ?? PlayCameraAnimation szAnimationPath is nil !!", nAnimationId, nLockId);
		return;
	end

	if MODULE_GAMESERVER then
		nLockId = nil;
	end

	if self.nAnimationLockId > 0 then
		Log("[Fuben] ERR ?? PlayCameraAnimation self.nAnimationLockId = " .. self.nAnimationLockId, "nLockId = " .. nLockId);
		return;
	end

	self.nAnimationLockId = nLockId;

	local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui:CloseBlackBgWindow");
		pPlayer.CallClientScript("Ui.CameraMgr.PlayCameraAnimation", szAnimationPath);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:PlayEffect(nResId, nX, nY, nZ, bRenderPos)
	local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui:PlayEffect", nResId, nX, nY, nZ, bRenderPos);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:PlayFactionEffect(tbFactionRes, nX, nY, nZ)
    if not tbFactionRes then
    	return;
    end

    local function fnPlayEffect(pPlayer)
    	local nResId = tbFactionRes[pPlayer.nFaction][pPlayer.nSex];
    	if nResId and nResId > 0 then
			pPlayer.CallClientScript("Ui:PlayEffect", nResId, nX or 0, nY or 0, nZ or 0, true);
		else
			Log("Error Funben Base Not Res", pPlayer.nFaction);
		end
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:PlayCGAnimation(nCGID)
    local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("CGAnimation:Play", nCGID);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:ShowAllRepresentObj(bShow)
    local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui:ShowAllRepresentObj", bShow);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:PlayCameraEffect(nResId)
    local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui:PlayCameraEffect", nResId);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:OpenWindow(...)
	local tbPack = {...};
	local function fnOpenWindow(pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", unpack(tbPack));
	end

	self:AllPlayerExcute(fnOpenWindow);
end

function tbBase:OpenWindowAutoClose(...)
	self.tbCacheWnd = self.tbCacheWnd or {};
	local tbPack = {...};
	if tbPack[1] then
		self.tbCacheWnd[tbPack[1]] = true;
	end

	self:OpenWindow(...);
end

function tbBase:CloseWindow(szWnd)
	local function fnOpenWindow(pPlayer)
		pPlayer.CallClientScript("Ui:CloseWindow", szWnd);
	end

	self:AllPlayerExcute(fnOpenWindow);
end

function tbBase:PreLoadWindow(szWnd)
	local function fnOpenWindow(pPlayer)
		pPlayer.CallClientScript("Ui:PreLoadWindow", szWnd);
	end

	self:AllPlayerExcute(fnOpenWindow);
end

function tbBase:PlaySound(nSoundID)
	 local function fnPlaySound(pPlayer)
		pPlayer.CallClientScript("Ui:PlayNpcSond", nSoundID);
	end

	self:AllPlayerExcute(fnPlaySound);
end

function tbBase:RestoreCameraRotation()
	local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui.CameraMgr.RestoreCameraRotation");
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:LeaveAnimationState(bRestoreCameraRotation)
	local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui.CameraMgr.LeaveCameraAnimationState");
		if bRestoreCameraRotation then
			pPlayer.CallClientScript("Ui.CameraMgr.RestoreCameraRotation");
		end
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:MoveCamera(nLockId, nTime, nX, nY, nZ, nrX, nrY, nrZ)
	if not MODULE_GAMESERVER and self.nAnimationLockId > 0 then
		Log("[Fuben] ERR ?? MoveCamera self.nAnimationLockId = " .. self.nAnimationLockId, "nLockId = " .. nLockId);
		return;
	end

	if not MODULE_GAMESERVER then
		self.nAnimationLockId = nLockId;
	end

	local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui.CameraMgr.MoveCameraTo", nTime, nX, nY, nZ, nrX, nrY, nrZ);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:MoveCameraToPosition(nLockId, nTime, nX, nY, nDist)
	if not MODULE_GAMESERVER and self.nAnimationLockId > 0 then
		Log("[Fuben] ERR ?? MoveCameraToPosition self.nAnimationLockId = " .. self.nAnimationLockId, "nLockId = " .. nLockId);
		return;
	end

	if not MODULE_GAMESERVER then
		self.nAnimationLockId = nLockId;
	end

	local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui.CameraMgr.MoveCameraToPosition", nTime, nX, nY, nDist);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:MoveCameraByTarget(nLockId, nTime, rY)
	if not MODULE_GAMESERVER and self.nAnimationLockId > 0 then
		Log("[Fuben] ERR ?? MoveCamera self.nAnimationLockId = " .. self.nAnimationLockId, "nLockId = " .. nLockId);
		return;
	end

	if not MODULE_GAMESERVER then
		self.nAnimationLockId = nLockId;
	end

	local function fnPlayEffect(pPlayer)
		pPlayer.CallClientScript("Ui.CameraMgr.MoveCameraByTarget", nTime, rY);
	end

	self:AllPlayerExcute(fnPlayEffect);
end

function tbBase:UnLock(nLockId)
	if self.tbLock[nLockId] then
		self.tbLock[nLockId]:UnLockMulti();
	end
end

function tbBase:BlackMsg(szMsg)
	local fnExcute = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	self:AllPlayerExcute(fnExcute);
end

function tbBase:Msg(szMsg)
	local fnExcute = function (pPlayer)
		pPlayer.Msg(szMsg)
	end
	self:AllPlayerExcute(fnExcute);
end

function tbBase:SetTargetPos(nX, nY)
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Fuben:SetTargetPos", nX, nY);
	end
	self:AllPlayerExcute(fnExcute);
end

function tbBase:ClearTargetPos()
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Fuben:SetTargetPos", 0, 0);
	end
	self:AllPlayerExcute(fnExcute);
end

-- 改变战斗模式
function tbBase:ChangeFightState(nFightState)
	local fnExcute = function (pPlayer)
		if pPlayer.nFightState ~= 2 then
			pPlayer.nFightMode = nFightState;
		end
	end
	self:AllPlayerExcute(fnExcute);
end

function tbBase:SetFubenProgress(nPersent, szInfo)
	self.tbCacheProgressInfo = {nPersent, szInfo};
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Fuben:SetFubenProgress", nPersent, szInfo);
	end
	self:AllPlayerExcute(fnExcute);
end

function tbBase:SetGameWorldScale(nScale)
	nScale = math.max(math.min(nScale, 5), 0.01);
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("SetGameWorldScale", nScale);
	end

	self:AllPlayerExcute(fnExcute);
end

function tbBase:ShowTaskDialog(nDialogId, bIsOnce)
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Ui:TryPlaySitutionalDialog", nDialogId, bIsOnce);
	end

	self:AllPlayerExcute(fnExcute);
end

function tbBase:PlaySceneAnimation(szObjectName, szAnimationName, nSpeed, bFinishHide)
	nSpeed = nSpeed or 1;
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui.Effect.PlaySceneAnimation", szObjectName, szAnimationName, nSpeed, bFinishHide);
	end

	self.tbCacheCmd = self.tbCacheCmd or {};
	table.insert(self.tbCacheCmd, {"Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui.Effect.PlaySceneAnimation", szObjectName, szAnimationName, nSpeed, bFinishHide});

	self:AllPlayerExcute(fnExcute);
end

function tbBase:PlaySceneAnimationWithPlayer(szObjectName, szAnimationName, nSpeed, bFinishHide)
	nSpeed = nSpeed or 1
	if bFinishHide == nil then
		bFinishHide = false
	end
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui.Effect.PlaySceneAnimationWithPlayer", szObjectName, szAnimationName, 0, nSpeed, bFinishHide);
	end

	self.tbCacheCmd = self.tbCacheCmd or {};
	table.insert(self.tbCacheCmd, {"Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui.Effect.PlaySceneAnimationWithPlayer", szObjectName, szAnimationName, 0, nSpeed, bFinishHide});

	self:AllPlayerExcute(fnExcute);
end

function tbBase:BatchPlaySceneAnimation(szObjectName, nStartIdx, nEndIdx, szAnimationName, nSpeed, bFinishHide)
	nSpeed = nSpeed or 1;
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui:BatchPlaySceneAnimation", szObjectName, nStartIdx, nEndIdx, szAnimationName, nSpeed, bFinishHide);
	end

	self.tbCacheCmd = self.tbCacheCmd or {};
	table.insert(self.tbCacheCmd, {"Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui:BatchPlaySceneAnimation", szObjectName, nStartIdx, nEndIdx, szAnimationName, nSpeed, bFinishHide});

	self:AllPlayerExcute(fnExcute);
end

function tbBase:SetForbiddenOperation(bForbidden, bNotJoyStick)
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Ui:SetForbiddenOperation", bForbidden, bNotJoyStick);
	end

	self:AllPlayerExcute(fnExcute);
end

function tbBase:SetHeadVisiable(szNpcGroup, bShow, nDealyTime)
	nDealyTime = nDealyTime or 0;
	Timer:Register(nDealyTime * Env.GAME_FPS + 1, self._SetHeadVisiable, self, szNpcGroup, bShow);
end

function tbBase:_SetHeadVisiable(szNpcGroup, bShow)
	if not self.tbNpcGroup[szNpcGroup] then
		Log("[Fuben]_SetHeadVisiable szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
		local fnExcute = function (pPlayer)
			pPlayer.CallClientScript("Npc:DoCmdWhenNpcLoadFinish", nNpcId, "Ui.Effect.SetAvatarHeadVisable", nNpcId, bShow);
		end
		self:AllPlayerExcute(fnExcute);
	end
end

function tbBase:SetNpcBloodVisable(szNpcGroup, bShow, nDealyTime)
	nDealyTime = nDealyTime or 0;
	Timer:Register(nDealyTime * Env.GAME_FPS + 1, self._SetNpcBloodVisable, self, szNpcGroup, bShow);
end

function tbBase:_SetNpcBloodVisable(szNpcGroup, bShow)
	if not self.tbNpcGroup[szNpcGroup] then
		Log("[Fuben]_SetNpcBloodVisable szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
		local fnExcute = function (pPlayer)
			pPlayer.CallClientScript("Npc:DoCmdWhenNpcLoadFinish", nNpcId, "Ui.Effect.SetNpcBloodVisable", nNpcId, bShow);
		end
		self:AllPlayerExcute(fnExcute);
	end
end

function tbBase:ChangeNpcCamp(szNpcGroup, nCamp)
	if not self.tbNpcGroup[szNpcGroup] then
		Log("[Fuben]ChangeNpcCamp NpcGroup is not Exist", szNpcGroup);
		return 0;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetCamp(nCamp);
		end
	end
end

function tbBase:SetNpcPos(szNpcGroup, nX, nY)
	if not self.tbNpcGroup[szNpcGroup] then
		Log("[Fuben]SetNpcPos szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetPosition(nX, nY);
		end
	end
end

function tbBase:SetAllUiVisiable(bShow)
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Ui:SetAllUiVisable", bShow);
	end

	self:AllPlayerExcute(fnExcute);
end

function tbBase:Random(...)
	local tbParam = {...}
	local nValue = MathRandom(1, 1000000);
	for _, tbInfo in pairs(tbParam) do
		if nValue <= tbInfo[1] then
			self.tbLock[tbInfo[2]]:StartLock();
			break;
		end
		nValue = nValue - tbInfo[1];
	end
end

function tbBase:DoIfCase(szCase, ...)
	local nCurTime = GetTime();
	local nAverageLevel = self:GetAverageLevel()
	local _, nPlayerCount = KPlayer.GetMapPlayer(self.nMapId);
	local tbParam =
	{
		nEnemyLevel = self.nEnemyLevel or nAverageLevel,
		nLevel = nAverageLevel,
		nPassedTime = nCurTime - (self.nStartTime or nCurTime),
		nPlayerCount = nPlayerCount;
		nStarLevel = self.nStarLevel or 0;
		nFubenLevel = self.nFubenLevel;
		bElite = self.bElite;
	}
	Fuben.tbExcuteTable = tbParam;
	local fnExc = loadstring("local self = Fuben.tbExcuteTable; return "..szCase);
	if fnExc then
		local nExcRet, nResult = xpcall(fnExc, Lib.ShowStack);
		if nResult then
			local tbEvent = {...}
			for _, tbInfo in ipairs(tbEvent) do
				self:OnEvent(unpack(tbInfo))
			end
		end
	end
	Fuben.tbExcuteTable = nil;
end

function tbBase:DoIfPlayer(szCase, nNeedCount, ...)
	local fnExc = loadstring("local pPlayer = ...; return "..szCase);
	local nSucCount = 0;
	local nFaiCount = 0;
	if fnExc then
		local fnExcute = function (pPlayer)
			if fnExc(pPlayer) then
				nSucCount = nSucCount + 1;
			else
				nFaiCount = nFaiCount + 1;
			end
		end
		self:AllPlayerExcute(fnExcute);
	end

	if (nNeedCount >= 0 and nSucCount >= nNeedCount) or
		(nNeedCount < 0 and nFaiCount == 0 and nSucCount > 0) then
		local tbEvent = {...}
		for _, tbInfo in ipairs(tbEvent) do
			self:OnEvent(unpack(tbInfo))
		end
	end
end

function tbBase:PauseLock(nLockId)
	if self.tbLock[nLockId] then
		self.tbLock[nLockId]:Pause();
	end
end

function tbBase:ResumeLock(nLockId)
	if self.tbLock[nLockId] then
		self.tbLock[nLockId]:Resume();
	end
end

function tbBase:SetShowTime(nLockId, bNotNextFrame, szTimeTitle, bCache)
	if not bNotNextFrame then
		Timer:Register(1, self.SetShowTime, self, nLockId, true, szTimeTitle, bCache);
		return;
	end

	local nEndTime = 0
	if self.tbLock[nLockId] then
		nEndTime = GetTime() + math.floor(Timer:GetRestTime(self.tbLock[nLockId].nTimerId) / Env.GAME_FPS);
	end
	self.szShowTimeTitle = szTimeTitle
	self.nShowEndTime = nEndTime;
	self.szShowTimeTitle = szTimeTitle;
	local function fnSetShowTime(pPlayer)
		pPlayer.CallClientScript("Fuben:SetEndTime", nEndTime, szTimeTitle);
	end
	self:AllPlayerExcute(fnSetShowTime);
	if bCache then
		self.tbCacheCmd = self.tbCacheCmd or {};
		table.insert(self.tbCacheCmd, {"Fuben:SetEndTime", nEndTime, szTimeTitle});
	end
end

function tbBase:SetKickoutPlayerDealyTime(nTime)
	self.nDealyKickOutAllMapPlayerTime = nTime;
end

function tbBase:SetPlayerDeathDoRevive(nTime, szMsg, bReviveHere)
	nTime = nTime or 0
	szMsg = szMsg or "您将在 %d 秒后复活"
	self.tbPlayerDeathDoRevive = {nTime = nTime, szMsg = szMsg, bReviveHere = bReviveHere}
end

function tbBase:_KickOutAllMapPlayer(nTime)
	if not nTime or nTime <= 0 then
		return
	end

	local function fnLeave(pPlayer)
		pPlayer.GotoEntryPoint();
	end

	Timer:Register(math.floor(Env.GAME_FPS * nTime) + 1, function ()
		self:AllPlayerInMapExcute(fnLeave);
	end);

end

function tbBase:SetTargetInfo(szInfo, nLockId, bNotNextFrame, bCache)
	if not bNotNextFrame then
		Timer:Register(1, self.SetTargetInfo, self, szInfo, nLockId, true, bCache);
		return;
	end

	local nEndTime = 0;
	if self.tbLock[nLockId] then
		nEndTime = GetTime() + math.floor(Timer:GetRestTime(self.tbLock[nLockId].nTimerId) / Env.GAME_FPS);
	end
	self.tbCacheTargetInfo = {szInfo, nLockId}
	local function fnSetTargetInfo(pPlayer)
		pPlayer.CallClientScript("Fuben:SetTargetInfo", szInfo, nEndTime);
	end
	self:AllPlayerExcute(fnSetTargetInfo);
	if bCache then
		self.tbCacheCmd = self.tbCacheCmd or {};
		table.insert(self.tbCacheCmd, {"Fuben:SetTargetInfo", szInfo, nEndTime});
	end
end

function tbBase:NpcBubbleTalk(szNpcGroup, szContent, nDuration, nDealyTime, nMaxCount)
	if nDealyTime == 0 then
		self:_NpcBubbleTalk(szNpcGroup, szContent, nDuration, nMaxCount);
	else
		Timer:Register(Env.GAME_FPS * nDealyTime, self._NpcBubbleTalk, self, szNpcGroup, szContent, nDuration, nMaxCount);
	end
end

function tbBase:_NpcBubbleTalk(szNpcGroup, szContent, nDuration, nMaxCount)
	if not self.tbNpcGroup[szNpcGroup] then
		Log("[Fuben]NpcBubbleTalk NpcGroup is not Exist", szNpcGroup);
		return;
	end

	local tbAllNpc = {};
	for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			table.insert(tbAllNpc, nNpcId);
		end
	end

	local function fnNpcBubbleTalk(pPlayer)
		pPlayer.CallClientScript("Ui:NpcBubbleTalk", tbAllNpc, szContent, nDuration, nMaxCount);
	end
	self:AllPlayerExcute(fnNpcBubbleTalk);
end

function tbBase:AddAnger(nAnger)
	local function fnAddAnger(pPlayer)
		pPlayer.GetNpc().AddAnger(nAnger);
	end
	self:AllPlayerExcute(fnAddAnger);
end

function tbBase:DoDeath(szGroup)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]DoDeath szGroup is not Exist", szGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.DoDeath();
		end
	end
end

function tbBase:OnTrapCount(szClassName, nPlayerId)
	local tbTrapCountEvent = (self.tbTrap[szClassName] or {}).tbTrapCountEvent;
	if not tbTrapCountEvent or tbTrapCountEvent.tbPlayer[nPlayerId] then
		return;
	end

	local _, nPlayerCount = KPlayer.GetMapPlayer(self.nMapId);
	local nCurCount = tbTrapCountEvent.nCurCount + 1;
	tbTrapCountEvent.nCurCount = nCurCount;
	tbTrapCountEvent.tbPlayer[nPlayerId] = true;

	local nLastEventCount = 0;
	local tbCurEvent = {};
	for nCount, tbEvent in pairs(tbTrapCountEvent.tbEvent) do
		nCount = (nCount == -1 and nPlayerCount or nCount);
		if nCount > nCurCount and nCount <= nPlayerCount then
			nLastEventCount = nLastEventCount + 1;
		elseif nCount == nCurCount then
			for _, tbEve in ipairs(tbEvent) do
				table.insert(tbCurEvent, tbEve);
			end
		end
	end

	if nLastEventCount <= 0 then
		self.tbTrap[szClassName].tbTrapCountEvent = nil;
	end

	if not tbCurEvent then
		return;
	end

	for _, tbInfo in ipairs(tbCurEvent) do
		self:OnEvent(unpack(tbInfo))
	end

	tbTrapCountEvent[nCurCount] = nil;
end

function tbBase:DoIfTrapCount(szClassName, nNeedCount, ...)
	if not self.tbTrap then
		self.tbTrap = {}
	end

	self.tbTrap[szClassName] = self.tbTrap[szClassName] or {};
	self.tbTrap[szClassName].tbTrapCountEvent = self.tbTrap[szClassName].tbTrapCountEvent or {};

	local tbTrapCountEvent = self.tbTrap[szClassName].tbTrapCountEvent;

	tbTrapCountEvent.nCurCount = 0;
	tbTrapCountEvent.tbPlayer = {};
	tbTrapCountEvent.tbEvent = tbTrapCountEvent.tbEvent or {};
	tbTrapCountEvent.tbEvent[nNeedCount] = {...};
end

function tbBase:CastSkillCycle(szType, szGroup, nTimeSpace, nSkillId, nSkilLevel, nParam1, nParam2)
	self.tbCycleInfo = self.tbCycleInfo or {};

	local function fnCastSkill()
		if not self.tbNpcGroup[szGroup] then
			Log("[Fuben]CastSkillCycle szGroup is not Exist", szGroup);
			return;
		end

		for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.CastSkill(nSkillId, nSkilLevel, nParam1, nParam2);
			end
		end

		return true;
	end

	self.tbCycleInfo[szType] = self.tbCycleInfo[szType] or {};
	local nTimerId = Timer:Register(Env.GAME_FPS * nTimeSpace, fnCastSkill);
	table.insert(self.tbCycleInfo[szType], nTimerId);

	fnCastSkill();
end

function tbBase:StartTimeCycle(szType, nTimeSpace, nCycleCount, ...)
	self.tbCycleInfo = self.tbCycleInfo or {};
	self.tbCycleEventInfo = self.tbCycleEventInfo or {nIdx = 0};
	self.tbCycleEventInfo.nIdx = self.tbCycleEventInfo.nIdx + 1;
	self.tbCycleEventInfo[self.tbCycleEventInfo.nIdx] = {};


	local tbEventInfo = self.tbCycleEventInfo[self.tbCycleEventInfo.nIdx];
	tbEventInfo.szType = szType;
	tbEventInfo.tbEvent = {...};
	tbEventInfo.nCycleCount = nCycleCount;
	if not nCycleCount or nCycleCount <= 0 then
		tbEventInfo.nCycleCount = 9999;
	end

	local function fnCycle(self, nIdx)
		local tbEventInfo = self.tbCycleEventInfo[nIdx];
		if not tbEventInfo then
			return;
		end

		tbEventInfo.nCount = tbEventInfo.nCount or 0;
		tbEventInfo.nCount = tbEventInfo.nCount + 1;
		for _, tbInfo in ipairs(tbEventInfo.tbEvent) do
			self:OnEvent(unpack(tbInfo));
		end

		if tbEventInfo.nCount >= tbEventInfo.nCycleCount then
			for nId, nTimerId in pairs(self.tbCycleInfo[tbEventInfo.szType] or {}) do
				if nTimerId == tbEventInfo.nTimerId then
					table.remove(self.tbCycleInfo[tbEventInfo.szType], nId);
					break;
				end
			end
		end

		return tbEventInfo.nCount < tbEventInfo.nCycleCount;
	end

	self.tbCycleInfo[szType] = self.tbCycleInfo[szType] or {};
	local nTimerId = Timer:Register(Env.GAME_FPS * nTimeSpace, fnCycle, self, self.tbCycleEventInfo.nIdx);
	tbEventInfo.nTimerId = nTimerId;
	table.insert(self.tbCycleInfo[szType], nTimerId);
end

function tbBase:CloseCycle(szType)
	self.tbCycleInfo = self.tbCycleInfo or {};
	for _, nTimerId in pairs(self.tbCycleInfo[szType] or {}) do
		Timer:Close(nTimerId);
	end

	self.tbCycleInfo[szType] = nil;
end

function tbBase:ChangeCameraSetting(fDistance, fLookDownAngle, fFieldOfView)
	local function fnChangeCameraSetting(pPlayer)
		pPlayer.CallClientScript("Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui.CameraMgr.ChangeCameraSetting", fDistance, fLookDownAngle, fFieldOfView);
	end
	self.tbCacheCmd = self.tbCacheCmd or {};
	table.insert(self.tbCacheCmd, {"Map:DoCmdWhenMapLoadFinish", self.nMapId, "Ui.CameraMgr.ChangeCameraSetting", fDistance, fLookDownAngle, fFieldOfView});
	self:AllPlayerExcute(fnChangeCameraSetting);
end

function tbBase:NpcHpUnlock(szGroup, nLockId, nPercent)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]NpcHpUnlock szGroup is not Exist", szGroup);
		return;
	end

	local function fnHpUnlock()
		if self.tbLock[nLockId] then
			self.tbLock[nLockId]:UnLockMulti();
		end
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			Npc:RegisterNpcHpPercent(pNpc, nPercent, fnHpUnlock);
		end
	end
end

function tbBase:SetBossBlood(szGroup, nBloodLevel, nDealyTime)
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(Env.GAME_FPS * nDealyTime, self.SetBossBlood, self, szGroup, nBloodLevel);
		return;
	end

	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]SetBossBlood szGroup is not Exist", szGroup);
		return;
	end

	local pNpc = nil;
	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			break;
		end
	end

	if not pNpc then
		return;
	end

	local function fnShowBossBlood(pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "SpecialLife", pNpc.nId, nBloodLevel);
	end
	self:AllPlayerExcute(fnShowBossBlood);
end

function tbBase:ChangeNpcFightState(szGroup, nFightState, nDealyTime)
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(Env.GAME_FPS * nDealyTime, self.ChangeNpcFightState, self, szGroup, nFightState);
		return;
	end

	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]ChangeNpcFightState szGroup is not Exist", szGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.nFightMode = nFightState;
		end
	end
end

function tbBase:AddSimpleNpc(nNpcTemplateId, nX, nY, nDir)
	KNpc.Add(nNpcTemplateId, 1, -1, self.nMapId, nX, nY, 0, nDir);
end

function tbBase:SetNpcProtected(szGroup, nProtected)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]SetNpcProtected szGroup is not Exist", szGroup);
		return;
	end

	nProtected = nProtected or 0;
	nProtected = nProtected == 1 and 1 or 0;
	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetProtected(nProtected);
		end
	end
end

function tbBase:SetPlayerProtected(nProtected)
	nProtected = nProtected or 0;
	nProtected = nProtected == 1 and 1 or 0;
	local function fnShowBossBlood(pPlayer)
		pPlayer.GetNpc().SetProtected(nProtected);
	end
	self:AllPlayerExcute(fnShowBossBlood);
end

function tbBase:SaveNpcInfo(szNpcGroup)
	self.szSaveNpcGroup = szNpcGroup;
end

function tbBase:AddBuff(nSkillId, nSkilLevel, nTime, bSaveDeath, bForce)
	local function fnAddBuff(pPlayer)
		self:OnUseSkillState(nSkillId);
		pPlayer.GetNpc().AddSkillState(nSkillId, nSkilLevel, 0, nTime * Env.GAME_FPS, bSaveDeath, bForce);
	end
	self:AllPlayerExcute(fnAddBuff);
end

function tbBase:NpcAddBuff(szGroup, nSkillId, nSkilLevel, nTime)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]NpcAddBuff szGroup is not Exist", szGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.AddSkillState(nSkillId, nSkilLevel, 0, nTime * Env.GAME_FPS);
		end
	end
end

function tbBase:NpcRemoveBuff(szGroup, nSkillId)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]NpcRemoveBuff szGroup is not Exist", szGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.RemoveSkillState(nSkillId);
		end
	end
end

function tbBase:OpenGuide(nUnLock, szDescType, szDesc, szWindow, szWnd, tbPointer, bDisableClick, bBlackBg, bDisableVoice)
	if MODULE_GAMESERVER then
		return;
	end

	self.tbCacheWnd = self.tbCacheWnd or {};
	self.tbCacheWnd["Guide"] = true;
    self.nGuideLockId = nUnLock;
	Fuben:OpenGuide(self, szDescType, szDesc, szWindow, szWnd, tbPointer, bDisableClick, bBlackBg, bDisableVoice);
end

function tbBase:SetSceneSoundScale(nScale)
	local function fnSend(pPlayer)
		pPlayer.CallClientScript("Ui:SetSceneSoundScale", nScale);
	end

	self:AllPlayerExcute(fnSend);
end

function tbBase:SetDialogueSoundScale(nScale)
	local function fnSend(pPlayer)
		pPlayer.CallClientScript("Ui:SetDialogueSoundScale", nScale);
	end

	self:AllPlayerExcute(fnSend);
end

function tbBase:SetEffectSoundScale(nScale)
    local function fnSend(pPlayer)
		pPlayer.CallClientScript("Ui:SetEffectSoundScale", nScale);
	end

	self:AllPlayerExcute(fnSend);
end

function tbBase:SetGuidingJoyStick(bGuid)
    Operation:SetGuidingJoyStick(bGuid);
end

function tbBase:NpcFindEnemyUnlock(szGroup, nLockId, nDealyTime)
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(Env.GAME_FPS * nDealyTime, self.NpcFindEnemyUnlock, self, szGroup, nLockId);
		return;
	end

	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]NpcFindEnemyUnlock szGroup is not Exist", szGroup);
		return;
	end

	local function fnOnFindEnemy(pNpc, pTarget)
		if self.bClose == 1 then
			return;
		end

		local nEnemyUnlockId = pNpc.nEnemyUnlockId;
		if not nEnemyUnlockId or not self.tbLock[nEnemyUnlockId] then
			return;
		end

		pNpc.nEnemyUnlockId = nil;
		pNpc.SetFindEnemyNotify(false);
		self.tbLock[nEnemyUnlockId]:UnLockMulti();
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetFindEnemyNotify(true);
			pNpc.nEnemyUnlockId = nLockId;
			pNpc.fnOnFindEnemy = fnOnFindEnemy;
		end
	end
end

function tbBase:NpcFindEnemyRaiseEvent(szGroup, bDelete, szEvent, ...)
	if not self.tbNpcGroup[szGroup] then
		Log("[Fuben]NpcFindEnemyRaiseEvent szGroup is not Exist", szGroup);
		return;
	end

	local tbArgs = {...}
	local function fnOnFindEnemy(pNpc, pTarget)
		if self.bClose == 1 then
			return;
		end

		pNpc.SetFindEnemyNotify(false);
		if bDelete then
			pNpc.Delete()
		end
		self:RaiseEvent(szEvent, pTarget.dwPlayerID, unpack(tbArgs))
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetFindEnemyNotify(true);
			pNpc.fnOnFindEnemy = fnOnFindEnemy;
		end
	end
end

function tbBase:SetNpcRange(szNpcGroup, nVisionRadius, nActiveRadius, nDealyTime)
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(Env.GAME_FPS * nDealyTime, self.SetNpcRange, self, szNpcGroup, nVisionRadius, nActiveRadius);
		return;
	end

	if not self.tbNpcGroup[szNpcGroup] then
		Log("[Fuben]SetNpcRange szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetNpcRange(nVisionRadius or 0, nActiveRadius or 0);
		end
	end
end

function tbBase:SetNpcDir(szNpcGroup, nDir)
	-- if MODULE_GAMESERVER then
	-- 	return;
	-- end
	local tbGroup = self.tbNpcGroup[szNpcGroup];
	if not tbGroup then
		Log("[Fuben]SetNpcDir szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	for i, nNpcId in pairs(tbGroup) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetDir(nDir or 0);
		end
	end
end

function tbBase:StopEndTime()
	local function fnStop(pPlayer)
		pPlayer.CallClientScript("Fuben:StopEndTime");
	end

	self:AllPlayerExcute(fnStop);
end

function tbBase:SetPlayerDir(nDir)
	if MODULE_GAMESERVER then
		return;
	end

	local function fnSetDir(pPlayer)
		pPlayer.GetNpc().SetDir(nDir);
	end

	self:AllPlayerExcute(fnSetDir);
end

function tbBase:DropBuffer(nX, nY, szBuffInfo)
	if type(nX) == "string" then
		nX, nY = self:GetPoint(nX);
	end

	Item.Obj:DropBuffer(self.nMapId, nX, nY, szBuffInfo);
end

function tbBase:DoCommonAct(szNpcGroup, nActId, nActEventId, bLoop, nFrame)
	if not bLoop then
		bLoop = 0;
	end
	nFrame = nFrame or 0;

	local tbGroup = self.tbNpcGroup[szNpcGroup];
	if not tbGroup then
		Log("[Fuben]DoCommonAct szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	local function fnDoCommonAct(pPlayer)
		pPlayer.CallClientScript("Fuben:DoCommonAct", tbGroup, nActId, nActEventId, bLoop, nFrame)
	end

	self:AllPlayerExcute(fnDoCommonAct);
end

function tbBase:SetNearbyRange(nRange)
	if not MODULE_GAMESERVER then
		return;
	end

	SetMapNearbyRange(self.nMapId, nRange);
end

function tbBase:SetDynamicRevivePoint(nX, nY)
	self.tbDynamicRevivePoint = {nX, nY};

	local function fnSetRevivePos(pPlayer)
		pPlayer.SetTempRevivePos(pPlayer.nMapId, unpack(self.tbDynamicRevivePoint));
	end

	self:AllPlayerExcute(fnSetRevivePos);
end

function tbBase:PlayerBubbleTalk(szMsg)
	local function fnBubbleTalk(pPlayer)
		pPlayer.CallClientScript("ChatMgr:OnChannelMessage", ChatMgr.ChannelType.Nearby, pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nPortrait, pPlayer.nLevel, szMsg);
	end

	self:AllPlayerExcute(fnBubbleTalk);
end

function tbBase:HomeScreenTip(szTitle, szInfo, nShowTime, nDealyTime)
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(nDealyTime * Env.GAME_FPS, self.HomeScreenTip, self, szTitle, szInfo, nShowTime);
		return;
	end

	local function fnHomeScreenTip(pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenTip", szTitle, szInfo, nShowTime);
	end
	self:AllPlayerInMapExcute(fnHomeScreenTip);
end

function tbBase:SetActiveForever(szNpcGroup, nActive)
	if not MODULE_GAMESERVER then
		return;
	end

	local tbGroup = self.tbNpcGroup[szNpcGroup];
	if not tbGroup then
		Log("[Fuben]SetActiveForever szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	for i, nNpcId in pairs(tbGroup) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SetActiveForever(nActive);
		end
	end
end

function tbBase:GetTextContent(szContentGroup)
	self.tbSetting.TEXT_CONTNET = self.tbSetting.TEXT_CONTNET or {};
	return self.tbSetting.TEXT_CONTNET[szContentGroup];
end

function tbBase:NpcRandomTalk(szNpcGroup, szContentGroup, nDuration, nDealyTime, nMaxCount)
	self.tbNpcRandomTalkFunc = self.tbNpcRandomTalkFunc or {};
	local fnRandomContent = self.tbNpcRandomTalkFunc[szContentGroup];
	if not fnRandomContent then
		local tbContent = self:GetTextContent(szContentGroup);
		if not tbContent or #tbContent <= 0 then
			Log("[ERROR][Fuben] text content group not existed: ", self.nMapId, szContentGroup);
			return;
		end
		fnRandomContent = Lib:GetDifferentRandomSelect(tbContent);
		self.tbNpcRandomTalkFunc[szContentGroup] = fnRandomContent;
	end

	local szContent = fnRandomContent();
	self:NpcBubbleTalk(szNpcGroup, szContent, nDuration, nDealyTime, nMaxCount);
end

function tbBase:_KickOutAllPlayerToKinMap(nTime)
	if not nTime or nTime <= 0 then
		return;
	end

	local function fnLeave(pPlayer)
		local bRet = Map:SwitchKinMap(pPlayer);
		if not bRet then
			pPlayer.GotoEntryPoint();
		end
	end

	Timer:Register(math.floor(Env.GAME_FPS * nTime) + 1, function ()
		self:AllPlayerInMapExcute(fnLeave);
	end);
end

function tbBase:SetKickOutToKinMapDelayTime(nTime)
	self.nKickOutToKinMapDelayTime = nTime;
end

function tbBase:SetNpcLife(szNpcGroup, nPercent)
	local tbGroup = self.tbNpcGroup[szNpcGroup];
	if not tbGroup then
		Log("[Fuben]SetNpcLife szNpcGroup is not Exist", szNpcGroup);
		return;
	end

	for i, nNpcId in pairs(tbGroup) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local nLife = math.max(math.min(math.floor(nPercent * pNpc.nMaxLife / 100), pNpc.nMaxLife), 1);
			pNpc.SetCurLife(nLife);
		end
	end
end

function tbBase:PlayHelpVoice(szVoicePath)
	if MODULE_GAMESERVER then
		local function fnPlay(pPlayer)
			pPlayer.CallClientScript("ChatMgr.PlayHelpVoice", szVoicePath);
		end

		self:AllPlayerExcute(fnPlay);
	else
		ChatMgr.PlayHelpVoice(szVoicePath);
	end
end

function tbBase:DoPlayerCommonAct(nActId, nActEventId, bLoop, nFrame)
	bLoop = bLoop or 0;
	nFrame = nFrame or 0;

	self:AllPlayerExcute(function (pPlayer)
		pPlayer.CallClientScript("Fuben:DoPlayerCommonAct", nActId, nActEventId, bLoop, nFrame);
	end);
end

function tbBase:PlaySceneCameraAnimation(szObjectName, szAnimName, nLockId)
	if self.nSceneAnimationLockId and self.nSceneAnimationLockId > 0 then
		Log("[ERROR][Fuben] PlaySceneCameraAnimation self.nSceneAnimationLockId = " .. self.nSceneAnimationLockId, "nLockId = " .. nLockId);
		return;
	end

	if MODULE_GAMESERVER then
		nLockId = nil;
	end

	self.nSceneAnimationLockId = nLockId;

	local function fnPlay(pPlayer)
		pPlayer.CallClientScript("CameraAnimation:PlaySceneCameraAnimation", szObjectName, szAnimName, 1);
	end

	self:AllPlayerExcute(fnPlay);
end

function tbBase:DoFinishTaskExtInfo(szExtInfo)
	if not MODULE_GAMESERVER then
		Log("[ERROR][Fuben] DoFinishTaskExtInfo only used on server state !!", debug.traceback());
		return;
	end
	self:AllPlayerExcute(function (pPlayer)
		Task:OnTaskExtInfo(pPlayer, szExtInfo);
	end);
end