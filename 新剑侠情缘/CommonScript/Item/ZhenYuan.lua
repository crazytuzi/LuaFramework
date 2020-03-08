Require("CommonScript/Item/Define.lua")

Item.tbZhenYuan 	= Item.tbZhenYuan or {};
local tbZhenYuan 	= Item.tbZhenYuan;
tbZhenYuan.RAND_SKILL_VAL = 30000000; --随出技能需要的价值量
tbZhenYuan.MAX_RATE = 10000
tbZhenYuan.SAVE_GROUP = 132
tbZhenYuan.tbSAVE_KEY_XY = {};
tbZhenYuan.tbSAVE_KEY_CC = {};
tbZhenYuan.tbSAVE_KEY_IDENTI_XX = {}; --鉴定每一阶稀有的次数
tbZhenYuan.SAVE_KEY_IDENTI_XX_VAL = 31; --鉴定稀有累积起来的价值量，用于鉴定技能， 使用这个是出九阶真元时
tbZhenYuan.szOpenTimeFrame = "OpenLevel69"
tbZhenYuan.nItemValueToExpParam = 1 / 10000; --真元道具的价值量与经验的转换参数

tbZhenYuan.nItemKeySKillInfo = 7;
tbZhenYuan.nItemKeySKillExp = 8;
tbZhenYuan.tbGetSkillZhenYuanItemId = { --必出技能，不影响已有鉴定出技能规则
	[7051] = 1 ;
};
tbZhenYuan.tbExceptSkillZhenYuanItemId = { --必不出技能，不影响已有鉴定出技能规则
	[7323] = 1;
}


function tbZhenYuan:TrimSetting()
	self.tbMakerLevelSetting = LoadTabFile(
		"Setting/Item/ZhenYuan/Maker.tab", 
		"dssdddsdd", "nLevel", 
		{"nLevel","szName","OpenTimeFrame","nItemXY","nItemCC","nItemPT","szMoneyType","nPrice","SkillMaxLevel"});	
	
	local tbAttribQuality = LoadTabFile(
		"Setting/Item/ZhenYuan/AttribQuality.tab", 
		"ddd", nil, 
		{"EquipLevel", "AttribLevel", "Quality",});		
	self.tbColor = {};
	for _, v in pairs(tbAttribQuality) do
		self.tbColor[v.EquipLevel*100 + v.AttribLevel] = v.Quality;
	end

	self.tbSkillValue = LoadTabFile(
		"Setting/Item/ZhenYuan/SkillValue.tab", 
		"ddd", nil, 
		{"Level","FightPower","Value"});	

	self.tbLevelSetting = LoadTabFile(
		"Setting/Item/ZhenYuan/AttribLevel.tab", 
		"dd", "RealLevel", 
		{"RealLevel", "AttribLevel"});

	local tbFile = LoadTabFile(
		"Setting/Item/ZhenYuan/ShowColor.tab", 
		"dd", nil, 
		{"Quality","SKillQuality"});	

	self.tbShowColor = {};
	for i,v in ipairs(tbFile) do
		self.tbShowColor[v.Quality] = v.SKillQuality
	end

	if MODULE_GAMESERVER then
		local nCurMaxLevel = #self.tbMakerLevelSetting;
		assert(nCurMaxLevel <= 20)
		for i=1,10 do
			table.insert(self.tbSAVE_KEY_XY, i)
			table.insert(self.tbSAVE_KEY_CC, 10 + i)
			table.insert(self.tbSAVE_KEY_IDENTI_XX, 20 + i); --后面如果超了10阶段的话 已有的key不能改
		end
		--31已用
		for i=32,41 do
			table.insert(self.tbSAVE_KEY_XY, i)
			table.insert(self.tbSAVE_KEY_CC, 10 + i)
			table.insert(self.tbSAVE_KEY_IDENTI_XX, 20 + i); 
		end

		local tbCols = {"nTimes"}
		local szCos = "d";
		for i=1,nCurMaxLevel do
			szCos = szCos .. "dd";
			table.insert(tbCols, "nRate" .. i)
			table.insert(tbCols, "nValue" .. i)
		end
		self.tbSkillRate = LoadTabFile(
		"Setting/Item/ZhenYuan/SkillRate.tab", 
		szCos, "nTimes", tbCols);	

		self.tbRandSkillId = LoadTabFile(
		"Setting/Item/ZhenYuan/RandSkill.tab", 
		"dd", nil, 
		{"SkillId", "Probility"});	
		
		self.tbMakeRateSettings = LoadTabFile("Setting/Item/ZhenYuan/MakerRate.tab", "ddd", "nTimes",
        {"nTimes", "nCCRate", "nXYRate"})

		--所有等级的 真元都有对应的等级设置
		--阶数是小于 save_Key 数的

		self:CheckData();
	end
end

function tbZhenYuan:CheckData()
	local tbMakeRateSettings = self.tbMakeRateSettings
	local tbData = {}
	for k,v in pairs(tbMakeRateSettings) do
		table.insert(tbData, {k, v})
	end
	table.sort( tbData, function (a, b)
		return a[1] < b[1]
	end )
	local nCurMaxLevel = #self.tbMakerLevelSetting;
	assert(self.tbSkillRate[#self.tbSkillRate]["nRate" .. nCurMaxLevel] > 0, nCurMaxLevel)
	for i=2,#tbData do
		local tbV2 = tbData[i][2]
		local tbV1 = tbData[i - 1][2]
		assert(tbV1.nCCRate <= tbV2.nCCRate )
		assert(tbV1.nXYRate <= tbV2.nXYRate )
		assert(tbV2.nCCRate <= 1000 )
		assert(tbV2.nXYRate <= 1000 )
	end
	
	local nTotalRate = 0;
	for i,v in ipairs(self.tbRandSkillId) do
		nTotalRate = nTotalRate + v.Probility
	end
	assert(nTotalRate == self.MAX_RATE)

	for nLevel,v in pairs(self.tbMakerLevelSetting) do
		if v.SkillMaxLevel ~= 0 then
			assert(self.tbSkillValue[v.SkillMaxLevel], nLevel)
		end
	end
	
	assert(#self.tbMakerLevelSetting <= #self.tbSAVE_KEY_XY)
end

function tbZhenYuan:InitEquipMakerXYItemValues()
    local tbMap = {}
    for nLevel, tb in pairs(self.tbMakerLevelSetting) do
        local nUnidentifyId = tb.nItemXY
        local tbInfo = KItem.GetItemBaseProp(nUnidentifyId)
        tbMap[nLevel] = tbInfo.nValue
    end

    self.tbEquipMakerXYItemValues = tbMap
end

function tbZhenYuan:GetRareIndentyTransFailTimes(pPlayer, nTarLevel )
	--如果鉴定目标等级的稀有真元，先将所有阶段的已鉴定次数价值量汇合，确定出当前阶数对应的 失败次数再取Rate
	local nVal = 0;
	local szFailLevelsVal = ""
	for nLevel = 1, #self.tbMakerLevelSetting do
		local nSaveKeyXYIndentify = self.tbSAVE_KEY_IDENTI_XX[nLevel]
		local nXYFails = pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKeyXYIndentify)
		if nXYFails > 0 then
			szFailLevelsVal = string.format("%s; %d|%d ", szFailLevelsVal, nLevel, nXYFails)
			nVal = nVal + self.tbSkillRate[nXYFails]["nRate" .. nLevel]
		end
	end
	local nTarTimes = 0
	for nTransFail = 0, #self.tbSkillRate do
		if nVal >= self.tbSkillRate[nTransFail]["nRate" .. nTarLevel] then
			nTarTimes = nTransFail
		else
			break;
		end
	end
	return nTarTimes, szFailLevelsVal;
end

-- Server 属性生成
function tbZhenYuan:OnGenerate(pEquip)
	local tbForbid = {};
	local tbSaveAttribs = {};
	local tbRefinement = Item.tbRefinement
	local nRealLevel = pEquip.nRealLevel;
	local tbLevelSetting = self.tbLevelSetting[nRealLevel]
	if not tbLevelSetting then
		Log(debug.traceback(), nRealLevel)
		return
	end

	local tbCustomAttri = tbRefinement:GetCustomAttri(pEquip.dwTemplateId)
	if tbCustomAttri then
		for i,v in ipairs(tbCustomAttri) do
			tbRefinement:SetItemIntValue(pEquip, i, v)
		end
	else
		local tbCurAttribLevel;
		if me  then
			local pCurEquip = me.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
			if pCurEquip then
				tbCurAttribLevel = tbRefinement:GetRandomAttribTypeLevel(pCurEquip)
			end
		end
		local nAttribLevel = tbLevelSetting.AttribLevel;
		local szAttrib = tbRefinement:RandomAttribType(Item.EQUIPTYPE_EN_NAME[Item.EQUIP_ZHEN_YUAN], tbForbid, tbCurAttribLevel, nAttribLevel);
		local nAttribId = tbRefinement:AttribCharToId(szAttrib);	
		local nSave = tbRefinement:AttribToSaveData(nAttribId, nAttribLevel);		-- 左移16位，ID为高16位，等级为低16位
		tbRefinement:SetItemIntValue(pEquip, 1, nSave)
	end
	
	if pEquip.nDetailType == Item.DetailType_Rare and me then
		local bForbitSkill = self.tbExceptSkillZhenYuanItemId[pEquip.dwTemplateId]
		if not bForbitSkill then
			local nLevel = pEquip.nLevel
			local bDirectGetSkill = self.tbGetSkillZhenYuanItemId[pEquip.dwTemplateId]
			local bGetSkill = false
			if bDirectGetSkill then
				bGetSkill = true
			else
				local nMaxFails = #self.tbSkillRate 
				local nMaxRate = self.tbSkillRate[nMaxFails]["nRate" .. nLevel]
				local nRan = MathRandom(nMaxRate);

				local nXYFails, szFailTimes = self:GetRareIndentyTransFailTimes(me, nLevel)
				nXYFails = math.min(nXYFails, nMaxFails)
				local nCurRate =  self.tbSkillRate[nXYFails]["nRate" .. nLevel]
				Log("tbZhenYuan:OnGenerateXY", pEquip.dwTemplateId,me.dwID, nMaxRate, nRan, nCurRate, nLevel, nXYFails, szFailTimes)
				bGetSkill = nRan <= nCurRate;
			end
		
			if bGetSkill then
				local nRandSkill = self:GetRandSkillId(me)
				local nSkillLevel = 1;
				local nSave = tbRefinement:AttribToSaveData(nRandSkill, nSkillLevel);
				pEquip.SetIntValue(self.nItemKeySKillInfo, nSave)	
				if not bDirectGetSkill then
					for k,v in pairs(self.tbSAVE_KEY_IDENTI_XX) do
						me.SetUserValue(self.SAVE_GROUP, v, 0)	
					end
				end
			else
				local nSaveKeyXYIndentify = self.tbSAVE_KEY_IDENTI_XX[nLevel]
				me.SetUserValue(self.SAVE_GROUP, nSaveKeyXYIndentify, me.GetUserValue(self.SAVE_GROUP, nSaveKeyXYIndentify) + 1)
			end
		end
		
	end
end

function tbZhenYuan:InitEquip(pEquip)
	local tbAttribs = Item.tbRefinement:GetRandomAttrib(pEquip); --根据intval 转成 属性id 和等级是和洗练是一样的
	local nMaxQuality = 0;
	local nRefineValue = 0;
	local nRefinePower = 0;
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local nQuality = self:GetAttribColor(pEquip.nLevel, tbAttrib.nAttribLevel);
		local tbSetting = Item.tbRefinement:GetAttribSetting(tbAttrib.szAttrib, tbAttrib.nAttribLevel, pEquip.nItemType);
		if tbSetting then
			pEquip.SetRandAttrib(nIdx, tbAttrib.szAttrib, unpack(tbSetting.tbMA))
			nRefineValue = nRefineValue + tbSetting.nAttribValue
			nRefinePower = nRefinePower + tbSetting.nFightPower
		end
		
		if nMaxQuality < nQuality then
			nMaxQuality = nQuality;
		end
	end
	local nTotalIndex = #tbAttribs
	local nSaveSkillId  = pEquip.GetIntValue(self.nItemKeySKillInfo)
	if nSaveSkillId ~= 0 then
		local nSkillId, nSkillLevel = Item.tbRefinement:SaveDataToAttrib(nSaveSkillId)
		local nCurMaxLevel = self:GetEquipMaxSkillLevel(pEquip.nLevel)
		if nSkillLevel < nCurMaxLevel then
			local nOldSrcExp = pEquip.GetIntValue(self.nItemKeySKillExp)
			local nLevelUpLeedExp = Item.tbZhenYuan:GetSkillLevelUpNeedExp(nSkillLevel)
			if nOldSrcExp >= nLevelUpLeedExp then
				Log("ZhenYuan SkillLevelup when Init", (me and me.dwID), nSkillLevel, pEquip.nLevel, nOldSrcExp, nLevelUpLeedExp, pEquip.dwTemplateId)
				nOldSrcExp = nOldSrcExp - nLevelUpLeedExp
				nSkillLevel = nSkillLevel + 1;
				nSaveSkillId = Item.tbRefinement:AttribToSaveData(nSkillId, nSkillLevel);
				pEquip.SetIntValue(self.nItemKeySKillInfo, nSaveSkillId)
				pEquip.SetIntValue(self.nItemKeySKillExp, nOldSrcExp)
			end    
		end
        local tbSkillValue = self.tbSkillValue[nSkillLevel]
        nRefineValue = nRefineValue + tbSkillValue.Value
        nRefinePower = nRefinePower + tbSkillValue.FightPower

        pEquip.SetRandAttrib(nTotalIndex + 1, "add_skill_level", nSkillId, nSkillLevel, 1);
    end
	return nRefinePower, nRefineValue, nMaxQuality;
end


function tbZhenYuan:GetRandSkillId(pPlayer)
	local tbForbid = {};
	local nForbitConut = 0
	if pPlayer then --先禁止玩家的已拥有的技能
		local tbALlItem = pPlayer.FindItemInBag("ZhenYuan")
		local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
		if pEquip then
			table.insert(tbALlItem, pEquip)
		end
		for i,pItem in ipairs(tbALlItem) do
			local nSaveSkillId = pItem.GetIntValue(self.nItemKeySKillInfo) 
			if nSaveSkillId ~= 0 then
				local nSkillId, nSkillLevel = Item.tbRefinement:SaveDataToAttrib(nSaveSkillId)
				tbForbid[nSkillId] = true
				nForbitConut = nForbitConut + 1;
			end
		end
	end
	if nForbitConut > 0 and nForbitConut < #self.tbRandSkillId then
		local nMaxRate = math.ceil(self.MAX_RATE * (#self.tbRandSkillId - nForbitConut) / #self.tbRandSkillId)
		local nRate = MathRandom(1, nMaxRate);
		local nSumRate = 0;
		for i,v in ipairs(self.tbRandSkillId) do
			if not tbForbid[v.SkillId] then
				nSumRate = nSumRate + v.Probility
				if nRate <= nSumRate then
					return v.SkillId
				end	
			end
		end
	end
	
	local nRate = MathRandom(1, self.MAX_RATE);
	local nSumRate = 0;
	for i,v in ipairs(self.tbRandSkillId) do
		nSumRate = nSumRate + v.Probility
		if nRate <= nSumRate then
			return v.SkillId
		end
	end
end

function tbZhenYuan:GetAttribColor(nEquipLevel, nAttribLevel)
	local nKey = nEquipLevel * 100 + nAttribLevel;
	local nAttribColor = self.tbColor[nKey]
	if not nAttribColor then
		Log("[ERROR] can find color in ".. nEquipLevel .." ".. nAttribLevel);
		return 1;
	else
		return nAttribColor;
	end
end

function tbZhenYuan:GetMakeLevelSetting(nLevel)
	return self.tbMakerLevelSetting[nLevel]
end

function tbZhenYuan:GetCanMakeLevelSettingList()
	local tbList = {};
	for nLevel,v in ipairs(self.tbMakerLevelSetting) do
		if GetTimeFrameState(v.OpenTimeFrame) ~= 1 then
			break;
		end	
		table.insert(tbList, v)
	end
	table.sort( tbList, function (a, b)
		return a.nLevel > b.nLevel
	end )
	return tbList
end

function tbZhenYuan:CanMakeZhenYuan(pPlayer, nLevel)
	local tbLevelSetting = self:GetMakeLevelSetting(nLevel)
	if not tbLevelSetting then
		return false, "无效阶数"
	end
	if GetTimeFrameState(tbLevelSetting.OpenTimeFrame) ~= 1 then
		return false, "时间轴未开放"
	end
	if pPlayer.GetMoney(tbLevelSetting.szMoneyType) < tbLevelSetting.nPrice then
		return false, "元气不足，无法凝聚真元"
	end
	return tbLevelSetting
end

function tbZhenYuan:_EquipMakerGatherFails(pPlayer, nDestLevel)
	local nTotalValue = 0
	for nLevel=1, nDestLevel - 1 do
		local nSaveKey = self.tbSAVE_KEY_XY[nLevel]
		local nFails = pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKey)
		if nFails > 0 then
			local nValue = self.tbEquipMakerXYItemValues[nLevel]
			nTotalValue = nTotalValue+(nFails*nValue)
			pPlayer.SetUserValue(self.SAVE_GROUP, nSaveKey, 0)
			Log("tbZhenYuan:_EquipMakerGatherFails reset", pPlayer.dwID, nDestLevel, nFails, nValue, nTotalValue)
		end
	end

	if nTotalValue>0 then
		local nDestValue = self.tbEquipMakerXYItemValues[nDestLevel]
		local nAddFails = math.floor(nTotalValue/nDestValue)
		if nAddFails>0 then
			local nDestSaveKey = self.tbSAVE_KEY_XY[nDestLevel]
			local nFails = pPlayer.GetUserValue(self.SAVE_GROUP, nDestSaveKey)
			pPlayer.SetUserValue(self.SAVE_GROUP, nDestSaveKey, nFails+nAddFails)
			Log("tbZhenYuan:_EquipMakerGatherFails add", pPlayer.dwID, nDestSaveKey, nTotalValue, nDestValue, nFails, nAddFails)
		end
	end
end

function tbZhenYuan:_EquipMakerUpdateSaveKey(pPlayer, nLevel, szItemType)
	local nKeyXY = self.tbSAVE_KEY_XY[nLevel]
	local nKeyCC = self.tbSAVE_KEY_CC[nLevel]
	local nXYCount = pPlayer.GetUserValue(self.SAVE_GROUP, nKeyXY)
	local nCCCount = pPlayer.GetUserValue(self.SAVE_GROUP, nKeyCC)

	if szItemType == "nItemXY" then
		nXYCount = 0;
	elseif szItemType == "nItemCC" then
		nCCCount = 0;
	elseif szItemType == "nItemPT" then
		nXYCount = nXYCount + 1
		nCCCount = nCCCount + 1
	else
		Log(debug.traceback() ,pPlayer.dwID, nLevel, szItemType)
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, nKeyXY, nXYCount)
	pPlayer.SetUserValue(self.SAVE_GROUP, nKeyCC, nCCCount)
	Log("Shop:_EquipMakerUpdateSaveKey", pPlayer.dwID, nLevel, szItemType, nXYCount, nCCCount)
end


function tbZhenYuan:_EquipMakerGetRandomIdx(pPlayer, nLevel)
	-- 先随稀有,若不出稀有则随传承,若不出传承则必出普通
	-- 稀有概率 + 传承概率 ≥ 100%，则先随稀有，若不出稀有则必出传承
	local nMaxFails = #self.tbMakeRateSettings --0开始存，#取出老还是去掉0 的
	local nSaveKeyXY = self.tbSAVE_KEY_XY[nLevel]
	local nXYFails = pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKeyXY)
	nXYFails = math.min(nXYFails, nMaxFails)
	local nXYRate = self.tbMakeRateSettings[nXYFails].nXYRate
	local nRand = MathRandom(1, 1000)
	Log("tbZhenYuan:_EquipMakerGetRandomIdx", pPlayer.dwID, nXYFails, nLevel, nRand)
	if nRand <= nXYRate then
		return "nItemXY"
	else
		local nSaveKeyCC = self.tbSAVE_KEY_CC[nLevel]	
		local nCCFails = pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKeyCC);
		nCCFails = math.min(nCCFails, nMaxFails)
		local nCCRate = self.tbMakeRateSettings[nCCFails].nCCRate
		if nRand <= (nCCRate + nXYRate) then
			return "nItemCC"
		else
			return "nItemPT"
		end
	end
end

function tbZhenYuan:MakeEquip(pPlayer, nLevel)
	local tbLevelSetting, szMsg = self:CanMakeZhenYuan(pPlayer, nLevel)
	if not tbLevelSetting then
		return
	end

	self:_EquipMakerGatherFails(pPlayer, nLevel)
	local szItemType = self:_EquipMakerGetRandomIdx(pPlayer, nLevel)
	local nItemId = tbLevelSetting[szItemType]
	if not version_tx then
		if szItemType == "nItemXY"  then
			local nRewardValueDebt = Player:GetRewardValueDebt(pPlayer.dwID);
			if nRewardValueDebt > 0 and MathRandom(100)<50 then
				local nOldItemId = nItemId
				nItemId = tbLevelSetting["nItemCC"]
				local tbItemBase1 = KItem.GetItemBaseProp(nOldItemId)
				local tbItemBase2 = KItem.GetItemBaseProp(nItemId)
				local nPoint = math.floor((tbItemBase1.nValue - tbItemBase2.nValue) / 1000) 
				Player:CostRewardValueDebt(pPlayer.dwID, nPoint, Env.LogWay_MakeZhenYuan, nLevel)	
				Log("tbZhenYuan:MakeEquip CostValueDebt", pPlayer.dwID, nRewardValueDebt, nPoint, Player:GetRewardValueDebt(pPlayer.dwID))
			end
		end
	end
	
	if not pPlayer.CostMoney(tbLevelSetting.szMoneyType, tbLevelSetting.nPrice, Env.LogWay_MakeZhenYuan, nItemId) then
		return
	end
	self:_EquipMakerUpdateSaveKey(pPlayer, nLevel, szItemType)
	local pItem = pPlayer.AddItem(nItemId, 1, nil, Env.LogWay_MakeZhenYuan)
	Achievement:AddCount(pPlayer, "ZhenYuan_1", 1)


	local szEquipName = Item:GetItemTemplateShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)
	if pItem.nDetailType == Item.DetailType_Rare then
		local szSysMsg = string.format("「%s」成功凝聚出了<%s>，真是鸿运当头！", pPlayer.szName, szEquipName)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szSysMsg, pPlayer.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId, nFaction = pPlayer.nFaction, nSex = pPlayer.nSex})
		Achievement:AddCount(pPlayer, "ZhenYuan_Rare", 1)
		
	end
	pPlayer.CallClientScript("Item.tbZhenYuan:OnMakeResult", nItemId)
end

function tbZhenYuan:GetSkillLevelInfo(nLevel)
	return self.tbSkillValue[nLevel]
end

function tbZhenYuan:GetTrasnExpParam(pItem, nTarSkillId)
	local nSaveSkillId  = pItem.GetIntValue(self.nItemKeySKillInfo)
	if nSaveSkillId ~= 0 then
		local nSkillId, nSkillLevel = Item.tbRefinement:SaveDataToAttrib(nSaveSkillId)
		if nSkillId and nSkillId == nTarSkillId then
			return 1.5, nSkillLevel
		else
			return 1.2, nSkillLevel
		end
	end
	local nDetailType = pItem.nDetailType
	if nDetailType == Item.DetailType_Rare then
		return 1
	elseif nDetailType == Item.DetailType_Inherit then
		return 0.5
	else
		return  0.3
	end
end

function tbZhenYuan:GetSkillLevelUpNeedExp(nCurLevel)
	local tbCurLevelInfo = self.tbSkillValue[nCurLevel]
	local tbNextLevelInfo = self.tbSkillValue[nCurLevel + 1]
	if not tbCurLevelInfo or not tbNextLevelInfo then
		return 0;
	end
	return tbNextLevelInfo.Value - tbCurLevelInfo.Value
end

--计算真元价值的 exp
function tbZhenYuan:CalItemsTotalExp(tbItems, pTarEquip)
	local nTotalExp = 0;
	local nSaveSkillId  = pTarEquip.GetIntValue(self.nItemKeySKillInfo)
	local nSkillId;
	if nSaveSkillId ~= 0 then
		nSkillId = Item.tbRefinement:SaveDataToAttrib(nSaveSkillId)
	end
	for i, pItem in ipairs(tbItems) do
		local nParam, nSkillLevel = self:GetTrasnExpParam(pItem, nSkillId);
		-- 技能升级时价值量已经加到道具里了 --升一级加的价值量是算到下一级里去的
		local nItemValue = pItem.GetSingleValue() --里面已经算了等级的价值了，再加上 经验的
		local nCurExp = pItem.GetIntValue(self.nItemKeySKillExp)
		if nCurExp > 0 then
			nItemValue = nItemValue + nCurExp; --因为道具价量现在是直接等价与
		end
		nTotalExp = nTotalExp + nItemValue * nParam
	end
	return nTotalExp
end

function tbZhenYuan:CanSkillLevelUp(pPlayer, nItemId)
	if not nItemId then
		return
	end
	local pCurEquip = pPlayer.GetItemInBag(nItemId)
	if not pCurEquip then
		return 
	end
	local tbSkillInfo = Item:GetClass("ZhenYuan"):GetSkillAttribTip(pCurEquip)
	if not tbSkillInfo then
		return
	end
	local nSkillID, nSkillLevel = unpack(tbSkillInfo)
	local nMaxLevel = self:GetEquipMaxSkillLevel(pCurEquip.nLevel)
	if not nMaxLevel then
		return
	end

	if nSkillLevel >= nMaxLevel then
		return
	end
	return true;
end

function tbZhenYuan:CheckCanSkillLevelUp(pPlayer, tbCostItemIds)
	local tbPItems = {}
	for i,v in ipairs(tbCostItemIds) do
		local pItem = pPlayer.GetItemInBag(v)
		if not pItem or pItem.szClass ~= "ZhenYuan" then
			return false, "无效道具"
		end
		table.insert(tbPItems, pItem)
	end
	local pCurEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
	if not pCurEquip then
		return false, "当前未装备真元"
	end

	local nTotalExp = self:CalItemsTotalExp(tbPItems, pCurEquip)
	if nTotalExp == 0 then
		return false, "可增加经验为0"
	end

	local nCurExp = pCurEquip.GetIntValue(self.nItemKeySKillExp)
	local tbSkillInfo = Item:GetClass("ZhenYuan"):GetSkillAttribTip(pCurEquip)
	if not tbSkillInfo then
		return false, "当前真元不含有技能"
	end
	local nSkillID, nSkillLevel = unpack(tbSkillInfo)

	local nMaxLevel = self:GetEquipMaxSkillLevel(pCurEquip.nLevel)
	if nSkillLevel >=  nMaxLevel then
		return false, string.format("当前装备真元最大技能等级为%d级", nMaxLevel) 
	end

	local nNeedExp = self:GetSkillLevelUpNeedExp(nSkillLevel)
	if nNeedExp == 0 then
		return false, "当前已满级"
	end
	return tbPItems, "",nTotalExp,nSkillID,nSkillLevel,pCurEquip,nCurExp ;
end

function tbZhenYuan:ZhenYuanSkillLevelUp(pPlayer, tbCostItemIds)
	local tbPItems, _, nTotalExp,nSkillID,nSkillLevel,pCurEquip,nCurExp  = self:CheckCanSkillLevelUp(pPlayer, tbCostItemIds)
	if not tbPItems then
		return
	end

	for i,v in ipairs(tbPItems) do
		v.Delete(Env.LogWay_MakeZhenYuan)
	end
	local nMaxSkillLevel = self:GetEquipMaxSkillLevel(pCurEquip.nLevel)
	local nEatTotalExp = nTotalExp; 
	nTotalExp = nTotalExp + nCurExp; --这样剩多级时好算点
	local nOldnTotalExp = nTotalExp
	--只升一次，
	local nOldSkillLevel = nSkillLevel 
	while nTotalExp > 0 do
		local nNeedExp = self:GetSkillLevelUpNeedExp(nSkillLevel)
		if nNeedExp > 0 and nSkillLevel < nMaxSkillLevel  and  nTotalExp >= nNeedExp then
			nSkillLevel = nSkillLevel + 1;
			nTotalExp = nTotalExp - nNeedExp;
		else
			break;
		end
	end

	local bChange = false
	if nSkillLevel > nOldSkillLevel then
		local nSave = Item.tbRefinement:AttribToSaveData(nSkillID, nSkillLevel)
		pCurEquip.SetIntValue(self.nItemKeySKillInfo, nSave)	
		bChange = true;
	end
	local nNeedExp = self:GetSkillLevelUpNeedExp(nSkillLevel)
	local nSaveLeftExp = math.max(0, math.min(nNeedExp, nTotalExp)) 
	pCurEquip.SetIntValue(self.nItemKeySKillExp, nSaveLeftExp)	
	pCurEquip.ReInit();
	if bChange then
		FightPower:ChangeFightPower("ZhenYuan", pPlayer)
	end

	pPlayer.CallClientScript("Item.tbZhenYuan:OnZhenYuanSKillLevelUpRet")

	pPlayer.TLog("ZhenYuanSKillFlow", pCurEquip.dwTemplateId, nOldSkillLevel, nCurExp, nSkillLevel, nSaveLeftExp, nEatTotalExp)
	Log("tbZhenYuan:ZhenYuanSkillLevelUp", pPlayer.dwID, pCurEquip.dwTemplateId, nOldSkillLevel, nCurExp, nSkillLevel, nSaveLeftExp, nOldnTotalExp, nTotalExp)
	return true
end

function tbZhenYuan:GetEquipMaxSkillLevel(nLevel)
	local tbInfo = self.tbMakerLevelSetting[nLevel]
	if tbInfo then
		return tbInfo.SkillMaxLevel
	end
end

function tbZhenYuan:CanRefineSkill(pPlayer, nItemId)
	if not nItemId then
		return
	end
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		return
	end

	if pItem.nEquipPos ~= Item.EQUIPPOS_ZHEN_YUAN then
		return
	end

	local pCurEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
	if not pCurEquip then
		return
	end
	if pCurEquip.dwId == nItemId then
		return
	end
	local nSaveSkillIdCur  = pCurEquip.GetIntValue(self.nItemKeySKillInfo)
	local nSaveSkillIdSrc  = pItem.GetIntValue(self.nItemKeySKillInfo)
	if nSaveSkillIdSrc == 0 then
		return
	end
	local nSkillIdCur, nSkillLevelCur = Item.tbRefinement:SaveDataToAttrib(nSaveSkillIdCur)
	local nSkillIdSrc, nSkillLevelSrc = Item.tbRefinement:SaveDataToAttrib(nSaveSkillIdSrc)
	if nSkillIdCur == nSkillIdSrc then
		return
	end
	if nSaveSkillIdCur == 0 then
		if pCurEquip.nLevel < pItem.nLevel then --将有技能的洗到没技能的上只能洗到同等或更高阶上
			return
		end
	end

	return true, nSkillIdCur, nSkillLevelCur, nSkillIdSrc, nSkillLevelSrc, pCurEquip, pItem
end

function tbZhenYuan:GetRefineSkillCost(nSkillLevelSrc)
	return "Contrib", 50000 
end

function tbZhenYuan:OnRequestRefineSkill(pPlayer, nItemId)
	local bRet,nSkillIdCur, nSkillLevelCur, nSkillIdSrc, nSkillLevelSrc, pCurEquip, pItem = self:CanRefineSkill(pPlayer, nItemId)
	if not bRet then
		return
	end
	local szMoneyType, nMoney = self:GetRefineSkillCost(nSkillLevelSrc)
	if not pPlayer.CostMoney(szMoneyType, nMoney, Env.LogWay_ZhenYuanSkill) then
		return
	end

	local nOldCurSkilVal = pCurEquip.GetIntValue(self.nItemKeySKillInfo)
	local nOldSrcSkilVal = pItem.GetIntValue(self.nItemKeySKillInfo)

	local nSaveIdCur = nOldSrcSkilVal
	local nSaveIdSrc = nOldCurSkilVal
	if nOldCurSkilVal ~= 0 then --身上的也有技能则只是交换技能id，没技能就全部交换
		nSaveIdCur = Item.tbRefinement:AttribToSaveData(nSkillIdSrc, nSkillLevelCur);		
		nSaveIdSrc = Item.tbRefinement:AttribToSaveData(nSkillIdCur, nSkillLevelSrc);		
	else
		local nOldCurExp = pCurEquip.GetIntValue(self.nItemKeySKillExp)	
		local nOldSrcExp = pItem.GetIntValue(self.nItemKeySKillExp)
		if nOldSrcExp ~= 0 then
			pCurEquip.SetIntValue(self.nItemKeySKillExp, nOldSrcExp)	
			pItem.SetIntValue(self.nItemKeySKillExp, nOldCurExp)
		end
	end

	pCurEquip.SetIntValue(self.nItemKeySKillInfo, nSaveIdCur)
	pItem.SetIntValue(self.nItemKeySKillInfo, nSaveIdSrc)

	pCurEquip.ReInit();
	pItem.ReInit();
	FightPower:ChangeFightPower("ZhenYuan", pPlayer)
	pPlayer.CenterMsg("技能洗练成功！")
	pPlayer.TLog("EquipFlow", pCurEquip.nItemType, pCurEquip.dwTemplateId, pCurEquip.dwId, 1, Env.LogWay_ZhenYuanSkill, 0, 2, pCurEquip.GetIntValue(1),pCurEquip.GetIntValue(2), pCurEquip.GetIntValue(3), pCurEquip.GetIntValue(4), pCurEquip.GetIntValue(5),pCurEquip.GetIntValue(6), nSaveIdCur, "");
	pPlayer.TLog("EquipFlow", pItem.nItemType, pItem.dwTemplateId, pItem.dwId, 1, Env.LogWay_ZhenYuanSkill, 0, 3, pItem.GetIntValue(1),pItem.GetIntValue(2), pItem.GetIntValue(3), pItem.GetIntValue(4), pItem.GetIntValue(5),pItem.GetIntValue(6),nSaveIdSrc, "");
	Achievement:AddCount(pPlayer, "ZhenYuanRefinement_Skill", 1)
end

if MODULE_GAMECLIENT then
	function tbZhenYuan:OnMakeResult(nItemId)
		UiNotify.OnNotify(UiNotify.emNOTIFY_ZHEN_YUAN_MAKE, nItemId)
	end

	function tbZhenYuan:OnZhenYuanSKillLevelUpRet()
		UiNotify.OnNotify(UiNotify.emNOTIFY_ZHEN_YUAN_MAKE)
	end

	function tbZhenYuan:RequestRefineSkill(nItemId)
		local bRet, nSkillIdCur, nSkillLevelCur, nSkillIdSrc, nSkillLevelSrc = self:CanRefineSkill(me, nItemId)
		if not bRet then
			me.CenterMsg("无法洗练技能")
			return
		end

		local szMoneyType, nMoney = self:GetRefineSkillCost(nSkillLevelSrc)
		local szMoneyName = Shop:GetMoneyName(szMoneyType)
		local szMoneyUseDesc = string.format("%d%s", nMoney, szMoneyName)
		if me.GetMoney(szMoneyType) < nMoney then
			me.CenterMsg(string.format("您身上不够" .. szMoneyUseDesc))
			return
		end

		local _, szSkillNameSrc = FightSkill:GetSkillShowInfo(nSkillIdSrc);
		local _, szSkillNameCur = FightSkill:GetSkillShowInfo(nSkillIdCur);
		szSkillNameCur = szSkillNameCur or "";
		local szMsg = string.format("您确定要花费%s将已装备的真元上的技能[FFFE0D]%s[-]，替换为[FFFE0D]%s[-]吗？（替换后，技能等级将会继承保留）",szMoneyUseDesc, szSkillNameCur, szSkillNameSrc)
		local fnAgree = function ()
			Ui:CloseWindow("EquipTips")
			RemoteServer.ZhenYuanRefineSkill(nItemId)
		end
	    me.MsgBox(szMsg, {{"同意", fnAgree}, {"取消"}})
	end
end

tbZhenYuan:TrimSetting()
