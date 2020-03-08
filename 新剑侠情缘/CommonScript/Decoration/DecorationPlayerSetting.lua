
Decoration.tbAllActPlayerInfo = Decoration.tbAllActPlayerInfo or {};
Decoration.nMaxPlayerSettingCount = 5;
Decoration.nEnterPlayerActStateInterval = 2

function Decoration:LoadPlayerSetting()
	local szType = "dddd";
	local tbTitle = {"nDecorationId", "nType", "nMaxPlayerCount", "nBufferId"};
	for i = 1, self.nMaxPlayerSettingCount do
		for j = 1, i do
			szType = szType .. "sss";
			table.insert(tbTitle, string.format("szPlayerPos_%s_%s", i, j));
			table.insert(tbTitle, string.format("szPlayerExtPos_%s_%s", i, j));
			table.insert(tbTitle, string.format("szSlot_%s_%s", i, j));
		end
	end

	self.tbPlayerSetting = {};
	self.tbAllBufferId = {};
	local tbFile = LoadTabFile("Setting/Decoration/DecorationPlayerSetting.tab", szType, nil, tbTitle);
	for _, tbRow in pairs(tbFile) do
		local tbInfo = {};

		tbInfo.nDecorationId = tbRow.nDecorationId;
		tbInfo.nType = tbRow.nType;
		tbInfo.nMaxPlayerCount = tbRow.nMaxPlayerCount;
		tbInfo.nBufferId = tbRow.nBufferId;
		tbInfo.tbPlayerPosInfo = {};
		tbInfo.tbPlayerExtPosInfo = {};

		self.tbAllBufferId[tbInfo.nBufferId] = true;

		assert(tbInfo.nMaxPlayerCount <= self.nMaxPlayerSettingCount);

		for i = 1, tbInfo.nMaxPlayerCount do
			for j = 1, i do
				local szSlot = tbRow[string.format("szSlot_%s_%s", i, j)] or "";
				local szPlayerPos = tbRow[string.format("szPlayerPos_%s_%s", i, j)] or "";
				local nPosX, nPosY = string.match(szPlayerPos, "^([^|]+)|([^|]+)$");
				nPosX = tonumber(nPosX or "");
				nPosY = tonumber(nPosY or "");
				assert(nPosX and nPosY);

				tbInfo.tbPlayerPosInfo[i] = tbInfo.tbPlayerPosInfo[i] or {};
				tbInfo.tbPlayerPosInfo[i][j] = {nPosX, nPosY};

				if szSlot and szSlot ~= "" then
					tbInfo.tbSlotInfo = tbInfo.tbSlotInfo or {};
					tbInfo.tbSlotInfo[i] = tbInfo.tbSlotInfo[i] or {};
					tbInfo.tbSlotInfo[i][j] = szSlot;
				end

				local szPlayerExtPos = tbRow[string.format("szPlayerExtPos_%s_%s", i, j)] or "";
				local tbLines = Lib:SplitStr(szPlayerExtPos, ";");
				for _, szInfo in pairs(tbLines) do
					local nR, nX, nY = string.match(szInfo, "^([^|]+)|([^|]+)|([^|]+)$");
					if nR then
						nR = tonumber(nR);
						nX = tonumber(nX);
						nY = tonumber(nY);
						if nR then
							tbInfo.tbPlayerExtPosInfo[i] = tbInfo.tbPlayerExtPosInfo[i] or {};
							tbInfo.tbPlayerExtPosInfo[i][j] = tbInfo.tbPlayerExtPosInfo[i][j] or {};
							tbInfo.tbPlayerExtPosInfo[i][j][nR] = {nX, nY};
						end
					end
				end
			end
		end

		self.tbPlayerSetting[tbRow.nDecorationId] = self.tbPlayerSetting[tbRow.nDecorationId] or {};
		self.tbPlayerSetting[tbRow.nDecorationId][tbRow.nType] = tbInfo;
	end
end
Decoration:LoadPlayerSetting();

function Decoration:GetPlayerSetting(nDecorationId, nType)
	if not self.tbPlayerSetting[nDecorationId] or not self.tbPlayerSetting[nDecorationId][nType] then
		return;
	end

	return self.tbPlayerSetting[nDecorationId][nType];
end

function Decoration:ClearAllPlayerActState(nMapId)
	for nId, tbRepInfo in pairs(self.tbAllDecoration) do
		if tbRepInfo.nMapId == nMapId and self.tbAllActPlayerInfo[nId] then
			for nPlayerId in pairs(self.tbAllActPlayerInfo[nId]) do
				self:ExitPlayerActState(nPlayerId);

				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					pPlayer.SendBlackBoardMsg("有人正在进行家园装修");
				end
			end
		end
	end
end

function Decoration:DecorationChangeActType(pPlayer, nId, nType)
	if MODULE_GAMECLIENT then
		RemoteServer.DecorationChangeActType(nId, nType);
		return;
	end

	local tbRepInfo = self.tbAllDecoration[nId];
	if not tbRepInfo or pPlayer.nMapId ~= tbRepInfo.nMapId then
		return;
	end

	local tbSetting = self:GetPlayerSetting(tbRepInfo.nTemplateId, nType);
	if not tbSetting then
		return;
	end

	if not tbRepInfo.tbParam then
		return;
	end

	local tbTemplate = self.tbAllTemplate[tbRepInfo.nTemplateId];
	if not tbTemplate then
		return;
	end

	local bHasMe = false;
	for _, nNpcId in pairs(tbRepInfo.tbParam.tbNpcIdInfo or {}) do
		local bIsMe = false;
		if nNpcId == pPlayer.GetNpc().nId then
			bHasMe = true;
			bIsMe = true;
		end

		if tbTemplate.szSubType == "Chuang" then
			local pOther = pPlayer;
			if not bIsMe then
				local pNpc = KNpc.GetById(nNpcId);
				if pNpc then
					pOther = pNpc.GetPlayer();
				end
			end

			if pOther then
				pOther.SendBlackBoardMsg(bIsMe and "你扭动着身子，更换了睡姿" or "枕边人扭动着身子，更换了睡姿");
			end
		end
	end

	if not bHasMe then
		return;
	end

	tbRepInfo.tbParam.nType = nType;
	Decoration:ChangeParam(nId, tbRepInfo.tbParam);
end

function Decoration:EnterPlayerActState(pPlayer, nId, nParam, nType)
	if MODULE_GAMECLIENT then
		local nNow = GetTime()
		if nNow-(pPlayer.nLastEnterPlayerActState or 0)<=self.nEnterPlayerActStateInterval then
			pPlayer.CenterMsg("操作太频繁了")
			return
		end
		pPlayer.nLastEnterPlayerActState = nNow
		RemoteServer.DecorationEnterActState(nId, nParam, nType);
		return;
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_UseDecoration) then
		pPlayer.CenterMsg("当前状态不可使用家具");
		return;
	end

	if self.tbAllActPlayerInfo[nId] and self.tbAllActPlayerInfo[nId][pPlayer.dwID] then
		return;
	end

	local tbRepInfo = self.tbAllDecoration[nId];
	if not tbRepInfo or pPlayer.nMapId ~= tbRepInfo.nMapId then
		return;
	end

	local bRet, szMsg = self:CanOperation(tbRepInfo, pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local tbSetting = self:GetPlayerSetting(tbRepInfo.nTemplateId, nType);
	if not tbSetting then
		return;
	end

	if tbRepInfo.tbParam and Lib:CountTB(tbRepInfo.tbParam.tbPlayerInfo or {}) >= tbSetting.nMaxPlayerCount then
		pPlayer.CenterMsg("该家具使用人数已达上限");
		return;
	end

	self:ExitPlayerActState(pPlayer.dwID);

	self.tbAllActPlayerInfo[nId] = self.tbAllActPlayerInfo[nId] or {};

	local nIdx = 1;
	local tbParam = Lib:CopyTB(tbRepInfo.tbParam or {});
	tbParam.tbPlayerInfo = tbParam.tbPlayerInfo or {};
	tbParam.tbNpcIdInfo = tbParam.tbNpcIdInfo or {};
	tbParam.tbGender = tbParam.tbGender or {}
	tbParam.nType = nType;
	for i = 1, Lib:CountTB(tbParam.tbPlayerInfo) + 1 do
		if not tbParam.tbPlayerInfo[i] then
			tbParam.tbPlayerInfo[i] = nParam;
			tbParam.tbNpcIdInfo[i] = pPlayer.GetNpc().nId;
			tbParam.tbGender[i] = pPlayer.nSex
			nIdx = i;
			self.tbAllActPlayerInfo[nId][pPlayer.dwID] = i;
			break;
		end
	end

	local nPlayerCount = Lib:CountTB(tbParam.tbPlayerInfo);

	-- 床类家具当返回一个人的时候类型必须要是 0
	local tbTemplate = self.tbAllTemplate[tbRepInfo.nTemplateId];
	if nPlayerCount == 1 then
		if tbTemplate.szSubType == "Chuang" then
			tbParam.nType = 0;
		end
	end

	Env:SetSystemSwitchOff(pPlayer, Env.SW_All);

	Decoration:ChangeParam(nId, tbParam);

	local m, x, y = pPlayer.GetWorldPos();
	pPlayer.tbDecorationActStatePos = {x, y};

	self:UpdatePlayerSettingPos(tbRepInfo);
	pPlayer.AddSkillState(tbSetting.nBufferId, 1, 0, 10000000);

	local pPlayerNpc = pPlayer.GetNpc()
	local nNpcResID, tbCurFeature = pPlayerNpc.GetFeature()
	pPlayerNpc.ChangeFeature(nNpcResID,Npc.NpcResPartsDef.npc_part_body, tbCurFeature[Npc.NpcResPartsDef.npc_part_body])
	pPlayerNpc.ChangeFeature(nNpcResID,Npc.NpcResPartsDef.npc_part_head, tbCurFeature[Npc.NpcResPartsDef.npc_part_head])
	pPlayerNpc.ChangeFeature(nNpcResID,Npc.NpcResPartsDef.npc_part_weapon, tbCurFeature[Npc.NpcResPartsDef.npc_part_weapon])

	pPlayer.CallClientScript("Decoration:OnSyncPlayerActState", true);

	if MODULE_GAMESERVER then
		local bOtherHouse = not House:IsInOwnHouse(pPlayer)
		if tbTemplate.szSubType == "GuiZi" then
			if bOtherHouse then
				Achievement:AddCount(pPlayer, "House_Hide", 1)
			end
		elseif tbTemplate.szSubType == "Chuang" then
			if bOtherHouse then
				Achievement:AddCount(pPlayer, "House_Sleep", 1)
			end
			if nPlayerCount == 2 then
				for nPid in pairs(self.tbAllActPlayerInfo[nId]) do
					Achievement:AddCount(nPid, "House_SleepTogether", 1)
				end
			end
		elseif tbTemplate.szSubType == "YuGang" then
			if bOtherHouse then
				Achievement:AddCount(pPlayer, "House_Wash", 1)
			end
		elseif tbTemplate.szSubType == "QiuQian" then
			if nPlayerCount == 2 then
				for nPid in pairs(self.tbAllActPlayerInfo[nId]) do
					Achievement:AddCount(nPid, "House_Swing", 1)
				end
			end
		end
	end
end

function Decoration:SyncPosInfo(nMapId, nOrgX, nOrgY, nNewX, nNewY)
	self.tbOrgPosInfo = {nMapId = nMapId, nOrgX = nOrgX, nOrgY = nOrgY, nNewX = nNewX, nNewY = nNewY};
end

function Decoration:GetPlayerSettingOrgPos(pPlayer)
	local nMapId, nX, nY = pPlayer.GetWorldPos();
	if self.tbOrgPosInfo and self.tbOrgPosInfo.nMapId == nMapId and self.tbOrgPosInfo.nNewX == nX and self.tbOrgPosInfo.nNewY == nY then
		return nMapId, self.tbOrgPosInfo.nOrgX, self.tbOrgPosInfo.nOrgY;
	end

	return nMapId, nX, nY;
end

function Decoration:UpdatePlayerSettingPos(tbDecoration)
	local tbParam = tbDecoration.tbParam;
	local tbSetting = self:GetPlayerSetting(tbDecoration.nTemplateId, tbParam.nType);
	if not tbSetting then
		return;
	end

	local nPlayerCount = Lib:CountTB(tbParam.tbPlayerInfo or {});
	if nPlayerCount <= 0 then
		return;
	end

	local tbPosInfo = tbSetting.tbPlayerPosInfo[nPlayerCount];

	local tbAllNpcInfo = self:GetSortNpcInfo(tbParam.tbNpcIdInfo or {});
	for nIndex, nNpcId in pairs(tbAllNpcInfo) do
		local pNpc = KNpc.GetById(nNpcId);
		local pRole = nil;
		if pNpc then
			pRole = pNpc.GetPlayer();
		end
		if pRole then
			local nPPX, nPPY = tbPosInfo[nIndex][1], tbPosInfo[nIndex][2];
			if tbDecoration.nRotation == 0 then
				nPPX, nPPY = nPPY, -1 * nPPX;
			elseif tbDecoration.nRotation == 90 then
				nPPX, nPPY = nPPX * -1, nPPY * -1;
			elseif tbDecoration.nRotation == 180 then
				nPPX, nPPY = -1 * nPPY, nPPX;
			elseif tbDecoration.nRotation == 270 then
				nPPX, nPPY = nPPX, nPPY;
			end

			local tbExtPosInfo = (tbSetting.tbPlayerExtPosInfo[nPlayerCount] or {})[nIndex];
			if tbExtPosInfo and tbExtPosInfo[tbDecoration.nRotation] then
				nPPX, nPPY = unpack(tbExtPosInfo[tbDecoration.nRotation]);
			end

			pRole.SetPosition(tbDecoration.nX + nPPX, tbDecoration.nY + nPPY);

			pRole.CallClientScript("Decoration:SyncPosInfo", pRole.nMapId, (pRole.tbDecorationActStatePos or {0, 0})[1], (pRole.tbDecorationActStatePos or {0, 0})[2], tbDecoration.nX + nPPX, tbDecoration.nY + nPPY);
		end
	end
end

function Decoration:OnSyncActState(bState)
	self:OnSyncPlayerActState(bState);
end

function Decoration:OnSyncPlayerActState(bState)
	self.bActState = bState;
end

function Decoration:ExitPlayerActState(nPlayerId, bNotSyncChangeParam)
	local tbToRemove = {};
	for nId, tbInfo in pairs(self.tbAllActPlayerInfo or {}) do
		if tbInfo[nPlayerId] then
			local tbDecoration = self.tbAllDecoration[nId];
			if tbDecoration then
				local tbParam = Lib:CopyTB(tbDecoration.tbParam or {});
				tbParam.tbPlayerInfo = tbParam.tbPlayerInfo or {};
				tbParam.tbPlayerInfo[tbInfo[nPlayerId]] = nil;
				if tbParam.tbNpcIdInfo then
					tbParam.tbNpcIdInfo[tbInfo[nPlayerId]] = nil;
				end
				if tbParam.tbGender then
					tbParam.tbGender[tbInfo[nPlayerId]] = nil
				end

				-- 床类家具当返回一个人的时候类型必须要是 0
				if Lib:CountTB(tbParam.tbPlayerInfo) == 1 then
					local tbTemplate = self.tbAllTemplate[tbDecoration.nTemplateId];
					if tbTemplate.szSubType == "Chuang" then
						tbParam.nType = 0;
					end
				end
				Decoration:ChangeParam(nId, tbParam, bNotSyncChangeParam);
				self:UpdatePlayerSettingPos(tbDecoration);
			end
			tbInfo[nPlayerId] = nil;
		end
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if MODULE_GAMECLIENT then
		if not self.bActState then
			return;
		end

		self.bActState = false;
		for nBufferId in pairs(self.tbAllBufferId) do
			if pPlayer.GetNpc().GetSkillState(nBufferId) then
				self.bActState = true;
				break;
			end
		end

		if self.bActState then
			RemoteServer.DecorationExitActState();
		end
		return;
	end

	if not pPlayer.tbDecorationActStatePos then
		return;
	end

	if pPlayer.tbDecorationActStatePos then
		pPlayer.SetPosition(pPlayer.tbDecorationActStatePos[1], pPlayer.tbDecorationActStatePos[2]);
		pPlayer.tbDecorationActStatePos = nil;
	end

	Env:SetSystemSwitchOn(pPlayer, Env.SW_All);
	for nBufferId in pairs(self.tbAllBufferId) do
		pPlayer.RemoveSkillState(nBufferId);
	end
	pPlayer.GetNpc().RestoreFeature()
	pPlayer.CallClientScript("Decoration:OnSyncPlayerActState", false);
end

function Decoration:ExitPlayerActStateByDecorationId(nId, bNotSync)
	local tbInfo = self.tbAllActPlayerInfo[nId];
	if not tbInfo then
		return;
	end

	local nCount = 0;
	local nExitPlayerId = nil;
	for nPlayerId in pairs(tbInfo) do
		self:ExitPlayerActState(nPlayerId, bNotSync);
		nCount = nCount + 1;
		nExitPlayerId = nPlayerId;
	end

	return nCount > 0, nExitPlayerId;
end

function Decoration:GetSortNpcInfo(tbNpcIdInfo)
	local tbNewInfo = {};

	local tbIdx = {};
	for nIdx, nNpcId in pairs(tbNpcIdInfo) do
		table.insert(tbIdx, nIdx);
	end

	table.sort(tbIdx);

	for _, nIdx in ipairs(tbIdx) do
		table.insert(tbNewInfo, tbNpcIdInfo[nIdx]);
	end

	return tbNewInfo;
end

function Decoration:OnCreateClientRep_PlayerSetting(tbRepInfo, pRep)
	if not tbRepInfo.tbParam then
		return;
	end

	local tbSetting = self:GetPlayerSetting(tbRepInfo.nTemplateId, tbRepInfo.tbParam.nType or 0);
	if not tbSetting then
		return;
	end

	local nPlayerCount = Lib:CountTB(tbRepInfo.tbParam.tbPlayerInfo or {});
	if not tbSetting.tbSlotInfo or nPlayerCount <= 0 or not tbSetting.tbSlotInfo[nPlayerCount] then
		return;
	end

	local tbSlotInfo = tbSetting.tbSlotInfo[nPlayerCount];
	local tbNpcIdInfo = self:GetSortNpcInfo(tbRepInfo.tbParam.tbNpcIdInfo or {});
	local nUseSlotCount = 0;
	for _, nNpcId in ipairs(tbNpcIdInfo) do
		nUseSlotCount = nUseSlotCount + 1;
		if Ui.Effect.IsNpcGameObjectExist(nNpcId) then
			pRep:BindNpcToSlot(nNpcId, tbSlotInfo[nUseSlotCount], "sit");
		else
			Timer:Register(Env.GAME_FPS, function (nRepId, nNpcId, szSlot)
				local pRep = Ui.Effect.GetObjRepresent(nRepId);
				if not pRep then
					return false;
				end
				if Ui.Effect.IsNpcGameObjectExist(nNpcId) then
					pRep:BindNpcToSlot(nNpcId, szSlot, "sit");
					return false;
				end
				return true;
			end, pRep.m_nID, nNpcId, tbSlotInfo[nUseSlotCount]);
		end
	end
end