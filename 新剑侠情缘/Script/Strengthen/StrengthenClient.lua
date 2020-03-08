
function Strengthen:MegerMA(tbValue1, tbValue2)
	local tbRet = {};
	for i,v in ipairs(tbValue1) do
		tbRet[i] = v + tbValue2[i]
	end

	return tbRet;
end

function Strengthen:GetEquipStrengthenInfo(pPlayer, nTemplateId, nEquipPos)
	local tbAttrib = KItem.GetEquipBaseProp(nTemplateId).tbBaseAttrib;
	local tbStrengthen = pPlayer.GetStrengthen();
	local nStrenLevel = tbStrengthen[nEquipPos + 1];

	local tbRet = {};
	for i, tbMA in ipairs(tbAttrib) do
		local tbCurValue = self:GetAttribValues(tbMA.szName, nStrenLevel, nEquipPos);
		local tbShowValue = tbCurValue;
		if tbCurValue and tbCurValue[1] ~= 0 then
			tbShowValue =  self:MegerMA(tbCurValue, tbMA.tbValue);
		end

		local szNextName, szNextValue = "";
		local tbNextValue;
		if nStrenLevel < self.STREN_LEVEL_MAX then
			tbNextValue = self:GetAttribValues(tbMA.szName, nStrenLevel + 1, nEquipPos);
			if tbNextValue and tbNextValue[1] ~= 0 then
				local tbValue =  self:MegerMA(tbNextValue, tbMA.tbValue);
				szNextName, szNextValue = FightSkill:GetMagicDescSplit(tbMA.szName, tbValue);	
			end
		end

		local szCurName, szCurValue = "";
		if (tbShowValue and tbShowValue[1] ~= 0) or (tbNextValue and tbNextValue[1] ~= 0) then
			szCurName, szCurValue = FightSkill:GetMagicDescSplit(tbMA.szName, tbShowValue);		
		end
		if szCurValue or szNextValue then
			tbRet[i] = {
				tbCur = {
					szName = szCurName,
					szValue = szCurValue,
				},
				tbNext = {
					szName = szNextName,
					szValue = szNextValue,
				},
			};	
		end
	end

	return tbRet;
end

function Strengthen:OnResponse(bSuccess, szInfo, nEquipPos, nNewEnhanceLevel, nCurFightPower, nOrgFightPower)
	if bSuccess and nEquipPos and nNewEnhanceLevel then
		if szInfo then
			local tbEquip = me.GetEquips()
			local nEquipId = tbEquip[nEquipPos]
			local pEquip = me.GetItemInBag(nEquipId);
			szInfo = string.format("你的%s成功强化到+%d", pEquip.szName, nNewEnhanceLevel);
		end
		me.SetStrengthen(nEquipPos, nNewEnhanceLevel)
		self:UpdateEnhAtrrib(me)
		UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER) -- 因为客户端 UpdateEnhAtrrib 更新额外属性也会加战力，所以现在刷新下
	end

	if szInfo then
		-- me.CenterMsg(szInfo)
		UiNotify.OnNotify(UiNotify.emNOTIFY_STRENGTHEN_RESULT, bSuccess, nCurFightPower, nOrgFightPower);
	end
end

function Strengthen:CanEquipUpgrade(nItemId)
	if not nItemId then
		return false
	end
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem then
		return false
	end
	local nEquipPos = pItem.nEquipPos
	if StoneMgr:CheckInsetUpgradeFlag(nItemId) then
		return true
	end
	local bRet = Strengthen:CanStrengthen(me, pItem, true);
	if bRet then
		return true
	end
	return Item.GoldEquip:CanUpgrade(me, pItem)
end

