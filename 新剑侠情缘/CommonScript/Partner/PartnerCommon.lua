Require("CommonScript/Partner/PartnerDef.lua");

function Partner:CheckVersion(tbInfo)
	if (tbInfo.version_tx == 1 and version_tx) or
		(tbInfo.version_vn == 1 and version_vn) or
		(tbInfo.version_hk == 1 and version_hk) or
		(tbInfo.version_xm == 1 and version_xm) or
		(tbInfo.version_en == 1 and version_en) or
		(tbInfo.version_kor == 1 and version_kor) or
		(tbInfo.version_th == 1 and version_th) then
		return true;
	end

	return false;
end

function Partner:Init()
	self.tbPartnerExp = {};
	local tbFile = LoadTabFile("Setting/Partner/PartnerExp.tab", "ddddddd", "Level", {"Level", "SSS", "SS", "S", "A", "B", "C"});
	assert(tbFile, "Setting/Partner/PartnerExp.tab read fail !!");
	for nLevel, tbInfo in pairs(tbFile) do
		self.tbPartnerExp[nLevel] = tbInfo;
	end

	self.tbAllPartnerInfo = {};
	local tbAllIcon = LoadTabFile("Setting/Partner/PartnerIcon.tab", "dss", "IconId", {"IconId", "Atlas", "Sprite"});
	assert(tbAllIcon, "Setting/Partner/PartnerIcon.tab read fail !!");
	local tbFile = LoadTabFile("Setting/Partner/PartnerTemplate.tab", "dsdddsdsdddddddd", nil, {"Id", "szGrowthType", "StoneIcon", "StoneValue", "Value", "Info", "Hide", "ShowTimeFrame", "ValueLimit",
		"version_tx", "version_vn", "version_hk", "version_xm", "version_en", "version_kor", "version_th"});
	assert(tbFile, "Setting/Partner/PartnerTemplate.tab read fail !!");
	for _, tbInfo in pairs(tbFile) do
		assert(tbInfo.Id < self.PARTNER_HAS_MAX_ID);

		if tbInfo.Hide == 0 and not self:CheckVersion(tbInfo) then
			self.tbAllPartnerInfo[tbInfo.Id] = self.tbAllPartnerInfo[tbInfo.Id] or {};
			self.tbAllPartnerInfo[tbInfo.Id].tbIcon = tbAllIcon[tbInfo.StoneIcon] or tbAllIcon[0];
			self.tbAllPartnerInfo[tbInfo.Id].nStoneValue = tbInfo.StoneValue;
			self.tbAllPartnerInfo[tbInfo.Id].nValue = tbInfo.Value;
			self.tbAllPartnerInfo[tbInfo.Id].szInfo = tbInfo.Info;
			self.tbAllPartnerInfo[tbInfo.Id].szShowTimeFrame = tbInfo.ShowTimeFrame;
			self.tbAllPartnerInfo[tbInfo.Id].szGrowthType = tbInfo.szGrowthType;
			self.tbAllPartnerInfo[tbInfo.Id].nValueLimit = tbInfo.ValueLimit;
		end
	end

	self.tbWeaponInfo = {};
	self.tbWeaponValue = {};
	self.tbPartner2WeaponItem = {};
	local tbWeaponSetting = LoadTabFile("Setting/Partner/WeaponSetting.tab", "ddd", nil, {"nPartnerId", "nItemId", "nValue"});
	for _, tbInfo in pairs(tbWeaponSetting) do
		assert(not self.tbWeaponInfo[tbInfo.nItemId], "Setting/Partner/WeaponSetting.tab ERR !!!! " .. tbInfo.nItemId);
		assert(not self.tbPartner2WeaponItem[tbInfo.nPartnerId], "Setting/Partner/WeaponSetting.tab ERR !!!! " .. tbInfo.nPartnerId);
		self.tbWeaponInfo[tbInfo.nItemId] = tbInfo.nPartnerId;
		self.tbPartner2WeaponItem[tbInfo.nPartnerId] = tbInfo.nItemId;
		self.tbWeaponValue[tbInfo.nPartnerId] = tbInfo.nValue * self.nWeaponValue2RealValue;
	end

	self.tbProtentialItemRandomInfo = {};
	local nTotalRate = 0;
	local tbRandomInfo = LoadTabFile("Setting/Partner/ProtentialRandom.tab", "ss", nil, {"nTimes", "nRate"});
	for _, tbInfo in pairs(tbRandomInfo) do
		local nTimes = tonumber(tbInfo.nTimes);
		local nRate = tonumber(tbInfo.nRate);
		assert(nTimes and nRate);

		nTotalRate = nRate * 1000 + nTotalRate;
		table.insert(self.tbProtentialItemRandomInfo, {nTimes, nTotalRate});
	end
	self.tbProtentialItemRandomInfo.nTotalRate = nTotalRate;
end
Partner:Init();

function Partner:GetFightPower(nTemplateId, nQualityLevel, nGrowthType, nLevel, nWeaponState, tbProtentialInfo, tbSkillInfo, nAwareness)
	local tbGrowth = self.tbPartnerGrowthInfo[nGrowthType];
	if not tbGrowth then
		return 0;
	end

	local nValue = self:GetProtentialValue(nGrowthType, tbProtentialInfo);
	if nWeaponState and nWeaponState == 1 then
		nValue = nValue + (self.tbWeaponValue[nTemplateId] or 0);
	end

	if nAwareness and nAwareness == 1 then
		local _, _, _, nAddValue = Partner:GetAwarenessAddInfo(nQualityLevel);
		nValue = nValue + nAddValue;
	end

	nValue = nValue + self:GetSkillValue(tbSkillInfo);
	nValue = math.floor(nValue + 0.1);

	return math.floor(nValue * self.nValueToFightPower);
end

function Partner:GetMaxFightPower(tbPartnerInfo)
	local nTemplateId, nQualityLevel, nGrowthType = tbPartnerInfo.nTemplateId, tbPartnerInfo.nQualityLevel, tbPartnerInfo.nGrowthType;
	local tbGrowth = self.tbPartnerGrowthInfo[nGrowthType];
	if not tbGrowth then
		return 0;
	end

	local tbProtentialInfo = {};
	for nProtentialType, szType in pairs(self.tbAllProtentialType) do
		local nMaxLimit = self:GetLimitProtentialValue(tbPartnerInfo.nQualityLevel, tbPartnerInfo.nGrowthType, nProtentialType, tbPartnerInfo["nLimitProtential" .. szType], #self.tbGradeLevelProtentialLimit, tbPartnerInfo.nAwareness);
		tbProtentialInfo[szType] = nMaxLimit * self.tbProtentialToValue[tbPartnerInfo.nQualityLevel];
	end

	local nValue = self:GetProtentialValue(nGrowthType, tbProtentialInfo);
	nValue = nValue + (self.tbWeaponValue[nTemplateId] or 0);

	if tbPartnerInfo.nAwareness and tbPartnerInfo.nAwareness == 1 then
		local _, _, _, nAddValue = Partner:GetAwarenessAddInfo(nQualityLevel);
		nValue = nValue + nAddValue;
	end

	nValue = nValue + Partner.tbSkillAvaMaxValue[nQualityLevel];
	return math.floor(nValue * self.nValueToFightPower);
end

function Partner:GetProtentialValue(nGrowthType, tbProtentialInfo)
	local nValue = 0;
	for _, nPValue in pairs(tbProtentialInfo or {}) do
		nValue = nValue + nPValue;
	end

	return nValue;
end

function Partner:GetSkillValue(tbSkillInfo)
	local nValue = 0;
	for nSkillId, nSkillLevel in pairs(tbSkillInfo) do
		nSkillLevel = math.max(nSkillLevel, 1);
		local tbSkillInfo = self:GetSkillInfoBySkillId(nSkillId);
		if tbSkillInfo then
			nValue = nValue + tbSkillInfo.tbSkillValue[nSkillLevel];
		end
	end

	return nValue;
end

function Partner:CheckCanUseSkillBook(pPlayer, nPartnerId, nItemId)
	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner then
		return false, "无效同伴";
	end

	local szName, _, _, _, nSeries = GetOnePartnerBaseInfo(pPartner.nTemplateId);
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem then
		return false, "无效道具";
	end

	if pItem.szClass ~= "PartnerSkillBook" then
		return false, "非法道具";
	end

	local nSkillBookId =  KItem.GetItemExtParam(pItem.dwTemplateId, 1);
	local tbSkillSetting = self:GetSkillInfo(nSkillBookId);
	if not tbSkillSetting then
		return false, "异常道具";
	end

	if tbSkillSetting.nSeries > 0 and nSeries ~= tbSkillSetting.nSeries then
		return false, string.format("%s与此书五行不符！", szName);
	end

	local bCanUse = false;
	local nPos = 0;
	local tbReplaceInfo = {};
	local tbSkillInfo = pPartner.GetNormalSkillInfo();

	local tbOtherParam = {};
	tbOtherParam.szName = szName;
	tbOtherParam.nTemplateId = pPartner.nTemplateId;
	tbOtherParam.tbSkillInfo = tbSkillInfo;
	tbOtherParam.nSkillId = tbSkillSetting.nSkillId;
	tbOtherParam.pItem = pItem;

	for i = 1, self.MAX_PARTNER_SKILL_COUNT do
		local nCurSkillId = tbSkillInfo[i].nSkillId;
		if nCurSkillId > 0 then
			local tbSSetting = self:GetSkillInfoBySkillId(nCurSkillId);
			if not tbSSetting then
				return false, "异常配置";
			end

			if tbSSetting.nType == tbSkillSetting.nType then
				if tbSSetting.nLevel >= tbSkillSetting.nLevel then
					return false, tbSSetting.nLevel == tbSkillSetting.nLevel and "已经拥有相同的技能了" or "已经拥有同类高阶的技能了";
				else
					return true, "", tbOtherParam, i, nil, tbSkillSetting.tbSkillValue[1];
				end
			elseif tbSSetting.nQuality <= tbSkillSetting.nQuality then
				bCanUse = true;
				tbReplaceInfo[i] = true;
			end
		else
			bCanUse = true;
			if nPos <= 0 then
				nPos = i;
			end
		end
	end

	if not bCanUse then
		return false, "此技能书不可用";
	end

	return true, "", tbOtherParam, nPos, tbReplaceInfo, tbSkillSetting.tbSkillValue[1];
end

function Partner:CheckCanGradeLevelup(pPlayer, nPartnerId)
	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner then
		return false, "无效同伴";
	end

	local nGradeLevel = pPartner.GetGradeLevel() + 1;
	local nPLevel = pPartner.nLevel;

	if nGradeLevel >= #self.tbGradeLevelProtentialLimit then
		return false, "此同伴已突破至极限";
	end

	local tbNextInfo = self.tbGradeLevelProtentialLimit[#self.tbGradeLevelProtentialLimit - nGradeLevel];
	if nPLevel < tbNextInfo[1] then
		return false, "当前无需突破";
	end

	return true, "", pPartner, nGradeLevel;
end

function Partner:CheckCanUseProtentialItem(pPlayer, nPartnerId, nProtentialType)
	local szProtentialType = self.tbAllProtentialType[nProtentialType];
	if not szProtentialType then
		return false, "请选择要提升的资质";
	end

	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner then
		return false, "目标同伴不存在";
	end

	local szName, nQualityLevel, _, nGrowthType, nSeries = GetOnePartnerBaseInfo(pPartner.nTemplateId);

	local tbGrowth = self.tbPartnerGrowthInfo[nGrowthType] or {};
	local nType = tbGrowth[szProtentialType];
	if not nType then
		return false, "无效资质类型";
	end

	local nProtential = pPartner.GetProtential(nProtentialType);
	local nPValue = math.floor(nProtential / self.tbProtentialToValue[nQualityLevel]);
	local nLimitProtential, bMax = self:GetLimitProtentialValue(nQualityLevel, nGrowthType, nProtentialType, pPartner.GetLimitProtential(nProtentialType), pPartner.GetGradeLevel() + 1, self:GetPartnerAwareness(pPlayer, pPartner.nTemplateId));
	if nPValue >= nLimitProtential then
		if bMax then
			return false, string.format("%s潜能已达上限", self.tbProtentialName[nProtentialType]);
		else
			return false, string.format("%s已达当前上限，突破后才可提升", self.tbProtentialName[nProtentialType]);
		end
	end

	local nCount, tbItem = pPlayer.GetItemCountInAllPos(self.nPartnerProtentialItem);
	if nCount <= 0 or not tbItem[1] then
		return false, "资质丹不足";
	end

	return true, "", nType, nProtential, tbItem[1], pPartner, nQualityLevel;
end

function Partner:GetItemValue(nItemTemplateId)
	self.tbCacheItemValue = self.tbCacheItemValue or {};
	if not self.tbCacheItemValue[nItemTemplateId] then
		local tbBasePro = KItem.GetItemBaseProp(nItemTemplateId) or {};
		self.tbCacheItemValue[nItemTemplateId] = tbBasePro.nValue;
	end

	return self.tbCacheItemValue[nItemTemplateId];
end

function Partner:RandomProtentialItemValue()
	local nTimes = 0.5;
	local nRandom = MathRandom(self.tbProtentialItemRandomInfo.nTotalRate);
	for _, tbInfo in ipairs(self.tbProtentialItemRandomInfo) do
		if nRandom <= tbInfo[2] then
			nTimes = tbInfo[1];
			break;
		end
	end

	local nProtentialItemValue = self:GetItemValue(self.nPartnerProtentialItem);
	return nProtentialItemValue * nTimes, nProtentialItemValue;
end

function Partner:CheckReinitPartner(pPlayer, nPartnerId)
	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner then
		return false, "无此同伴";
	end

	local tbPosInfo = pPlayer.GetPartnerPosInfo();
	for i = 1, 4 do
		if tbPosInfo[i] == nPartnerId then
			return false, "已上阵同伴不能进行洗髓";
		end
	end

	local szName, nQualityLevel, _, nGrowthType = GetOnePartnerBaseInfo(pPartner.nTemplateId);
	local nCost = self.ServeranceCost[nQualityLevel];
	if not nCost then
		return false, "配置错误";
	end

	local nCount = pPlayer.GetItemCountInAllPos(self.nSeveranceItemId);
	local nDiscountCount, bDiscount = Item:GetClass("SeveranceDiscount"):Discount(pPlayer, nCost, nQualityLevel)
	if not nCount or nCount < nDiscountCount then
		return false, "洗髓丹不足";
	end

	local nProtentialValue = pPartner.GetUseProtentialItemValue();
	local nProtentialItemCount = self:GetRandomCount(nProtentialValue, self.nPartnerProtentialItem, self.tbReinitRate.Protential);
	if not nProtentialItemCount then
		return false, "此同伴不能洗髓";
	end

	local nSkillValue = pPartner.GetSkillValue(self.INT_VALUE_USE_SKILL_BOOK);
	local nSkillItemCount = self:GetRandomCount(nSkillValue, self.nSeveranceItemId, self.tbReinitRate.Skill);
	if not nSkillItemCount then
		return false, "此同伴不能洗髓";
	end

	local tbAward;
	if nProtentialItemCount > 0 then
		tbAward = tbAward or {};
		table.insert(tbAward, {"item", self.nPartnerProtentialItem, nProtentialItemCount});
	end

	if nSkillItemCount > 0 then
		tbAward = tbAward or {};
		table.insert(tbAward, {"item", self.nSeveranceItemId, nSkillItemCount});
	end

	return true, "", pPartner, nDiscountCount, tbAward, nQualityLevel, nProtentialValue, bDiscount;
end

function Partner:GetTotalBaseExp(nQualityLevel, nLevel, nExp)
	local nBaseExp = GetPartnerBaseExp(nQualityLevel, nLevel);
	nExp = nExp / nBaseExp;
	for i = 1, nLevel - 1 do
		nExp = nExp + (self:GetLevelupExp(nQualityLevel, i) / GetPartnerBaseExp(nQualityLevel, i));
	end

	return math.floor(nExp);
end

function Partner:GetLevelupExp(nQualityLevel, nCurLevel)
	local tbInfo = self.tbPartnerExp[nCurLevel];
	if not tbInfo then
		return;
	end
	if version_tx then
		return tbInfo[self.tbQualityLevelDes_Old[nQualityLevel] or "nil"];
	else
		return tbInfo[self.tbQualityLevelDes[nQualityLevel] or "nil"];
	end
end

function Partner:CheckPartnerId(nPartnerId)
	if self.tbAllPartnerInfo[nPartnerId] then
		return true;
	end

	return false;
end

function Partner:GetPartnerValueByTemplateId(nPartnerTemplateId)
	local tbPartnerInfo = self.tbAllPartnerInfo[nPartnerTemplateId] or {};
	return tbPartnerInfo.nValue or 0;
end

function Partner:GetGrowthTypeByTemplateId(nPartnerTemplateId)
	local tbPartnerInfo = self.tbAllPartnerInfo[nPartnerTemplateId] or {};
	return tbPartnerInfo.szGrowthType == "" and "精武" or tbPartnerInfo.szGrowthType;
end

function Partner:GetExpItemExp(pPlayer, nItemTemplateId, nQualityLevel, nLevel)
	local nExp = Item:GetClass("PartnerExpItem"):GetExpInfo(0, nItemTemplateId, pPlayer);
	local nBaseExp = GetPartnerBaseExp(nQualityLevel, nLevel);
	return math.floor(nExp * nBaseExp);
end

function Partner:CheckCanDecomposePartner(pPlayer, tbPartnerList)
	local szLogInfo = "";
	local bHasLimitPartner = false;
	local nProtentialItemCount, nSkillItemCount, nExpItemCount, nSubExpItemCount, nUseItemProtentialValue = 0, 0, 0, 0, 0;
	local tbWeaponInfo = {};
	for nPartnerId in pairs(tbPartnerList) do
		local pPartner = pPlayer.GetPartnerObj(nPartnerId);
		if not pPartner then
			return false, "未发现要分解的同伴！";
		end

		if self.tbAllPartnerInfo[pPartner.nTemplateId].nValueLimit == 1 then
			bHasLimitPartner = true;
		end

		local nP, nS, nE, nWeaponItemId, nSE, nUP = self:GetDecomposeItem(pPlayer, pPartner);
		if not nP then
			return false, string.format("%s 不能遣散", pPartner.szName);
		end

		szLogInfo = string.format("%s%s|%s;", szLogInfo, pPartner.nTemplateId, pPartner.szName);
		nProtentialItemCount = nProtentialItemCount + nP;
		nSkillItemCount = nSkillItemCount + nS;
		nExpItemCount = nExpItemCount + nE;
		nSubExpItemCount = nSubExpItemCount + nSE;
		nUseItemProtentialValue = nUseItemProtentialValue + nUP
		if nWeaponItemId and nWeaponItemId > 0 then
			tbWeaponInfo[nWeaponItemId] = tbWeaponInfo[nWeaponItemId] or 0;
			tbWeaponInfo[nWeaponItemId] = tbWeaponInfo[nWeaponItemId] + 1;
		end
	end

	local tbAward = {};
	if nProtentialItemCount > 0 then
		table.insert(tbAward, {"item", self.nPartnerProtentialItem, nProtentialItemCount});
	end

	if nSkillItemCount > 0 then
		table.insert(tbAward, {"item", self.nSeveranceItemId, nSkillItemCount});
	end

	if nExpItemCount > 0 then
		table.insert(tbAward, {"item", self.nPartnerExpItemId, nExpItemCount});
	end

	if nSubExpItemCount > 0 then
		table.insert(tbAward, {"item", self.nPartnerSubExpItemId, nSubExpItemCount});
	end

	for nWeaponItemId, nCount in pairs(tbWeaponInfo) do
		table.insert(tbAward, {"item", nWeaponItemId, nCount});
	end

	return true, "", tbAward, szLogInfo, nUseItemProtentialValue, bHasLimitPartner;
end

function Partner:GetRandomCount(nTotalValue, nItemTemplateId, tbRate, nFixValue, nSubItemTemplateId)
	if nTotalValue <= 0 then
		return 0, 0;
	end

	nFixValue = nFixValue or 0;
	local function fnRandomValue(nValue1, nValue2)
		return MathRandom(nValue1 * 100000, nValue2 * 100000) / 100000;
	end

	local function fnRandomCount(nTotal, nOneValue, nSubOneValue)
		local nCount = math.floor(nTotal / nOneValue);
		local nLastValue = nTotal % nOneValue;
		local nSubCount = 0;
		if nSubOneValue <= 0 then
			local nRate = nLastValue / nOneValue;
			local bRandom = MathRandom(1000) <= (nRate * 1000);
			nCount = nCount + (bRandom and 1 or 0);
		else
			nSubCount = math.floor(nLastValue / nSubOneValue);
			local nRate = (nLastValue % nSubOneValue) / nSubOneValue;
			local bRandom = MathRandom(1000) <= (nRate * 1000);
			nSubCount = nSubCount + (bRandom and 1 or 0);
		end

		return nCount, nSubCount;
	end

	local nTimes = fnRandomValue(unpack(tbRate));
	local nItemValue = self:GetItemValue(nItemTemplateId);
	if not nItemValue or nItemValue <= 0 then
		return;
	end

	local nSubItemValue = 0;
	if nSubItemTemplateId and nSubItemTemplateId > 0 then
		nSubItemValue = self:GetItemValue(nSubItemTemplateId) or 0;
	end

	return fnRandomCount(nTotalValue * nTimes + nFixValue, nItemValue, nSubItemValue);
end

function Partner:GetDecomposeItem(pPlayer, pPartner)
	local bLimit = self.tbAllPartnerInfo[pPartner.nTemplateId].nValueLimit == 1;
	local _, nQualityLevel, _, nGrowthType, nSeries = GetOnePartnerBaseInfo(pPartner.nTemplateId);

	local tbProtentialInfo = {}
	for nType, szName in pairs(self.tbAllProtentialType) do
		tbProtentialInfo[szName] = pPartner.GetProtential(nType);
	end

	local nUseItemProtentialValue = pPartner.GetUseProtentialItemValue();
	local nProtentialValue = math.max(self:GetProtentialValue(nGrowthType, tbProtentialInfo) - nUseItemProtentialValue, 1);
	if bLimit then
		nProtentialValue = 1;
	end
	local nProtentialItemCount = self:GetRandomCount(nProtentialValue, self.nPartnerProtentialItem, self.tbDecomposeRate.Protential, nUseItemProtentialValue);
	if not nProtentialItemCount then
		return;
	end

	local nSkillValue = pPartner.GetSkillValue(self.INT_VALUE_USE_SKILL_BOOK);
	if nSkillValue > 0 then
		nSkillValue = nSkillValue + pPartner.GetSkillValue(self.INT_VALUE_SKILL_ORG_VALUE);
	else
		local tbSkillInfo = {};
		for i = 1, 5 do
			local nSkillId, nSkillLevel = pPartner.GetSkillInfo(i);
			if nSkillId > 0 then
				tbSkillInfo[nSkillId] = math.max(nSkillLevel, 1);
			end
		end
		nSkillValue = self:GetSkillValue(tbSkillInfo);
	end

	if bLimit then
		nSkillValue = pPartner.GetSkillValue(self.INT_VALUE_USE_SKILL_BOOK) + 1;
	end

	local nSkillItemCount = self:GetRandomCount(nSkillValue, self.nSeveranceItemId, self.tbDecomposeRate.Skill);
	if not nSkillItemCount then
		return;
	end

	local nLevel, nExp = pPartner.GetLevelInfo();
	local nBaseExp = self:GetTotalBaseExp(nQualityLevel, nLevel, nExp);
	local nExpItemCount, nSubExpItemCount = self:GetRandomCount(nBaseExp / self.nValueToBaseExp, self.nPartnerExpItemId, self.tbDecomposeRate.Exp, 0, self.nPartnerSubExpItemId)

	local nWeaponItemId = self.tbPartner2WeaponItem[pPartner.nTemplateId];
	if pPartner.nWeaponState ~= 1 then
		nWeaponItemId = nil;
	end

	return nProtentialItemCount, nSkillItemCount, nExpItemCount, nWeaponItemId, nSubExpItemCount, nUseItemProtentialValue;
end

function Partner:GetValueBase(tbAttribInfo, szMagicValueName)
	if tbAttribInfo[szMagicValueName] then
		return tbAttribInfo[szMagicValueName];
	end

	return (tbAttribInfo.tbBaseAttrib[szMagicValueName] or {tbValue = {0}}).tbValue[1];
end

function Partner:GetJingMaiValueBase(tbAttribInfo, ...)
	local tbValueName = {...};
	local nValue = 0;
	for _, szType in pairs(tbValueName) do
		if tbAttribInfo[szType] then
			nValue = nValue + tbAttribInfo[szType];
		else
			nValue = nValue + (tbAttribInfo.tbBaseAttrib[szType] or {tbValue = {0}}).tbValue[1];
		end
	end

	return nValue;
end

function Partner:GetBaseAttack(tbAttribInfo)
	local nDmgPhysics = tbAttribInfo.nDmgPhysics or 0;
	local nDmgPhysicsP = (tbAttribInfo.tbBaseAttrib["physics_potentialdamage_p"] or {tbValue = {0}}).tbValue[1];
	local nBaseDmg = (tbAttribInfo.tbBaseAttrib["basic_damage_v"] or {tbValue = {0}}).tbValue[1];
	local nPhysicalDmg = (tbAttribInfo.tbBaseAttrib["physical_damage_v"] or {tbValue = {0}}).tbValue[1];

	return nDmgPhysics * (100 + nDmgPhysicsP) / 100 + nBaseDmg + nPhysicalDmg;
end

function Partner:GetValueByBaseValue(tbAttribInfo, szType, szMagicValueName, szMagicPresentName)
	local nBaseValue = tbAttribInfo[szType] or 0;
	local nMaxValueP = (tbAttribInfo.tbBaseAttrib[szMagicPresentName] or {tbValue = {0}}).tbValue[1];
	local nMaxValueV = (tbAttribInfo.tbBaseAttrib[szMagicValueName] or {tbValue = {0}}).tbValue[1];

	return math.floor(nMaxValueV + (nBaseValue * (100 + nMaxValueP) / 100));
end

function Partner:GetDeadlyStrike(tbAttribInfo)
	local nDeadlyStrike = tbAttribInfo.nDeadlyStrike or 0;
	local nDeadlyStrikeV = (tbAttribInfo.tbBaseAttrib["deadlystrike_v"] or {tbValue = {0}}).tbValue[1];
	local nDeadlyStrikeP = (tbAttribInfo.tbBaseAttrib["deadlystrike_p"] or {tbValue = {0}}).tbValue[1];

	return nDeadlyStrike + nDeadlyStrikeV + (tbAttribInfo.nEnergy or 0) * nDeadlyStrikeP / 200;  -- 别问我为啥是200，C里面直接这么写的
end

function Partner:GetDeadlyStrikeDamage(tbAttribInfo)
	local nDeadlyStrikeDamageP = (tbAttribInfo.tbBaseAttrib["deadlystrike_damage_p"] or {tbValue = {0}}).tbValue[1];

	return nDeadlyStrikeDamageP, string.format("%s%%", nDeadlyStrikeDamageP + 180);  -- 别问我为啥是 180，晓飞直接这么写的
end

function Partner:GetResis(tbAttribInfo, szType)
	local nSeries = (tbAttribInfo.tbBaseAttrib[szType .. "_resist_v"] or {tbValue = {0}}).tbValue[1];
	local nSeriesP = (tbAttribInfo.tbBaseAttrib[szType .. "_resist_p"] or {tbValue = {0}}).tbValue[1];
	local nAllSeriesP = (tbAttribInfo.tbBaseAttrib["all_series_resist_p"] or {tbValue = {0}}).tbValue[1];
	local nAllSeriesV = (tbAttribInfo.tbBaseAttrib["all_series_resist_v"] or {tbValue = {0}}).tbValue[1];

	return math.floor(nSeries * (nSeriesP + 100) / 100 + (tbAttribInfo.nAllSeries or 0) * (100 + nAllSeriesP) / 100 + nAllSeriesV);
end

function Partner:GetValueWithAllValue(tbAttribInfo, szType, szAllValue)
	local nValue = (tbAttribInfo.tbBaseAttrib[szType] or {tbValue = {0}}).tbValue[1];
	local nAllValue = (tbAttribInfo.tbBaseAttrib[szAllValue] or {tbValue = {0}}).tbValue[1];
	return nValue + nAllValue;
end

function Partner:GetStarValue(nFightPower)
	local nCurLevel = 1;
	for nLevel, nValue in ipairs(Partner.tbStarDef) do
		if nFightPower >= nValue then
			nCurLevel = nLevel;
		else
			break;
		end
	end

	return nCurLevel / 2, nCurLevel;
end

function Partner:GetPartnerSkillLevelByFightPower(nFightPower)
	local _, nStarLevel = Partner:GetStarValue(nFightPower);
	local nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;
	return nSkillLevel
end

function Partner:GetFightPowerShowInfo(nFightPower)
	local nCurLevel = 1;
	for nLevel, nValue in ipairs(Partner.tbStarDef) do
		if nFightPower >= nValue then
			nCurLevel = nLevel;
		else
			break;
		end
	end

	return self.tbFightPowerLevelToSpr[nCurLevel] or self.tbFightPowerLevelToSpr[1];
end

function Partner:GetAbsBaseValueWhithP(tbAttribInfo, szMagicValueName)
	local nValue = math.abs(Partner:GetValueBase(tbAttribInfo, szMagicValueName))

	return nValue, string.format("%s%%", nValue);
end

function Partner:GetBaseValueWhithP(tbAttribInfo, ...)
	local nValue = self:GetJingMaiValueBase(tbAttribInfo, ...);
	return nValue, string.format("%s%%", nValue);
end

function Partner:GetIgnoreResis(tbAttribInfo, ...)
	local tbValueName = {...};
	local nValue = 0;
	for _, szType in pairs(tbValueName) do
		local nSeries = (tbAttribInfo.tbBaseAttrib[szType] or {tbValue = {0, 0}}).tbValue[2];
		nValue = nValue + nSeries;
	end
	return nValue;
end

Partner.tbAllAttribDef =
{
	{"生命",		Partner.GetValueByBaseValue, "nLifeMax", "lifemax_v", "lifemax_p"},
	{"攻击力",		Partner.GetBaseAttack},
	{"体质",		"nVitality", "vitality_v"},
	{"敏捷",		"nDexterity", "dexterity_v"},
	{"力量",		"nStrength", "strength_v"},
	{"灵巧",		"nEnergy", "energy_v"},
	{"体质成长",	"Protential", "Vitality"},
	{"敏捷成长",	"Protential", "Dexterity"},
	{"力量成长",	"Protential", "Strength"},
	{"灵巧成长",	"Protential", "Energy"},
	{"生命回复",	"recover_life_v"},
	{"金系抗性",	Partner.GetResis, "metal"},		-- metal_resist_v all_series_resist_v
	{"木系抗性",	Partner.GetResis, "wood"},		-- wood_resist_v
	{"水系抗性",	Partner.GetResis, "water"},		-- water_resist_v
	{"火系抗性",	Partner.GetResis, "fire"},		-- fire_resist_v
	{"土系抗性",	Partner.GetResis, "earth"},		-- earth_resist_v
	{"命中",		Partner.GetValueByBaseValue, "nAttackRate", "attackrate_v", "attackrate_p"},
	{"闪避",		Partner.GetValueByBaseValue, "nDefense", "defense_v", "defense_p"},
	{"忽略闪避",	"ignore_defense_v"},
	{"会心几率",	Partner.GetDeadlyStrike},
	{"会心伤害",	Partner.GetDeadlyStrikeDamage},
	{"抗会心几率",	"weaken_deadlystrike_v"},
	{"会心免伤",	Partner.GetBaseValueWhithP,	"weaken_deadlystrike_damage_p"},
	{"受伤几率",	Partner.GetValueWithAllValue, "state_hurt_attackrate", "add_seriesstate_rate_v"},
	{"眩晕几率",	Partner.GetValueWithAllValue, "state_stun_attackrate", "add_seriesstate_rate_v"},
	{"迟缓几率",	Partner.GetValueWithAllValue, "state_slowall_attackrate", "add_seriesstate_rate_v"},
	{"致缠几率",	Partner.GetValueWithAllValue, "state_zhican_attackrate", "add_seriesstate_rate_v"},
	{"麻痹几率",	Partner.GetValueWithAllValue, "state_palsy_attackrate", "add_seriesstate_rate_v"},
	{"抗受伤几率",	Partner.GetValueWithAllValue, "state_hurt_resistrate", "resist_allseriesstate_rate_v"},
	{"抗眩晕几率",	Partner.GetValueWithAllValue, "state_stun_resistrate", "resist_allseriesstate_rate_v"},
	{"抗迟缓几率",	Partner.GetValueWithAllValue, "state_slowall_resistrate", "resist_allseriesstate_rate_v"},
	{"抗致缠几率",	Partner.GetValueWithAllValue, "state_zhican_resistrate", "resist_allseriesstate_rate_v"},
	{"抗麻痹几率",	Partner.GetValueWithAllValue, "state_palsy_resistrate", "resist_allseriesstate_rate_v"},
	{"抗受伤时间",	Partner.GetValueWithAllValue, "state_hurt_resisttime", "resist_allseriesstate_time_v"},
	{"抗眩晕时间",	Partner.GetValueWithAllValue, "state_stun_resisttime", "resist_allseriesstate_time_v"},
	{"抗迟缓时间",	Partner.GetValueWithAllValue, "state_slowall_resisttime", "resist_allseriesstate_time_v"},
	{"抗致缠时间",	Partner.GetValueWithAllValue, "state_zhican_resisttime", "resist_allseriesstate_time_v"},
	{"抗麻痹时间",	Partner.GetValueWithAllValue, "state_palsy_resisttime", "resist_allseriesstate_time_v"},
}

Partner.tbJingMaiExtAttribDef =
{
	{"忽略金系抗性", Partner.GetIgnoreResis, "ignore_metal_resist_v", "ignore_all_resist_v"},
	{"忽略木系抗性", Partner.GetIgnoreResis, "ignore_wood_resist_v", "ignore_all_resist_v"},
	{"忽略水系抗性", Partner.GetIgnoreResis, "ignore_water_resist_v", "ignore_all_resist_v"},
	{"忽略火系抗性", Partner.GetIgnoreResis, "ignore_fire_resist_v", "ignore_all_resist_v"},
	{"忽略土系抗性", Partner.GetIgnoreResis, "ignore_earth_resist_v", "ignore_all_resist_v"},
	{"抵挡角色伤害", Partner.GetAbsBaseValueWhithP, "playerdmg_npc_p"},
	{"对怪物伤害", Partner.GetBaseValueWhithP, "damage4npc_p"},
	{"对玩家伤害", Partner.GetBaseValueWhithP, "damage4player_p"},
	{"基础生命", Partner.GetBaseValueWhithP, "lifemax_p"},
};


function Partner:GetAllPartnerBaseInfo()
	if not self.tbAllPartnerBaseInfo then
		self.tbAllPartnerBaseInfo = GetAllPartnerBaseInfo();
	end

	return self.tbAllPartnerBaseInfo;
end

function Partner:GetMaxUseItemCount(pPlayer, nPartnerId, nItemTemplateId)
	local tbPartner = pPlayer.GetPartnerInfo(nPartnerId);
	if not tbPartner then
		return 0;
	end

	local nUseCount = 0;
	local nCurExp = tbPartner.nExp;
	local nLevelUpExp = self:GetLevelupExp(tbPartner.nQualityLevel, tbPartner.nLevel);
	local nMaxLevel = math.min(pPlayer.nLevel - 1, #self.tbPartnerExp);
	for i = tbPartner.nLevel, nMaxLevel do
		nLevelUpExp = self:GetLevelupExp(tbPartner.nQualityLevel, i);

		local nItemExp = self:GetExpItemExp(pPlayer, nItemTemplateId, tbPartner.nQualityLevel, i);
		local nCurUseCount = math.max(math.ceil((nLevelUpExp - nCurExp) / nItemExp), 0);

		if nUseCount == 0 and nCurUseCount == 0 then
			nCurUseCount = 1;
		end

		nUseCount = nUseCount + nCurUseCount;
		nCurExp = nCurExp + nCurUseCount * nItemExp - nLevelUpExp;
	end

	return nUseCount;
end

function Partner:GetPartnerMaxExp(pPlayer, nPartnerId)
	local tbPartner = pPlayer.GetPartnerInfo(nPartnerId);
	if not tbPartner then
		return 0;
	end

	local nTotalExp = 0;
	for nLevel = tbPartner.nLevel, pPlayer.nLevel - 1 do
		nTotalExp = nTotalExp + self:GetLevelupExp(tbPartner.nQualityLevel, nLevel);
	end

	nTotalExp = nTotalExp - tbPartner.nExp;
	if pPlayer.nLevel > tbPartner.nLevel then
		nTotalExp = math.max(nTotalExp, 1);
	end
	return math.max(nTotalExp, 0);
end

function Partner:GetPartnerDesc(nPartnerId)
	local tbPartnerInfo = self.tbAllPartnerInfo[nPartnerId] or {};
	return tbPartnerInfo.szInfo or ""
end

function Partner:GetSortedPartnerList(pPlayer, fnCmp, bOnlyPos)
	local tbPartnerList = {};
	local tbAllPartner = pPlayer.GetAllPartner();
	local tbPartnerPos = pPlayer.GetPartnerPosInfo();

	for nPos, nPartnerId in pairs(tbPartnerPos) do
		if nPartnerId > 0 and tbAllPartner[nPartnerId] then
			tbAllPartner[nPartnerId].nPos = nPos;
		end
	end

	for nPartnerId, tbInfo in pairs(tbAllPartner) do
		if not bOnlyPos or tbInfo.nPos then
			table.insert(tbPartnerList, nPartnerId);
		else
			tbAllPartner[nPartnerId] = nil
		end
	end

	local function fnDefaultCmp(nP1, nP2)
		local tbPartner1 = tbAllPartner[nP1] or {nQualityLevel = 6, nFightPower = 0};
		local tbPartner2 = tbAllPartner[nP2] or {nQualityLevel = 6, nFightPower = 0};

		if tbPartner1.nPos or tbPartner2.nPos then
			return (tbPartner1.nPos or 99) < (tbPartner2.nPos or 99);
		end

		if tbPartner1.nQualityLevel ~= tbPartner2.nQualityLevel then
			return tbPartner1.nQualityLevel < tbPartner2.nQualityLevel;
		end

		if tbPartner1.nFightPower ~= tbPartner2.nFightPower then
			return tbPartner1.nFightPower > tbPartner2.nFightPower;
		end
		return nP1 > nP2
	end

	table.sort(tbPartnerList, fnCmp or fnDefaultCmp);
	return tbPartnerList, tbAllPartner;
end

function Partner:GetPartnerAllSkillInfo(pPlayer, nPartnerId)
	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner then
		return;
	end

	local tbDefaultSkill = GetPartnerDefaultSkill(pPartner.nTemplateId);
	local tbSkillInfo = pPartner.GetNormalSkillInfo();
	local tbAllSkillInfo = {};
	tbAllSkillInfo.tbNormalSkill = tbSkillInfo;
	tbAllSkillInfo.tbDefaultSkill = {};
	for nIdx, nSkillId in pairs(tbDefaultSkill) do
		tbAllSkillInfo.tbDefaultSkill[nIdx] = {};
		tbAllSkillInfo.tbDefaultSkill[nIdx].nSkillId = nSkillId;
		tbAllSkillInfo.tbDefaultSkill[nIdx].nSkillLevel = 1;
	end
	return tbAllSkillInfo, pPartner;
end

function Partner:GetPartnerProtectSkillInfo(pPlayer)
	local tbPosInfo = pPlayer.GetPartnerPosInfo();
	local tbResult = {};

	local tbSkillLevelInfo = {};
	for nPos, nPartnerId in pairs(tbPosInfo) do
		local tbPartnerInfo = pPlayer.GetPartnerInfo(nPartnerId);
		if tbPartnerInfo then
			tbPartnerInfo.nAwareness = Partner:GetPartnerAwareness(pPlayer, tbPartnerInfo.nTemplateId);

			local tbDefaultSkill = GetPartnerDefaultSkill(tbPartnerInfo.nTemplateId);
			local _, nStarLevel = Partner:GetStarValue(tbPartnerInfo.nFightPower);
			local nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;
			local nMaxFightPower = Partner:GetMaxFightPower(tbPartnerInfo);
			local _, nMaxStar = Partner:GetStarValue(nMaxFightPower);
			local nMaxSkillLevel = math.max(Partner.tbFightPowerToSkillLevel[nMaxStar] or 1, nSkillLevel);

			local nSkillId = tbDefaultSkill[2];
			tbSkillLevelInfo[nSkillId] = math.max(nSkillLevel, tbSkillLevelInfo[nSkillId] or 0);
			table.insert(tbResult, {
				nSkillId = nSkillId;
				nSkillLevel = nSkillLevel;
				nMaxSkillLevel = nMaxSkillLevel;
				nPos = nPos;
			});
		end
	end

	for _, tbInfo in pairs(tbResult) do
		tbInfo.bActive = false;
		if tbSkillLevelInfo[tbInfo.nSkillId] and tbInfo.nSkillLevel >= tbSkillLevelInfo[tbInfo.nSkillId] then
			tbSkillLevelInfo[tbInfo.nSkillId] = nil;
			tbInfo.bActive = true;
		end
	end

	return tbResult;
end

function Partner:CloseOtherUi()
	Ui:CloseWindow("PartnerSkillTips");
	Ui:CloseWindow("PartnerProtential");
	Ui:CloseWindow("PartnerExpUse");
end


function Partner:GetPartnerCountByQuality(pPlayer,nQualityLevel)
	if not nQualityLevel then
		return 0
	end

	local nHave = 0
	local tbAllPartner = pPlayer.GetAllPartner();
	for _,tbInfo in pairs(tbAllPartner) do
		if tbInfo.nQualityLevel == nQualityLevel then
			nHave = nHave + 1
		end
	end

	return nHave
end

function Partner:OnCreatePartnerNpc(pPartner, pNpc, bByScript)
	local nSkillLevel = Partner:GetPartnerSkillLevelByFightPower(pPartner.nFightPower)
	Lib:CallBack({JingMai.OnCreatePartnerNpc, JingMai, pNpc.nId});
--	Lib:CallBack({PartnerCard.OnCreatePartnerNpc, PartnerCard, pNpc.nId, pPartner.nTemplateId, nSkillLevel});
	if MODULE_GAMECLIENT and not bByScript then
		return;
	end

	if pPartner.GetAwareness() == 1 then
		local tbAwareness = Partner:GetAwareness(pPartner.nTemplateId);
		if tbAwareness and tbAwareness.nAwarenessSkillId and tbAwareness.nAwarenessSkillId > 0 then
			pNpc.AddSkillState(tbAwareness.nAwarenessSkillId, 1, 0, 365 * 24 * 3600);
			if not string.find(pNpc.szName, "觉醒") then
				pNpc.SetName(string.format("%s·觉醒", pNpc.szName));
			end
		end
	end
end

function Partner:GetAttribShowInfo(tbPAttribInfo, tbPartnerInfo)
	local tbProtentialList = {
		"Vitality",
		"Dexterity",
		"Strength",
		"Energy",
	};
	local tbInfo = {};
	for _, szType in ipairs(tbProtentialList) do
		local tbValue = {};
		local nValue = tbPAttribInfo["n" .. szType];
		local nLimitLevel = tbPartnerInfo["nLimitProtential" .. szType];
		local nLimitProtential, bIsMaxGrade = self:GetLimitProtentialValue(tbPartnerInfo.nQualityLevel,
														tbPartnerInfo.nGrowthType,
														Partner.tbAllProtentialTypeStr2Id[szType],
														nLimitLevel,
														tbPartnerInfo.nGradeLevel + 1,
														tbPartnerInfo.nAwareness);

		local nMaxValue = tbPAttribInfo["n" .. szType] + math.max(nLimitProtential - math.floor(tbPartnerInfo["nProtential" .. szType] / Partner.tbProtentialToValue[tbPartnerInfo.nQualityLevel]), 0);
		nValue = bIsMaxGrade and math.min(nValue, nMaxValue) or nValue;
		tbValue.tbValue = {nValue, nMaxValue};
		tbValue.nLimitLevel = nLimitLevel;
		tbValue.nValue =  nValue / nMaxValue;
		table.insert(tbInfo, tbValue);
	end

	return tbInfo;
end