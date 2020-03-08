
local function GetBuildingSetting()
	local tbResult = {};
	local tbMaxLevel = {};
	local szBuildingPath = "Setting/Kin/KinBuilding.tab";
	local tbSetting = LoadTabFile(szBuildingPath, "dddds", nil,
		{"BuildingId", "Level", "MainBuildingLimit", "LevelUpCost", "Desc"});

	for _, tbLineData in ipairs(tbSetting) do
		local nBuildingId = tbLineData.BuildingId;
		local nBuildingLevel = tbLineData.Level;
		tbResult[nBuildingId] = tbResult[nBuildingId] or {};
		tbResult[nBuildingId][nBuildingLevel] = {
			nMainBuildingRequire = tbLineData.MainBuildingLimit,
			nLevelUpCost = tbLineData.LevelUpCost,
			szDesc = tbLineData.Desc,
		};

		tbMaxLevel[nBuildingId] = tbMaxLevel[nBuildingId] or 1;
		if tbLineData.Level > tbMaxLevel[nBuildingId] then
			tbMaxLevel[nBuildingId] = tbLineData.Level;
		end
	end

	return tbResult, tbMaxLevel;
end

local tbBuildingSetting, tbBuildingMaxLevel = GetBuildingSetting();

function Kin:GetBuildingInfo(nBuildingId, nLevel)
	local tbBuildingData = assert(tbBuildingSetting[nBuildingId]);
	return tbBuildingData[nLevel];
end

function Kin:CanLevelUp(nBuildingId, nLevel, nMainBuildingLevel)
	if nBuildingId == Kin.Def.Building_Main then
		return Kin:GetMainBuildingOpenLevel() >= nLevel, 1;
	end

	local tbBuildingInfo = Kin:GetBuildingInfo(nBuildingId, nLevel);
	if not tbBuildingInfo then
		return false, 1
	end
	return nMainBuildingLevel >= tbBuildingInfo.nMainBuildingRequire, tbBuildingInfo.nMainBuildingRequire;
end

function Kin:GetBuildingCurrentMaxLevel(nBuildingId)
	local nMainLevel = self:GetMainBuildingOpenLevel()
	if nBuildingId==Kin.Def.Building_Main then
		return nMainLevel
	end

	for nLevel=1, math.huge do
		if not self:CanLevelUp(nBuildingId, nLevel, nMainLevel) then
			return nLevel-1
		end
	end
	return nMainLevel
end

function Kin:GetBuildingLimitLevel(nBuildingId)
	return Kin.Def.BuildingOpenLimit[nBuildingId];
end

function Kin:CheckKinCamp(nCamp)
	if Kin.Def.bForbidCamp then
		return true;
	end

    if nCamp ~= Npc.CampTypeDef.camp_type_neutrality and
       nCamp ~= Npc.CampTypeDef.camp_type_song and
       nCamp ~= Npc.CampTypeDef.camp_type_jin then
       return false;
    end

    return true;
end

local function GetTimeFrameKeyByLevel(nLevel)
	return Kin.Def.tbBuildingLevel2Key[nLevel];
end

local nCurDay = nil;
local nMaxMainBuildingLevel = 2;

function Kin:GetMainBuildingOpenLevel()
	local nToday = Lib:GetLocalDay(GetTime() - Kin.Def.nBuildingLevelUpdateTime);
	if nToday ~= nCurDay then
		nCurDay = nToday;
		for nLevel = 3, Kin.Def.nMaxBuildingLevel do
			if GetTimeFrameState(GetTimeFrameKeyByLevel(nLevel)) ~= 1 then
				break;
			end
			nMaxMainBuildingLevel = nLevel;
		end
	end

	local szNextLevelTimeFrame = GetTimeFrameKeyByLevel(nMaxMainBuildingLevel + 1);
	return nMaxMainBuildingLevel, szNextLevelTimeFrame;
end

function Kin:GetBuildingMaxLevel(nBuildingId)
	return tbBuildingMaxLevel[nBuildingId] or 1;
end

function Kin:GetBuildingUpgradeCost(nBuildingId, nNextLevel)
	if nNextLevel > Kin:GetBuildingMaxLevel(nBuildingId) then
		return 0, 0;
	end

	local tbBuildingInfo = Kin:GetBuildingInfo(nBuildingId, nNextLevel) or {};
	local nCost = tbBuildingInfo.nLevelUpCost;
	assert(nCost, string.format("KinBuilding.tab填表出错%d, %d", nBuildingId, nNextLevel));

	local nMaxLevel = self:GetBuildingCurrentMaxLevel(nBuildingId)
	local nLevel = nNextLevel-1
	local nDiscountRate = Kin.Def.BuildingDiscountRate[nMaxLevel - nLevel] or 1;
	nCost = math.floor(nCost * nDiscountRate);
	return nCost, nDiscountRate;
end

local szKinCountSettingPath = "Setting/Kin/LevelSetting.tab";
local tbLevelSetting = tbLevelSetting or
	LoadTabFile(szKinCountSettingPath, "dddddddddddn", "Level",
		{"Level", "MaxMember", "MaxMemberAbroad", "MaxNewer", "MaxRetire",
		"MaxMaster", "MaxViceMaster", "MaxCommander", "MaxElder",
		"MaxElite", "MaxMascot", "MaxFound"});

local CareerSettingNameMap = {
	[Kin.Def.Career_Master]     = "MaxMaster",
	[Kin.Def.Career_ViceMaster] = "MaxViceMaster",
	[Kin.Def.Career_Commander]  = "MaxCommander",
	[Kin.Def.Career_Elder]      = "MaxElder",
	[Kin.Def.Career_Elite]      = "MaxElite",
	[Kin.Def.Career_Mascot]     = "MaxMascot",
	[Kin.Def.Career_New]        = "MaxNewer",
	[Kin.Def.Career_Retire]     = "MaxRetire",
	["MaxMember"]               = "MaxMember",
	["MaxMemberAbroad"]			= "MaxMemberAbroad",
}

function Kin:GetMaxMember(nLevel, itemKey)
	if itemKey == Kin.Def.Career_Leader then
		return 1
	end
	if itemKey == Kin.Def.Career_Normal then
		local szKey = "MaxMemberAbroad"
		if version_tx or version_hk or version_vn or version_xm then
			szKey = "MaxMember"
		end
		return self:GetMaxMember(nLevel, szKey)
	end
	local szItemName = assert(CareerSettingNameMap[itemKey]);
	return tbLevelSetting[nLevel][szItemName];
end

function Kin:GetDonationsFound(nVip, nTimeBegin, nTimeEnd)
	if nTimeBegin>nTimeEnd then
		Log("[x] Kin:GetDonationsFound", nVip, tostring(nTimeBegin), tostring(nTimeEnd))
		return
	end

	local tbBegin = self:GetDonateSetting(nVip, nTimeBegin)
	local tbEnd = self:GetDonateSetting(nVip, nTimeEnd)
	return tbEnd.nTotalFound-tbBegin.nTotalFound+tbBegin.nFound
end

function Kin:GetDonationsCost(nVip, nTimeBegin, nTimeEnd)
	if nTimeBegin>nTimeEnd then
		Log("[x] Kin:GetDonationsCost", nVip, tostring(nTimeBegin), tostring(nTimeEnd))
		return
	end

	local tbBegin = self:GetDonateSetting(nVip, nTimeBegin)
	local tbEnd = self:GetDonateSetting(nVip, nTimeEnd)
	return tbEnd.nTotalPrice-tbBegin.nTotalPrice+tbBegin.nPrice
end

function Kin:GetMaxFound(nLevel)
	assert(tbLevelSetting[nLevel])
	return tbLevelSetting[nLevel].MaxFound;
end

function Kin:LoadRedBagSetting()
	self.tbRedBagTypes = LoadTabFile("Setting/Kin/KinRedBagType.tab", "dsssd", "nId",
		{"nId", "szRecordFormat", "szRelation", "szRepeat", "nGlobal"})

	local tbOrgSetting = LoadTabFile("Setting/Kin/KinRedBag.tab", "ddddsddd", "nEventId",
		{"nEventId", "nTypeId", "nTarget", "nBaseGold", "szAddGoldList", "nCount", "nAverageMin", "nKind"})

	local tbSettings = {}
	for nEventId,tb in pairs(tbOrgSetting) do
		local tbList = Lib:SplitStr(tb.szAddGoldList, "_")
		local tbAddGoldList = {}
		for _,szGold in ipairs(tbList) do
			table.insert(tbAddGoldList, tonumber(szGold))
		end
		table.sort(tbAddGoldList, function(a, b) return a<b end)

		tbSettings[nEventId] = {
			nEventId = tb.nEventId,
			nTypeId = tb.nTypeId,
			nTarget = tb.nTarget,
			nBaseGold = tb.nBaseGold,
			nCount = tb.nCount,
			nAverageMin = tb.nAverageMin,
			tbAddGoldList = tbAddGoldList,
			nKind = tb.nKind,	-- 参见Kin.Def.tbRedBagKind
		}

		-- 海外版本强制转为普通红包
		if not version_tx then
			tbSettings[nEventId].nKind = Kin.Def.tbRedBagKind.NORMAL
		end
	end
	self.tbRedBagSettings = tbSettings

	local tbRedBagIdGrps = {}
	for nEventId,tb in pairs(tbSettings) do
		tbRedBagIdGrps[tb.nTypeId] = tbRedBagIdGrps[tb.nTypeId] or {}
		tbRedBagIdGrps[tb.nTypeId][nEventId] = true
	end
	self.tbRedBagIdGrps = tbRedBagIdGrps
end
Kin:LoadRedBagSetting()

function Kin:GetRedBagSetting(nEventId)
	return self.tbRedBagSettings[nEventId]
end

function Kin:LoadActivitySetting()
	local tbSetting = LoadTabFile("Setting/Kin/KinActivity.tab", "sddd", nil,
		{"szJudgement", "nWeekAvg", "nHasSalary", "nDismiss"})
	table.sort(tbSetting, function(tbA, tbB)
		return tbA.nWeekAvg<tbB.nWeekAvg
	end)
	for nIdx,tb in ipairs(tbSetting) do
		if tb.nHasSalary>0 then
			tbSetting.nMinSalaryIdx = nIdx
			break
		end
	end
	self.tbActivitySettings = tbSetting
end
Kin:LoadActivitySetting()

function Kin:LoadDonateSetting()
	local tbSetting = LoadTabFile("Setting/Kin/KinDonate.tab", "ddddddddd", nil,
		{"nMax", "nVip0", "nVip1", "nVip3", "nVip6", "nVip9", "nVip12", "nVip16", "nFound"})
	table.sort(tbSetting, function(tbA, tbB)
		return tbA.nMax<tbB.nMax
	end)

	self.tbDonateSetting = tbSetting
	for _, tb in ipairs(self.tbDonateSetting) do
		local nLastVip = 0
		for nVip=0, Recharge.nMaxVip do
			if not tb["nVip"..nVip] then
				tb["nVip"..nVip] = tb["nVip"..nLastVip]
			else
				nLastVip = nVip
			end
		end
	end
end
Kin:LoadDonateSetting()

function Kin:GetDonateSetting(nVip, nCount)
	local nTotalPrice, nTotalFound = 0, 0
	local nLastMax = 0
	local tbCurSetting = nil
	for _, tb in ipairs(self.tbDonateSetting) do
		local nPrice = tb["nVip"..nVip]
		if nPrice<=0 then
			nPrice = 30
		end

		if tb.nMax>=nCount then
			nTotalFound = nTotalFound+tb.nFound*(nCount-nLastMax)
			nTotalPrice = nTotalPrice+nPrice*(nCount-nLastMax)
			tbCurSetting = tb
			break
		end
		nTotalFound = nTotalFound+tb.nFound*(tb.nMax-nLastMax)
		nTotalPrice = nTotalPrice+nPrice*(tb.nMax-nLastMax)
		nLastMax = tb.nMax
	end

	if not tbCurSetting then
		tbCurSetting = self.tbDonateSetting[#self.tbDonateSetting]
	end

	return {
		nMax = tbCurSetting.nMax,
		nPrice = tbCurSetting["nVip"..nVip]>0 and tbCurSetting["nVip"..nVip] or 30,
		nTotalPrice = nTotalPrice,
		nTotalFound = nTotalFound,
		nFound = tbCurSetting.nFound,
	}
end

function Kin:GetDonateVipSetting(nVip)
	local tbRet = {}
	local szKey = "nVip"..nVip
	for i, tb in ipairs(self.tbDonateSetting) do
		if tb[szKey] <= 0 then
			break
		end
		table.insert(tbRet, {tb.nMax, tb[szKey]})
	end

	local nGold = 0
	for i=#tbRet, 1, -1 do
		if nGold == tbRet[i][2] then
			table.remove(tbRet, i)
		else
			nGold = tbRet[i][2]
		end
	end

	return tbRet
end

function Kin:GetCareerNewLevels()
	local szTimeFrame = Lib:GetMaxTimeFrame(Kin.tbCareerNewTimeFrames)
	local tbSetting = Kin.tbCareerNewTimeFrames[szTimeFrame]
	if not tbSetting then
		return 0, 0
	end
	return unpack(tbSetting)
end

function Kin:RedBagIsModifyValid(nEventId, nAddGold, nCount, nVip)
	if not nEventId or nEventId<=0 then
		if nAddGold>0 then
			return false, "此红包不可增加元宝"
		else
			return true
		end
	end

	local tbSetting = self.tbRedBagSettings[nEventId]

	if nCount<tbSetting.nCount then
		return false, "红包个数不能再少了"
	end

	local bGlobal = self:RedBagIsEventGlobal(nEventId)
	if not bGlobal and nCount>100 then
		return false, "红包个数不能再多了"
	end

	if nAddGold>0 then
		local bValidAddGold = false
		for _,nGold in ipairs(tbSetting.tbAddGoldList) do
			if nGold==nAddGold then
				bValidAddGold = true
				break
			end
		end
		if not bValidAddGold then
			return false, "不支持增加这么多金额"
		end

		if not self:RedBagIsMultiValid(nVip, tbSetting.nBaseGold, nAddGold) then
			return false, "剑侠V等级不足"
		end
	end

	local nTotalGold = tbSetting.nBaseGold+nAddGold
	local fAverageGold = nTotalGold/nCount
	if fAverageGold<tbSetting.nAverageMin then
		return false, "红包个数不能再多了"
	end

	return true
end

function Kin:RedBagOnAddTitle(pPlayer, nTitleID)
	local nRedBagEvent = Kin.Def.tbTitle2RedBagEvent[nTitleID]
	if not nRedBagEvent then
		return
	end

    Kin:RedBagOnEvent(pPlayer, nRedBagEvent)
end

function Kin:RedBagOnEvent(playerIdOrObj, nEventType, nCount)
	if MODULE_ZONESERVER then return end
	if Server and Server:IsCloseIOSEntry() then
		Log("[!] Kin:RedBagOnEvent ios entry closed", tostring(playerIdOrObj), nEventType, tostring(nCount))
		return
	end

	local pPlayer = playerIdOrObj
	if type(playerIdOrObj)=="number" then
		pPlayer = KPlayer.GetPlayerObjById(playerIdOrObj)
		if not pPlayer then
			local szCmd = string.format("Kin:RedBagOnEvent(%d, %d, %d)", playerIdOrObj, nEventType, nCount or 0)
			KPlayer.AddDelayCmd(playerIdOrObj, szCmd, "RedBagOnEvent")
			return
		end
	end
	if not pPlayer then
		Log("[x] Kin:RedBagOnEvent pPlayer nil", tostring(playerIdOrObj), tostring(nEventType), tostring(nCount))
		return
	end
	self:_RedBagOnEvent(pPlayer, nEventType, nCount)
end

function Kin:_RedBagOnEvent(pPlayer, nEventType, nCount)
	if not MODULE_GAMESERVER then
		return
	end

	if nEventType==Kin.tbRedBagEvents.first_master or
			nEventType==Kin.tbRedBagEvents.top10_master or
			nEventType==Kin.tbRedBagEvents.good_master then
		local nKinId = pPlayer.dwKinId
		local tbKin = Kin:GetKinById(nKinId)
		if not tbKin then
			return
		end
		local nLeaderId = tbKin:GetLeaderId()
		if nLeaderId>0 then
			return
		end
	end

	local tbTypeCfg = self.tbRedBagTypes[nEventType]
	local tbIdGrp = self.tbRedBagIdGrps[nEventType] or {}
	for nEventId in pairs(tbIdGrp) do
		while true do
			local szRepeat = tbTypeCfg.szRepeat
			if szRepeat=="" then
				if self:IsRedBagSent(pPlayer, nEventId) then
					break
				end
			elseif szRepeat=="weekly" then
				local nLastSend = self:_GetRedBagSendTime(pPlayer, nEventId)
				local nLastSendWeek = Lib:GetLocalWeek(nLastSend)
				local nCurWeek = Lib:GetLocalWeek(GetTime())
				if nLastSendWeek==nCurWeek then
					break
				end
			elseif szRepeat=="nolimit" then
				--no limit
			else
				Log("[x] Kin:RedBagOnEvent, unknown szRepeat", szRepeat, nEventType, nCount, nEventId)
				break
			end

			local tbSetting = self.tbRedBagSettings[nEventId]
			local nTarget = tbSetting.nTarget
			if tbTypeCfg.szRelation=="=" then
				if nCount~=nTarget then
					break
				end
			elseif tbTypeCfg.szRelation==">=" then
				if nCount<nTarget then
					break
				end
			elseif tbTypeCfg.szRelation=="<=" then
				if nCount>nTarget then
					break
				end
			end
			self:_RedBagGain(pPlayer.dwID, nEventId, nCount)

			break
		end
	end
end

function Kin:RedBagGetContent(tbRedBag)
	if tbRedBag.szContent then
		return tbRedBag.szContent
	end

	local szRet = ""
	local tbSetting = self.tbRedBagSettings[tbRedBag.nEventId]
	if not tbSetting then
		Log("[x] Kin:RedBagGetContent failed", tbRedBag.nEventId)
		return szRet
	end
	local nTypeId = tbSetting.nTypeId
	local tbTypeSetting = self.tbRedBagTypes[nTypeId]
	local szFormatStr = tbTypeSetting.szRecordFormat

	if nTypeId==Kin.tbRedBagEvents.newbie_king or nTypeId==Kin.tbRedBagEvents.big_brother then
		local nFaction = tbRedBag.tbOwner.nFaction
		if not nFaction and MODULE_GAMESERVER then
			local tbStayInfo = KPlayer.GetRoleStayInfo(tbRedBag.tbOwner.nId)
			nFaction = tbStayInfo.nFaction
		end
		local szFactionName = nFaction and Faction:GetName(nFaction) or ""
		szRet = string.format(szFormatStr, szFactionName)
	elseif nTypeId==Kin.tbRedBagEvents.vip_level or
		nTypeId==Kin.tbRedBagEvents.all_strength or nTypeId==Kin.tbRedBagEvents.all_insert then
		szRet = string.format(szFormatStr, tbSetting.nTarget)
	elseif nTypeId==Kin.tbRedBagEvents.title then
		local szTitle = Player.tbHonorLevel:GetHonorName(tbSetting.nTarget)
		szRet = string.format(szFormatStr, szTitle)
	elseif nTypeId==Kin.tbRedBagEvents.wsd_rank then
		local szRank = string.format("前%d名", tbSetting.nTarget)
		if tbSetting.nTarget==1 then
			szRank = "第一名"
		end
		szRet = string.format(szFormatStr, szRank)
	elseif nTypeId==Kin.tbRedBagEvents.white_tiger_boss or nTypeId==Kin.tbRedBagEvents.tower_floor then
		szRet = string.format(szFormatStr, Lib:Transfer4LenDigit2CnNum(tbSetting.nTarget))
	else
		szRet = szFormatStr
	end
	return szRet
end


local tbMultiInfos = {
	[2] = {
		icon = "Multiple2",
		desc = "双倍金额",
	},
	[3] = {
		icon = "Multiple3",
		desc = "三倍金额",
	},
	[6] = {
		icon = "Multiple6",
		desc = "六倍金额",
	},
}
function Kin:RedBagGetMultiInfo(nEventId, nGold)
	if not nEventId or nEventId<=0 then
		return nil
	end

	local tbSetting = self.tbRedBagSettings[nEventId]
	local nBase = tbSetting.nBaseGold
	for nMulti,tbInfo in pairs(tbMultiInfos) do
		if nMulti*nBase == nGold then
			return tbInfo.icon, tbInfo.desc, nMulti
		end
	end
	return nil
end

function Kin:RedBagGetBaseGold(nTypeId)
	if not nTypeId or nTypeId<=0 then
		return nil
	end
	local tbIdGrp = self.tbRedBagIdGrps[nTypeId] or {}
	local nEventId = next(tbIdGrp)
	if not nEventId then
		Log("[x] Kin:RedBagGetBaseGold invalid nEventId", tostring(nTypeId))
		return nil
	end
	local tbSetting = self.tbRedBagSettings[nEventId]
	return tbSetting.nBaseGold
end

function Kin:RedBagIsPlayerGrabEnough(pPlayer)
	if not pPlayer then
		return true
	end

	local nCurCount = pPlayer.GetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerGrabCount)
	local nLastTime = pPlayer.GetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerLastGrabTime)
	local nNow = GetTime()
	local nLastDay = Lib:GetLocalDay(nLastTime)
	local nToday = Lib:GetLocalDay(nNow)
	if nToday>nLastDay then
		return false
	end

	return nCurCount>=Kin.Def.nRedBagMaxGrabPerDay
end

function Kin:RedBagIsMultiValid(nVip, nBaseGold, nAddGold)
	local nMaxMulti = 1
	for i=#self.Def.tbVipRedBagMaxMulti, 1, -1 do
		local nMinVip, nMax = unpack(self.Def.tbVipRedBagMaxMulti[i])
		if nVip>=nMinVip then
			nMaxMulti = nMax
			break
		end
	end
	local nCurMulti = (nAddGold+nBaseGold)/nBaseGold
	return nCurMulti<=nMaxMulti
end

function Kin:IsCareerTitleForbidden(nCareer, szTitle)
	if Kin.Def.tbForbiddenTitleNames[szTitle] then
		return true
	end

	for nc, szName in pairs(Kin.Def.Career_Name) do
		if szTitle==szName and nCareer~=nc then
			return true
		end
	end
	return false
end

function Kin:IsGatherExtraReward()
	-- if Sdk:IsEfunHKTW() then
	-- 	return Sdk.Def.bIsEfunTWHKWeekendActOpen;
	-- end

	local nWeekDay = Lib:GetLocalWeekDay();
	return nWeekDay == 6 or nWeekDay == 7;
end

function Kin:GatherGetExtraRewardRate()
	local nExtraRate = 0;
	if Kin:IsGatherExtraReward() then
		return Kin.GatherDef.WeekendExtraAnswerRate, Kin.GatherDef.WeekendDicePriceExtraPercent;
	end
	return 0, 0;
end

function Kin:GetChangeNamePrice(pPlayer)
	local nChangeItem = pPlayer.GetItemCountInAllPos(Kin.Def.nChangeNameItem)
    if nChangeItem > 0 then
        return 0, true
    end
    return Kin.Def.nChangeNameCost, false
end

function Kin:GetVipDonateContributeInc(nVipLevel)
	local tbConfig = Recharge.tbVipExtSetting.KinDonateContributeInc
	local fRet = 0
	for _, tb in ipairs(tbConfig) do
		local nVip, fInc = unpack(tb)
		if nVipLevel>=nVip then
			fRet = fInc
		else
			break
		end
	end
	return fRet
end

function Kin:IsNameValid(szName)
	if not szName or szName=="" then
		return false, "请输入名字"
	end

	--if Lib:HasNonChineseChars(szName) then
	--	return false, "家族名只能使用中文字符，请修改后重试"
	--end

	if string.find(szName, "%s") then
		return false, "家族名当中不可含有空格"
	end

	local bInvalidWords = false
	if MODULE_GAMESERVER then
		bInvalidWords = not CheckNameAvailable(szName)
	else
		bInvalidWords = ReplaceLimitWords(szName)
	end
	if bInvalidWords then
		return false, "家族名含有敏感字符，请修改后重试"
	end

	if version_tx or version_th or version_kor then
		local nNameLen = Lib:Utf8Len(szName)
		if nNameLen > Kin.Def.nMaxKinNameLength or nNameLen < Kin.Def.nMinKinNameLength then
			return false, string.format("家族名字需在%d~%d字之间", Kin.Def.nMinKinNameLength, Kin.Def.nMaxKinNameLength)
		end
	else
		local nNameLen = string.len(szName)
		if nNameLen > Kin.Def.nMaxKinNameLength then
			return false, "家族名字过长，请重新输入";
		elseif nNameLen < Kin.Def.nMinKinNameLength then
			return false, "家族名字过短，请重新输入";
		end
	end
	return true
end

function Kin:CareerCmp(nCareer1, nCareer2)
	local nOrder1 = self.Def.tbCareersOrder[nCareer1] or math.huge
	local nOrder2 = self.Def.tbCareersOrder[nCareer2] or math.huge
	return nOrder2 - nOrder1
end

function Kin:ComputeChangeLeaderDeadline(nChangeLeaderTime)
	local nDeadline = nChangeLeaderTime+Kin.Def.nChangeLeaderTime
	local tbDeadline = os.date("*t", nDeadline)
	tbDeadline.hour = 23
	tbDeadline.min = 59
	tbDeadline.sec = 59
	return os.time(tbDeadline)
end

Kin.Def.tbJoinCDSaveSettings = {
	nGrp = 32,
	nCDKey = 3,
	nProtectKey = 4,
}

function Kin:GetJoinCD(pPlayer)
	local nDeadline = pPlayer.GetUserValue(self.Def.tbJoinCDSaveSettings.nGrp, self.Def.tbJoinCDSaveSettings.nCDKey)
	return nDeadline-GetTime()
end

function Kin:RedBagIsEventGlobal(nEventId)
	local nEventType = self.tbRedBagSettings[nEventId].nTypeId
	return self.tbRedBagTypes[nEventType].nGlobal==1
end

function Kin:RedBagIsIdGlobal(szId)
	return string.find(szId, "g_")~=nil
end

function Kin:RedBagCheckKind(nKind, szVoicePwd)
	if nKind ~= self.Def.tbRedBagKind.NORMAL and nKind ~= self.Def.tbRedBagKind.VOICE
			and nKind ~= self.Def.tbRedBagKind.FIXED_VOICE then
		return false, "类型错误"
	end
	if nKind == self.Def.tbRedBagKind.VOICE or nKind == self.Def.tbRedBagKind.FIXED_VOICE then
		local nMin, nMax = unpack(self.Def.tbVoicePwdLen)
		local nLen = Lib:Utf8Len(szVoicePwd or "")
		if nLen < nMin or nLen > nMax then
			return false, string.format("红包口令字数限制为%d~%d", nMin, nMax)
		end
		if szVoicePwd and ReplaceLimitWords(szVoicePwd) then
			return false, "口令中含有敏感字符，请修改后重试"
		end
		if szVoicePwd and Lib:HasNonChineseChars(szVoicePwd) then
			return false, "口令只能使用中文字符"
		end
		if not CheckNameAvailable(szVoicePwd) then
			return false, "口令中含有特殊字符"
		end
	end
	return true
end

function Kin:GetGiftInc(nVip)
	local tbSetting = Recharge.tbVipExtSetting.KinGiftBoxInc
	for i=#tbSetting, 1, -1 do
		local nMinVip, nInc = unpack(tbSetting[i])
		if nVip>=nMinVip then
			return nInc
		end
	end
	return 0
end

function Kin:GetGiftMaxCount(nVip)
	local nInc = self:GetGiftInc(nVip)
	return self.Def.nMaxGiftBoxPerDay+nInc
end

-- 是否可以在副本中踢人等操作
function Kin:CanControlFuben(nPlayerId)
	local nCareer = 0
	if MODULE_GAMESERVER then
    	nCareer = Kin:GetPlayerCareer(nPlayerId)
	elseif MODULE_GAMECLIENT then
		local tbData = Kin:GetMyMemberData() or {nCareer = 0}
		nCareer = tbData.nCareer
	end
	if self.Def.tbFubenControl[nCareer] then
		return true
	end

	if self.Def.tbFubenControl[Kin.Def.Career_Leader] then
		if MODULE_GAMESERVER then
			local tbKin = Kin:GetKinByMemberId(nPlayerId)
			if not tbKin then
				return false
			end
			return tbKin:GetLeaderId() == nPlayerId
		elseif MODULE_GAMECLIENT then
			return Kin:GetLeaderId() == nPlayerId
		end
	end

	return false
end