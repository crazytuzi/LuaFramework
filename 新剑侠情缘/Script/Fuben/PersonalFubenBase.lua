local tbFuben = Fuben:CreateFubenClass("PersonalFubenBase");

local tbAwardLevelToObjID = {
	[0] = 12,
	[1] = 12,
	[2] = 12,
	[3] = 12,
	[4] = 12,
	[5] = 12,
	[6] = 12,
	[7] = 12,
	[8] = 12,
}

function tbFuben:OnCreate(tbFubenAward, nFubenIndex, nFubenLevel, nStartTime, tbHelperInfo)
	self.nDeathCount = 0;
	self.tbHelperInfo = tbHelperInfo;
	self.tbAllAward = tbFubenAward;
	self.nFubenIndex = nFubenIndex;
	self.nFubenLevel = nFubenLevel;
	self.tbClientData = self.tbClientData or {};
	self.tbClientData.nServerStartTime = nStartTime;
	self.tbCurAward = { tbItemAward = {} };
	self.nAwardCount = 0
	self.tbNpcInfo = {};

	self.nSectionId, self.nSubSectionId = PersonalFuben:GetSectionIdx(nFubenIndex, nFubenLevel);
	self.nStarLevel = PersonalFuben:GetFubenStarLevel(me, self.nSectionId, self.nSubSectionId, self.nFubenLevel);

	if tbHelperInfo and not tbHelperInfo.bIsNpc and tbHelperInfo.dwID then
		self.tbClientData.nHelperId = tbHelperInfo.dwID;
	elseif tbHelperInfo and tbHelperInfo.bIsNpc then
		self.tbClientData.nHelperId = -1;
	end

	self:RandomNpcAward();
end

function tbFuben:CountNpcInfo()
	self.tbNpcCount = {};
	local tbSetting = self.tbSetting;
	for _, tbLockSetting in pairs(tbSetting.LOCK) do
		for _, tbEvent in pairs(tbLockSetting.tbStartEvent or {}) do
			if tbEvent[1] == "RaiseEvent" and tbEvent[2] == "AddNpcWithAward" then
				self.tbNpcCount[tbEvent[8]] = (self.tbNpcCount[tbEvent[8]] or 0) + self:GetNumber(tbEvent[4]);
			end
		end

		for _, tbEvent in pairs(tbLockSetting.tbUnLockEvent or {}) do
			if tbEvent[1] == "RaiseEvent" and tbEvent[2] == "AddNpcWithAward" then
				self.tbNpcCount[tbEvent[8]] = (self.tbNpcCount[tbEvent[8]] or 0) + self:GetNumber(tbEvent[4]);
			end
		end
	end
end

function tbFuben:RandomNpcAward()
	self:CountNpcInfo();

	self.tbAllNpcAward = {};

	local tbRandomFun = {};
	local function fnGetNpcAward(nAwardLevel)
		tbRandomFun[nAwardLevel] = tbRandomFun[nAwardLevel] or Lib:GetRandomSelect(self.tbNpcCount[nAwardLevel] or 0);
		self.tbAllNpcAward[nAwardLevel] = self.tbAllNpcAward[nAwardLevel] or {};

		local nNpcIndex = tbRandomFun[nAwardLevel]();
		local tbNpcAward = self.tbAllNpcAward[nAwardLevel];
		tbNpcAward[nNpcIndex] = tbNpcAward[nNpcIndex] or {};
		return tbNpcAward[nNpcIndex];
	end

	local function fnRandomItemAward(nAwardLevel, tbAwardInfo)
		for nItemId, nItemCount in pairs(tbAwardInfo) do
			for i = 1, nItemCount do
				local tbNpcAward = fnGetNpcAward(nAwardLevel);
				tbNpcAward.tbItemAward = tbNpcAward.tbItemAward or {};
				tbNpcAward.tbItemAward[nItemId] = (tbNpcAward.tbItemAward[nItemId] or 0) + 1;
			end
		end
	end

	local function fnRandomNumInfo(szType, nAwardLevel, tbAwardInfo)
		for _, nCount in pairs(tbAwardInfo) do
			local tbNpcAward = fnGetNpcAward(nAwardLevel);
			tbNpcAward[szType] = (tbNpcAward[szType] or 0) + nCount;
		end
	end

	for nAwardLevel, tbAward in pairs(self.tbAllAward) do
		if self.tbNpcCount[nAwardLevel] and self.tbNpcCount[nAwardLevel] > 0 then
			for szType, tbInfo in pairs(tbAward) do
				if szType == "tbItem" then
					fnRandomItemAward(nAwardLevel, tbInfo);
				elseif szType == "Coin" or szType == "Exp" or szType == "Gold" then
					fnRandomNumInfo(szType, nAwardLevel, tbInfo);
				end
			end
		else
			Log("[PersonalFuben] ERR ??  self.tbNpcCount[nAwardLevel] is nil !!", self.nFubenIndex, self.nFubenLevel, nAwardLevel);
		end
	end
end

function tbFuben:ShowUI()
	Ui:OpenWindow("HomeScreenFuben");
	if me.nLevel <= PersonalFuben.NoviceLevel then
		Ui:CloseWindow("HomeScreenTask");
	end
end

function tbFuben:OnPlayerDeath()
	me.Revive(1);
	self:GameLost();
end

function tbFuben:OnAddNpc(pNpc, nAwardLevel)
	if not nAwardLevel then
		return;
	end

	pNpc.tbFubenAwardInfo = {};
	pNpc.tbFubenAwardInfo.nAwardLevel = nAwardLevel;
	pNpc.tbFubenAwardInfo.nIndex = self.tbNpcInfo[nAwardLevel] or 1;
	self.tbNpcInfo[nAwardLevel] = (self.tbNpcInfo[nAwardLevel] or 1) + 1;
end

function tbFuben:GetNpcAward(pNpc)
	if not pNpc or not pNpc.tbFubenAwardInfo then
		return;
	end

	local nAwardLevel = pNpc.tbFubenAwardInfo.nAwardLevel;
	local nIndex = pNpc.tbFubenAwardInfo.nIndex;

	return (self.tbAllNpcAward[nAwardLevel] or {})[nIndex], nAwardLevel;
end

function tbFuben:OnKillNpc(pNpc)
	local tbAward, nAwardLevel = self:GetNpcAward(pNpc);
	local tbInfo = {};
	if tbAward then
		local nObjID = tbAwardLevelToObjID[nAwardLevel] or 1;
		tbInfo.tbUserDef = {};

		for nItemId, nCount in pairs(tbAward.tbItemAward or {}) do
			self.tbCurAward.tbItemAward[nItemId] = self.tbCurAward.tbItemAward[nItemId] or 0;
			self.tbCurAward.tbItemAward[nItemId] = self.tbCurAward.tbItemAward[nItemId] + nCount;
			self.nAwardCount = self.nAwardCount + nCount;
			for i = 1, nCount do
				table.insert(tbInfo.tbUserDef, {nObjID = nObjID, szTitle = "宝箱", nDropType = Item.DROP_OBJ_TYPE_SPE});
			end
		end

		if tbAward.Coin then
			self.tbCurAward.nCoin = (self.tbCurAward.nCoin or 0) + tbAward.Coin;
			table.insert(tbInfo.tbUserDef, {nObjID = Shop:GetMoneyObjId("Coin") or 0, szTitle = "银两", nDropType = Item.DROP_OBJ_TYPE_MONEY});
		end

		local _, nX, nY = pNpc.GetWorldPos();
		me.DropItemInPos(nX, nY, tbInfo);
	end

	Ui("HomeScreenFuben"):Update(self.nAwardCount or 0, self.tbCurAward.nCoin or 0);
end

function tbFuben:OnShowCurAward()
	Lib:Tree(self.tbCurAward);
end

function tbFuben:OnAddNpcWithAward(nIndex, nNum, nLock, szGroup, szPointName, nAwardLevel, nDir, nDealyTime, nEffectId, nEffectTime)
	assert(nAwardLevel, string.format("副本没配置npc奖励级别！！%s    %s    %s   %s    %s", nIndex or "nil", nNum or "nil", nLock or "nil", szGroup or "nil", szPointName or "nil"));
	self:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, false, nDir, nDealyTime, nEffectId, nEffectTime, nAwardLevel);
end

function tbFuben:SyncOther(pPlayer)
	if pPlayer.tbPartnerGroup then
		local m, x, y = pPlayer.GetWorldPos();
		pPlayer.tbPartnerGroup:SetPosition(x, y);
	end

	if self.pHelper then
		self.pHelper.SetPosition(x, y);
	end
end

function tbFuben:OnJoin(pPlayer)
	pPlayer.Revive();
	pPlayer.CallClientScript("Fuben:SetTargetPos");
	
	self:CloseDazuoGuideTimer();
	if pPlayer.nLevel >= 10 and pPlayer.nLevel <= 25 then
		self.nDazuoGuideTimerId = Timer:Register(Env.GAME_FPS, function ()
			if Ui:WindowVisible("Guide") == 1 or pPlayer.GetDoing() == Npc.Doing.sit then
				return true;
			end

			local pNpc = pPlayer.GetNpc();
			local fRatio = pNpc.nCurLife / pNpc.nMaxLife;
			if fRatio >= 0.5 then
				return true;
			end

			self.nDazuoGuideTimerId = nil;

			pPlayer.SendBlackBoardMsg("侠士受伤颇重！快打坐调息一番，可在较短时间内治疗伤势！");
			self:OpenGuide(nil, "PopT", "请点击使用打坐", "HomeScreenBattle", "BtnDazuo", {0, -40}, false, false, true);
		end);
	end
end

function tbFuben:CloseDazuoGuideTimer()
	if self.nDazuoGuideTimerId then
		Timer:Close(self.nDazuoGuideTimerId);
		self.nDazuoGuideTimerId = nil;
	end
end

function tbFuben:OnOut(pPlayer)
	self:CloseDazuoGuideTimer();
end

function tbFuben:OnMapLoaded()
	self:ShowUI();
	self.tbClientData = self.tbClientData or {};
	self.tbClientData.nStartTime = GetTime();

	local tbPartnerGroup = Partner:InitPartnerGroup(me);
	if self.tbSetting.bForbidPartner then
		tbPartnerGroup:DoForbidPartner();
	end

	if not self.tbSetting.bForbidHelper and self.tbHelperInfo and self.nFubenLevel == PersonalFuben.PERSONAL_LEVEL_ELITE then
		self.pHelper = Helper:CreateNpc(me, self.tbHelperInfo);
	end

	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, function (self)
		self:OnLeaveCurMap();
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
	end, self);

	local tbPersonalFubenData = Client:GetUserInfo("PersonalFuben");
	if tbPersonalFubenData.nAutoFight then
		AutoFight:ChangeState(tbPersonalFubenData.nAutoFight);
	end

	Timer:Register(Env.GAME_FPS * 0.5, function ()
		self:Start();
		Log("[FubenStart]", self.nSectionId, self.nSubSectionId, self.nFubenLevel);
	end)
end

function tbFuben:OnLeaveCurMap()
	PersonalFuben:CloseUI();
	if me.tbPartnerGroup then
		me.tbPartnerGroup:Close();
	end

	if self.nReviveTimerId then
		Timer:Close(self.nReviveTimerId);
		self.nReviveTimerId = nil;
	end

	self:LeaveFuben(me);
end

function tbFuben:GameWin()
	if self.nTimeoutLockId and self.tbLock[self.nTimeoutLockId] then
		self.tbClientData.nCostTime = self.tbLock[self.nTimeoutLockId]:GetTimeInfo();
		self.tbClientData.nCostTime = math.floor(self.tbClientData.nCostTime);
	else
		Log("[PersonalFubenBase] GameWin ERR ?? self.nTimeoutLockId ERR ?? ", self.nTimeoutLockId or "nil");
	end

	self.tbClientData.bIsWin = true;
	me.tbBeforePersonFuben = {nOldLevel = me.nLevel, nOldExpPercent = me.GetExp()/me.GetNextLevelExp()}
	self:Close();

	Timer:Register(Env.GAME_FPS * 2, function ()
		local tbFubenInst = Fuben:GetFubenInstance(me);
		if tbFubenInst and tbFubenInst.bClose == 1 then
			PersonalFuben:DoLeaveFuben(false, true);
		end
	end);

	Guide:OnFinishFuben(self.nFubenLevel, self.nSectionId, self.nSubSectionId)
	Log("[GameWin]", self.nSectionId, self.nSubSectionId, self.nFubenLevel);
end

function tbFuben:GameLost()
	self.tbClientData.bIsWin = false;
	self:Close();
	Ui:OpenWindow("PersonalFubenFail", self.szFailMsg);
	Log("[GameLost]", self.nSectionId, self.nSubSectionId, self.nFubenLevel);
end

function tbFuben:OnClose()
	if self.nReviveTimerId then
		Timer:Close(self.nReviveTimerId);
		self.nReviveTimerId = nil;
		me.Revive();
	end
	me.CallClientScript("Fuben:SetTargetPos");
	if self.bClose ~= 1 then
		self.tbClientData = self.tbClientData or {};
		self.tbClientData.nEndTime = GetTime();
		if self.tbClientData.bIsWin then
			Helper:OnClientUseHelper(self.tbClientData.nHelperId);
		end

		Player:RemoteServer_Safe("SendPersonalFubenResult", self.tbClientData);
	end

	local tbPersonalFubenData = Client:GetUserInfo("PersonalFuben");
	local nCurFightState = AutoFight:GetFightState();
	if not tbPersonalFubenData.nAutoFight or tbPersonalFubenData.nAutoFight ~= nCurFightState then
		tbPersonalFubenData.nAutoFight = nCurFightState;
		Client:SaveUserInfo();
	end

	if self.bCreateFakeTeam then
		TeamMgr:OnSynQuite()
		self.bCreateFakeTeam = false
	end
end

function tbFuben:OnSetFailMsg(szMsg)
	self.szFailMsg = szMsg;
end

function tbFuben:OnShowTaskDialog(nLockId, nDialogId, bIsOnce, nDealyTime)
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(Env.GAME_FPS * nDealyTime, self.OnShowTaskDialog, self, nLockId, nDialogId, bIsOnce);
		return;
	end

	Ui:TryPlaySitutionalDialog(nDialogId, bIsOnce, {self.UnLock, self, nLockId});
end

function tbFuben:OnCloseDynamicObstacle(szObsName)
	CloseDynamicObstacle(me.nMapId, szObsName);
end

function tbFuben:OnRegisterTimeoutLock()
	self.nTimeoutLockId = self.nCurLockId;
end

function tbFuben:OnShowPlayer(bShow)
	Ui.Effect.ShowNpcRepresentObj(me.GetNpc().nId, bShow);
end

function tbFuben:OnShowPartnerAndHelper(bShow)
	local tbAllPartnerNpc = me.GetAllPartnerNpc();

	if self.pHelper then
		Ui.Effect.ShowNpcRepresentObj(self.pHelper.nId, bShow);
	end

	for _, pPartner in pairs(tbAllPartnerNpc) do
		Ui.Effect.ShowNpcRepresentObj(pPartner.nId, bShow);
	end
end

function tbFuben:OnFllowPlayer(szNpcGroup, bFllow)
	for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.AI_SetFollowNpc(bFllow and me.GetNpc().nId or 0);
		end
	end
end

function tbFuben:OnPlayerRunTo(nX, nY)
	AutoPath:GotoAndCall(me.nMapId, nX, nY);
end

function tbFuben:OnChangeAutoFight(bFight)
	local nAutoType = bFight and AutoFight.OperationType.Auto or AutoFight.OperationType.Manual;
	AutoFight:ChangeState(nAutoType);
end

function tbFuben:OnCallPartner()
	if me.tbPartnerGroup then
		me.tbPartnerGroup:Close();
	end
	Partner:InitPartnerGroup(me);
	Ui("HomeScreenTask"):FoldTaskButton(false);
end

function tbFuben:OnPartnerSay(szInfo, nDuration, nCount)
	if not me.tbPartnerGroup then
		return;
	end

	nCount = nCount or 1;
	self.nSayCount = 0;
	local function fnSay(pNpc, szContent, self)
		if self.nSayCount >= nCount then
			return;
		end

		self.nSayCount = self.nSayCount + 1;
		pNpc.BubbleTalk(szContent, tostring(nDuration));
	end

	me.tbPartnerGroup:AllPartnerExcute(fnSay, szInfo, self);
end

function tbFuben:OnLog(...)
	--Log(...);
end

function tbFuben:OnAddFakeGouhuoSkillState(nSkillId, nSkillLevel, nTime)
	me.GetNpc().AddSkillState(nSkillId, nSkillLevel, 0, nTime)
	me.GetNpc().AddSkillState(Item:GetClass("jiu").nJiuSkillId, nSkillLevel, 0, nTime)
	me.GetNpc().AddSkillState(XiuLian.tbDef.nXiuLianBuffId, nSkillLevel, 0, nTime)
end

function tbFuben:OnAddNpc2FakeTeam(...)
	local nMapId, nPosX, nPosY = me.GetWorldPos()
	TeamMgr:OnSynNewTeam(-1, me.dwID, {})
	self.bCreateFakeTeam = true
	local tbFaction = {}
	for i = 1, Faction.MAX_FACTION_COUNT do
		table.insert(tbFaction, i)
	end
	Lib:SmashTable(tbFaction)
	local tbGroup = {...}
	local nLastCout = TeamMgr.MAX_MEMBER_COUNT - 1
	for _, szGroup in pairs(tbGroup) do
		if nLastCout <= 0 then
			return
		end
		for _, nId in pairs(self.tbNpcGroup[szGroup]) do
			if nLastCout <= 0 then
				return
			end
			local pNpc = KNpc.GetById(nId)
			if pNpc then
				local tbMemberData = {
					nPlayerID      = -1;
					nNpcID         = nId;
					szName         = pNpc.szName;
					nFaction       = tbFaction[nLastCout];
					nSex           = pNpc.nSex;
					nPortrait      = PlayerPortrait:GetDefaultId(tbFaction[nLastCout], pNpc.nSex);
					nHonorLevel    = 1;
					nKinId         = 0;
					nLevel         = pNpc.nLevel;
					nMapId         = nMapId;
					nMapTemplateId = 0;
					nPosX          = nPosX;
					nPosY          = nPosY;
					nVipLevel      = 1;
					nHpPercent     = 100;
				}
				TeamMgr:OnSynAddMember(tbMemberData)
				nLastCout = nLastCout - 1
			end
		end
	end
end