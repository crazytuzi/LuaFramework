Furniture.MagicBowl = Furniture.MagicBowl or {}
local MagicBowl = Furniture.MagicBowl

MagicBowl.Def = {
	nNewDayTime = 4*3600,	--新的一天时间偏移

	szOpenFrame = "OpenLevel69",	--开启时间轴
	szMinLevel = 60,	--玩家最低等级
	nMakeFurnitureHouseLvl = 2,	--打造聚宝盆家具所需家园最小等级

	szPrayCostType = "SilverBoard",	--祈福消耗类型，元宝扣除比较特殊，不可配元宝
	tbPrayCosts = {	--祈福花费
		{1, 0},	--{最大次数（含）, 价格}
		{2,	0},
		{3,	10},
		{4,	20},
		{5,	30},
		{6,	40},
		{7, 50},
		{8, 60},
		{999999, 60},
	},

	--计算公式：中间值 + 百分比*浮动值
	--AttribValInscription.tab: Value123(中间值), Value123Offset(浮动值)
	tbPrayPercentDesc = {	--祈福结果评价描述
		{-100, "歹", 1},	--{百分比, 评价, 品质（用于显示颜色）}
		{-50, "弱", 2},
		{0, "平", 3},
		{50, "良", 4},
		{100, "吉", 5},
	},
	tbPrayDefaultIdxs = {2, 3},	--默认下标
	nPrayDuration = 3*24*3600,	--祈福生效时间（秒）
	nCheckPrayExpireDelta = 5*60,	--检查祈福过期间隔（秒）
}

function MagicBowl:IsOpened(pPlayer)
	--return pPlayer.nLevel >= self.Def.szMinLevel and GetTimeFrameState(self.Def.szOpenFrame) == 1
	return false
end

function MagicBowl:LoadSettings()
	self.tbMagicBowlSettings = LoadTabFile("Setting/House/MagicBowl.tab", "ddddsd", "nLevel",
		{"nLevel", "nAttributeCount", "nItemId", "nComfortLvl", "szOpenFrame", "nCostValue"})
	self.tbMaterials = LoadTabFile("Setting/House/MagicBowlMaterials.tab", "dd", "nTemplateId",
		{"nTemplateId", "nValueRate"})

	self.tbAttrCfg = {}
	local tbAttrCfg = LoadTabFile("Setting/Item/RandomAttrib/AttribValInscription.tab", "sdddddddd", nil,
		{"AttribType", "Level", "FightPower", "Value1", "Value2", "Value3", "Value1Offset", "Value2Offset", "Value3Offset"})
	for _, v in pairs(tbAttrCfg) do
		self.tbAttrCfg[v.AttribType] = self.tbAttrCfg[v.AttribType] or {}
		self.tbAttrCfg[v.AttribType][v.Level] = {
			tbMA = {v.Value1, v.Value2, v.Value3},
			tbMAOffset = {v.Value1Offset, v.Value2Offset, v.Value3Offset},
			nFightPower = v.FightPower,
		}
	end

	local tbAttribQuality = LoadTabFile("Setting/Item/RandomAttrib/InscriptionAttribQuality.tab", "ddd", nil,
		{"EquipLevel", "AttribLevel", "Quality",})
	self.tbColor = {}
	for _, v in pairs(tbAttribQuality) do
		self.tbColor[v.EquipLevel*100 + v.AttribLevel] = v.Quality
	end

	self.tbInscriptionMakeSettings = LoadTabFile("Setting/House/InscriptionMake.tab", "dddddddddddd", "nMBLvl",
		{"nMBLvl", "nItemId", "nValue1", "nTime1", "nValue2", "nTime2", "nValue3", "nTime3", "nValue4", "nTime4", "nValue5", "nTime5"})
end
MagicBowl:LoadSettings()

function MagicBowl:GetPrayValue(nSaveData, nPrayIdx)
	local nAttribId, nLevel = Item.tbRefinement:SaveDataToAttrib(nSaveData)
	local szAttrType = Item.tbRefinement:AttribIdToChar(nAttribId)
	local tbCfg = self.tbAttrCfg[szAttrType][nLevel]
	local nPercent = self.Def.tbPrayPercentDesc[nPrayIdx][1]/100
	local tbOffset, tbValue = tbCfg.tbMAOffset, tbCfg.tbMA
	return szAttrType, {
		tbValue[1] + math.ceil(tbOffset[1]*nPercent),
		tbValue[2] + math.ceil(tbOffset[2]*nPercent),
		tbValue[3] + math.ceil(tbOffset[3]*nPercent),
	}
end

function MagicBowl:GetAttrFightPower(nSaveData)
	local nAttribId, nLevel = Item.tbRefinement:SaveDataToAttrib(nSaveData)
	local szAttrType = Item.tbRefinement:AttribIdToChar(nAttribId)
	local tbCfg = self.tbAttrCfg[szAttrType][nLevel]
	return tbCfg.nFightPower or 0
end

function MagicBowl:GetLevelSetting(nLevel)
	return self.tbMagicBowlSettings[nLevel]
end

function MagicBowl:GetMaxAttrCount(nOwner)
	local tbMagicBowl = nil
	if MODULE_GAMESERVER then
		tbMagicBowl = self:GetData(nOwner)
	elseif MODULE_GAMECLIENT then
		tbMagicBowl = House:GetMagicBowlData(nOwner)
	end
	if not tbMagicBowl then
		return 0
	end

	local tbSetting = self:GetLevelSetting(tbMagicBowl.nLevel)
	if not tbSetting then
		return 0
	end
	return tbSetting.nAttributeCount
end

function MagicBowl:GetInscriptionMakeSetting(nMBLevel)
	return self.tbInscriptionMakeSettings[nMBLevel]
end

function MagicBowl:GetPrayCost(nNextTimes)
	for _, tb in ipairs(self.Def.tbPrayCosts) do
		local nMax, nCost = unpack(tb)
		if nNextTimes<=nMax then
			return nCost
		end
	end
	return math.huge
end

function MagicBowl:GetInscriptionState(nMBLvl, nStage, nDeadline)
	if nStage<=0 then
		nStage, nDeadline = 1, 0
	end

	local tbSetting = self:GetInscriptionMakeSetting(nMBLvl)
	if GetTime()<=nDeadline then
		return "running", nStage>=5 or tbSetting["nValue"..(nStage+1)]<=0	--当前阶段正在运行
	end

	if nStage>=5 or (nDeadline>0 and tbSetting["nValue"..(nStage+1)]<=0) then
		return "finished"	--已经结束
	end

	return "rest"	--等待开启下个阶段
end

function MagicBowl:CheckMaterials(tbMaterials, nCachedValue)
	local nTotalValue = nCachedValue
	for nId, nCount in pairs(tbMaterials) do
		local pItem = KItem.GetItemObj(nId)
		if not pItem then
			return false, "道具不存在"
		end
		if nCount>pItem.nCount then
			return false, "道具数量不足"
		end
		if nCount<=0 then
			return false, "道具数量非法"
		end
		nTotalValue = nTotalValue+(self:GetMaterialValue(pItem)*nCount)
	end
	return true, "", nTotalValue
end

function MagicBowl:GetMaterialValue(pItem)
	local tbItem = self.tbMaterials[pItem.dwTemplateId]
	if not tbItem then
		return 0
	end
	return math.ceil(pItem.nOrgValue*tbItem.nValueRate/100)
end

function MagicBowl:RemoveOldAttrs(pPlayer)
	pPlayer = pPlayer or me
	local tbCurAttrs = pPlayer.tbMBAttrs or {}
	for szType, tbMa in pairs(tbCurAttrs) do
		pPlayer.GetNpc().ChangeAttribValue(szType, -tbMa[1], -tbMa[2], -tbMa[3])
	end
	pPlayer.tbMBAttrs = nil
end

function MagicBowl:RecordOldAttr(pPlayer, szType, tbMa)
	pPlayer.tbMBAttrs = pPlayer.tbMBAttrs or {}
	pPlayer.tbMBAttrs[szType] = tbMa
end

function MagicBowl:GetAttribColor(nEquipLevel, nAttribLevel)
	local nKey = nEquipLevel * 100 + nAttribLevel
	local nAttribColor = self.tbColor[nKey]
	if not nAttribColor then
		Log("[x] MagicBowl:GetAttribColor", nEquipLevel , nAttribLevel)
		return 1
	else
		return nAttribColor
	end
end

if MODULE_GAMECLIENT then
	function MagicBowl:CanRefinement(pItem)
		local tbTarAttribs = House:MagicBowlGetAttrs()
		if not tbTarAttribs then
			return false
		end
		if not next(tbTarAttribs) then
			return true
		end

		local tbSrcAttribs = Item.tbRefinement:GetRandomAttrib(pItem)
		for _, tbAttrib in ipairs(tbSrcAttribs) do
			local bExistSame = false
	        for _, tbTarAttrib in ipairs(tbTarAttribs) do
	            if tbTarAttrib.szAttrib == tbAttrib.szAttrib then
	            	bExistSame = true
	            	if tbAttrib.nAttribLevel > tbTarAttrib.nAttribLevel then
                 		return true
                 	end
	            end
	        end
	        if not bExistSame then
	        	return true
	        end
	    end
	end
end