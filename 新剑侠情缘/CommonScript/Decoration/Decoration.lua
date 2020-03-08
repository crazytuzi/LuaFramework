Decoration.CELL_LOGIC_WIDTH = 28;
Decoration.CELL_LOGIC_HEIGHT = 28;

Decoration.RELATION_NONE = 0;
Decoration.RELATION_WEDDING = 1;

function Decoration:LoadSetting()
	self.tbNormalRes = LoadTabFile("Setting/Decoration/DecorationRes.tab", "ds", "nResId", {"nResId", "szResPath"});
	self.tbAllTemplate = LoadTabFile("Setting/Decoration/DecorationTemplate.tab", "dssssdddddddssdd", "nTemplateId",
		{"nTemplateId", "szInfo", "szType", "szSubType", "szResPath", "nWidth", "nLength", "nHeight", "bCanOperation", "bHasObstacle", "nBarrierType", "nDepth", "szLimitRotation", "szScale", "bShowDir", "nAllowRelation"});

	for _, tbInfo in pairs(self.tbAllTemplate) do
		if tbInfo.szLimitRotation ~= "" then
			local tbLimit = {}
			local tbValue = Lib:SplitStr(tbInfo.szLimitRotation, "|");
			for _, limit in pairs(tbValue) do
				limit = tonumber(limit);
				assert(limit % 90 == 0);
				tbLimit[limit] = true;
			end
			tbInfo.tbLimitRotation = tbLimit;
			assert(Lib:CountTB(tbInfo.tbLimitRotation) < 4);
		end


		local nXMin, nXMax, nYMin, nYMax = string.match(tbInfo.szScale, "(%d+)|(%d+);(%d+)|(%d+)");
		nXMin = tonumber(nXMin or "");
		nXMax = tonumber(nXMax or "");
		nYMin = tonumber(nYMin or "");
		nYMax = tonumber(nYMax or "");
		if nXMin and nXMax and nYMin and nYMax and nXMin < nXMax and nYMin < nYMax then
			nXMin = nXMin / 100;
			nXMax = nXMax / 100;
			nYMin = nYMin / 100;
			nYMax = nYMax / 100;
			tbInfo.tbScale = {nXMin, nXMax, nYMin, nYMax};
		end
		tbInfo.szScale = nil;
		tbInfo.bCanOperation = tbInfo.bCanOperation == 1;
	end

	local tbFile = LoadTabFile("Setting/Decoration/DecorationBlackMsg.tab", "ds", "nDecorationId", {"nDecorationId", "szMsg"});
	for nDecorationId, tbInfo in pairs(tbFile) do
		if self.tbAllTemplate[nDecorationId] then
			self.tbAllTemplate[nDecorationId].szBlackBoardMsg = tbInfo.szMsg;
		end
	end

	self.tbLandSetting = {};
	local szFile = "Setting/Decoration/DecorationLand.tab";
	local tbFile = LoadTabFile(szFile, "dds", nil, { "nDecorationId", "nState", "szRes" });
	for _, tbRow in pairs(tbFile) do
		local nDecorationId = tbRow.nDecorationId;
		local nState = tbRow.nState;
		self.tbLandSetting[nDecorationId] = self.tbLandSetting[nDecorationId] or {};
		assert(not self.tbLandSetting[nDecorationId][nState], "Decoration land:" .. nDecorationId);

		self.tbLandSetting[nDecorationId][nState] =
		{
			szRes =	tbRow.szRes,
		};
	end
end
Decoration:LoadSetting();

if MODULE_GAMESERVER then
	Decoration.tbAllDecoration = Decoration.tbAllDecoration or {};
	Decoration.nNextDecorationId = Decoration.nNextDecorationId or 1;
end

if MODULE_GAMECLIENT then
	Decoration.tbClientDecoration = Decoration.tbClientDecoration or {};
end

Decoration.tbDecorationDepth = Decoration.tbDecorationDepth or {};

function Decoration:GetSubTypeByDecorationId(nDecorationId)
	local tbTemplate = self.tbAllTemplate[nDecorationId];
	if not tbTemplate or not tbTemplate.szSubType then
		return;
	end

	return tbTemplate.szSubType;
end

function Decoration:GetScaleSetting(nDecorationId)
	local tbTemplate = self.tbAllTemplate[nDecorationId];
	if not tbTemplate or not tbTemplate.tbScale then
		return;
	end

	return unpack(tbTemplate.tbScale)
end

function Decoration:CheckScale(nDecorationId, nSX, nSY)
	nSX = nSX or 1;
	nSY = nSY or 1;

	if nSX == 1 and nSY == 1 then
		return true;
	end

	local nSXMin, nSXMax, nSYMin, nSYMax = self:GetScaleSetting(nDecorationId);
	if not nSXMin or nSX < nSXMin or nSX > nSXMax or nSY < nSYMin or nSY > nSYMax then
		return false;
	end

	return true;
end

function Decoration:FormatScale(nDecorationId, nSX, nSY)
	if not self:CheckScale(nDecorationId, nSX, nSY) then
		return nil, nil;
	end

	if nSX == 1 then
		nSX = nil;
	end

	if nSY == 1 then
		nSY = nil;
	end

	return nSX, nSY;
end

function Decoration:GetNextRotation(nTemplateId, nRotation)
	nRotation = nRotation or 270;
	local tbTemplate = self.tbAllTemplate[nTemplateId];
	if not tbTemplate then
		return nRotation;
	end

	for i = 1, 4 do
		nRotation = (nRotation + 90) % 360;
		if not tbTemplate.tbLimitRotation or not tbTemplate.tbLimitRotation[nRotation] then
			return nRotation;
		end
	end

	return nRotation;
end

function Decoration:FormatRotation(nTemplateId, nRotation)
	nRotation = nRotation or 270;
	nRotation = nRotation % 90 == 0 and nRotation or 270;
	local tbTemplate = self.tbAllTemplate[nTemplateId];
	if not tbTemplate then
		return nRotation;
	end

	if tbTemplate.tbLimitRotation and tbTemplate.tbLimitRotation[nRotation] then
		return self:GetNextRotation(nTemplateId, nRotation);
	end

	return nRotation;
end

function Decoration:ForeachCell(nX, nY, nRotation, nTemplateId)
	local tbTemplate = self.tbAllTemplate[nTemplateId] or {nWidth = 0, nLength = 0};
	local nWidth, nLength = tbTemplate.nWidth, tbTemplate.nLength;
	if math.floor(nRotation / 90) % 2 == 1 then
		nWidth, nLength = nLength, nWidth;
	end

	local nSX = math.floor((nX - nWidth * self.CELL_LOGIC_WIDTH / 2) / self.CELL_LOGIC_WIDTH);
	local nSY = math.floor((nY - nLength * self.CELL_LOGIC_HEIGHT / 2) / self.CELL_LOGIC_HEIGHT);
	local i, j = 0, -1;
	if nX <= nWidth * self.CELL_LOGIC_HEIGHT / 2 then
		i = nWidth + 1;
	end
	return function ()
		j = j + 1;
		if j >= nLength then
			i = i + 1;
			j = 0;
		end
		if i >= nWidth then
			return nil, nil;
		end
		return nSX + i, nSY + j;
	end
end

-- 吸附边界
function Decoration:GetRealPos(nTemplateId, nX, nY, nRotation)
	nRotation = nRotation or 0;

	local tbTemplate = self.tbAllTemplate[nTemplateId];
	local nWidth, nLength = tbTemplate.nWidth, tbTemplate.nLength;
	if math.floor(nRotation / 90) % 2 == 1 then
		nWidth, nLength = nLength, nWidth;
	end

	if nWidth <= 0 and nLength <= 0 then
		return nX, nY;
	end

	local nSpace = (nX - nWidth * self.CELL_LOGIC_WIDTH / 2) % self.CELL_LOGIC_WIDTH;
	nX = nSpace > (self.CELL_LOGIC_WIDTH / 2) and nX + self.CELL_LOGIC_WIDTH - nSpace or nX - nSpace;

	nSpace = (nY - nLength * self.CELL_LOGIC_HEIGHT / 2) % self.CELL_LOGIC_HEIGHT;
	nY = nSpace > (self.CELL_LOGIC_HEIGHT / 2) and nY + self.CELL_LOGIC_HEIGHT - nSpace or nY - nSpace;

	nX = math.max(nX, self.CELL_LOGIC_WIDTH * nWidth / 2 + self.CELL_LOGIC_WIDTH);
	nY = math.max(nY, self.CELL_LOGIC_HEIGHT * nLength / 2 + self.CELL_LOGIC_HEIGHT);

	return nX, nY;
end

function Decoration:CheckDepth(nMapId, nX, nY, nRotation, nTemplateId)
	local tbTemplate = self.tbAllTemplate[nTemplateId];
	for x, y in Decoration:ForeachCell(nX, nY, nRotation, nTemplateId) do
		if self.tbDecorationDepth[nMapId] and self.tbDecorationDepth[nMapId][tbTemplate.nDepth] and
			self.tbDecorationDepth[nMapId][tbTemplate.nDepth][x] and self.tbDecorationDepth[nMapId][tbTemplate.nDepth][x][y] then
			return false;
		end
	end
	return true;
end

function Decoration:CheckBarrier(nMapId, nX, nY, nRotation, nTemplateId)
	local tbTemplate = self.tbAllTemplate[nTemplateId];
	for x, y in Decoration:ForeachCell(nX, nY, nRotation, nTemplateId) do
		local nBarrier = GetBarrierInfo(nMapId, x * self.CELL_LOGIC_WIDTH, y * self.CELL_LOGIC_HEIGHT);
		if nBarrier == 255 and self.tbClientTempObsInfo and self.tbClientTempObsInfo[x] and self.tbClientTempObsInfo[x][y] then
			nBarrier = tbTemplate.nBarrierType;
		end
		if nBarrier ~= tbTemplate.nBarrierType then
			if tbTemplate.bHasObstacle == 1 then
				return false
			end

			local nOrgType = self:GetOrgBarrierType(nMapId, x, y) or nBarrier;
			if nOrgType ~= tbTemplate.nBarrierType then
				return false;
			end
		end
	end
	return true;
end

function Decoration:GetOrgBarrierType(nMapId, nX, nY)
	local tbMapInfo = self.tbDecorationDepth[nMapId] or {};
	for _, tbDepInfo in pairs(tbMapInfo) do
		if tbDepInfo[nX] and tbDepInfo[nX][nY] then
			return tbDepInfo[nX][nY];
		end
	end
end

function Decoration:CheckNpc(nMapId, nX, nY, nRotation, nTemplateId)
	local tbTemplate = self.tbAllTemplate[nTemplateId];
	if tbTemplate and tbTemplate.bHasObstacle == 0 then
		return true;
	end

	local nWidth, nLength = tbTemplate.nWidth, tbTemplate.nLength;
	if math.floor(nRotation / 90) % 2 == 1 then
		nWidth, nLength = nLength, nWidth;
	end
	local tbRange = {{nX - self.CELL_LOGIC_WIDTH * nWidth / 2, nY - self.CELL_LOGIC_HEIGHT * nLength / 2},
					 {nX + self.CELL_LOGIC_WIDTH * nWidth / 2, nY + self.CELL_LOGIC_HEIGHT * nLength / 2}};
	local tbAllNpc = {}
	if MODULE_GAMECLIENT then
		tbAllNpc = KNpc.GetNpcListInCurrentMap();
	else
		tbAllNpc = KNpc.GetMapNpc(nMapId, true);
	end

	for _, pNpc in pairs(tbAllNpc or {}) do
		local m, x, y = pNpc.GetWorldPos();
		if x >= tbRange[1][1] and x <= tbRange[2][1] and
			y >= tbRange[1][2] and y <= tbRange[2][2] then
			return false;
		end
	end
	return true;
end

function Decoration:CheckCanUseDecoration(nMapId, nX, nY, nRotation, nTemplateId, bNotCheckNpc)
	nRotation = nRotation or 0;
	local tbTemplate = self.tbAllTemplate[nTemplateId];
	if not self.tbAllTemplate[nTemplateId] then
		return false, "异常物品！";
	end

	if MODULE_GAMESERVER then
		local nMapTemplateId = GetMapInfoById(nMapId);
		if not nMapTemplateId then
			return false, "不存在的地图！";
		end
	end

	local bRet = self:CheckDepth(nMapId, nX, nY, nRotation, nTemplateId);
	if not bRet then
		return false, "此处不能摆放！";
	end

	bRet = self:CheckBarrier(nMapId, nX, nY, nRotation, nTemplateId);
	if not bRet then
		return false, "此处不可摆放！";
	end

	bRet = self:CheckNpc(nMapId, nX, nY, nRotation, nTemplateId);
	if not bNotCheckNpc and not bRet then
		return false, "此处无法摆放！";
	end

	return true;
end

function Decoration:ClearClientTempObs()
	self.tbClientTempObsInfo = nil;
end

function Decoration:SetObstacle(nMapId, nX, nY, nRotation, nTemplateId, bClear, bClientTemp)
	if not MODULE_GAMECLIENT then
		bClientTemp = false;
	end

	local tbTemplate = self.tbAllTemplate[nTemplateId];
	if not tbTemplate then
		return;
	end

	if tbTemplate.bHasObstacle == 1 then
		local nWidth, nLength = tbTemplate.nWidth, tbTemplate.nLength;
		if math.floor(nRotation / 90) % 2 == 1 then
			nWidth, nLength = nLength, nWidth;
		end

		local nType = bClear and tbTemplate.nBarrierType or 255;

		if bClear and bClientTemp then
			nType = 255;
		end

		SetSubWorldBarrierInfo(nMapId, nX, nY, nWidth * self.CELL_LOGIC_WIDTH / 2, nLength * self.CELL_LOGIC_HEIGHT / 2, nType);
	end

	if bClientTemp and tbTemplate.bHasObstacle == 1 then
		self.tbClientTempObsInfo = {};
	end

	for x, y in Decoration:ForeachCell(nX, nY, nRotation, nTemplateId) do
		self.tbDecorationDepth[nMapId] = self.tbDecorationDepth[nMapId] or {};
		self.tbDecorationDepth[nMapId][tbTemplate.nDepth] = self.tbDecorationDepth[nMapId][tbTemplate.nDepth] or {};
		self.tbDecorationDepth[nMapId][tbTemplate.nDepth][x] = self.tbDecorationDepth[nMapId][tbTemplate.nDepth][x] or {};
		if bClear then
			self.tbDecorationDepth[nMapId][tbTemplate.nDepth][x][y] = nil;
		else
			self.tbDecorationDepth[nMapId][tbTemplate.nDepth][x][y] = tbTemplate.nBarrierType;
		end

		if bClear and bClientTemp and tbTemplate.bHasObstacle == 1 then
			self.tbClientTempObsInfo[x] = self.tbClientTempObsInfo[x] or {};
			self.tbClientTempObsInfo[x][y] = true;
		end
	end
end

function Decoration:GetDecorationRepById(nId)
	local tbRepInfo = self.tbClientDecoration[nId];
	if not tbRepInfo then
		return;
	end

	local pRep = Ui.Effect.GetObjRepresent(tbRepInfo.nRepId);
	if not pRep then
		return;
	end

	return pRep;
end

function Decoration:NewDecoration(nMapId, nX, nY, nRotation, nTemplateId, bCreateMap, bCanOperation)
	local tbSetting = {nX = nX, nY = nY, nRotation = nRotation, nTemplateId = nTemplateId, bCanOperation = bCanOperation};
	return self:NewDecorationByTB(nMapId, tbSetting, bCreateMap)
end

function Decoration:NewDecorationByTB(nMapId, tbSetting, bNotSync)
	local nX, nY, nSX, nSY, nRotation, nTemplateId, bCanOperation = tbSetting.nX, tbSetting.nY, tbSetting.nSX, tbSetting.nSY, tbSetting.nRotation, tbSetting.nTemplateId, tbSetting.bCanOperation;
	nRotation = self:FormatRotation(nTemplateId, nRotation);

	nX, nY = self:GetRealPos(nTemplateId, nX, nY, nRotation);
	local bRet, szMsg = self:CheckCanUseDecoration(nMapId, nX, nY, nRotation, nTemplateId);
	if not bRet then
		return false, szMsg;
	end

	local nId = self.nNextDecorationId;
	self.nNextDecorationId = self.nNextDecorationId + 1;

	if bCanOperation == nil then
		local tbTemplate = self.tbAllTemplate[nTemplateId];
		bCanOperation = tbTemplate.bCanOperation;
	end
	self.tbAllDecoration[nId] = {nMapId = nMapId, nX = nX, nY = nY, nSX = nSX, nSY = nSY, nRotation = nRotation, nTemplateId = nTemplateId, bCanOperation = bCanOperation};

	self:SetObstacle(nMapId, nX, nY, nRotation, nTemplateId, false);

	self:OnCreate(nId);

	if not bNotSync then
		KPlayer.MapBoardcastScriptByFuncName(nMapId, "Decoration:OnSyncDecoration", nMapId, nId, Decoration:GetSyncInfo(self.tbAllDecoration[nId]));
	end
	return true, "", nId;
end

function Decoration:CheckCanChangePos(nId, nX, nY, nRotation)
	local tbDecoration = self.tbAllDecoration[nId];
	if not tbDecoration then
		return false, "不存在的物品！";
	end

	Decoration:OnCheckChangePos(nId);

	local nRX, nRY = self:GetRealPos(tbDecoration.nTemplateId, nX, nY, nRotation);
	if nRX ~= nX and nRY ~= nY then
		return false, "摆放位置不对！";
	end

	if true then		-- 这是一块的，中间不要插入代码
		self:SetObstacle(tbDecoration.nMapId, tbDecoration.nX, tbDecoration.nY, tbDecoration.nRotation, tbDecoration.nTemplateId, true);
		local bRet, szMsg = self:CheckCanUseDecoration(tbDecoration.nMapId, nX, nY, nRotation, tbDecoration.nTemplateId);
		if not bRet then
			self:SetObstacle(tbDecoration.nMapId, tbDecoration.nX, tbDecoration.nY, tbDecoration.nRotation, tbDecoration.nTemplateId);
			return false, szMsg;
		end
		self:SetObstacle(tbDecoration.nMapId, tbDecoration.nX, tbDecoration.nY, tbDecoration.nRotation, tbDecoration.nTemplateId);
	end

	return true, "", tbDecoration;
end

function Decoration:ChangeDecorationPos(nId, nX, nY, nRotation, nSX, nSY)
	local bRet, szMsg, tbDecoration = self:CheckCanChangePos(nId, nX, nY, nRotation);
	if not bRet then
		return false, szMsg;
	end

	self:SetObstacle(tbDecoration.nMapId, tbDecoration.nX, tbDecoration.nY, tbDecoration.nRotation, tbDecoration.nTemplateId, true);

	KPlayer.MapBoardcastScriptByFuncName(tbDecoration.nMapId, "Decoration:SetObstacle", tbDecoration.nMapId, tbDecoration.nX, tbDecoration.nY, tbDecoration.nRotation, tbDecoration.nTemplateId, true);

	self:SetObstacle(tbDecoration.nMapId, nX, nY, nRotation, tbDecoration.nTemplateId, false);

	tbDecoration.nX = nX;
	tbDecoration.nY = nY;
	tbDecoration.nSX = nSX;
	tbDecoration.nSY = nSY;
	tbDecoration.nRotation = nRotation;
	KPlayer.MapBoardcastScriptByFuncName(tbDecoration.nMapId, "Decoration:OnSyncDecoration", tbDecoration.nMapId, nId, Decoration:GetSyncInfo(tbDecoration));
	return true;
end

function Decoration:SyncDecoration(nId)
	local tbDecoration = self.tbAllDecoration[nId];
	if not tbDecoration then
		return;
	end
	KPlayer.MapBoardcastScriptByFuncName(tbDecoration.nMapId, "Decoration:OnSyncDecoration", tbDecoration.nMapId, nId, Decoration:GetSyncInfo(tbDecoration));
end

function Decoration:ChangeParam(nId, tbParam, bNotSyncChangeParam)
	local tbDecoration = self.tbAllDecoration[nId];
	if not tbDecoration then
		return false, "不存在的物品！";
	end

	tbDecoration.tbParam = tbParam;
	if not bNotSyncChangeParam then
		KPlayer.MapBoardcastScriptByFuncName(tbDecoration.nMapId, "Decoration:OnSyncDecoration", tbDecoration.nMapId, nId, Decoration:GetSyncInfo(tbDecoration));
	end
	return true;
end

function Decoration:GetSyncInfo(tbDecoration)
	return {nX = tbDecoration.nX,
			nY = tbDecoration.nY,
			nSX = tbDecoration.nSX,
			nSY = tbDecoration.nSY,
			nRotation = tbDecoration.nRotation,
			nTemplateId = tbDecoration.nTemplateId,
			tbParam = tbDecoration.tbParam,
			bCanOperation = tbDecoration.bCanOperation,
			};
end

function Decoration:ChangeScale(nId, nSX, nSY)
	local tbDecoration = self.tbAllDecoration[nId];
	if not tbDecoration then
		return false;
	end

	tbDecoration.nSX = nSX or 1;
	tbDecoration.nSY = nSY or 1;
	KPlayer.MapBoardcastScriptByFuncName(tbDecoration.nMapId, "Decoration:OnSyncScale", nId, nSX, nSY);
end

function Decoration:DeleteDecoration(nId)
	if MODULE_GAMESERVER then
		if self.tbAllDecoration[nId] then
			self:OnDelete(nId);
			local tbDecoration = self.tbAllDecoration[nId];
			self:SetObstacle(tbDecoration.nMapId, tbDecoration.nX, tbDecoration.nY, tbDecoration.nRotation, tbDecoration.nTemplateId, true);
			KPlayer.MapBoardcastScriptByFuncName(tbDecoration.nMapId, "Decoration:SetObstacle", tbDecoration.nMapId, tbDecoration.nX, tbDecoration.nY, tbDecoration.nRotation, tbDecoration.nTemplateId, true);
			KPlayer.MapBoardcastScriptByFuncName(self.tbAllDecoration[nId].nMapId, "Decoration:DeleteDecoration", nId);
			self.tbAllDecoration[nId] = nil;
		end
	end

	if MODULE_GAMECLIENT then
		if self.tbClientDecoration[nId] then
			if self.tbClientDecoration[nId].nRepId then
				Ui.Effect.RemoveObjRepresent(self.tbClientDecoration[nId].nRepId);
			end
			self.tbClientDecoration[nId] = nil;
			UiNotify.OnNotify(UiNotify.emNOTIFY_DELETE_DECORATION, nId);
		end
	end
end

function Decoration:OnMapDestroy(nMapTemplateId, nMapId)
	local tbToDelete = {};
	for nId, tbInfo in pairs(self.tbAllDecoration or {}) do
		if tbInfo.nMapId == nMapId then
			tbToDelete[nId] = true;
		end
	end

	for nId in pairs(tbToDelete) do
		self.tbAllDecoration[nId] = nil;
	end
	self.tbDecorationDepth[nMapId] = nil;
end

function Decoration:PlayerOnEnterMap(nMapId)
	self:DoSyncMapDecoration(me, nMapId);
end

function Decoration:DoSyncMapDecoration(pPlayer, nMapId)
	local nMapId = nMapId or pPlayer.nMapId;
	local tbToSync = {};
	local nCount = 0;

	pPlayer.CallClientScript("Decoration:OnSyncMapDecoration", nMapId, pPlayer.nMapTemplateId, {});
	for nId, tbInfo in pairs(self.tbAllDecoration) do
		if tbInfo.nMapId == nMapId then
			nCount = nCount + 1;
			tbToSync[nId] = Decoration:GetSyncInfo(tbInfo);

			if nCount >= 10 then
				pPlayer.CallClientScript("Decoration:OnBatchSyncDecoration", nMapId, tbToSync);
				tbToSync = {};
				nCount = 0;
			end
		end
	end

	if nCount > 0 then
		pPlayer.CallClientScript("Decoration:OnBatchSyncDecoration", nMapId, tbToSync);
	end
end

function Decoration:GetRepInfoByRepId(nRepId)
	for nId, tbRepInfo in pairs(self.tbClientDecoration) do
		if tbRepInfo.nRepId == nRepId then
			return nId, tbRepInfo;
		end
	end
end

function Decoration:OnBatchSyncDecoration(nMapId, tbToSync)
	for nId, tbInfo in pairs(tbToSync or {}) do
		self:OnSyncDecoration(nMapId, nId, tbInfo);
	end
end

function Decoration:OnSyncDecoration(nMapId, nId, tbSetting)
	if self.tbClientDecoration[nId] then
		self:DeleteDecoration(nId);
	end

	self.tbClientDecoration[nId] = {
		nMapId = nMapId,
		nX = tbSetting.nX,
		nY = tbSetting.nY,
		nSX = tbSetting.nSX,
		nSY = tbSetting.nSY,
		nRotation = tbSetting.nRotation,
		nTemplateId = tbSetting.nTemplateId,
		tbParam = tbSetting.tbParam,
		bCanOperation = tbSetting.bCanOperation,
		};

	if me.nMapId == nMapId and not Map:IsMapOnLoading() then
		self:CreateClientRep(self.tbClientDecoration[nId]);
	end
end

function Decoration:OnSyncMapDecoration(nMapId, nMapTemplateId, tbDecoration)
	local tbToRemove = {};
	for nId in pairs(self.tbClientDecoration or {}) do
		tbToRemove[nId] = true;
	end

	if nMapTemplateId == me.nMapTemplateId then
		for nId, tbInfo in pairs(self.tbClientDecoration) do
			Decoration:SetObstacle(me.nMapId, tbInfo.nX, tbInfo.nY, tbInfo.nRotation, tbInfo.nTemplateId, true);
		end
	end

	for nId in pairs(tbToRemove) do
		self:DeleteDecoration(nId);
	end

	for nId, tbInfo in pairs(tbDecoration) do
		self:OnSyncDecoration(nMapId, nId, tbInfo);
	end
end

function Decoration:OnMapLoaded()
	local tbToRemove = {};
	for nId, tbRepInfo in pairs(self.tbClientDecoration) do
		if tbRepInfo.nMapId == me.nMapId then
			self:CreateClientRep(tbRepInfo);
		else
			tbToRemove[nId] = true;
		end
	end

	for nId in pairs(tbToRemove) do
		self.tbClientDecoration[nId] = nil;
	end
	--处理依据家具模板ID设置的障碍(只有障碍，没有家具)
	if self.tbFakeBarrier then
		for i = #self.tbFakeBarrier, 1, -1 do
			local tbData = self.tbFakeBarrier[i]
			if me.nMapId == tbData.nMapId then
				self:SetObstacle(tbData.nMapId, tbData.nX, tbData.nY, tbData.nRotation, tbData.nTemplateId, tbData.bClear, tbData.bClientTemp)
				table.remove(self.tbFakeBarrier, i)
			end
		end
	end
end

function Decoration:CreateClientRep(tbRepInfo, bTest)
	if tbRepInfo.nRepId then
		return;
	end

	local tbTemplate = self.tbAllTemplate[tbRepInfo.nTemplateId];
	if not tbTemplate then
		return;
	end

	Ui:CloseWindow("FurnitureOptUi");

	if not bTest then
		self:SetObstacle(me.nMapId, tbRepInfo.nX, tbRepInfo.nY, tbRepInfo.nRotation, tbRepInfo.nTemplateId, false);
	end

	local nId = 0;
	for i, tbTmpRep in pairs(self.tbClientDecoration) do
		if tbTmpRep == tbRepInfo then
			nId = i;
			break;
		end
	end

	local pRep = Ui.Effect.CreateObjRepresent();
	tbRepInfo.nRepId = pRep.m_nID;

	if nId > 0 then
		local szName = string.format("%s_%s_%s_%s", nId, tbRepInfo.nRepId, tbRepInfo.nTemplateId, tbTemplate.szInfo);
		pRep:SetName(szName);
	end

	pRep:SetLogicPos(tbRepInfo.nX, tbRepInfo.nY);
	pRep:AddEffectRes(tbTemplate.szResPath);
	pRep:SetRotation(0, (math.floor(tbRepInfo.nRotation / 90) % 4) * 90, 0);

	pRep:SetScale(tbRepInfo.nSX or 1, 1, tbRepInfo.nSY or 1);
	pRep:SetPenetrateClick(false);

	Decoration:OnCreateClientRep(tbRepInfo, pRep);
	Decoration:OnCreateClientRep_PlayerSetting(tbRepInfo, pRep);

	if House.bDecorationMode or bTest or (tbRepInfo.bCanOperation and (tbTemplate.szType ~= "" or tbTemplate.szSubType ~= "")) then
		pRep:SetColliderLogicSize(tbTemplate.nWidth * self.CELL_LOGIC_WIDTH, tbTemplate.nHeight, tbTemplate.nLength * self.CELL_LOGIC_HEIGHT);
	else
		pRep:SetColliderLogicSize(1, 1, 1);
	end

	local bColliderActive = (not bTest) and not House.bDecorationMode;
	pRep:SetMapColliderActive(bColliderActive);
	UiNotify.OnNotify(UiNotify.emNOTIFY_DECORATION_CHANGE, nId);
end

function Decoration:OnLoadEffectFinish(nRepId, szEffectName)
	local tbRepInfo = nil;
	for nId, tbInfo in pairs(self.tbClientDecoration) do
		if tbInfo.nRepId == nRepId then
			tbRepInfo = tbInfo;
			break;
		end
	end

	if not tbRepInfo then
		return;
	end

	local tbTemplate = self.tbAllTemplate[tbRepInfo.nTemplateId];
	if not tbTemplate then
		return;
	end

	local tbClass = self:GetClass(tbTemplate.szType, 1);
	if not tbClass or not tbClass.OnLoadEffectFinish then
		return;
	end

	tbClass:OnLoadEffectFinish(tbRepInfo, tbTemplate.szResPath == szEffectName, szEffectName);
end

function Decoration:CanOperation(tbDecoration, pOperator)
	if not tbDecoration.bCanOperation or not pOperator then
		return false, "此家具不能使用";
	end

	if MODULE_GAMESERVER then
		if ActionInteract:IsInteract(pOperator) then
			return false, "处于交互状态不能操作";
		end
	end

	local tbTemplate = self.tbAllTemplate[tbDecoration.nTemplateId];
	if not tbTemplate then
		return false, "异常的家具";
	end

	local dwOwnerId = nil;
	if MODULE_GAMESERVER then
		dwOwnerId = House:GetHouseInfoByMapId(tbDecoration.nMapId);
	else
		dwOwnerId = House.dwOwnerId;
	end

	if dwOwnerId and dwOwnerId ~= pOperator.dwID
		and tbTemplate.nAllowRelation == Decoration.RELATION_WEDDING
		and not Wedding:IsLover(dwOwnerId, pOperator.dwID) then

		return false, "新婚家具，不允许使用";
	end

	return true;
end

--根据家具模板设置障碍(只是设置障碍，家具不存在)
function Decoration:OnSyncBarrierByFurnitureTID(nMapId, nX, nY, nRotation, nTemplateId, bClear, bClientTemp)
	self.tbFakeBarrier = self.tbFakeBarrier or {}
	if me.nMapId == nMapId and not Map:IsMapOnLoading() then
		self:SetObstacle(nMapId, nX, nY, nRotation, nTemplateId, bClear, bClientTemp)
	else
		local tbData = {}
		tbData.nMapId = nMapId
		tbData.nX = nX
		tbData.nY = nY
		tbData.nRotation = nRotation
		tbData.nTemplateId = nTemplateId
		tbData.bClear = bClear
		tbData.bClientTemp = bClientTemp
		table.insert(self.tbFakeBarrier, tbData)
	end
end