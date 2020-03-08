Require("CommonScript/Fuben/FubenBase.lua");
Require("CommonScript/Map/Map.lua");

-- 副本进入地图限制 通用白名单
Fuben.tbSafeMap = {};
for nMapTemplateId in pairs(Map.tbMapList) do
	if Map:IsCityMap(nMapTemplateId) then
		Fuben.tbSafeMap[nMapTemplateId] = true;
	end
end

function Fuben:Init()
	self.tbFubenTemplate = {};		-- 副本活动脚本模板 (nMapTemplateId 为索引)
	self.tbFubenInstance = {};		-- 副本活动实例(nMapId 为索引)
	self.tbFubenSetting = {};		-- 副本活动事件锁结构(nMapTemplateId 为索引)
	self.tbFubenClass = {};
	self.tbApply = {};
end

if not Fuben.tbFubenTemplate then
	Fuben:Init();
end

function Fuben:LoadFubenNpcTemplateIdx()
	self.tbNpcTemplateIdx = {};
	local tbFile = LoadTabFile("Setting/Fuben/FubenNpcTemplateIdx.tab", "sdd", nil, {"szIndex", "nNpcTemplate1", "nNpcTemplate2"});
	for _, tbRow in pairs(tbFile) do
		assert(not self.tbNpcTemplateIdx[tbRow.szIndex], "Setting/Fuben/FubenNpcTemplateIdx.tab  index repeat !!  " .. tbRow.szIndex);
		self.tbNpcTemplateIdx[tbRow.szIndex] = {};
		self.tbNpcTemplateIdx[tbRow.szIndex][1] = tbRow.nNpcTemplate1;
		self.tbNpcTemplateIdx[tbRow.szIndex][2] = tbRow.nNpcTemplate2;
	end
end
Fuben:LoadFubenNpcTemplateIdx();

function Fuben:GetFubenClass(szClassName)
	local tbBase = self.tbBase;
	if szClassName and self.tbFubenClass[szClassName] then
		tbBase = self.tbFubenClass[szClassName];
	end
	return tbBase;
end

-- 创建一种副本类型
function Fuben:CreateFubenClass(szClassName, szBaseName)
	local tbBase = self:GetFubenClass(szBaseName);
	self.tbFubenClass[szClassName] = Lib:NewClass(tbBase);
	return self.tbFubenClass[szClassName];
end

-- 创建副本实例
function Fuben:CreateFuben(nMapTemplateId, nMapId, nFubenLevel, ...)
	if not self.tbFubenTemplate[nMapTemplateId] or not self.tbFubenSetting[nMapTemplateId] then
		return;		-- 该地图不存在绑定的副本
	end

	nFubenLevel = nFubenLevel or 1;
	self:CloseAllClientFuben();
	self.tbFubenInstance[nMapId] = Lib:NewClass(self.tbFubenTemplate[nMapTemplateId]);
	self.tbFubenInstance[nMapId]:InitFuben(nMapId, self.tbFubenSetting[nMapTemplateId], nFubenLevel);
	self.tbFubenInstance[nMapId]:OnCreate(...);

	Log("CreateFuben", nMapTemplateId, nMapId, self.tbFubenInstance[nMapId], ...);
end

function Fuben:CloseAllClientFuben()
	if MODULE_GAMESERVER then
		return;
	end

	for nMapId, tbIns in pairs(self.tbFubenInstance or {}) do
		tbIns:Close();
	end

	self.tbFubenInstance = {};
end

function Fuben:RegisterFuben(nMapTemplateId, szFubenClass, szPathFile, szNpcPointFile)
	local tbTemplate = Lib:NewClass(self:GetFubenClass(szFubenClass or ""))
	tbTemplate:LoadSetting(szPathFile, szNpcPointFile);
	self.tbFubenTemplate[nMapTemplateId] = tbTemplate
	return tbTemplate;
end

function Fuben:RegisterNpcExtAward(tbTemplate, szNpcExtAwardPath)
	if not tbTemplate or not szNpcExtAwardPath then
		return;
	end

	local tbFileIdxInfo =
	{
		{"nFubenLevel",		"d"},
		{"szType",			"s"},
		{"SubType",			"s"},
		{"nItemId",			"d"},
		{"nCount",			"d"},
		{"nAwardLevel",		"d"},
		{"nRate",			"d"},
		{"bCritAward",		"d"},
		{"bFirst",			"d"},
		{"nSpecialRate",	"s"},
		{"bStarAward",		"d"},
	};

	local tbFileInfo = {
		szType = "";
		szIndex = nil;
		tbTitle = {};
	};
	for _, tbInfo in pairs(tbFileIdxInfo) do
		table.insert(tbFileInfo.tbTitle, tbInfo[1]);
		tbFileInfo.szType = tbFileInfo.szType .. tbInfo[2];
	end


	local tbFile = LoadTabFile(szNpcExtAwardPath, tbFileInfo.szType, tbFileInfo.szIndex, tbFileInfo.tbTitle);
	if not tbFile then
		Log("[Fuben] Fuben:RegisterFuben ERR ?? tbFile is nil !!", szNpcExtAwardPath);
		return;
	end

	local tbAllAward = {};
	local tbTmpInfo = {};
	local tbFirstAward;
	local tbStarAward = {};
	local tbNormalAward = {};
	local tbTotalRate = {};
	for _, tbRow in pairs(tbFile) do
		tbRow.nSpecialRate = tonumber(tbRow.nSpecialRate) or 0;

		if tbRow.SubType ~= "" then
			tbRow.SubType = tonumber(tbRow.SubType) or tbRow.SubType;
		else
			tbRow.SubType = nil;
		end

		if tbRow.bFirst == 1 then
			tbFirstAward = tbFirstAward or {};
			tbFirstAward[tbRow.nFubenLevel] = tbFirstAward[tbRow.nFubenLevel] or {};
			table.insert(tbFirstAward[tbRow.nFubenLevel], tbRow);
		elseif tbRow.bStarAward == 1 then
			tbStarAward = tbStarAward or {};
			tbStarAward[tbRow.nFubenLevel] = tbStarAward[tbRow.nFubenLevel] or {};
			table.insert(tbStarAward[tbRow.nFubenLevel], tbRow);
		else
			local tbResult = self:SplitCoin(tbRow);
			for _, tbInfo in pairs(tbResult) do
				table.insert(tbNormalAward, tbInfo);
			end

			if tbRow.nRate > 0 then
				tbTotalRate[tbRow.nFubenLevel] = tbTotalRate[tbRow.nFubenLevel] or 0;
				tbTotalRate[tbRow.nFubenLevel] = tbTotalRate[tbRow.nFubenLevel] + tbRow.nRate;
			end

			tbAllAward[tbRow.nFubenLevel] = tbAllAward[tbRow.nFubenLevel] or {};
			if tbRow.nItemId > 0 then
				table.insert(tbAllAward[tbRow.nFubenLevel], {"item", tbRow.nItemId, tbRow.nCount});
			elseif Player.AwardType[tbRow.szType] and tbRow.SubType then
				table.insert(tbAllAward[tbRow.nFubenLevel], {tbRow.szType, tbRow.SubType, tbRow.nCount});
			elseif Player.AwardType[tbRow.szType] then
				table.insert(tbAllAward[tbRow.nFubenLevel], {tbRow.szType, tbRow.nCount});
			else
				assert(false,  "unknow award type " .. tbRow.szType .. " file : " .. szNpcExtAwardPath);
			end
		end
	end


	local function fnCmpItemValue(a, b)
		local nAAwardType = Player.AwardType[a[1]];
		local nBAwardType = Player.AwardType[b[1]];

		local function fnCheckType(a, a2, b, b2, value)
			if a == value and b == value then
				return a2 > b2;
			end

			return a == value;
		end

		local szItemClassA, szItemClassB;
		if nAAwardType == Player.award_type_item then
			local tbItemInfoA = KItem.GetItemBaseProp(a[2]);
			szItemClassA = (tbItemInfoA or {}).szClass;
		end

		if nBAwardType == Player.award_type_item then
			local tbItemInfoB = KItem.GetItemBaseProp(b[2]);
			szItemClassB = (tbItemInfoB or {}).szClass;
		end

		local nVa = Player:GetAwardValue(a) or 0;
		local nVb = Player:GetAwardValue(b) or 0;

		return nVa > nVb;
	end

	for _, tbAwardInfo in pairs(tbAllAward) do
		table.sort(tbAwardInfo, fnCmpItemValue);
		local szLastType, varLastSubType;
		for index = #tbAwardInfo, 1, -1 do
			local tbItemInfo = tbAwardInfo[index];
			if tbItemInfo[1] == szLastType and tbItemInfo[2] == varLastSubType then
				table.remove(tbAwardInfo, index + 1);
			else
				szLastType = tbItemInfo[1];
				varLastSubType = tbItemInfo[2];
			end
		end
	end

	tbTemplate.tbStarAward = tbStarAward;
	tbTemplate.tbFirstAward = tbFirstAward;
	tbTemplate.tbPersonalAward = tbNormalAward;
	tbTemplate.tbTotalRate = tbTotalRate;
	tbTemplate.tbAllAward = tbAllAward;
end

function Fuben:SplitCoin(tbRow)
	if tbRow.szType ~= "Coin" and tbRow.szType ~= "coin" then
		return {tbRow};
	end

	local tbResult = {};
	local nNewRate = 0;
	for i = 1, 5 do
		local tbNew = Lib:CopyTB1(tbRow);
		tbNew.nCount = math.floor(tbRow.nCount / 4) * (i + 2);
		tbNew.nRate = math.floor(0.2 * tbRow.nRate);
		nNewRate = nNewRate + tbNew.nRate;
		table.insert(tbResult, tbNew);
	end

	tbResult[3].nCount = tbResult[3].nCount + (tbRow.nCount - tbResult[3].nCount) * 4;
	tbResult[3].nRate = tbResult[3].nRate + tbRow.nRate - nNewRate;
	return tbResult;
end

function Fuben:Load()
	for nMapTemplateId, tbSetting in pairs(self.tbFubenSetting) do
		Fuben:RegisterFuben(nMapTemplateId, tbSetting.szFubenClass, tbSetting.szPathFile, tbSetting.szNpcPointFile);
		Fuben:RegisterNpcExtAward(Fuben.tbFubenTemplate[nMapTemplateId], tbSetting.szNpcExtAwardPath);
	end

	if self.RandomFuben and self.RandomFuben.LoadSetting then
		self.RandomFuben:LoadSetting();
	end

	if self.AdventureFuben and self.AdventureFuben.Init then
		self.AdventureFuben:Init()
	end
end

-- 绑定地图ID和副本配置
function Fuben:SetFubenSetting(nMapTemplateId, tbSetting)
	tbSetting.nMapTemplateId = nMapTemplateId;
	self.tbFubenSetting[nMapTemplateId] = tbSetting;
end

function Fuben:GetFubenSettingByMapTID(nMapTemplateId)
    return self.tbFubenSetting[nMapTemplateId];
end

function Fuben:OnLogin(bReConnect)
	if me.nState == Player.emPLAYER_STATE_ALONE then
		return;
	end

	me.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
	local tbInst = self.tbFubenInstance[me.nMapId];
	if tbInst and (tbInst.OnLogin or tbInst.OnLoginBase) then
		if tbInst.OnLoginBase then
			tbInst:OnLoginBase(bReConnect);
		end
		if tbInst.OnLogin then
			tbInst:OnLogin(bReConnect);
		end
	end

	if tbInst and tbInst.tbCacheCmd then
		me.CallClientScript("Fuben:OnSyncCacheCmd", tbInst.nMapId, tbInst.tbCacheCmd);
	end

	if MODULE_GAMESERVER and not tbInst and self.tbFubenTemplate[me.nMapTemplateId] then
		me.GotoEntryPoint();
	end

	if MODULE_GAMESERVER then
		Fuben.WhiteTigerFuben:OnReconnect(bReConnect)
	end
end

function Fuben:OnEnter(nMapTemplateId, nMapId)
	local tbInst = self.tbFubenInstance[nMapId];
	if tbInst then
		print("tbInst, tbInst.OnEnter==", tbInst, tbInst.OnEnter)
	end

	if tbInst and tbInst.OnEnter then
		tbInst:OnEnter(nMapId);
	end

	if MODULE_GAMESERVER and not tbInst and self.tbFubenTemplate[nMapTemplateId] then
		Log("[Fuben] OnEnter ERR ?? Enter Fuben Map Whithout Create Fuben Inst !!!", me.dwID, me.szName, nMapTemplateId, nMapId);
		me.GotoEntryPoint();
	end
end

function Fuben:OnLeave(nMapTemplateId, nMapId)
	local tbInst = self.tbFubenInstance[nMapId];
	if tbInst and tbInst.OnLeave then
		tbInst:OnLeave(nMapId);
	end
end

function Fuben:OnDestroyMap(nMapId)
	if self.tbFubenInstance[nMapId] then
		self.tbFubenInstance[nMapId]:Close();
		self.tbFubenInstance[nMapId] = nil;
		self:ClearMap(nMapId);
	end
end

function Fuben:OnMapLoaded(nMapId)
   	if self.tbFubenInstance[nMapId] and self.tbFubenInstance[nMapId].OnMapLoaded then
		self.tbFubenInstance[nMapId]:OnMapLoaded();
	end
end

function Fuben:OnPlayerTrap(nMapId, szTrapName)
	if me.bRandomFubenRealDeath then
		return;
	end

	local tbInst = self.tbFubenInstance[nMapId];
	if tbInst and tbInst.OnPlayerTrap then
		tbInst:OnPlayerTrap(szTrapName);
	end
end

function Fuben:OnNpcTrap(nMapId, szTrapName)
	local tbInst = self.tbFubenInstance[nMapId]
	if tbInst and tbInst.OnNpcTrap then
		tbInst:OnNpcTrap(szTrapName)
	end
end

function Fuben:OnKillNpc(pNpc, pKiller)
	local tbInst = self.tbFubenInstance[pNpc.nMapId];
	if tbInst and tbInst.OnNpcDeathFubenBase then
		tbInst:OnNpcDeathFubenBase(pNpc, pKiller);
	end
end

function Fuben:OnNpcCreate(pNpc)
	local tbInst = self.tbFubenInstance[pNpc.nMapId];
	if tbInst and tbInst.OnNpcCreateFubenBase then
		tbInst:OnNpcCreateFubenBase(pNpc);
	end
end

function Fuben:NpcUnLock(pNpc)
	if not pNpc.tbFubenNpcData then
		return;
	end

	local tbFuben = pNpc.tbFubenNpcData.tbFuben;
	local nLock = pNpc.tbFubenNpcData.nLock;
	if not tbFuben or not nLock or not tbFuben.tbLock[nLock] then
		return;
	end

	tbFuben.tbLock[nLock]:UnLockMulti();
end

function Fuben:NpcRaiseEvent(pNpc, szEventName, pPlayer, szParam)
	local tbInst = self.tbFubenInstance[pNpc.nMapId];
	if tbInst then
		tbInst:RaiseEvent(szEventName, pPlayer, pNpc, szParam);
	end
end

function Fuben:NpcRaiseEventCheck(pNpc, szEventName, pPlayer, szParam)
	local tbInst = self.tbFubenInstance[pNpc.nMapId];
	if not tbInst then
		return
	end
	if not szEventName then
		return true
	end
	local fnCheck = tbInst["Check" .. szEventName]
	if fnCheck then
		return fnCheck(tbInst, pPlayer, pNpc, szParam)
	end
	return true
end

function Fuben:IsInLock(pNpc)
	if not pNpc.tbFubenNpcData or not pNpc.tbFubenNpcData.tbFuben or not pNpc.tbFubenNpcData.nLock then
		return 0;
	end

	return 1;
end

function Fuben:ReviveClientPlayer(bResult, szMsg)
	if MODULE_GAMESERVER then
		return;
	end

	if not bResult then
		me.Msg(szMsg or "发现异常，无法复活！");
		return;
	end

	me.Revive();
end

function Fuben:OnPlayCameraAnimationFinish()
	if MODULE_GAMESERVER then
		return;
	end

	for _, tbIns in pairs(self.tbFubenInstance) do
		if tbIns.nAnimationLockId and tbIns.nAnimationLockId > 0 then
			local nLockId = tbIns.nAnimationLockId;
			tbIns.nAnimationLockId = 0;
			tbIns.tbLock[nLockId]:UnLockMulti();
		end
	end
end

function Fuben:OnSceneCameraAnimationFinish()
	if MODULE_GAMESERVER then
		return;
	end

	for _, tbIns in pairs(self.tbFubenInstance) do
		if tbIns.nSceneAnimationLockId and tbIns.nSceneAnimationLockId > 0 then
			local nLockId = tbIns.nSceneAnimationLockId;
			tbIns.nSceneAnimationLockId = 0;
			tbIns.tbLock[nLockId]:UnLockMulti();
		end
	end
end

function Fuben:ClearMap(nMapId)
	print("Fuben:ClearMap >> nMapId = " .. nMapId);
end

function Fuben:GetFubenInstance(pPlayer)
	return self.tbFubenInstance[pPlayer.nMapId];
end

function Fuben:GetFubenInstanceByMapId(nMapId)
	return self.tbFubenInstance[nMapId]
end