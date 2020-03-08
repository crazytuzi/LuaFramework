
Partner.AWARENESS_SAVE_GROUP = 127;
Partner.AWARENESS_SAVE_VERSION = 1;
Partner.AWARENESS_SAVE_START_IDX = 2;
Partner.AWARENESS_SAVE_END_IDX = 10;

Partner.MAX_AWARENESS_ID = (Partner.AWARENESS_SAVE_END_IDX - Partner.AWARENESS_SAVE_START_IDX + 1) * 32;

function Partner:LoadAwareness()
	local tbFile = LoadTabFile("Setting/Partner/PartnerAwarenessCost.tab", "dddddddddd", nil,
						{"nPartnerId", "nUiEffectId", "nAwarenessSkillId", "nNeedSeveranceItem", "bNeedWeapon", "nCost1", "nCost2", "nCost3", "nCost4", "nCost5"});

	self.tbAwareness = {};
	for _, tbInfo in pairs(tbFile) do
		assert(not self.tbAwareness[tbInfo.nPartnerId]);
		assert(tbInfo.nUiEffectId > 0);
		assert(tbInfo.nAwarenessSkillId > 0);
		assert(tbInfo.nPartnerId > 0);
		assert(tbInfo.nNeedSeveranceItem > 0);
		assert(tbInfo.nCost1 > 0);
		assert(tbInfo.nCost2 > 0);
		assert(tbInfo.nCost3 > 0);
		assert(tbInfo.nCost4 > 0);
		assert(tbInfo.nCost5 > 0);

		self.tbAwareness[tbInfo.nPartnerId] = {
			nUiEffectId				= tbInfo.nUiEffectId;
			nAwarenessSkillId		= tbInfo.nAwarenessSkillId;
			nNeedSeveranceItem		= tbInfo.nNeedSeveranceItem;
			bNeedWeapon 			= (tbInfo.bNeedWeapon == 1 and true or false);
			nCost1					= tbInfo.nCost1;
			nCost2					= tbInfo.nCost2;
			nCost3					= tbInfo.nCost3;
			nCost4					= tbInfo.nCost4;
			nCost5					= tbInfo.nCost5;
		};
	end

	self.tbAwarenessAdd = {};
	tbFile = LoadTabFile("Setting/Partner/PartnerAwarenessAdd.tab", "ddddd", nil, {"nQualityLevel", "nAddProtential", "nAddProtentialByLevel", "nAddProtentialLimit", "nAddValue"});
	for _, tbInfo in pairs(tbFile) do
		assert(not self.tbAwarenessAdd[tbInfo.nQualityLevel]);
		assert(tbInfo.nQualityLevel > 0 and tbInfo.nQualityLevel <= 5);
		assert(tbInfo.nAddProtential > 0);
		assert(tbInfo.nAddProtentialByLevel > 0);
		assert(tbInfo.nAddProtentialLimit > 0);

		self.tbAwarenessAdd[tbInfo.nQualityLevel] = {
			nAddProtential = tbInfo.nAddProtential;
			nAddProtentialLimit = tbInfo.nAddProtentialLimit;
			nAddProtentialByLevel = tbInfo.nAddProtentialByLevel;
			nAddValue = tbInfo.nAddValue;
		};
	end
end
Partner:LoadAwareness();


function Partner:GetAwareness(nPartnerTemplateId)
	return self.tbAwareness[nPartnerTemplateId];
end

function Partner:GetAwarenessAddInfo(nQualityLevel)
	local tbAddInfo = self.tbAwarenessAdd[nQualityLevel] or {};
	return tbAddInfo.nAddProtential, tbAddInfo.nAddProtentialLimit, tbAddInfo.nAddProtentialByLevel, tbAddInfo.nAddValue;
end

function Partner:GetAwAddProtentialLimit(nQualityLevel, nGrowthType, nProtentialType)
	local tbGrowth = self.tbPartnerGrowthInfo[nGrowthType];
	if not tbGrowth then
		Log("[Partner] GetAwAddProtentialLimit tbGrowth is nil !!");
		return;
	end

	local nType = tbGrowth[self.tbAllProtentialType[nProtentialType] or "nil"];
	if not nType then
		Log("[Partner] GetAwAddProtentialLimit nType is nil !!");
		return;
	end

	local nAddLimit = self.tbAwarenessAdd[nQualityLevel];
	return math.floor(nAddLimit * nType / 10);
end

function Partner:GetAwarenessSaveIdx(nPartnerTemplateId)
	return math.floor(nPartnerTemplateId / 32) + self.AWARENESS_SAVE_START_IDX, (nPartnerTemplateId + 31) % 32
end

function Partner:GetPartnerAwareness(pPlayer, nPartnerTemplateId)
	if nPartnerTemplateId <= 0 or nPartnerTemplateId >= self.MAX_AWARENESS_ID then
		Log("[Partner] GetPartnerAwareness ERR ?? nPartnerTemplateId >= self.MAX_AWARENESS_ID");
		return 0;
	end

	local nIdx, nBit = self:GetAwarenessSaveIdx(nPartnerTemplateId);
	local nValue = pPlayer.GetUserValue(self.AWARENESS_SAVE_GROUP, nIdx);
	return Lib:LoadBits(nValue, nBit, nBit);
end

function Partner:SetPartnerAwareness(pPlayer, nPartnerTemplateId)
	if nPartnerTemplateId <= 0 or nPartnerTemplateId >= self.MAX_AWARENESS_ID then
		Log("[Partner] SetPartnerAwareness ERR ?? nPartnerTemplateId >= self.MAX_AWARENESS_ID");
		return;
	end

	local nIdx, nBit = self:GetAwarenessSaveIdx(nPartnerTemplateId);
	local nValue = pPlayer.GetUserValue(self.AWARENESS_SAVE_GROUP, nIdx);
	nValue = Lib:SetBits(nValue, 1, nBit, nBit);
	pPlayer.SetUserValue(self.AWARENESS_SAVE_GROUP, nIdx, nValue);

	self:DoSetAwareness(nPartnerTemplateId, 1, pPlayer);
end

function Partner:DoSetAwareness(nPartnerTemplateId, nAwareness, pPlayer)
	if MODULE_GAMECLIENT then
		pPlayer = me;
	end

	local tbAllPartnerInfo = pPlayer.GetAllPartner();
	for nPartnerId, tbPartnerInfo in pairs(tbAllPartnerInfo or {}) do
		if tbPartnerInfo.nTemplateId == nPartnerTemplateId then
			local pPartner = pPlayer.GetPartnerObj(nPartnerId);
			pPartner.SetAwareness(nAwareness);
			pPartner.Update();
			if MODULE_GAMECLIENT then
				UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE, nPartnerId);
			end
		end
	end
end

function Partner:CheckCanAwareness(pPlayer, nPartnerId, tbUsePartnerInfo)
	if GetTimeFrameState(Partner.szOpenAwarenessTimeFrame) ~= 1 then
		return false, "功能暂未开放";
	end

	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner then
		return false, "不存在的同伴";
	end

	local tbNeedInfo = self.tbAwareness[pPartner.nTemplateId];
	if not tbNeedInfo then
		return false, "不可觉醒的同伴";
	end

	local nCount = pPlayer.GetItemCountInBags(self.nPartnerAwarenessCostItem);
	if nCount < tbNeedInfo.nNeedSeveranceItem then
		return false, "资质丹不足";
	end

	local tbPosInfo = pPlayer.GetPartnerPosInfo();
	if Lib:CountTB(tbUsePartnerInfo) ~= 5 then
		return false, "觉醒所需材料不足";
	end

	local nTotalExpItemCount = 0;
	local nTotalSubExpItemCount = 0;
	local nTotalSkillItemCount = 0;
	local nTotalProtentialItemCount = 0;
	local nTotalProtentialValue = 0;

	local tbConsumeItem = {};
	local tbUse = {};
	for i = 1, 5 do
		local nPId = tbUsePartnerInfo[i];
		if tbUse[nPId] then
			return false, "数据异常";
		end

		tbUse[nPId] = true;
		local pUPObj = pPlayer.GetPartnerObj(nPId or 0);
		if not pUPObj then
			return false, "觉醒所需同伴不存在";
		end

		for j = 1, 4 do
			if tbPosInfo[j] == nPId then
				return false, "已上阵同伴不能用来觉醒";
			end
		end

		if pUPObj.nTemplateId ~= tbNeedInfo["nCost" .. i] then
			return false, "觉醒所需同伴不符合";
		end

		if tbNeedInfo.bNeedWeapon and pUPObj.nWeaponState ~= 1 then
			local nWeaponItemId = self.tbPartner2WeaponItem[pUPObj.nTemplateId];
			if nWeaponItemId then
				local nCount = pPlayer.GetItemCountInBags(nWeaponItemId);
				if nCount <= 0 then
					return false, "所需同伴本命武器不足";
				end
				table.insert(tbConsumeItem, nWeaponItemId);
			end
		end

		local nProtentialValue = pUPObj.GetUseProtentialItemValue();
		nTotalProtentialValue = nTotalProtentialValue + nProtentialValue;

		local nProtentialItemCount = self:GetRandomCount(nProtentialValue, self.nPartnerProtentialItem, self.tbReinitRate.Protential);
		if not nProtentialItemCount then
			return false, "此同伴不能用来觉醒";
		end

		nTotalProtentialItemCount = nTotalProtentialItemCount + nProtentialItemCount;

		local nSkillValue = pUPObj.GetSkillValue(self.INT_VALUE_USE_SKILL_BOOK);
		local nSkillItemCount = self:GetRandomCount(nSkillValue, self.nSeveranceItemId, self.tbReinitRate.Skill);
		if not nSkillItemCount then
			return false, "此同伴不能洗髓";
		end

		nTotalSkillItemCount = nTotalSkillItemCount + nSkillItemCount;

		local _, nQualityLevel = GetOnePartnerBaseInfo(pUPObj.nTemplateId);
		local nLevel, nExp = pUPObj.GetLevelInfo();
		local nBaseExp = self:GetTotalBaseExp(nQualityLevel, nLevel, nExp);
		local nExpItemCount, nSubExpItemCount = self:GetRandomCount(nBaseExp / self.nValueToBaseExp, self.nPartnerExpItemId, self.tbDecomposeRate.Exp, 0, self.nPartnerSubExpItemId);
		nTotalExpItemCount = nTotalExpItemCount + nExpItemCount;
		nTotalSubExpItemCount = nTotalSubExpItemCount + nSubExpItemCount;
	end

	local tbAward;
	if nTotalProtentialItemCount > 0 then
		tbAward = tbAward or {};
		table.insert(tbAward, {"item", self.nPartnerProtentialItem, nTotalProtentialItemCount});
	end

	if nTotalSkillItemCount > 0 then
		tbAward = tbAward or {};
		table.insert(tbAward, {"item", self.nSeveranceItemId, nTotalSkillItemCount});
	end

	if nTotalExpItemCount > 0 then
		tbAward = tbAward or {};
		table.insert(tbAward, {"item", self.nPartnerExpItemId, nTotalExpItemCount});
	end

	if nTotalSubExpItemCount > 0 then
		tbAward = tbAward or {};
		table.insert(tbAward, {"item", self.nPartnerSubExpItemId, nTotalSubExpItemCount});
	end

	return true, "", pPartner.nTemplateId, tbNeedInfo, tbAward, tbConsumeItem, nTotalProtentialValue;
end

function Partner:OnClientLogin()
	local tbAllPartnerInfo = me.GetAllPartner();
	for nPartnerId, tbPartnerInfo in pairs(tbAllPartnerInfo or {}) do
		local nAwareness = Partner:GetPartnerAwareness(me, tbPartnerInfo.nTemplateId);
		local pPartner = me.GetPartnerObj(nPartnerId);
		pPartner.SetAwareness(nAwareness);
	end
end