Require("CommonScript/Player/Player.lua");
Require("CommonScript/Furniture/FurnitureCommon.lua");

House.szOpenTimeFrame = "OpenDay15";
House.nMinOpenLevel = 50;

House.nAccessType_Friend = 1;
House.nAccessType_Kin = 2;
House.nAccessType_Stranger = 3;

House.nAccessType_Decoration = 4;

House.nCheckInIntimacyLevel = 20;		-- 入住亲密度等级限制
House.nOpenPhotoStateMinLevel = 6;  -- 开启拍照模式最低等级

-- 入住信息
House.USERGROUP_LANDLORD = 130;
House.USERKEY_LANDLORD = 1;			-- 房东id
House.USERKEY_TIME_CHECKIN = 2;		-- 入住时间

House.ROOMER_COMFORT_REDUCE = 5;	-- 房客特权等级差
House.BASE_ENERGY_GAIN = 2000;		-- 基础元气产出

House.MUSE_SKILL = 1083;					-- 冥想技能
House.MUSE_EFFECT = 1086;					-- 冥想特效
House.MUSE_TIME = 1;						-- 冥想时间
House.MUSE_POS = { 1520, 6495 };			-- 冥想位置

-- 家具打造开放时间轴
House.tbFurnitureMakeTimeFrame = {
	[1] = "OpenDay15",
	[2] = "OpenDay15",
	[3] = "OpenDay99",
	[4] = "OpenDay224",
	[5] = "OpenDay399",
	[6] = "OpenLevel159",
};

-- 升级家园时，自动收起范围内的家具
House.tbPackupRange = {
	[1] = {},
	[2] = {
		{{1414,7268}, {2767,7345}},
	},
	[3] = {
		{{2898,5945}, {2985,7095}},
	},
	[4] = {},
	[5] = {
		{{3509,7184}, {4724,7267}},
	},
	[6] = {
		--室外回收
		{{6593,15185}, {8113,15978}},
		{{3341,20626}, {4431,19794}},
		{{4915,20177}, {5225,19249}},
		{{6522,18716}, {5869,19309}},
		{{6318,16841}, {5752,17426}},
		{{6514,16306}, {5757,16586}},
		{{6513,16306}, {6792,15691}},
		{{3234,18437}, {3492,19088}},
		{{3769,19360}, {3488,19070}},
		{{3229,20926}, {3545,21350}},
		{{4381,21912}, {4552,21651}},
		{{8104,16729}, {8355,16945}},
		{{8783,17291}, {8353,16902}},
		{{9448,15157}, {9785,15527}},
		{{4862,14353}, {6210,13986}},
		{{4161,21821}, {4493,21576}},
		{{5894,18466}, {6105,18204}},

		--室内回收
		{{3877,8659}, {5563,8778}},
	},
}

-- 放置家具的有效区域
House.tbValidFurnitureBox = {
	{{931,22413}, {10755,22413}, {931,13467}, {10755,13467}},	--lt, rt, lb, rb
	{{931,9829}, {7142,9829}, {931,3593}, {7142,3593}},
}
-- 主座配置
House.tbMainSeatInfo = {
--地图id	虚拟凳子id		坐标
	[4003] = {30000, 		{4602, 6505}},  --4级家园
	[4004] = {30000, 		{4603, 6507}},  --5级家园
	[4005] = {30000, 		{4591, 6510}},  --6级家园
	[4008] = {30000, 		{4591, 6510}},  --6级家园
}

House.tbNormalCameraSetting = {23, 35};  --默认视角
House.tbDecorationModelCameraSetting = {30, 35};  --装修视角
House.tbPlayCameraSetting1 = {12, 25};  --拍照视角1
House.tbPlayCameraSetting2 = {8.5, 10};  --拍照视角2

House.nMakeFurnitureCostCount = 5;

House.nFirstHouseTaskId = 3100;				-- 家园第一个引导任务
House.nSecondHouseTaskId = 3101;			-- 家园第二个引导任务
House.nFinishHouseTaskId = 3105;			-- 家园最后一个导引任务，完成此任务后会获得家园级

House.tbAllHouseTask = {3100, 3101, 3102, 3103, 3104, 3105};  --家园所有任务ID

House.nItemValueToComfortValue = 0.0001;		-- 价值量兑换舒适度比例
House.fFurnitureSellRatio = 0.5;		--家具出售折扣

House.ROOMER_REFRESH_TIME = 4 * 3600;	-- 房客特权生效时间

House.nTrapCount = 4;

House.tbSampleHouseSetting =
{
	[4006] = { nTargetHouse = 4004 },
}

House.NOTIFY_LEVEL = 4;	-- 达到x家园等级给予公告

-- 冥想加成npc
House.tbMuseExtAwardNpc =
{
	[2399] = 0.5,
	[2400] = 0.5,
};

House.szMuseTimeframe = "OpenLevel69";	--冥想开启时间轴
House.nMuseMinLevel = 60;	--冥想最低等级

House.nHorseCollectGrp = 195

House.nParrotFurnitureId = 11192	--鹦鹉家具id
House.tbParrotDefaultTalks = {
	"救命！我变成鸟了！",
	"",	--为空字符串则不会冒泡
	"",
}
House.szParrotEditMoneyType = "SilverBoard"
House.tbParrotEditPrice = {
	tbOwner = {0, 20, 50},	--主人
	tbOther = {50, 50, 50},	--非主人
}
House.tbParrotTalkLength = {2, 12}	--鹦鹉学舌语句长度限制 {最小，最大}
if version_vn then
	House.tbParrotTalkLength = {2, 50}
elseif version_th then
	House.tbParrotTalkLength = {2, 50}
end
House.nParrotTalkDuration = 7 * 24 * 3600  --每次修改持续时间（秒）
House.nParrotTalkInterval = 10	--鹦鹉每x秒说一句话
House.nParrotHiddenNpcTempId = 2427	--隐藏npc，用于实现鹦鹉冒泡说话

function House:IsHorseCollected(pPlayer, nHorseShowId)
	local tbSetting = self:GetHorseCollectSetting(nHorseShowId)
	if not tbSetting then
		Log("[x] House:IsHorseCollected", pPlayer.dwID, nHorseShowId)
		return true
	end

	for i = 1, 255 do
		local nCollect = pPlayer.GetUserValue(self.nHorseCollectGrp, i) or 0
		if nCollect <= 0 then
			return false
		end
		if nCollect == tbSetting.nGiveItemId then
			return true
		end
	end
	return false
end

function House:IsMuseOpened(pPlayer)
	return pPlayer.nLevel >= self.nMuseMinLevel and GetTimeFrameState(self.szMuseTimeframe) == 1
end

function House:LoadSetting()
	local szType = "dsddddddssssds";
	local tbTitle = {"nLevel", "szOpenTimeFrame","nMapTemplateId", "nNeedComfortLevel", "nLevelupTime", "nLevelupCost", "nX", "nY", "szHouseStartPos", "szHouseEndPos", "szOutStartPos", "szOutEndPos", "nRoomerCount", "szDescription"};
	for i = 1, self.nTrapCount do
		szType = szType .. "ss";
		table.insert(tbTitle, "szTrap" .. i);
		table.insert(tbTitle, "szDst" .. i);
	end

	local nMaxFurnitureCount = #Furniture.tbNormalFurniture;
	for i = 1, nMaxFurnitureCount do
		szType = szType .. "d";
		table.insert(tbTitle, "nTypeMaxCount" .. i);
	end

	local tbFile = LoadTabFile("Setting/House/House.tab", szType, "nLevel", tbTitle);
	self.tbMapTemplateIdToSetting = {};
	self.tbHouseSetting = {};
	local function GetNumber(szInfo)
		local x, y = string.match(szInfo, "^(%d+)|(%d+)$");
		x, y = tonumber(x), tonumber(y);
		return x, y;
	end

	House.tbComfortValueLimit = {};
	for _, tbRow in pairs(tbFile) do
		local tbInfo = {};
		tbInfo.nLevel = tbRow.nLevel;
		tbInfo.nMapTemplateId = tbRow.nMapTemplateId;
		tbInfo.nX = tbRow.nX;
		tbInfo.nY = tbRow.nY;
		tbInfo.nLevelupTime = tbRow.nLevelupTime;
		tbInfo.nNeedComfortLevel = tbRow.nNeedComfortLevel;
		tbInfo.szOpenTimeFrame = tbRow.szOpenTimeFrame;
		tbInfo.nRoomerCount = tbRow.nRoomerCount;
		tbInfo.nLevelupCost = tbRow.nLevelupCost;
		tbInfo.szDescription = string.gsub(tbRow.szDescription, "\\n", "\n");

		local x, y = GetNumber(tbRow.szHouseStartPos);
		tbInfo.tbHouseRange = {{x, y}};
		x, y = GetNumber(tbRow.szHouseEndPos);
		table.insert(tbInfo.tbHouseRange, {x, y});

		x, y = GetNumber(tbRow.szOutStartPos);
		tbInfo.tbOutRange = {{x, y}};
		x, y = GetNumber(tbRow.szOutEndPos);
		table.insert(tbInfo.tbOutRange, {x, y});

		tbInfo.tbTrapInfo = {};
		for i = 1, self.nTrapCount do
			local szTrapName = tbRow["szTrap" .. i];
			local szDst = tbRow["szDst" .. i];
			if szTrapName ~= "" then
				x, y = GetNumber(szDst);
				tbInfo.tbTrapInfo[szTrapName] = x and {x, y} or szDst;
			end
		end

		House.tbComfortValueLimit[tbInfo.nLevel] = {};
		for i = 1, nMaxFurnitureCount do
			House.tbComfortValueLimit[tbInfo.nLevel][i] = tbRow["nTypeMaxCount" .. i];
		end

		self.tbHouseSetting[tbRow.nLevel] = tbInfo;
		self.tbMapTemplateIdToSetting[tbRow.nMapTemplateId] = tbInfo;
	end

	tbFile = LoadTabFile("Setting/House/Furniture.tab", "dddddd", "nFurnitureTemplateId",
		{"nFurnitureTemplateId", "nType", "nLevel", "nDecorationId", "nIsHouse", "nTimeLimit"});
	self.tbFurnitureSetting = {};
	for nFurnitureTemplateId, tbRow in pairs(tbFile) do
		local tbInfo = {};
		tbInfo.nFurnitureTemplateId = tbRow.nFurnitureTemplateId;
		tbInfo.nType = tbRow.nType;
		tbInfo.nLevel = tbRow.nLevel;
		tbInfo.nDecorationId = tbRow.nDecorationId;
		tbInfo.nIsHouse = tbRow.nIsHouse;
		tbInfo.nTimeLimit = tbRow.nTimeLimit

		self.tbFurnitureSetting[nFurnitureTemplateId] = tbInfo;
	end

	self.tbFurnitureMakeSetting = {};

	szType = "ddddsssssss";
	tbTitle = {"nFurnitureItemId", "IS_NEW", "nWorldMsg", "nKinMsg", "nScale", "nPX", "nPY", "nPZ", "nRX", "nRY", "nRZ"};
	for i = 1, self.nMakeFurnitureCostCount do
		szType = szType .. "s";
		table.insert(tbTitle, "szCost" .. i);
	end
	tbFile = LoadTabFile("Setting/House/FurnitureMake.tab", szType, "nFurnitureItemId", tbTitle);

	for nFurnitureItemId, tbRow in pairs(tbFile) do
		local tbCost = {};
		for i = 1, self.nMakeFurnitureCostCount do
			local szCost = tbRow["szCost" .. i];
			if szCost ~= "" then
				local tbAward = Lib:SplitStr(szCost, "|");
				for i = 2, #tbAward do
					tbAward[i] = tonumber(tbAward[i]);
					assert(tbAward[i]);
				end

				local nAwardType = Player.AwardType[tbAward[1]];
				assert(nAwardType == Player.award_type_item or nAwardType == Player.award_type_money, "Setting/House/FurnitureMake.tab cost type error !!");
				table.insert(tbCost, tbAward);
			end
		end

		assert(#tbCost > 0);

		tbRow.nScale = tonumber(tbRow.nScale) or 1;
		tbRow.nPX = tonumber(tbRow.nPX) or 0;
		tbRow.nPY = tonumber(tbRow.nPY) or 0;
		tbRow.nPZ = tonumber(tbRow.nPZ) or 0;
		tbRow.nRX = tonumber(tbRow.nRX) or 0;
		tbRow.nRY = tonumber(tbRow.nRY) or 0;
		tbRow.nRZ = tonumber(tbRow.nRZ) or 0;

		self.tbFurnitureMakeSetting[nFurnitureItemId] = {bIsNew = (tbRow.IS_NEW == 1), nScale = tbRow.nScale, nWorldMsg = tbRow.nWorldMsg, nKinMsg = tbRow.nKinMsg, tbPosition = {tbRow.nPX, tbRow.nPY, tbRow.nPZ}, tbRotation = {tbRow.nRX, tbRow.nRY, tbRow.nRZ}, tbCost = tbCost};
	end

	self.tbHouseWaiYiSetting = {};
	szType = "ddsdddd";
	tbTitle = {"nId", "nMapId", "szName", "nPosType", "nWaiYiId", "nIconId", "nQuality"};
	tbFile = LoadTabFile("Setting/House/HouseWaiYiSetting.tab", szType, nil, tbTitle);
	for _, tbRow in pairs(tbFile) do
		self.tbHouseWaiYiSetting[tbRow.nId] = self.tbHouseWaiYiSetting[tbRow.nId] or {};
		self.tbHouseWaiYiSetting[tbRow.nId][tbRow.nMapId] = self.tbHouseWaiYiSetting[tbRow.nId][tbRow.nMapId] or {};

		if tbRow.nPosType > 0 and tbRow.nWaiYiId > 0 then
			self.tbHouseWaiYiSetting[tbRow.nId][tbRow.nMapId][tbRow.nPosType] = self.tbHouseWaiYiSetting[tbRow.nId][tbRow.nMapId][tbRow.nPosType] or {};
			local tbInfo = self.tbHouseWaiYiSetting[tbRow.nId][tbRow.nMapId][tbRow.nPosType];
			tbInfo.szName = tbRow.szName == "" and string.format("%s_%s_%s", tbRow.nId, tbRow.nPosType, tbRow.nWaiYiId) or tbRow.szName;
			tbInfo.nWaiYiId = tbRow.nWaiYiId;
			tbInfo.nIconId = tbRow.nIconId;
			tbInfo.nQuality = tbRow.nQuality;
		end
	end

	self.tbDefaultHouseWaiYiSetting = {};
	tbFile = LoadTabFile("Setting/House/DefaultHouseWaiYiSetting.tab", "dsddd", nil, {"nMapId", "szName", "nPosType", "nShowType", "nIconId"});
	for _, tbRow in pairs(tbFile) do
		self.tbDefaultHouseWaiYiSetting[tbRow.nMapId] = self.tbDefaultHouseWaiYiSetting[tbRow.nMapId] or {};
		self.tbDefaultHouseWaiYiSetting[tbRow.nMapId][tbRow.nPosType] = {
			szName = tbRow.szName;
			nShowType = tbRow.nShowType;
			nIconId = tbRow.nIconId;
		}
	end
end
House:LoadSetting();

function House:GetFurnitureScaleSetting(nFurnitureTemplateId)
	local tbFurniture = self.tbFurnitureSetting[nFurnitureTemplateId];
	if not tbFurniture then
		return nil;
	end

	return Decoration:GetScaleSetting(tbFurniture.nDecorationId);
end

function House:CheckFurnitureScale(nFurnitureTemplateId, nSX, nSY)
	local tbFurniture = self.tbFurnitureSetting[nFurnitureTemplateId];
	if not tbFurniture then
		return nil;
	end

	return Decoration:CheckScale(tbFurniture.nDecorationId, nSX, nSY);
end

function House:FormatScale(nFurnitureTemplateId, nSX, nSY)
	local tbFurniture = self.tbFurnitureSetting[nFurnitureTemplateId];
	if not tbFurniture then
		return nil;
	end

	return Decoration:FormatScale(tbFurniture.nDecorationId, nSX, nSY);
end

function House:CheckOverlapping(tbRange1, tbRange2)
	if self:CheckInRange(tbRange1[1], tbRange2) or
		self:CheckInRange(tbRange1[2], tbRange2) or
		self:CheckInRange({tbRange1[1][1], tbRange1[2][2]}, tbRange2) or
		self:CheckInRange({tbRange1[2][1], tbRange1[1][2]}, tbRange2) then

		return true;
	end

	if self:CheckInRange(tbRange2[1], tbRange1) or
		self:CheckInRange(tbRange2[2], tbRange1) or
		self:CheckInRange({tbRange2[1][1], tbRange2[2][2]}, tbRange1) or
		self:CheckInRange({tbRange2[2][1], tbRange2[1][2]}, tbRange1) then

		return true;
	end

	return false;
end

-- https://blog.csdn.net/san_junipero/article/details/79172260
function House:IsInValidBox(x, y)
	for _, tb in ipairs(self.tbValidFurnitureBox) do
        local A = tb[3]
        local B = tb[1]
        local C = tb[2]
        local D = tb[4]
        local a = (B[1] - A[1])*(y - A[2]) - (B[2] - A[2])*(x - A[1])
        local b = (C[1] - B[1])*(y - B[2]) - (C[2] - B[2])*(x - B[1])
        local c = (D[1] - C[1])*(y - C[2]) - (D[2] - C[2])*(x - C[1])
        local d = (A[1] - D[1])*(y - D[2]) - (A[2] - D[2])*(x - D[1])
        if ((a > 0 and b > 0 and c > 0 and d > 0) or (a < 0 and b < 0 and c < 0 and d < 0)) then
            return true
        end
	end
	return false
end

function House:CheckInRange(tbPos, tbRange)
	local tbX = {math.min(tbRange[1][1], tbRange[2][1]), math.max(tbRange[1][1], tbRange[2][1])};
	local tbY = {math.min(tbRange[1][2], tbRange[2][2]), math.max(tbRange[1][2], tbRange[2][2])};
	return tbPos[1] > tbX[1] and tbPos[1] < tbX[2] and tbPos[2] > tbY[1] and tbPos[2] < tbY[2];
end

function House:CheckOpen(pPlayer)
	if pPlayer.nLevel < self.nMinOpenLevel then
		return false;
	end

	if GetTimeFrameState(self.szOpenTimeFrame) ~= 1 then
		return false;
	end

	return true;
end

function House:IsTimeFrameOpen()
	return GetTimeFrameState(self.szOpenTimeFrame) == 1;
end

function House:GetMaxOpenHouseLevel()
	local szNextOpenTimeFrame;
	local nMaxLevel = 0;
	local nStartCheckLevel = 0;
	if not House.nLastCheckLevel or MODULE_GAMECLIENT then
		nStartCheckLevel = 1;
	else
		nStartCheckLevel = House.nLastCheckLevel;
	end

	for i = nStartCheckLevel, #self.tbHouseSetting do
		local tbInfo = self.tbHouseSetting[i];
		if GetTimeFrameState(tbInfo.szOpenTimeFrame) ~= 1 then
			szNextOpenTimeFrame = tbInfo.szOpenTimeFrame;
			break;
		end
		nMaxLevel = i;
		House.nLastCheckLevel = i;
	end
	return nMaxLevel, szNextOpenTimeFrame;
end

function House:CheckCanEnterMap(pPlayer)
	local nMapTemplateId = pPlayer.nMapTemplateId;
	if nMapTemplateId == Kin.Def.nKinMapTemplateId then
		return true;
	end

	if not Fuben.tbSafeMap[nMapTemplateId] and (not Map:IsHouseMap(nMapTemplateId)) and Map:GetClassDesc(nMapTemplateId) ~= "fight" then
		return false, "所在地图不允许进入";
	end

	return true;
end

function House:GetFurnitureType(nItemTemplateId)
	local tbSetting = self:GetFurnitureInfo(nItemTemplateId)
	if not tbSetting then
		return 0
	end
	return tbSetting.nType
end

function House:GetFurnitureInfo(nItemTemplateId)
	local tbBaseInfo = KItem.GetItemBaseProp(nItemTemplateId);
	if not tbBaseInfo or tbBaseInfo.szClass ~= "FurnitureItem" then
		return;
	end

	local nFurnitureTemplateId = KItem.GetItemExtParam(nItemTemplateId, 1);
	if not self.tbFurnitureSetting[nFurnitureTemplateId].nComfortValue then
		self.tbFurnitureSetting[nFurnitureTemplateId].nComfortValue = math.floor(KItem.GetBaseValue(nItemTemplateId) * self.nItemValueToComfortValue);
	end

	return self.tbFurnitureSetting[nFurnitureTemplateId], nFurnitureTemplateId;
end

function House:CheckCanPutFurnitureCommon(nMapTemplateId, nX, nY, nRotation, nTemplateId)
	local tbHouseSetting = self.tbMapTemplateIdToSetting[nMapTemplateId];
	if not tbHouseSetting then
		return false, "家具只能摆放在家园中";
	end

	if not self:IsInValidBox(nX, nY) then
		Log("[x] House:CheckCanPutFurnitureCommon", nMapTemplateId, nX, nY, nRotation, nTemplateId)
		return false, "此处不能摆放！"
	end

	local tbFurniture = House:GetFurnitureInfo(nTemplateId);
	if not tbFurniture then
		return false, "无效家具！";
	end

	if tbFurniture.nIsHouse == 1 and not House:CheckInRange({nX, nY}, tbHouseSetting.tbHouseRange) then
		return false, "此家具只能摆放在室内！";
	end

	if tbFurniture.nIsHouse == 0 and not House:CheckInRange({nX, nY}, tbHouseSetting.tbOutRange) then
		return false, "此家具只能摆放在庭院!";
	end

	return true;
end

function House:CheckInSameRange(nMapTemplateId, nX, nY, x, y)
	local tbHouseSetting = self.tbMapTemplateIdToSetting[nMapTemplateId];
	if not tbHouseSetting then
		return false;
	end

	if House:CheckInRange({nX, nY}, tbHouseSetting.tbHouseRange) and House:CheckInRange({x, y}, tbHouseSetting.tbHouseRange) then
		return true;
	end

	if House:CheckInRange({nX, nY}, tbHouseSetting.tbOutRange) and House:CheckInRange({x, y}, tbHouseSetting.tbOutRange) then
		return true;
	end

	return false;
end

function House:CheckInHouseRange(nMapTemplateId, nX, nY)
	local tbHouseSetting = self:GetHouseSetting(nMapTemplateId);
	if not tbHouseSetting then
		return false, false;
	end

	if House:CheckInRange({nX, nY}, tbHouseSetting.tbHouseRange) then
		return true, true;
	end

	if House:CheckInRange({nX, nY}, tbHouseSetting.tbOutRange) then
		return true, false;
	end

	return true, false;
end

function House:GetFurnitureMakeOpenTips()
	local tbOpenLevelInfo = {};
	local szNextTimeFrame;
	local bMax = true;
	for nLevel, szTimeFrame in ipairs(self.tbFurnitureMakeTimeFrame) do
		if GetTimeFrameState(szTimeFrame) ~= 1 then
			if szNextTimeFrame ~= szTimeFrame and not bMax then
				break;
			end
			bMax = false;
		end

		if szNextTimeFrame and szNextTimeFrame ~= szTimeFrame then
			tbOpenLevelInfo = {};
		end
		table.insert(tbOpenLevelInfo, nLevel);
		szNextTimeFrame = szTimeFrame;
	end

	local szOpenInfo = string.format("%s级", tbOpenLevelInfo[1]);
	for i = 2, #tbOpenLevelInfo do
		szOpenInfo = string.format("%s、%s级", szOpenInfo, tbOpenLevelInfo[i]);
	end

	if bMax then
		return string.format("当前已开放至 [FFFE0D]%s级[-] 家具制作", tbOpenLevelInfo[#tbOpenLevelInfo]);
	end

	local nRefDay = Lib:GetLocalDay(CalcTimeFrameOpenTime(szNextTimeFrame)) - Lib:GetLocalDay()
	return string.format("[FFFE0D]%s天[-] 后开放 [FFFE0D]%s[-] 家具制作", nRefDay, szOpenInfo);
end

function House:CheckCanMakeFurnitureCommon(pPlayer, nFurnitureItemId)
	local tbFurniture = self:GetFurnitureInfo(nFurnitureItemId);
	if not tbFurniture then
		return false, "不存在的家具";
	end

	local szTimeFrame = self.tbFurnitureMakeTimeFrame[tbFurniture.nLevel] or "unknown";
	if GetTimeFrameState(szTimeFrame) ~= 1 then
		return false, "此家具打造暂未开放";
	end

	local bOk, szErr = self:SpecialCheckCanMake(pPlayer, nFurnitureItemId)
	if not bOk then
		return false, szErr
	end

	return true, "", tbFurniture;
end

function House:GetFurnitureTypeCount(pPlayer, nType)
	if MODULE_GAMESERVER then
		local nBagCount = 0
		local tbFurnitures = Furniture:GetFurnitures(pPlayer)
		for nTemplateId, tbFurniture in pairs(tbFurnitures) do
			if self:GetFurnitureType(nTemplateId) == nType then
				nBagCount = nBagCount+(tbFurniture.nCount or 0)
			end
		end

		local nPutCount = 0
		local tbHouse = self:GetHouse(pPlayer.dwID)
		if tbHouse then
			for _, tb in ipairs(tbHouse.tbFurnitureSet) do
				if self:GetFurnitureType(tb.nTemplateId) == nType then
					nPutCount = nPutCount+1
				end
			end
		end
		return nBagCount+nPutCount
	end

	local nBagCount = 0
	for nTemplateId, nCount in pairs(self.tbFurniture) do
		if self:GetFurnitureType(nTemplateId) == nType then
			nBagCount = nBagCount+nCount
		end
	end

	local nPutCount = 0
	for _, tb in pairs(self.tbMapFurniture) do
		if self:GetFurnitureType(tb.nTemplateId) == nType then
			nPutCount = nPutCount+1
		end
	end
	return nBagCount+nPutCount
end

function House:SpecialCheckCanMake(pPlayer, nFurnitureItemId)
	local tbFurniture = self:GetFurnitureInfo(nFurnitureItemId)
	if not tbFurniture then
		return false
	end

	if tbFurniture.nType == Furniture.TYPE_CANT_MAKE then
		return false
	end

	if tbFurniture.nType==Furniture.TYPE_MAGIC_BOWL then
		local nHouseLevel = 0
		if MODULE_GAMESERVER then
			nHouseLevel = self:GetHouseLevel(pPlayer.dwID) or 0
		elseif MODULE_GAMECLIENT then
			nHouseLevel = self.nHouseLevel or 0
		end
		local nMinLvl = Furniture.MagicBowl.Def.nMakeFurnitureHouseLvl
		if nHouseLevel<nMinLvl then
			return false, string.format("家园达到%d级才能打造聚宝盆", nMinLvl)
		end

		if not Furniture.MagicBowl:IsOpened(pPlayer) then
			return false, "聚宝盆尚未开启"
		end
	end

	local nLimit = Furniture.tbExistCountLimits[tbFurniture.nType] or -1
	if nLimit<=0 then
		return true
	end

	if self:GetFurnitureTypeCount(pPlayer, tbFurniture.nType)>=nLimit then
		return false, "此类家具拥有数量已达上限"
	end

	return true
end

function House:CheckCanMakeFurniture(pPlayer, nFurnitureItemId)
	local bRet, szMsg, tbFurniture = self:CheckCanMakeFurnitureCommon(pPlayer, nFurnitureItemId);
	if not bRet then
		return false, szMsg;
	end

	local nHouseLevel = self.nHouseLevel;
	if MODULE_GAMESERVER then
		local tbHouse = self:GetHouse(pPlayer.dwID);
		if tbHouse then
			nHouseLevel = tbHouse.nLevel;
		end
	end

	if not nHouseLevel then
		return false, "没有家园，无法打造！";
	end

	local tbMakeInfo = self.tbFurnitureMakeSetting[nFurnitureItemId];
	if not tbMakeInfo then
		return false, "此家具无法打造！";
	end

	local tbCost = tbMakeInfo.tbCost;
	for _, tbInfo in pairs(tbCost) do
		local nAwardType = Player.AwardType[tbInfo[1]] or Player.award_type_unkonw;
		if nAwardType ~= Player.award_type_item and nAwardType ~= Player.award_type_money then
			return false, "不支持的材料类型！";
		end

		if nAwardType == Player.award_type_item then
			local nCount = pPlayer.GetItemCountInBags(tbInfo[2]);
			if nCount < tbInfo[3] then
				return false, "材料不足！";
			end
		end

		if nAwardType == Player.award_type_money then
			local nMoney = pPlayer.GetMoney(tbInfo[1]);
			if nMoney < tbInfo[2] then
				return false, "消耗品不足！";
			end
		end
	end

	return true, "", tbFurniture, tbCost, tbMakeInfo;
end

function House:CalcuComfortValue(nHouseLevel, tbFurnitureSet)
	local tbValue = {};
	for _, tbInfo in pairs(tbFurnitureSet) do
		local tbFurniture = self:GetFurnitureInfo(tbInfo.nTemplateId);
		if tbFurniture then
			tbValue[tbFurniture.nType] = tbValue[tbFurniture.nType] or {};
			table.insert(tbValue[tbFurniture.nType], tbFurniture.nComfortValue);
		end
	end

	local nValue = self:GetLevelComfort(nHouseLevel);
	local tbSetting = self.tbComfortValueLimit[nHouseLevel];
	for nType, nLimitCount in pairs(tbSetting or {}) do
		if tbValue[nType] then
			table.sort(tbValue[nType], function (a, b) return a > b; end);
			for i = 1, nLimitCount do
				if not tbValue[nType][i] then
					break;
				end
				nValue = nValue + tbValue[nType][i];
			end
		end
	end
	return nValue;
end

function House:GetLevelCost(nHouseLevel)
	local nCost = 0;
	for nLevel = 1, nHouseLevel - 1 do
		nCost = nCost + self.tbHouseSetting[nLevel].nLevelupCost;
	end
	return nCost;
end

function House:GetLevelComfort(nHouseLevel)
	local nCost = self:GetLevelCost(nHouseLevel);
	return math.floor(nCost * 0.1);
end

function House:CheckCanRide(pPlayer)
	local tbHouseSetting = self:GetHouseSetting(pPlayer.nMapTemplateId);
	if not tbHouseSetting then
		return true;
	end

	local nMapId, nX, nY = pPlayer.GetWorldPos();
	if House:CheckInRange({nX, nY}, tbHouseSetting.tbHouseRange) then
		return false, "马儿在庭院拴着，室内还是步行吧";
	end

	return true;
end

function House:GetHouseMap(dwOwnerId)
	local nHouseMapId = nil;
	if MODULE_GAMESERVER then
		local tbMapInfo = self.tbHouseMapInfo[dwOwnerId];
		if tbMapInfo then
			nHouseMapId = tbMapInfo.nMapId;
		end
	elseif MODULE_GAMECLIENT then
		if self.dwOwnerId and self.dwOwnerId == dwOwnerId then
			nHouseMapId = self.nHouseMapId;
		end
	end
	return nHouseMapId;
end

function House:IsInOwnHouse(pPlayer)
	local nHouseMapId = self:GetHouseMap(pPlayer.dwID);
	return nHouseMapId and nHouseMapId == pPlayer.nMapId or false;
end

function House:IsInLivingRoom(pPlayer)
	local bRet, nLoverId = House:IsInLoverHouse(pPlayer);
	if bRet then
		return true, nLoverId;
	end

	local nLandlordId = pPlayer.GetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_LANDLORD);
	if nLandlordId == 0 then
		return false;
	end

	local nHouseMapId = self:GetHouseMap(nLandlordId);
	if not nHouseMapId then
		return false;
	end

	return nHouseMapId == pPlayer.nMapId, nLandlordId;
end

function House:IsInLoverHouse(pPlayer)
	local nLoverId = Wedding:GetLover(pPlayer.dwID);
	if not nLoverId then
		return false;
	end

	local nHouseMapId = self:GetHouseMap(nLoverId);
	if not nHouseMapId then
		return false;
	end

	return nHouseMapId == pPlayer.nMapId, nLoverId;
end

function House:IsInPlayerHouse(pPlayer, nOwnerId)
	local nHouseMapId = self:GetHouseMap(nOwnerId)
	return nHouseMapId==pPlayer.nMapId
end

function House:HasDecorationAccess(pPlayer)
	if self:IsInOwnHouse(pPlayer) then
		return true;
	end

	local bIsInLivingRoom, nOwnerId = self:IsInLivingRoom(pPlayer);
	if not bIsInLivingRoom then
		return false;
	end

	if Wedding:IsLover(nOwnerId, pPlayer.dwID) then
		return true;
	end

	return self:CheckDecorationAccess(nOwnerId, pPlayer.dwID);
end

function House:CheckDecorationAccess(nOwnerId, dwRoomerId)
	local tbDecorationAccess = {};
	if MODULE_GAMECLIENT then
		tbDecorationAccess = self.tbAccessInfo[self.nAccessType_Decoration] or {};
	elseif MODULE_GAMESERVER then
		local tbHouse = self:GetHouse(nOwnerId);
		if tbHouse and tbHouse.tbAccess then
			tbDecorationAccess = tbHouse.tbAccess[self.nAccessType_Decoration] or {};
		end
	end

	return tbDecorationAccess[dwRoomerId] and true or false;
end

-- 在普通家园内，非样板房
function House:IsInNormalHouse(pPlayer)
	return self.tbMapTemplateIdToSetting[pPlayer.nMapTemplateId] and true or false;
end

function House:LoadComfortSetting()
	self.tbComfortSetting = {};
	local tbFile = LoadTabFile("Setting/House/HouseComfort.tab", "ddddd", "nLevel", { "nLevel", "nComfort", "nChuangGongRatio", "nEnergy", "nAddLevel" });
	for _, tbRow in pairs(tbFile) do
		local tbSetting = {};
		tbSetting.nLevel = tbRow.nLevel;
		tbSetting.nComfort = tbRow.nComfort;
		tbSetting.fChuangGongRatio = tbRow.nChuangGongRatio / 1000;
		tbSetting.nEnergy = tbRow.nEnergy;
		tbSetting.nAddLevel = tbRow.nAddLevel;

		table.insert(self.tbComfortSetting, tbSetting);
		assert(#self.tbComfortSetting == tbSetting.nLevel);
	end
end

function House:LoadMuseSetting()
	self.tbMuseSetting = {};
	local tbFile = LoadTabFile("Setting/House/Muse.tab", "ddsss", nil, { "Ratio", "AwardRatio", "KinNotify", "WorldNotify", "Result" });
	local nTotalRatio = 0;
	for _, tbRow in pairs(tbFile) do
		local tbSetting = {};
		tbSetting.nRatio = tbRow.Ratio;
		tbSetting.fAwardRatio = tbRow.AwardRatio / 1000;
		tbSetting.szKinNotify = tbRow.KinNotify;
		tbSetting.szWorldNotify = tbRow.WorldNotify;
		tbSetting.szResult = tbRow.Result;
		table.insert(self.tbMuseSetting, tbSetting);

		nTotalRatio = nTotalRatio + tbSetting.nRatio;
	end
	assert(nTotalRatio == 1000);
end

function House:LoadHorseCollectSetting()
	self.tbHorseCollectSetting = {}
	local tbFile = LoadTabFile("Setting/House/HorseCollectSetting.tab", "dsdd", nil, {"nHorseShowId", "szMoneyType", "nPrice", "nGiveItemId"})
	for _, tbRow in pairs(tbFile) do
		assert(Shop:IsMoneyType(tbRow.szMoneyType))
		self.tbHorseCollectSetting[tbRow.nHorseShowId] = tbRow
	end
end

House:LoadComfortSetting();
House:LoadMuseSetting();
House:LoadHorseCollectSetting()

function House:GetHorseCollectSetting(nHorseShowId)
	return self.tbHorseCollectSetting[nHorseShowId]
end

function House:CalcuComfortLevel(nComfort)
	local nLevel = 0;
	for _, tbSetting in ipairs(self.tbComfortSetting) do
		if nComfort < tbSetting.nComfort then
			break;
		end
		nLevel = tbSetting.nLevel;
	end
	return nLevel;
end

function House:GetComfortSetting(nLevel)
	return self.tbComfortSetting[nLevel];
end

function House:GetMaxComfortLevel()
	return #self.tbComfortSetting;
end

function House:CalcRoomerComfortLevel(nOwnerComfortLevel, nRoomerComfortLevel)
	local nLevel = math.max(1, nOwnerComfortLevel - self.ROOMER_COMFORT_REDUCE);
	local tbComfort = self:GetComfortSetting(nOwnerComfortLevel);
	return math.max(math.min(nRoomerComfortLevel + tbComfort.nAddLevel, nLevel), nRoomerComfortLevel);
end

function House:GetEnergyRatio(nEnergy)
	return (nEnergy - self.BASE_ENERGY_GAIN) / self.BASE_ENERGY_GAIN * 100;
end

function House:CalcuMuseResult()
	local nTotal = 1000;
	local nRand = MathRandom(1, nTotal);
	local nCur = 0;
	for nIndex, tbSetting in ipairs(self.tbMuseSetting) do
		nCur = nCur + tbSetting.nRatio;
		if nRand <= nCur then
			return tbSetting, nIndex;
		end
	end
	assert(false, "[ERROR][house] failed to calcu muse result: ", nRand);
end

function House:IsIndoor(pPlayer)
	local tbHouseSetting = self:GetHouseSetting(pPlayer.nMapTemplateId);
	if not tbHouseSetting then
		return false;
	end

	local _, nX, nY = pPlayer.GetWorldPos();
	return House:CheckInRange({nX, nY}, tbHouseSetting.tbHouseRange);
end

function House:IsValidRoomer(pPlayer)
	local nCheckInTime = pPlayer.GetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_TIME_CHECKIN);
	if nCheckInTime == 0 then
		return true;
	end

	local nCurDay = Lib:GetLocalDay(GetTime() - House.ROOMER_REFRESH_TIME);
	local nCheckInDay = Lib:GetLocalDay(nCheckInTime - House.ROOMER_REFRESH_TIME);
	return nCurDay > nCheckInDay;
end

function House:GetHouseSetting(nMapTemplateId)
	local tbSampleHouse = House:GetSampleHouseSetting(nMapTemplateId);
	if tbSampleHouse then
		nMapTemplateId = tbSampleHouse.nTargetHouse;
	end
	return self.tbMapTemplateIdToSetting[nMapTemplateId];
end

function House:GetSampleHouseSetting(nMapTemplateId)
	return House.tbSampleHouseSetting[nMapTemplateId];
end

function House:IsSampleHouse(nMapTemplateId)
	return House:GetSampleHouseSetting(nMapTemplateId) and true or false;
end

function House:IsNormalHouse(nMapTemplateId)
	return self.tbMapTemplateIdToSetting[nMapTemplateId] and true or false;
end

function House:GetValidLandlord(pPlayer)
	local nLandlordId = pPlayer.GetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_LANDLORD);
	if nLandlordId == 0 then
		return;
	end

	if not House:IsValidRoomer(pPlayer) then
		return;
	end

	return nLandlordId;
end

function House:IsRoomer(pPlayer, dwOwnerId)
	local nLandlordId = pPlayer.GetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_LANDLORD);
	if nLandlordId == dwOwnerId then
		return true;
	end

	if Wedding:IsLover(dwOwnerId, pPlayer.dwID) then
		return true;
	end

	return false;
end