Require("CommonScript/Partner/PartnerDef.lua");
Require("CommonScript/Partner/PartnerCommon.lua");

local MAX_SKILL_QUALITY = 6;
function Partner:LoadRandomData()
	local tbGrowthType = {1.5, 2, 2.5, 3, 3.5};
	local tbProtentialSetting = LoadTabFile("Setting/Partner/ProtentialSetting.tab", "ddd", "nQuality", {"nQuality", "nProtentialToValue", "nStartValue"});

	self.tbProtentialToValue = {};
	self.tbStartValueInfo = {};
	for nQuality in pairs(self.tbQualityLevelDes) do
		local tbCurInfo = tbProtentialSetting[nQuality];
		assert(tbCurInfo);

		self.tbStartValueInfo[nQuality] = tbCurInfo.nStartValue;
		self.tbProtentialToValue[nQuality] = tbCurInfo.nProtentialToValue;
	end

	self.tbProtentialRandomInfo = {};
	local nTotalRate = 0;
	local tbRandomInfo = LoadTabFile("Setting/Partner/ProtentialRandom.tab", "ss", nil, {"nTimes", "nRate"});
	for _, tbInfo in pairs(tbRandomInfo) do
		local nTimes = tonumber(tbInfo.nTimes);
		local nRate = tonumber(tbInfo.nRate);
		assert(nTimes and nRate);

		nTotalRate = nRate * 1000 + nTotalRate;
		table.insert(self.tbProtentialRandomInfo, {nTimes, nTotalRate});
	end
	self.tbProtentialRandomInfo.nTotalRate = nTotalRate;

	self.tbPartnerGrowthInfo = {};
	local tbGrowthSetting = LoadTabFile("Setting/Partner/GrowthTemplate.tab", "dssss", nil, {"nSettingId", "Strength", "Energy", "Dexterity", "Vitality"});
	for _, tbInfo in pairs(tbGrowthSetting) do
		self.tbPartnerGrowthInfo[tbInfo.nSettingId] = {};
		local tbGrowth = self.tbPartnerGrowthInfo[tbInfo.nSettingId];

		tbGrowth.Strength = tonumber(tbInfo.Strength);
		tbGrowth.Energy = tonumber(tbInfo.Energy);
		tbGrowth.Dexterity = tonumber(tbInfo.Dexterity);
		tbGrowth.Vitality = tonumber(tbInfo.Vitality);
	end

	self.tbLimitProtentialInfo = {};
	local tbLimitInfo = LoadTabFile("Setting/Partner/ProtentialLimit.tab", "ddsssss", nil, {"nQuality", "nLevel", "1.5", "2", "2.5", "3", "3.5"});
	for _, tbInfo in pairs(tbLimitInfo) do
		self.tbLimitProtentialInfo[tbInfo.nQuality] = self.tbLimitProtentialInfo[tbInfo.nQuality] or {};
		local tbLimit = self.tbLimitProtentialInfo[tbInfo.nQuality];

		tbLimit[tbInfo.nLevel] = tbLimit[tbInfo.nLevel] or {};
		tbLimit[tbInfo.nLevel][1.5] = tbInfo["1.5"];
		tbLimit[tbInfo.nLevel][2] = tbInfo["2"];
		tbLimit[tbInfo.nLevel][2.5] = tbInfo["2.5"];
		tbLimit[tbInfo.nLevel][3] = tbInfo["3"];
		tbLimit[tbInfo.nLevel][3.5] = tbInfo["3.5"];
	end

	for nQuality in pairs(self.tbQualityLevelDes) do
		assert(self.tbLimitProtentialInfo[nQuality]);
		for i = 1, self.MAX_PROTENTIAL_LIMITE_LEVEL do
			assert(self.tbLimitProtentialInfo[nQuality][i]);
			assert(self.tbLimitProtentialInfo[nQuality][i][1.5]);
			assert(self.tbLimitProtentialInfo[nQuality][i][2]);
			assert(self.tbLimitProtentialInfo[nQuality][i][2.5]);
			assert(self.tbLimitProtentialInfo[nQuality][i][3]);
			assert(self.tbLimitProtentialInfo[nQuality][i][3.5]);
		end
	end

	local szType = "dd";
	local tbTitle = {"nType", "nPartnerQuality"};

	for i = 0, self.MAX_PARTNER_SKILL_COUNT, 1 do
		szType = szType .. "dd";
		table.insert(tbTitle, "nCount" .. i);
		table.insert(tbTitle, "nBYCount" .. i);
	end

	for i = 1, MAX_SKILL_QUALITY do
		szType = szType .. "d";
		table.insert(tbTitle, "nQuality" .. i);
	end

	self.tbSkillRandomInfo = {};
	local tbSkillRandomInfo = LoadTabFile("Setting/Partner/SkillRandom.tab", szType, nil, tbTitle);
	for _, tbRow in pairs(tbSkillRandomInfo) do
		self.tbSkillRandomInfo[tbRow.nType] = self.tbSkillRandomInfo[tbRow.nType] or {};
		self.tbSkillRandomInfo[tbRow.nType][tbRow.nPartnerQuality] = {tbCountInfo = {}, tbQualityInfo = {}};
		local tbCountInfo = self.tbSkillRandomInfo[tbRow.nType][tbRow.nPartnerQuality].tbCountInfo;
		local nTotalRate = 0;
		local nBYTotalRate = 0;
		for i = 0, self.MAX_PARTNER_SKILL_COUNT, 1 do
			local nRate = tbRow["nCount" .. i];
			if nRate > 0 then
				nTotalRate = nTotalRate + nRate;
				table.insert(tbCountInfo, {i, nTotalRate});
			end
		end

		tbCountInfo.nTotalRate = nTotalRate;

		local tbQualityInfo = self.tbSkillRandomInfo[tbRow.nType][tbRow.nPartnerQuality].tbQualityInfo;
		nTotalRate = 0;
		for i = 1, MAX_SKILL_QUALITY do
			local nRate = tbRow["nQuality" .. i];
			if nRate > 0 then
				nTotalRate = nTotalRate + nRate;
				table.insert(tbQualityInfo, {i, nTotalRate});
			end
		end
		tbQualityInfo.nTotalRate = nTotalRate;
	end
end
Partner:LoadRandomData();

function Partner:ClcSkillValueByPartnerQuality()
	local tbRandomInfo = self.tbSkillRandomInfo[self.PARTNER_TYPE_NORMAL];
	self.tbPartnerSkillValue = {};
	for i = 1, self.MIN_PARTNER_QUALITY_LEVEL do
		local nTotalValue = 0;
		local nValue = 0;
		local tbQualityInfo = tbRandomInfo[i].tbQualityInfo;
		local tbCountInfo = tbRandomInfo[i].tbCountInfo;
		local nLastRate = 0;
		for _, tbQuality in ipairs(tbQualityInfo) do
			local nRate = (tbQuality[2] - nLastRate) / tbQualityInfo.nTotalRate;
			nLastRate = tbQuality[2];
			nValue = nValue + (nRate * self.tbOneSkillValueByQuality[tbQuality[1]]);
		end

		nLastRate = 0;
		for _, tbCount in ipairs(tbCountInfo) do
			local nRate = (tbCount[2] - nLastRate) / tbCountInfo.nTotalRate;
			nLastRate = tbCount[2];
			nTotalValue = nTotalValue + tbCount[1] * nValue * nRate;
		end
		self.tbPartnerSkillValue[i] = nTotalValue;
	end
end
Partner:ClcSkillValueByPartnerQuality();

function Partner:LoadQualtiySetting()
	local szType = "dd"
	local tbTitle = {"GrowthType", "QualityLevel"};
	for _, szName in pairs(Partner.tbAllProtentialType) do
		szType = szType .. "d";
		table.insert(tbTitle, szName);
	end

	for i = 1, 10 do
		szType = szType .. "sddd";
		table.insert(tbTitle, string.format("Attrib%dType", i));
		table.insert(tbTitle, string.format("Attrib%dValue1", i));
		table.insert(tbTitle, string.format("Attrib%dValue2", i));
		table.insert(tbTitle, string.format("Attrib%dValue3", i));
	end

	local tbFile = LoadTabFile("Setting/Partner/QualitySetting.tab", szType, nil, tbTitle);

	self.tbPartnerQualityInfo = {};
	for nRow, tbRow in pairs(tbFile) do
		self.tbPartnerQualityInfo[tbRow.GrowthType] = self.tbPartnerQualityInfo[tbRow.GrowthType] or {};
		assert(not self.tbPartnerQualityInfo[tbRow.GrowthType][tbRow.QualityLevel], "repeat row " .. nRow);
		self.tbPartnerQualityInfo[tbRow.GrowthType][tbRow.QualityLevel] = {};
		local tbQualityInfo = self.tbPartnerQualityInfo[tbRow.GrowthType][tbRow.QualityLevel];

		for _, szName in pairs(self.tbAllProtentialType) do
			tbQualityInfo[szName] = tbRow[szName];
		end

		tbQualityInfo.tbMagicAttrib = {};
		for i = 1, 10 do
			local szType = tbRow[string.format("Attrib%dType", i)];
			if szType and szType ~= "" then
				table.insert(tbQualityInfo.tbMagicAttrib, {szType, tbRow["Attrib" .. i .. "Value1"], tbRow["Attrib" .. i .. "Value2"], tbRow["Attrib" .. i .. "Value3"]});
			end
		end
	end
end
Partner:LoadQualtiySetting();

function Partner:RandomallLimitProtential(nGrowthType, nQuality, bIsBY, bIsGood)
	if type(bIsBY) == "number" then
		bIsBY = bIsBY == 1 and true or false;
	end

	if type(bIsGood) == "number" then
		bIsGood = bIsGood == 1 and true or false;
	end

	local nStartLevel = 1;
	if bIsBY then
		nStartLevel = self.nBYLimitStartRandomLevel;
	elseif bIsGood then
		nStartLevel = self.nGoodLimitStartRandomLevel;
	end

	local tbAllLimit = {};
	for i = 1, 4 do
		table.insert(tbAllLimit, MathRandom(nStartLevel, self.MAX_PROTENTIAL_LIMITE_LEVEL));
	end

	return unpack(tbAllLimit);
end

function Partner:GetLimitProtentialValue(nQualityLevel, nGrowthType, nProtentialType, nLimiteLevel, nGradeLevel, nAwareness)
	local tbGrowth = self.tbPartnerGrowthInfo[nGrowthType];
	if not tbGrowth then
		Log("[Partner] GetLimitProtentialValue tbGrowth is nil !!");
		return;
	end

	local nType = tbGrowth[self.tbAllProtentialType[nProtentialType] or "nil"];
	if not nType then
		Log("[Partner] GetLimitProtentialValue nType is nil !!");
		return;
	end

	if not self.tbLimitProtentialInfo[nQualityLevel] then
		Log("[Partner] GetLimitProtentialValue not LimitInfo !!");
		return;
	end

	local nMaxLimit = self.tbLimitProtentialInfo[nQualityLevel][nLimiteLevel][nType];
	if nAwareness and nAwareness == 1 then
		local nAddPro, nAddProLimit = self:GetAwarenessAddInfo(nQualityLevel);
		nMaxLimit = nMaxLimit + math.floor(nAddProLimit * nType / 10);
	end

	local nIdx = math.max(#self.tbGradeLevelProtentialLimit - nGradeLevel + 1, 1);
	local tbInfo = self.tbGradeLevelProtentialLimit[nIdx];

	return math.floor(nMaxLimit * tbInfo[2] / 100), nGradeLevel >= #self.tbGradeLevelProtentialLimit;
end

function Partner:RandomProtential(nGrowthType, nQuality)
	local tbGrowth = self.tbPartnerGrowthInfo[nGrowthType or -1];
	if not tbGrowth then
		Log("[Partner] RandomProtential ERR !! not tbGrowth ", nGrowthType, nQuality);
		return;
	end

	local tbAllProtential = {};
	for _, szInfo in ipairs(self.tbAllProtentialType) do
		local nType = tbGrowth[szInfo];
		if not nType then
			Log("[Partner] RandomProtential ERR !! not nType ", nGrowthType, nQuality);
			return;
		end

		local nTimes = 0.5;
		local nRandom = MathRandom(self.tbProtentialRandomInfo.nTotalRate);
		for _, tbInfo in ipairs(self.tbProtentialRandomInfo) do
			if nRandom <= tbInfo[2] then
				nTimes = tbInfo[1];
				break;
			end
		end

		local nValue = math.floor(nTimes * self.tbStartValueInfo[nQuality] * nType / 10);
		table.insert(tbAllProtential, nValue);
	end

	return unpack(tbAllProtential);
end

function Partner:RandomOneSkill(tbAllSkillId, nQuality, nSeries)
	if nQuality <= 0 then
		return nil;
	end

	local nRandom = MathRandom(#(tbAllSkillId[nQuality] or {}));
	local nSkillId = (tbAllSkillId[nQuality] or {})[nRandom];
	if not nSkillId or nSkillId <= 0 then
		Log("[Partner] RandomOneSkill ERR !! not nSkillId ", nQuality, nSeries);
	end

	if nSkillId and nSkillId > 0 then
		local tbSkillInfo = self:GetSkillInfoBySkillId(nSkillId or -1);
		if tbSkillInfo then
			local tbToRemove = {};
			for nQ, tbInfo in pairs(tbAllSkillId) do
				for nIdx, nS in pairs(tbInfo) do
					local tbCurSkillInfo = self:GetSkillInfoBySkillId(nS);
					if tbCurSkillInfo.nType == tbSkillInfo.nType then
						table.insert(tbToRemove, 1, {nQ, nIdx});
					end
				end
			end

			for _, tbInfo in ipairs(tbToRemove) do
				table.remove(tbAllSkillId[tbInfo[1]], tbInfo[2]);
			end
		end
	else
		nSkillId = self:RandomOneSkill(tbAllSkillId, nQuality - 1, nSeries);
	end

	return nSkillId;
end

function Partner:RandomAllSkill(nPartnerQuality, nSeries, nType)
	local tbRandomInfo = self.tbSkillRandomInfo[nType][nPartnerQuality];
	if not tbRandomInfo then
		return;
	end

	local nSkillCount = 0;
	local tbCountInfo = tbRandomInfo.tbCountInfo;
	local nRandom = MathRandom(tbCountInfo.nTotalRate);
	for _, tbInfo in ipairs(tbCountInfo) do
		if nRandom <= tbInfo[2] then
			nSkillCount = tbInfo[1];
			break;
		end
	end

	local tbAllSkillId = {};
	for _, tbInfo in pairs(self.tbSkillBookSetting.tbBookInfo) do
		if tbInfo.nSeries == 0 or tbInfo.nSeries == nSeries then
			tbAllSkillId[tbInfo.nQuality] = tbAllSkillId[tbInfo.nQuality] or {};
			table.insert(tbAllSkillId[tbInfo.nQuality], tbInfo.nSkillId);
		end
	end

	local tbSkillList = {};
	for i = 1, nSkillCount do
		local nQuality = 1;
		nRandom = MathRandom(tbRandomInfo.tbQualityInfo.nTotalRate);
		for _, tbInfo in ipairs(tbRandomInfo.tbQualityInfo) do
			if nRandom <= tbInfo[2] then
				nQuality = tbInfo[1];
				break;
			end
		end

		local nSkillId = self:RandomOneSkill(tbAllSkillId, nQuality, nSeries);
		if nSkillId and nSkillId > 0 then
			table.insert(tbSkillList, nSkillId);
		end
	end

	return #tbSkillList, tbSkillList;
end

function Partner:RandomBYState(nType)
	if nType and nType == self.PARTNER_TYPE_DEBT then
		return false;
	end

	return MathRandom(100000) <= self.nPartnerBYRate * 100000;
end

function Partner:RandomAll(nTemplateId, nType)
	local _, nQualityLevel, _, nGrowthType, nSeries = GetOnePartnerBaseInfo(nTemplateId);
	local bIsBY = nType == self.PARTNER_TYPE_BY or self:RandomBYState(nType);
	local nVitality, nDexterity, nStrength, nEnergy = self:RandomProtential(nGrowthType, nQualityLevel);
	local nLimitVitality, nLimitDexterity, nLimitStrength, nLimitEnergy = self:RandomallLimitProtential(nGrowthType, nQualityLevel, bIsBY, nType == self.PARTNER_TYPE_GOOD);

	nType = nType or self.PARTNER_TYPE_NORMAL;
	nType = bIsBY and self.PARTNER_TYPE_BY or nType;
	local nSkillCount, tbSkillInfo = self:RandomAllSkill(nQualityLevel, nSeries, nType);

	local tbData = {
		bIsBY = bIsBY;
		nSkillCount = nSkillCount;
		tbSkillInfo = tbSkillInfo;

		nVitality = nVitality;
		nDexterity = nDexterity;
		nStrength = nStrength;
		nEnergy = nEnergy;

		nLimitVitality = nLimitVitality;
		nLimitDexterity = nLimitDexterity;
		nLimitStrength = nLimitStrength;
		nLimitEnergy = nLimitEnergy;
	};


	nType = tbData.bIsBY and self.PARTNER_TYPE_BY or nType;

	local nMinBYFightPower = self.tbMinBYFightPower[nQualityLevel]
	if nMinBYFightPower then
		local tbProtentialInfo = {
			["Vitality"] = nVitality,
			["Dexterity"] = nDexterity,
			["Strength"] = nStrength,
			["Energy"] = nEnergy,
		}

		local tbSkill = {};
		for _, nSkillId in pairs(tbSkillInfo) do
			if nSkillId > 0 then
				tbSkill[nSkillId] = 1;
			end
		end

		local nFightPower = self:GetFightPower(nTemplateId, nQualityLevel, nGrowthType, 1, 0, tbProtentialInfo, tbSkill);
		if nFightPower >= nMinBYFightPower then
			tbData.bIsBY = true;
		end
	end

	return tbData, nType;
end

function Partner:SetPartnerData(pPartner, tbData, bSetUseProtentialItemValue)

	if not tbData.nAwareness or tbData.nAwareness ~= 1 then
		tbData.nAwareness = 0
	end

	pPartner.SetAwareness(tbData.nAwareness);
	pPartner.SetLevelInfo(tbData.nLevel or 0, tbData.nExp or 0);
	pPartner.SetGradeLevel(tbData.nGradeLevel or 0);
	pPartner.SetWeaponState(tbData.nWeaponState and tbData.nWeaponState or 0);
	pPartner.SetBYState(tbData.bIsBY and 1 or 0);
	pPartner.SetLimitProtential(self.POTENTIAL_TYPE_VITALITY, tbData.nLimitVitality);
	pPartner.SetProtential(self.POTENTIAL_TYPE_VITALITY, tbData.nVitality, true);

	pPartner.SetLimitProtential(self.POTENTIAL_TYPE_DEXTERITY, tbData.nLimitDexterity);
	pPartner.SetProtential(self.POTENTIAL_TYPE_DEXTERITY, tbData.nDexterity, true);

	pPartner.SetLimitProtential(self.POTENTIAL_TYPE_STRENGTH, tbData.nLimitStrength);
	pPartner.SetProtential(self.POTENTIAL_TYPE_STRENGTH, tbData.nStrength, true);

	pPartner.SetLimitProtential(self.POTENTIAL_TYPE_ENERGY, tbData.nLimitEnergy);
	pPartner.SetProtential(self.POTENTIAL_TYPE_ENERGY, tbData.nEnergy, true);

	if bSetUseProtentialItemValue then
		local _, nQualityLevel = GetOnePartnerBaseInfo(pPartner.nTemplateId);
		local nUsePItemValue = math.max(0, tbData.nVitality + tbData.nDexterity + tbData.nStrength + tbData.nEnergy - self.tbStartValueInfo[nQualityLevel]);
		pPartner.SetUseProtentialItemValue(nUsePItemValue);
	end

	for i = 1, Partner.MAX_PARTNER_SKILL_COUNT do
		if tbData.tbSkillInfo[i] then
			pPartner.SetSkillInfo(i, tbData.tbSkillInfo[i], 0, 0, false);
		else
			pPartner.SetSkillInfo(i, 0, 0, 0, false);
		end
	end
end

function Partner:GetPartnerData(pPartner)
	local tbData = {};
	tbData.nAwareness = pPartner.GetAwareness();
	tbData.nLevel, tbData.nExp = pPartner.GetLevelInfo();
	tbData.nGradeLevel = pPartner.GetGradeLevel();
	tbData.nWeaponState = pPartner.nWeaponState;
	tbData.bIsBY = pPartner.nBYState == 1 and true or false;

	for nTypeId, szType in pairs(self.tbAllProtentialType) do
		tbData["nLimit" .. szType] = pPartner.GetLimitProtential(nTypeId);
		tbData["n" .. szType] = pPartner.GetProtential(nTypeId);
	end

	tbData.tbSkillInfo = tbData.tbSkillInfo or {};
	for i = 1, Partner.MAX_PARTNER_SKILL_COUNT do
		local nSkillId, nSkillLevel, nSkillExp = pPartner.GetSkillInfo(i);
		if nSkillId > 0 then
			tbData.tbSkillInfo[i] = nSkillId;
		end
	end

	return tbData;
end

function Partner:GetSpecialPartnerValue(tbData)
	local szValue = "" ..
					(tbData.nLevel or 0) .. "|" ..
					(tbData.nExp or 0) .. "|" ..
					(tbData.nGradeLevel or 0) .. "|" ..
					(tbData.nWeaponState and tbData.nWeaponState or 0) .. "|" ..
					(tbData.bIsBY and 1 or 0) .. "|" ..
					(tbData.nVitality or 0) .. "|" ..
					(tbData.nDexterity or 0) .. "|" ..
					(tbData.nStrength or 0) .. "|" ..
					(tbData.nEnergy or 0) .. "|" ..
					(tbData.nLimitVitality or 0) .. "|" ..
					(tbData.nLimitDexterity or 0) .. "|" ..
					(tbData.nLimitStrength or 0) .. "|" ..
					(tbData.nLimitEnergy or 0) .. "|";

	for i = 1, Partner.MAX_PARTNER_SKILL_COUNT do
		tbData.tbSkillInfo = tbData.tbSkillInfo or {};
		local nSkillId = tbData.tbSkillInfo[i];
		local tbSkillInfo  = Partner:GetSkillInfoBySkillId(nSkillId or 0);
		szValue = szValue .. (tbSkillInfo and nSkillId or 0) .. "|";
	end

	return szValue;
end

function Partner:GetSpecialPartnerData(value)
	local tbValue = Lib:SplitStr(value, "|");
	local tbData           = {};
	tbData.nLevel          = tonumber(tbValue[1]) or 0;
	tbData.nExp            = tonumber(tbValue[2]) or 0;
	tbData.nGradeLevel     = tonumber(tbValue[3]) or 0;
	tbData.nWeaponState    = tonumber(tbValue[4]) or 0;
	tbData.bIsBY           = (tonumber(tbValue[5]) or 0) == 1;
	tbData.nVitality       = tonumber(tbValue[6]) or 0;
	tbData.nDexterity      = tonumber(tbValue[7]) or 0;
	tbData.nStrength       = tonumber(tbValue[8]) or 0;
	tbData.nEnergy         = tonumber(tbValue[9]) or 0;
	tbData.nLimitVitality  = tonumber(tbValue[10]) or 0;
	tbData.nLimitDexterity = tonumber(tbValue[11]) or 0;
	tbData.nLimitStrength  = tonumber(tbValue[12]) or 0;
	tbData.nLimitEnergy    = tonumber(tbValue[13]) or 0;

	tbData.tbSkillInfo = {};
	for i = 1, Partner.MAX_PARTNER_SKILL_COUNT do
		local nSkillId = tonumber(tbValue[13 + i]) or 0;
		if nSkillId >= 0 then
			tbData.tbSkillInfo[i] = nSkillId;
		else
			break;
		end
	end
	return tbData;
end

function Partner:GetReInitCostToGold(nPartnerTemplateId)
	local _, nQualityLevel = GetOnePartnerBaseInfo(nPartnerTemplateId);
	if not nQualityLevel or nQualityLevel > 3 then
		return;
	end

	local nItemCount = self.ServeranceCost[nQualityLevel];
	local nItemValue = self:GetItemValue(Partner.nSeveranceItemId);

	-- 转换为对应价值量的元宝数
	return math.floor(nItemCount * nItemValue / 1000);
end

function Partner:OnInit(pPartner, nAwareness, pPlayer)
	local nType = nil;
	if MODULE_GAMESERVER and pPlayer then
		local nNeed = Player:GetRewardValueDebt(pPlayer.dwID);
		if nNeed > 0 then
			local nCost = self:GetReInitCostToGold(pPartner.nTemplateId);
			if nCost and nCost > 0 then
				nType = Partner.PARTNER_TYPE_DEBT;
				Player:CostRewardValueDebt(pPlayer.dwID, nCost, Env.LogWay_PartnerReInit);
			end
		end
	end

	local tbData = self:RandomAll(pPartner.nTemplateId, nType);
	tbData.nAwareness = nAwareness or 0;
	self:SetPartnerData(pPartner, tbData);
end

function Partner:OnUpdate(pPartner)
	local _, nQualityLevel, _, nGrowthType = GetOnePartnerBaseInfo(pPartner.nTemplateId);
	local tbQualityInfo = (self.tbPartnerQualityInfo[nGrowthType] or {})[nQualityLevel];
	if not tbQualityInfo then
		Log("[Partner] OnUpdate ERROR !!!", nQualityLevel, nGrowthType);
		return;
	end

	pPartner.ClearMagicAttrib();

	local nAwareness = pPartner.GetAwareness();

	local nAddProtential, _, nAddProtentialByLevel = Partner:GetAwarenessAddInfo(nQualityLevel);
	if nAwareness == 0 then
		nAddProtential = 0;
		nAddProtentialByLevel = 0;
	end

	local tbGrowth = self.tbPartnerGrowthInfo[nGrowthType];
	local nLevel = pPartner.GetLevelInfo();
	--  先计算并设置基础属性再加魔法属性，否则会有问题
	local tbAllBaseAttrib = {};
	for nType, szName in pairs(self.tbAllProtentialType) do
		local nMaxValue, bIsMaxGrade = self:GetLimitProtentialValue(nQualityLevel, nGrowthType, nType, pPartner.GetLimitProtential(nType), pPartner.GetGradeLevel() + 1, nAwareness);
		local nValue = math.floor(pPartner.GetProtential(nType) / self.tbProtentialToValue[nQualityLevel]);
		nValue = bIsMaxGrade and math.min(nMaxValue, nValue) or nValue;
		tbAllBaseAttrib[nType] = nValue;
		tbAllBaseAttrib[nType] = tbAllBaseAttrib[nType] + tbQualityInfo[szName];

		-- 同伴升级增加潜能
		local nGrowthValue = tbGrowth[szName] / 10;
		tbAllBaseAttrib[nType] = nAddProtential * nGrowthValue 			-- 觉醒后增加初始潜能点
								+ tbAllBaseAttrib[nType]				-- 同伴初始潜能点
															-- 正常升级同伴增加潜能点				觉醒后每级额外增加潜能点
								+ math.max(nLevel, 0) * (self.tbLevelupGrowthValue[nQualityLevel] + nAddProtentialByLevel) * nGrowthValue;
	end

	pPartner.SetBaseAttrib(tbAllBaseAttrib[self.POTENTIAL_TYPE_VITALITY],
							tbAllBaseAttrib[self.POTENTIAL_TYPE_DEXTERITY],
							tbAllBaseAttrib[self.POTENTIAL_TYPE_STRENGTH],
							tbAllBaseAttrib[self.POTENTIAL_TYPE_ENERGY])

	for _, tbAttrib in pairs(tbQualityInfo.tbMagicAttrib) do
		pPartner.AddMagicAttrib(tbAttrib[1], tbAttrib[2] or 0, tbAttrib[3] or 0, tbAttrib[4] or 0);
	end

	if pPartner.nWeaponState == 1 then
		local tbEquip = GetPartnerWeaponInfo(pPartner.nTemplateId) or {};
		for _, tbMa in pairs(tbEquip.tbAttrib or {}) do
			pPartner.AddMagicAttrib(tbMa.szAttribName, tbMa.tbValue[1] or 0, tbMa.tbValue[2] or 0, tbMa.tbValue[3] or 0);
		end
	end

	local tbProtentialInfo = {}
	for nType, szName in pairs(self.tbAllProtentialType) do
		tbProtentialInfo[szName] = pPartner.GetProtential(nType);
	end

	local tbSkillInfo = {};
	for i = 1, 5 do
		local nSkillId, nSkillLevel = pPartner.GetSkillInfo(i);
		if nSkillId > 0 then
			tbSkillInfo[nSkillId] = math.max(nSkillLevel, 1);
		end
	end

	local nFightPower = self:GetFightPower(pPartner.nTemplateId, nQualityLevel, nGrowthType,
											nLevel, pPartner.nWeaponState, tbProtentialInfo, tbSkillInfo, nAwareness);

	local _, nStarLevel = self:GetStarValue(nFightPower);
	pPartner.SetProtectSkillLevel(self.tbFightPowerToSkillLevel[nStarLevel] or 1);
	pPartner.SetFightPower(nFightPower);
end

