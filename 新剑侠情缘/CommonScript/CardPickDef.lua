CardPicker.Def = {

nFreeGoldPickCdTime = 48 * 3600; -- 免费元宝抽卡Cd时间
nFreeCoinPickCdTime = 8 * 3600; -- 免费银两抽卡Cd时间
nFreeGoldCdTimeFromCreate = 60 * 60; -- 第一次免费抽卡的Cd时间

OpenLevel = 10;

nGoldPickResetFubenLevel = 1;  -- 普通关卡
nGoldPickResetSectionIdx = 2;  -- 2-4关卡解锁第一次免费元宝招募
nGoldPickResetSubSectionIdx = 4;

nCoinPickResetFubenLevel = 1;  -- 普通关卡
nCoinPickResetSectionIdx = 1;  -- 1-4关卡解锁第一次免费银两招募
nCoinPickResetSubSectionIdx = 4;

nCoinCost = 20000;  --银两单抽价格
nCoinTenCost = 180000;  --银两十连抽价格
nGoldCost = 240;  --元宝单抽价格
nGoldTenCost = 1980;  --元宝十连抽价格

nVipProbDivide = 10; -- 低于此V一概率，反之高V概率

nCurSpecialCountBegin = 20000; -- 抽过特殊卡牌后的重置次数
nGoldTenSpecialCount = 20;

-- 高V每次10连抽概率
tbHighVipSpecialPartnerRate = {
	[1]  = 0.001,
	[2]  = 0.003,
	[3]  = 0.006,
	[4]  = 0.01,
	[5]  = 0.015,
	[6]  = 0.02,
	[7]  = 0.03,
	[8]  = 0.04,
	[9]  = 0.06,
	[10] = 0.09,
	[11] = 0.12,
	[12] = 0.18,
	[13] = 0.24,
	[14] = 0.3,
	[15] = 0.4,
	[16] = 0.5,
	[17] = 0.6,
	[18] = 0.7,
	[19] = 0.85,
	[20] = 1,
};
-- 可抽到门客任选箱开放时间轴
szGoldTenPartnerCardChooseTimeFrame = "OpenLevel109";
-- 每n次重置
nGoldTenPartnerCardChooseCount = 20;
-- n次概率
tbPartnerCardChooseRate = {
	[1]  = 0.001,
	[2]  = 0.003,
	[3]  = 0.006,
	[4]  = 0.01,
	[5]  = 0.015,
	[6]  = 0.02,
	[7]  = 0.03,
	[8]  = 0.04,
	[9]  = 0.06,
	[10] = 0.09,
	[11] = 0.12,
	[12] = 0.18,
	[13] = 0.24,
	[14] = 0.3,
	[15] = 0.4,
	[16] = 0.5,
	[17] = 0.6,
	[18] = 0.7,
	[19] = 0.85,
	[20] = 1,
};
-- 第20次十连抽必出门客任选箱
tbPartnerCardChooseTenGold = {
	szItemType = "item",
	nItemId = 9705,
	nCount = 1,
};

-- 不能被任选箱替换的道具
tbTenGoldPCForbidReplace =
{
	["Partner"] = {11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,149,150,36,37,38,39,40,41,42,145,146,147,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,148};
	["PartnerCard"] = {12,13,14,15,18,19,20,21,22,23};
};
tbTenGoldPCForbidReplaceRef = {};

-- 第20次十连抽必出杨影枫
tbSpecialTenGoldSPartner = {
	szItemType = "Partner",
	nItemId = 13,
	nCount = 1,
};

-- 元宝招募礼品
tbGoldPickGift = {
	szItemType = "item",
	nItemId = 1968,
};

-- 银两招募礼品
tbCoinPickGift = {
	szItemType = "item",
	nItemId = 1016,
};

CARD_SAVE_GROUP            = 87;
SAVE_GOLD_PICK_COUNT_KEY   = 1;
SAVE_COIN_PICK_COUNT_KEY   = 2;
SAVE_GOLD_PICK_CACHE_BEGIN = 3;
SAVE_GOLD_PICK_CACHE_END   = 22;
SAVE_FRIST_THREE_S_BEGIN   = 23;
SAVE_FRIST_THREE_S_END     = 25;
SAVE_TEN_GOLD_COUNT_KEY    = 26;
SAVE_TEN_GOLD_COUNT_PARTNERCARD_CHOOSE_KEY    = 27;


CARD_SAVE_SYNC_GROUP     = 88;
SAVE_NEXT_GOLD_FREE_TIME = 1;
SAVE_NEXT_COIN_FREE_TIME = 3;
SAVE_LEFT_S_TIME         = 2;

CARD_GOLD_TEN_SALE_GROUP = 78;
CARD_GOLD_TEN_SALE_KEY   = 1;

szKinMsg = "恭喜家族成员「%s」通过元宝十连抽获得了%s";
szWorldMsg = "恭喜「%s」通过元宝十连抽获得了%s";

tbTypeKinMsg = {
	["Gold"] = "恭喜家族成员「%s」通过元宝招募获得了%s";
	["TenGold"] = "恭喜家族成员「%s」通过元宝十连抽获得了%s";
	["Coin"] = "恭喜家族成员「%s」通过银两招募获得了%s";
	["TenCoin"] = "恭喜家族成员「%s」通过银两十连抽获得了%s";
};

tbTypeWorldMsg = {
	["Gold"] = "恭喜「%s」通过元宝招募获得了%s";
	["TenGold"] = "恭喜「%s」通过元宝十连抽获得了%s";
	["Coin"] = "恭喜「%s」通过银两招募获得了%s";
	["TenCoin"] = "恭喜「%s」通过银两十连抽获得了%s";
};
};

Require("CommonScript/lib.lua");

-- 元宝十连抽打折活动配置
CardPicker.Def.tbGoldTenOnSaleSetting = {
	-- 活动开启时间, 活动结束时间, 活动标识(不可重复使用!, <17000 或> 30000，该区间用于长期活动), 折扣,
	-- {"2016-06-05 00:00:00", "2016-06-06 23:59:59", 1, 0.6},
	-- {"2016-11-30 04:00:01", "2016-12-01 04:00:00", 3, 0.6},
	-- {"2016-12-03 04:00:00", "2016-12-05 04:00:00", 4, 0.6},
	-- {"2016-12-07 04:00:00", "2016-12-08 04:00:00", 5, 0.6},
	-- {"2016-12-14 04:00:00", "2016-12-15 04:00:00", 6, 0.6},
	-- {"2016-12-21 04:00:00", "2016-12-22 04:00:00", 7, 0.6},
	-- {"2016-12-28 04:00:00", "2016-12-29 04:00:00", 8, 0.6},
	-- {"2017-01-21 00:00:00", "2017-01-21 23:59:59", 9, 0.6, version_vn, "OpenLevel39"},
	-- {"2017-01-04 04:00:00", "2017-01-05 04:00:00", 10, 0.6, version_tx},
	-- {"2017-01-11 04:00:00", "2017-01-12 04:00:00", 11, 0.6, version_tx},
	-- {"2017-01-20 04:00:00", "2017-01-21 04:00:00", 12, 0.6, version_tx},
	-- {"2017-03-08 00:00:00", "2017-03-10 23:59:59", 13, 0.6, version_hk},
	-- {"2017-03-25 00:00:00", "2017-03-26 23:59:59", 14, 0.6, version_xm, "OpenDay15"},
	-- {"2017-06-14 00:00:00", "2017-06-14 23:59:59", 15, 0.6, version_vn, "OpenLevel39"},
	-- {"2017-06-21 00:00:00", "2017-06-21 23:59:59", 16, 0.6, version_vn, "OpenLevel39"},
	-- {"2017-07-25 00:00:00", "2017-07-25 23:59:59", 17, 0.6, version_xm, "OpenLevel39"},
	-- {"2018-01-10 04:00:00", "2018-01-10 23:59:59", 18, 0.6, version_xm, "OpenLevel39"},
	-- {"2018-01-21 04:00:00", "2018-01-21 23:59:59", 19, 0.5, version_th, "OpenLevel39"},
	-- {"2018-01-28 04:00:00", "2018-01-28 23:59:59", 20, 0.5, version_th, "OpenLevel39"},
	-- {"2018-02-04 04:00:00", "2018-02-04 23:59:59", 21, 0.5, version_th, "OpenLevel39"},
	-- {"2018-02-11 04:00:00", "2018-02-11 23:59:59", 22, 0.5, version_th, "OpenLevel39"},
	-- {"2018-04-28 00:00:00", "2018-04-29 23:59:59", 23, 0.6, version_kor, "OpenLevel39"},
	{"2018-06-10 04:00:00", "2018-06-10 23:59:59", 25, 0.5, version_th, "OpenLevel39"},
	{"2018-06-17 04:00:00", "2018-06-17 23:59:59", 26, 0.5, version_th, "OpenLevel39"},
	{"2018-06-24 04:00:00", "2018-06-24 23:59:59", 27, 0.5, version_th, "OpenLevel39"},
	{"2018-07-01 04:00:00", "2018-07-01 23:59:59", 28, 0.5, version_th, "OpenLevel39"},
};

--- 元宝抽卡活动cd时间设置
CardPicker.Def.tbGoldFreeTimeCdTabel = {
	--{"2012-09-28 10:50:51", "2016-09-28 10:50:51", 24 * 3600},
};

--- 银两抽卡活动cd时间设置
CardPicker.Def.tbCoinFreeTimeCdTabel = {
	--{"2012-09-28 10:50:51", "2017-09-28 10:50:51", 24 * 3600},
};


local tbGoldTenTmpTable = {};
for nIdx, tbInfo in ipairs(CardPicker.Def.tbGoldTenOnSaleSetting) do
	if tbInfo[5] then
		tbInfo[1] = Lib:ParseDateTime(tbInfo[1]);
		tbInfo[2] = Lib:ParseDateTime(tbInfo[2]);
		table.insert(tbGoldTenTmpTable, tbInfo);
	end
end
CardPicker.Def.tbGoldTenOnSaleSetting = tbGoldTenTmpTable;

for _, tbInfo in ipairs(CardPicker.Def.tbGoldFreeTimeCdTabel) do
	tbInfo[1] = Lib:ParseDateTime(tbInfo[1]);
	tbInfo[2] = Lib:ParseDateTime(tbInfo[2]);
end

for _, tbInfo in ipairs(CardPicker.Def.tbCoinFreeTimeCdTabel) do
	tbInfo[1] = Lib:ParseDateTime(tbInfo[1]);
	tbInfo[2] = Lib:ParseDateTime(tbInfo[2]);
end

function CardPicker:GetFreeGoldCDTime()
	local nNow = GetTime();
	for _, tbInfo in ipairs(CardPicker.Def.tbGoldFreeTimeCdTabel) do
		if nNow >= tbInfo[1] and nNow <= tbInfo[2] then
			return tbInfo[3];
		end
	end
	return CardPicker.Def.nFreeGoldPickCdTime;
end

function CardPicker:GetFreeCoinCDTime()
	local nNow = GetTime();
	for _, tbInfo in ipairs(CardPicker.Def.tbCoinFreeTimeCdTabel) do
		if nNow >= tbInfo[1] and nNow <= tbInfo[2] then
			return tbInfo[3];
		end
	end
	return CardPicker.Def.nFreeCoinPickCdTime;
end

function CardPicker:CheckPickCutAct()
	Log("CardPicker:CheckPickCutAct")
	if CardPicker:IsPickCutActOpen() then
		local nNow = GetTime();
		local nOpenDayTime = 4 * 3600;
		local nOpenWeekDay = 3;
		local nWeekDay = Lib:GetLocalWeekDay(nNow - nOpenDayTime);
		if nWeekDay == nOpenWeekDay then
			self.nCardPickCutActValidTime = nNow - Lib:GetLocalDayTime(nNow - nOpenDayTime) + 24 * 3600;
			self.nCardPickCutActOnSaleFlag = Lib:GetLocalDay(nNow - nOpenDayTime);

			local szNewInfoMsg = "    诸位侠士，截止至%s，通过元宝招募同伴首次十连抽将享受六折优惠，有心的侠士赶快前往招募心仪的同伴吧！";
			local szTimeDesc = Lib:TimeDesc9(self.nCardPickCutActValidTime);
			szNewInfoMsg = string.format(szNewInfoMsg, szTimeDesc);
			local tbSetting = { szTitle = "十连抽限时优惠"};
			NewInformation:AddInfomation("CardPickAct", self.nCardPickCutActValidTime, {szNewInfoMsg}, tbSetting);
			Log("CardPickCutAct Open", self.nCardPickCutActOnSaleFlag);
		end
	else
		self.nCardPickCutActValidTime = nil;
		self.nCardPickCutActOnSaleFlag = nil;
	end
end

function CardPicker:IsPickCutActOpen()
	return version_tx or version_vn;
end

function CardPicker:IsOnPickCutAct()
	if not CardPicker:IsPickCutActOpen() then
		return false;
	end

	if self.nCardPickCutActValidTime and GetTime() < self.nCardPickCutActValidTime then
		return true;
	end
	return false;
end

function CardPicker:GetPickCutActInfo()
	return self.nCardPickCutActOnSaleFlag, 0.6;
end

function CardPicker:GetGoldTenCostInfo(pPlayer)
	local nNow = GetTime();
	local nOnSaleFlag = nil;
	local nRate = 1;
	for _, tbInfo in ipairs(CardPicker.Def.tbGoldTenOnSaleSetting) do
		if nNow >= tbInfo[1] and nNow <= tbInfo[2] then
			local szTimeFrame = tbInfo[6];
			if not szTimeFrame or GetTimeFrameState(szTimeFrame) == 1 then
				nOnSaleFlag = tbInfo[3];
				nRate = tbInfo[4];
				break;
			end
		end
	end

	if CardPicker:IsOnPickCutAct() then
		nOnSaleFlag, nRate = CardPicker:GetPickCutActInfo();
	end

	if not nOnSaleFlag then
		return CardPicker.Def.nGoldTenCost, nil;
	end

	local nCurFlag = pPlayer.GetUserValue(CardPicker.Def.CARD_GOLD_TEN_SALE_GROUP, CardPicker.Def.CARD_GOLD_TEN_SALE_KEY);
	if nCurFlag == nOnSaleFlag then
		return CardPicker.Def.nGoldTenCost, nil;
	end

	return math.floor(CardPicker.Def.nGoldTenCost * nRate), nOnSaleFlag;
end

CardPicker.tbSpecialReplaceCard = nil;
function CardPicker:GetSpecialReplaceCard()
	return self.tbSpecialReplaceCard;
end

function CardPicker:SetSpecialReplaceCard(tbReplaceCard)
	self.tbSpecialReplaceCard = tbReplaceCard;
end

-- 需要按时间轴从小到大排序，时间轴对应序号改变概率也应该跟着变
CardPicker.tbCardPickProbTimeFrameMap = {
	[1] = "OpenDay7",
	[2] = "OpenDay35",
	[3] = "OpenDay116",
	[4] = "OpenLevel109",
};

function CardPicker:LoadCardPickSetting()
	local tbResult = {};
	local tbCardPickerSetting = LoadTabFile("Setting/CardPicker/CardPicker.tab",
		"ssddddddddddddddddddddd", nil, {"PickerType", "ItemType", "ItemId",
						"Prob0", "Prob1", "Prob2", "Prob3", "Prob4",
						"Prob5", "Prob6", "Prob7", "Prob8", "Prob9",
						"ProbHighVip0","ProbHighVip1","ProbHighVip2","ProbHighVip3","ProbHighVip4",
						"ProbHighVip5","ProbHighVip6","ProbHighVip7","ProbHighVip8","ProbHighVip9",});


	local function LoadProbSetting(szProbKey, szPickType)
		local tbItems = {};
		for _, tbLineData in ipairs(tbCardPickerSetting) do
			if szPickType == tbLineData.PickerType and tbLineData[szProbKey] > 0 then
				local tbItem = {
					szItemType = tbLineData.ItemType;
					nItemId    = tbLineData.ItemId;
					nCount     = 1;
					nProb      = tbLineData[szProbKey];
				}

				if tbItem.szItemType == "Partner" then
					local szName, nQualityLevel = GetOnePartnerBaseInfo(tbLineData.ItemId);
					if nQualityLevel then
						tbItem.nQualityLevel = nQualityLevel;
					else
						Log("Get Partner Info Fail: ", tbLineData.ItemId)
					end
				end
				table.insert(tbItems, tbItem);
			end
		end
		return tbItems;
	end

	for nProbIdx = 0, #CardPicker.tbCardPickProbTimeFrameMap do
		local szTypeKey = CardPicker.tbCardPickProbTimeFrameMap[nProbIdx] or "Default";

		tbResult[szTypeKey] = {
			tbItems = {},
			tbHighVipItems = {},
		};
		local tbProbItems = tbResult[szTypeKey];
		tbProbItems.tbItems["Gold"] = LoadProbSetting("Prob" .. nProbIdx, "Gold");
		tbProbItems.tbHighVipItems["Gold"] = LoadProbSetting("ProbHighVip" .. nProbIdx, "Gold");
		tbProbItems.tbItems["Coin"] = LoadProbSetting("Prob" .. nProbIdx, "Coin");
		tbProbItems.tbHighVipItems["Coin"] = LoadProbSetting("ProbHighVip" .. nProbIdx, "Coin");
	end

	self.tbPickerSetting = tbResult;
end

function CardPicker:LoadSpecialCardsSchedule()
	local nMaxCardLen = 15;
	local szType = "s";
	local tbField = {"TimeFrame"};
	for i = 1, nMaxCardLen do
		szType = szType .. "d";
		table.insert(tbField, "Card" .. i);
	end

	local tbSchedules = LoadTabFile("Setting/CardPicker/SpecailCardSchedule.tab", szType, "TimeFrame", tbField);
	local tbDealedTimeFrame = {};

--[[
	for szTimeFrame, tbInfo in pairs(tbSchedules) do
		tbDealedTimeFrame[szTimeFrame] = {};
		for nIdx = 1, nMaxCardLen do
			local nPartnerId = tbInfo["Card" .. nIdx];
			if nPartnerId and nPartnerId > 0 then
				table.insert(tbDealedTimeFrame[szTimeFrame], nPartnerId);
			end
		end
	end
]]

	self.tbSpecialCardSchedule = tbDealedTimeFrame;
end

function CardPicker:GetCurTimeFramsSpecialCards()
	local szMaxTimeFrame = Lib:GetMaxTimeFrame(self.tbSpecialCardSchedule or {});
	return self.tbSpecialCardSchedule and self.tbSpecialCardSchedule[szMaxTimeFrame];
end

function CardPicker:Init()
	CardPicker:LoadCardPickSetting();

	if MODULE_GAMESERVER then
		CardPicker:CheckPickCutAct();
		CardPicker:LoadSpecialCardsSchedule();
	end
end

function CardPicker:GetCardPickItems(pPlayer, szPickType, fnCheck)
	local szItemsKey = "Default";
	for _, szTimeFrame in ipairs(CardPicker.tbCardPickProbTimeFrameMap) do
		if GetTimeFrameState(szTimeFrame) ~= 1 then
			break;
		end
		szItemsKey = szTimeFrame;
	end

	local tbItems = {};
	local nVipLevel = pPlayer.GetVipLevel();
	if nVipLevel >= CardPicker.Def.nVipProbDivide then
		tbItems = self.tbPickerSetting[szItemsKey].tbHighVipItems[szPickType];
	else
		tbItems = self.tbPickerSetting[szItemsKey].tbItems[szPickType];
	end

	if not fnCheck then
		return tbItems;
	end

	local tbFilteredItems = {};
	for _, tbItem in ipairs(tbItems) do
		if fnCheck(tbItem) then
			table.insert(tbFilteredItems, tbItem);
		end
	end
	return tbFilteredItems;
end

function CardPicker:IsSpecialPartnerHit(nGoldTenCount)
	local nRate = CardPicker.Def.tbHighVipSpecialPartnerRate[nGoldTenCount] or 1;
	return MathRandom() <= nRate;
end