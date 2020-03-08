
HousePlant.LAND_ID = 4427;
HousePlant.PLANT_COST = 200;				-- 种植消耗元宝数	
HousePlant.RIPEN_TIME = 3600 * 24;			-- 成熟时间

-- 植物状态
HousePlant.STATE_NULL = -1;				-- 空田
HousePlant.STATE_NORMAL = 0;			-- 正常
HousePlant.STATE_RIPEN = 100;			-- 成熟

-- 异常状态（注：按从小到大的顺序）
HousePlant.STATE_WATER = 1;				-- 待浇水
HousePlant.STATE_FERTILIZE = 2;			-- 待施肥
HousePlant.STATE_DISINFESTATION = 3;	-- 待除虫
HousePlant.tbSickStateSetting =
{
	{ szDesc = "缺水",	szCureTool = "水壶", szCureToolCost = "高级水壶",	szCureNotify = "本次浇水，树丛的成熟时间加快[FFFE0D]%s[-]",	szFailedMsg = "泥土看起来非常湿润，无需浇水", },
	{ szDesc = "缺肥",	szCureTool = "肥料", szCureToolCost = "高级肥料",	szCureNotify = "本次施肥，树丛的成熟时间加快[FFFE0D]%s[-]",	szFailedMsg = "泥土看起来十分肥沃，无需施肥",  },
	{ szDesc = "生虫",	szCureTool = "除虫剂", szCureToolCost = "高级除虫剂",	szCureNotify = "本次除虫，树丛的成熟时间加快[FFFE0D]%s[-]",	szFailedMsg = "植物看起来很健康，无需除虫", },
}

-- 植物养护
HousePlant.CURE_COST = 50;				-- 养护消耗元宝数
HousePlant.CURE_TIME_NORMAL = 3600;		-- 普通养护减少成熟时间
HousePlant.CURE_TIME_COST = 3600 * 2;	-- 元宝养护减少成熟时间
HousePlant.CURE_COST_AWARD = 500;		-- 消耗元宝养护获得贡献值
HousePlant.CURE_INTIMACY = 50;			-- 养护亲密度
HousePlant.CURE_INTIMACY_COST = 100;		-- 消耗元宝养护亲密度

-- 植物养护次数刷新时间，每天4点
HousePlant.CURE_TIMES_REFRESH_TIME = 4 * 3600;

-- 植物异常
HousePlant.tbSickGapSetting =
{
	{ nHour = 2, nSickGap = 2 * 3600 },
	{ nHour = 10, nSickGap = 4 * 3600 },
	{ nHour = 24, nSickGap = 2 * 3600 },
};

HousePlant.tbCureAward =
{
	{ tbAward = {{ "Contrib", 500 }}, nRatio = 270, szKinNotify = nil },
	{ tbAward = {{ "Contrib", 800 }}, nRatio = 150, szKinNotify = nil },
	{ tbAward = {{ "Contrib", 1000 }}, nRatio = 80, szKinNotify = "「%s」使用元宝协助养护时，获得了1000贡献，真是鸿运当头啊！"},
	{ tbAward = {{ "Energy", 500 }}, nRatio = 270, szKinNotify = nil },
	{ tbAward = {{ "Energy", 800 }}, nRatio = 150, szKinNotify = nil },
	{ tbAward = {{ "Energy", 1000 }}, nRatio = 80, szKinNotify = "「%s」使用元宝协助养护时，获得了1000元气，真是鸿运当头啊！" },
};

if MODULE_GAMESERVER then
	function HousePlant:LoadLevelRatioSetting(szFile, nMaxIndex, szKey)
		local tbSetting = {};
		local szType = "s";
		local tbCol = { "szTimeFrame" };
		for i = 1, nMaxIndex do
			szType = szType .. "dd";
			table.insert(tbCol, "nRatio" .. i);
			table.insert(tbCol, szKey .. i);
		end
		local tbFile = LoadTabFile(szFile, szType, nil, tbCol);
		for _, tbRow in pairs(tbFile) do
			local tbLevelSetting = {};
			tbLevelSetting.szTimeFrame = tbRow.szTimeFrame;
			assert(tbLevelSetting.szTimeFrame ~= "");

			local tbRand = {};
			local nTotalRatio = 0;
			for i = 1, nMaxIndex do
				local nRatio = tbRow["nRatio" .. i];
				assert(nRatio >= 0, szFile);

				table.insert(tbRand, { nResult = tbRow[szKey .. i], nRatio = nRatio });
				nTotalRatio = nTotalRatio + nRatio;
			end
			assert(nTotalRatio == 1000, szFile);
			tbLevelSetting.tbRand = tbRand;

			table.insert(tbSetting, tbLevelSetting);
		end
		return tbSetting;
	end

	function HousePlant:LoadSetting()
		HousePlant.tbCropCountSetting = HousePlant:LoadLevelRatioSetting("Setting/HousePlant/CropCount.tab", 4, "nCount");
		HousePlant.tbCropItemSetting = HousePlant:LoadLevelRatioSetting("Setting/HousePlant/CropItem.tab", 5, "nItem");

		HousePlant.tbCureAward.nTotalRatio = 0;
		for _, tbSetting in ipairs(HousePlant.tbCureAward) do
			HousePlant.tbCureAward.nTotalRatio = HousePlant.tbCureAward.nTotalRatio + tbSetting.nRatio;
		end
	end
	HousePlant:LoadSetting();

	function HousePlant:RandResult(tbRand)
		local nRand = MathRandom(1, 1000);
		local nCurValue = 0;
		for _, tbInfo in ipairs(tbRand) do
			nCurValue = nCurValue + tbInfo.nRatio;
			if nRand <= nCurValue then
				return tbInfo.nResult;
			end
		end
		assert(false, "failed to rand: " .. nRand);
		return -1;
	end

	function HousePlant:GetCropSetting(tbSetting)
		local tbResult = nil;
		for _, tbInfo in ipairs(tbSetting) do
			if GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
				break;
			end
			tbResult = tbInfo;
		end
		return tbResult;
	end

	function HousePlant:RandCropCount()
		local tbSetting = self:GetCropSetting(self.tbCropCountSetting);
		return self:RandResult(tbSetting.tbRand);
	end

	function HousePlant:GetCropAward()
		local nCount = self:RandCropCount();
		if nCount <= 0 then
			return;
		end

		local tbAward = {};
		local tbSetting = self:GetCropSetting(self.tbCropItemSetting);
		for i = 1, nCount do
			local nItemId = self:RandResult(tbSetting.tbRand);
			table.insert(tbAward, {"item", nItemId,	1});
		end
		return tbAward;
	end

	function HousePlant:CalcuSickTime()
		local nCurTime = GetTime();
		local nDayHour = Lib:GetLocalDayHour(nCurTime);
		for _, tbSetting in ipairs(self.tbSickGapSetting) do
			if nDayHour <= tbSetting.nHour then
				return nCurTime + tbSetting.nSickGap;
			end
		end
	end

	function HousePlant:GetCureAward()
		local nTotal = HousePlant.tbCureAward.nTotalRatio;
		local nRand = MathRandom(1, nTotal);
		local nCur = 0;
		for i, tbSetting in ipairs(HousePlant.tbCureAward) do
			nCur = nCur + tbSetting.nRatio;
			if nRand <= nCur then
				return tbSetting.tbAward, tbSetting.szKinNotify, i;
			end
		end
	end
end

function HousePlant:IsSickState(nState)
	return HousePlant.tbSickStateSetting[nState] and true or false;
end