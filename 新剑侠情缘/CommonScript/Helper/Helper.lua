
---------------  助战相关

Helper.MAX_JADE_COUNT        = 600;	-- 每日最大获取勾玉数量
Helper.MAX_LIST_COUNT        = 10;	-- 列表最大数量
Helper.MAX_FRIEND_COUNT      = 5;	-- 最大好友数量

Helper.FRIEND_JADE           = 10;		-- 好友增加勾玉
Helper.STRANGER_JADE         = 5;		-- 陌生人增加勾玉
Helper.REFRESH_STRANGER_TIME = 180;		-- 玩家的路人列表刷新时间间隔

Helper.REFRESH_TIME          = 3600 * 4;	-- 每天4点刷新

Helper.tbAiPath =
{
	[0] = "Setting/Npc/Ai/partner/FellowCommon.ini",
	[1] = "Setting/Npc/Ai/partner/FellowCommon.ini",
	[2] = "Setting/Npc/Ai/partner/FellowCommon.ini",
	[3] = "Setting/Npc/Ai/partner/FellowCommon.ini",
	[4] = "Setting/Npc/Ai/partner/FellowCommon.ini",
};

function Helper:GetData(pPlayer)
	local tbData = pPlayer.GetScriptTable("Helper");
	local nToday = Lib:GetLocalDay(GetTime() - self.REFRESH_TIME);
	if not tbData.nDate or tbData.nDate ~= nToday then
		tbData.nDate = nToday;
		tbData.nJadeCount = 0;
		tbData.tbFriendUsedList = {};
	end

	return tbData;
end

function Helper:OnLogin(pPlayer)
	local tbData = self:GetData(pPlayer);
	for nHelperId in pairs(tbData.tbFriendUsedList) do
		pPlayer.CallClientScriptWhithPlayer("Helper:SetFriendUsedList", nHelperId);
	end
end

function Helper:Update()
	self.nNextStrangerTime = self.nNextStrangerTime or 0;
	self.tbFriendList = self.tbFriendList or {};
	self:UpdateFirendList();

	if not self.tbStranger or #self.tbStranger <= 0 or self.nNextStrangerTime <= GetTime() then
		RemoteServer.GetStranger(self.MAX_LIST_COUNT - #self.tbFriendList);
		return false;
	end

	return true;
end

function Helper:UpdateFirendList()
	local tbResult = {};
	local tbAllFirend = FriendShip:GetAllFriendData() or {};
	local tbHelperData = Helper:GetData(me);

	local tbCurInfo = {};
	for i = #self.tbFriendList, 1, -1 do
		local tbInfo = self.tbFriendList[i];
		if tbHelperData.tbFriendUsedList[tbInfo.dwID] then
			table.remove(self.tbFriendList, i);
		else
			tbCurInfo[tbInfo.dwID] = 1;
		end
	end

	if #self.tbFriendList >= Helper.MAX_FRIEND_COUNT then
		return;
	end

	for _, tbInfo in pairs(tbAllFirend) do
		if not tbHelperData.tbFriendUsedList[tbInfo.dwID] and not tbCurInfo[tbInfo.dwID] then
			local tbFr = {};
			tbFr.dwID        = tbInfo.dwID;
			tbFr.szName      = tbInfo.szName;
			tbFr.nLevel      = tbInfo.nLevel;
			tbFr.nImity      = tbInfo.nImity;
			tbFr.nFaction    = tbInfo.nFaction;
			tbFr.nPortrait   = tbInfo.nPortrait;
			tbFr.nHonorLevel = tbInfo.nHonorLevel;

			table.insert(tbResult, tbFr);
		end
	end

	while(#tbResult > 0 and #self.tbFriendList < Helper.MAX_FRIEND_COUNT) do
		local nRandom = MathRandom(#tbResult);
		table.insert(self.tbFriendList, tbResult[nRandom]);
		table.remove(tbResult, nRandom);
	end

	local function fnSort(a, b)
		if a.nImity ~= b.nImity then
			return a.nImity > b.nImity;
		end

		if a.nHonorLevel ~= b.nHonorLevel then
			return a.nHonorLevel > b.nHonorLevel;
		end

		return a.dwID > b.dwID;
	end

	table.sort(self.tbFriendList, fnSort);
end

function Helper:OnGetStrangerList(tbStranger)
	local function fnCmp(a, b)
		return a.nHonorLevel > b.nHonorLevel;
	end
	table.sort(tbStranger, fnCmp);

	self.nNextStrangerTime = GetTime() + self.REFRESH_STRANGER_TIME;
	self.tbStranger = tbStranger;
	self.nOtherNpcCount = self.MAX_LIST_COUNT - #self.tbFriendList - #self.tbStranger;
	UiNotify.OnNotify(UiNotify.emNOTIFY_HELPER_GET_STRANGER);
end

function Helper:OnGetSyncData(nRoleId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_HELPER_GET_SYNCDATA, nRoleId);
end

function Helper:OnClientUseHelper(nHelperId)
	if not nHelperId or nHelperId <= 0 or FriendShip:IsFriend(me.dwID, nHelperId) then
		return;
	end

	local tbSInfo = nil;
	for nIdx, tbInfo in pairs(self.tbStranger or {}) do
		if tbInfo.dwID == nHelperId then
			tbSInfo = tbInfo;
			table.remove(self.tbStranger, nIdx);
			break;
		end
	end

	if tbSInfo then
		FriendShip:OpenAddFriendUI({dwID = nHelperId, szName = tbSInfo.szName});
	end
end

function Helper:RandomUseFriendOrStranger(pPlayer)
	local tbData = self:GetData(pPlayer);
	local tbAllFriend = KFriendShip.GetFriendList(pPlayer.dwID);

	local nHelperId = 0;
	local nCurImity = 0;
	local nHonorLevel = 0;

	-- 挑选规则，先按亲密度（高的优先），再按头衔（低的优先）
	for nFriendId, nImity in pairs(tbAllFriend) do
		if not tbData.tbFriendUsedList[nFriendId] then
			local tbRoleStayInfo = KPlayer.GetRoleStayInfo(nFriendId);
			if tbRoleStayInfo then
				if nImity > nCurImity or (nImity == nCurImity and tbRoleStayInfo.nHonorLevel < nHonorLevel) then
					nHelperId   = nFriendId;
					nCurImity   = nImity;
					nHonorLevel = tbRoleStayInfo.nHonorLevel;
				end
			end
		end
	end

	self:OnUseHelper(pPlayer, nHelperId);
end

function Helper:OnUseHelper(pPlayer, nHelperId)
	local bIsFriend = FriendShip:IsFriend(pPlayer.dwID, nHelperId);
	local tbData = self:GetData(pPlayer);
	local nJade = math.min(bIsFriend and self.FRIEND_JADE or self.STRANGER_JADE, self.MAX_JADE_COUNT - tbData.nJadeCount);
	if bIsFriend and not tbData.tbFriendUsedList[nHelperId] then
		self:SetFriendUsedList(pPlayer, nHelperId);
		FriendShip:AddImitityByKind(pPlayer.dwID, nHelperId, Env.LogWay_UseHelper);
	end

	tbData.nJadeCount = tbData.nJadeCount + nJade;
	if nJade > 0 then
		pPlayer.AddMoney("Jade", nJade, Env.LogWay_UseHelper);
	end
end

function Helper:CreateNpc(pPlayer, tbHelperInfo)
	if MODULE_GAMESERVER then
		Log("[Helper] ERR ?? Helper:CreateNpc can not use in server");
		return;
	end

	local pNpc;
	local nMapId, nX, nY = me.GetWorldPos();
	if tbHelperInfo.bIsNpc then
		local nSex = Player:Faction2Sex(tbHelperInfo.nFaction);
		pNpc = KPlayer.AddFakePlayer(tbHelperInfo.nFaction, nSex, tbHelperInfo.nLevel, nMapId, nX, nY);
		pNpc.SetName(tbHelperInfo.szName or "助战者");

		local tbSkillList = FightSkill:GetFakePlayerSkillList(tbHelperInfo.nFaction, tbHelperInfo.nLevel)
		for _, tbInfo in ipairs(tbSkillList) do
			local nSkillId, nLevel = unpack(tbInfo);
			pNpc.AddFightSkill(nSkillId, nLevel)
		end
	else
		local pAsyncData = KPlayer.GetAsyncData(tbHelperInfo.dwID);
		pNpc = pAsyncData.AddAsyncNpc(nMapId, nX, nY);
	end

	local szAiFile = self.tbAiPath[tbHelperInfo.nFaction] or self.tbAiPath[0];
	pNpc.SetAi(szAiFile);
	pNpc.AI_SetFollowNpc(pPlayer.GetNpc().nId);
	pNpc.SetMasterNpcId(pPlayer.GetNpc().nId);
	pNpc.SetCamp(0);
	pNpc.nFightMode = 1;

	return pNpc;
end

function Helper:SetFriendUsedList(pPlayer, nHelperId)
	local tbData = self:GetData(pPlayer);
	tbData.tbFriendUsedList[nHelperId] = 1;
	if MODULE_GAMESERVER then
		pPlayer.CallClientScriptWhithPlayer("Helper:SetFriendUsedList", nHelperId);
	end
end

