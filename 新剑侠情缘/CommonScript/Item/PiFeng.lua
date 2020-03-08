Require("CommonScript/Item/Define.lua")

Item.tbPiFeng 	= Item.tbPiFeng or {};
local tbPiFeng 	= Item.tbPiFeng;

tbPiFeng.OPEN_TIME_FRAME = "OpenLevel119" --开放时间轴
tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID = 11906; --鉴定时放入增加属性条目数的入微镜道具id
tbPiFeng.MAX_ATTRI_COUNT = 6; --最大属性条目数
tbPiFeng.MAX_ATTRI_VAL_RAND = 10000; --每个属性等级段的随机范围
tbPiFeng.szIndentiyfyMoneyType = "Coin"; --鉴定消耗的货币类型

--不同阶披风属性类型重随时消耗的道具数量
tbPiFeng.tbRAND_ATTRI_TYPE_ITEM_NUM = {
	[1] = 1;
};
tbPiFeng.RAND_ATTRI_TYPE_COST_ID = 11908;--每次重随属性类型消耗的道具ID

tbPiFeng.RAND_ATTRI_VAL_ITEM_NUM = 2; --数值重随消耗的道具数量
--不同阶披风数值重随时消耗的道具ID
tbPiFeng.tbRAND_ATTRI_VAL_ITEM_ID = {
	[1] = 11907;
};


tbPiFeng.tbIntValKeys = {
	nRandCountType = 1;
	nRandCountLevel = 2;
	AttirbTypeLevel1 = 3;
	AttirbTypeLevel2 = 4;
	AttirbTypeLevel3 = 5;
	AttirbTypeLevel4 = 6;
	AttirbTypeLevel5 = 7;
	AttirbTypeLevel6 = 8;
	AttirbRand1 = 9;
	AttirbRand2 = 10;
	AttirbRand3 = 11;
	AttirbRand4 = 12;
	AttirbRand5 = 13;
	AttirbRand6 = 14;
	TempAttirbType1 = 15; --属性重随时的临时记录
	TempAttirbType2 = 16;
	TempAttirbType3 = 17;
	TempAttirbType4 = 18;
	TempAttirbType5 = 19;
	TempAttirbType6 = 20;
	TempAttribIndex  = 21; --数值重随哪一个的临时记录
	TempAttribRand  = 22;
	TempAttirbTypeLevel = 23;
};

function tbPiFeng:GetAttribFightPowerSetting(  )
	if self.tbAttribFightPowerSetting then
		return self.tbAttribFightPowerSetting
	end
	self.tbAttribFightPowerSetting = LoadTabFile("Setting/Item/RandomAttribPF/AttribLevelFightPower.tab", "ddd", "AttribLevel", {"AttribLevel",	"FightPower",	"AttribValue"});	
	return self.tbAttribFightPowerSetting
end

function tbPiFeng:GetAttribValueSetting( nAttribId, nLevel )
	if self.tbAttribValueSetting then
		return self.tbAttribValueSetting
	end
	local tbFile = LoadTabFile("Setting/Item/RandomAttribPF/AttribLevelValue.tab", "sddddddd", nil, {"Attrib",	"AttribLevel",	"Val1From",	"Val2From",	"Val3From",	"Val1To",	"Val2To","Val3To"});	
	local tbAttribValueSetting = {}
	for i, v in ipairs(tbFile) do
		local nAttribId = Item.tbRefinement:AttribCharToId(v.Attrib)
		tbAttribValueSetting[nAttribId] = tbAttribValueSetting[nAttribId]  or {}
		tbAttribValueSetting[nAttribId][v.AttribLevel] = { {v.Val1From,v.Val2From,v.Val3From },{v.Val1To,v.Val2To,v.Val3To} }
	end
	self.tbAttribValueSetting = tbAttribValueSetting
	return tbAttribValueSetting
end

function tbPiFeng:GetAttriCountSetting( )
	if self.tbAttriCountSetting then
		return self.tbAttriCountSetting
	end
	local szCols = "dd";
	local tbCols = {"Level", "CostItem"}
	for i=1,self.MAX_ATTRI_COUNT do
		table.insert(tbCols, "Count" .. i)
		szCols = szCols .. "d";
	end
	local tbFile = LoadTabFile("Setting/Item/RandomAttribPF/AttribNum.tab", szCols, nil, tbCols);	
	local tbAttriCountSetting  = {}
	for i, v in ipairs(tbFile) do
		tbAttriCountSetting[v.Level] = tbAttriCountSetting[v.Level] or {}
		local tbCountRand = {}
		for j=1,self.MAX_ATTRI_COUNT do
			table.insert(tbCountRand, v["Count" .. j]);
		end
		table.insert(tbAttriCountSetting[v.Level], {nCostItemCount = v.CostItem, tbCountRand = tbCountRand });
	end
	self.tbAttriCountSetting = tbAttriCountSetting
	return tbAttriCountSetting
end

function tbPiFeng:GetMaxAtrriCountByLevel( nLevel )
	local tbSetting = self:GetAttriCountSetting()[nLevel]
	local nMaxCount = 0
	for i,v in ipairs(tbSetting) do
		for i2,v2 in ipairs(v.tbCountRand) do
			if v2 > 0 and i2 > nMaxCount then
				nMaxCount = i2;
			end
		end
	end
	return nMaxCount
end

function tbPiFeng:GetAttriGroupSetting(  )
	if self.tbAttriGroupSetting then
		return self.tbAttriGroupSetting
	end
	local tbFile = LoadTabFile("Setting/Item/RandomAttribPF/AttribGroup.tab","sd",nil,{"Attrib", "Group"} )
	local tbAttriGroupSetting = {}
	local nMaxGroup = 1
	for i,v in ipairs(tbFile) do
		local nAttriId = Item.tbRefinement:AttribCharToId(v.Attrib)
		tbAttriGroupSetting[v.Group] = tbAttriGroupSetting[v.Group] or {}
		table.insert(tbAttriGroupSetting[v.Group], nAttriId)
		if v.Group > nMaxGroup then
			nMaxGroup = v.Group
		end
	end
	self.MAX_ATTRI_GROUP = nMaxGroup
	self.tbAttriGroupSetting = tbAttriGroupSetting
	return tbAttriGroupSetting
end

function tbPiFeng:GetAttriMaxGroup(  )
	if self.MAX_ATTRI_GROUP then
		return self.MAX_ATTRI_GROUP
	end
	self:GetAttriGroupSetting()
	return self.MAX_ATTRI_GROUP
end

function tbPiFeng:GetAttriGroupRandSetting(  )
	if self.tbAttriGroupRandSetting then
		return self.tbAttriGroupRandSetting
	end

	local tbFile = LoadTabFile("Setting/Item/RandomAttribPF/AttribGroupRand.tab","dddd",nil,{ "Level","RandCount", "Group1Count", "Prob"} )
	local tbTemp = {}
	for i,v in ipairs(tbFile) do
		tbTemp[v.Level] = tbTemp[v.Level] or {};
		tbTemp[v.Level][v.RandCount] = tbTemp[v.Level][v.RandCount] or {};
		table.insert(tbTemp[v.Level][v.RandCount], {Group1Count = v.Group1Count, Prob = v.Prob})
	end

	local tbAttriGroupRandSetting = {}
	local fnSort = function ( a, b )
		return a.nRandCount < b.nRandCount
	end
	for k1,v1 in pairs(tbTemp) do
		tbAttriGroupRandSetting[k1] = tbAttriGroupRandSetting[k1] or {};
		for RandCount,v2 in pairs(v1) do
			table.insert(tbAttriGroupRandSetting[k1], {nRandCount = RandCount, tbProb = v2 })
		end
		table.sort( tbAttriGroupRandSetting[k1], fnSort )
	end
	
	self.tbAttriGroupRandSetting = tbAttriGroupRandSetting
	return tbAttriGroupRandSetting
end

function tbPiFeng:GetAttribLevelSetting(  )
	if self.tbAttribLevelSetting then
		return self.tbAttribLevelSetting
	end
	local tbFile = LoadTabFile("Setting/Item/RandomAttribPF/AttribLevel.tab","dddd",nil,{"Level","RandCount","AttribLevel",	"Probility"} )
	local tbTemp = {}
	for i,v in ipairs(tbFile) do
		tbTemp[v.Level] = tbTemp[v.Level] or {}
		tbTemp[v.Level][v.RandCount] = tbTemp[v.Level][v.RandCount] or {}
		table.insert(tbTemp[v.Level][v.RandCount], {AttribLevel = v.AttribLevel, Probility = v.Probility})
	end
	local tbAttribLevelSetting = {}
	local fnSort = function ( a, b )
		return a.nRandCount < b.nRandCount
	end
	for k1,v1 in pairs(tbTemp) do
		tbAttribLevelSetting[k1] = tbAttribLevelSetting[k1] or {}
		for RandCount,v2 in pairs(v1) do
			table.insert(tbAttribLevelSetting[k1], {nRandCount = RandCount, tbProb = v2})
		end
		table.sort(tbAttribLevelSetting[k1], fnSort)
	end
	self.tbAttribLevelSetting = tbAttribLevelSetting
	return tbAttribLevelSetting
end

function tbPiFeng:GetShowAttriCountRate( nLevel, nCostItemCount )
	local tbSetting = self:GetAttriCountSetting()[nLevel]
	local tbCountRand;
	for i,v in ipairs(tbSetting) do
		if nCostItemCount <= v.nCostItemCount then
			tbCountRand = v.tbCountRand
			break;
		end
	end
	if not tbCountRand then
		tbCountRand = tbSetting[#tbSetting].tbCountRand
	end
	return tbCountRand;
end

function tbPiFeng:GetAttriCountMaxRate( nLevel )
	local tbSetting = self:GetAttriCountSetting()[nLevel]
	return tbSetting[#tbSetting]
end

--add完以后手动设值，再 Reinit
function tbPiFeng:ManualGenerate( pPlayer, pEquip, nCostItemCount )
	local nCurHaveCount = pPlayer.GetItemCountInBags(self.ADD_ATTRI_COUNT_ITEM_ID)
	if nCostItemCount > nCurHaveCount then
		pPlayer.CenterMsg("道具数量不足"..nCostItemCount)
		nCostItemCount = nCurHaveCount;
	end
	if nCostItemCount > 0 then
		nCostItemCount = pPlayer.ConsumeItemInBag(self.ADD_ATTRI_COUNT_ITEM_ID, nCostItemCount, Env.LogWay_PiFeng);
	end
	--属性条目，再属性类型，再属性等级
	local nAttriCount, nRandVal = self:GetGenerateAttriCount(pEquip.nLevel,nCostItemCount)
	Log("tbPiFeng:ManualGenerate",pPlayer.dwID, pEquip.nLevel, nCostItemCount, nAttriCount,nRandVal)
	local nRandCountType = 1
	local tbAttriIdList = self:GetRandtbAttriTypes(pEquip.nLevel, nRandCountType,nAttriCount)
	self:SetItemIntVal( pEquip, "nRandCountType", nRandCountType + 1)
	
	local tbAttriIds = {}
	for i,v in ipairs(tbAttriIdList) do
		tbAttriIds[v] = 1;
	end
	local nRandCountLevel = 1;
	self:RandAttriLevel(tbAttriIds, nRandCountLevel, pEquip.nLevel)
	self:SetItemIntVal(pEquip, "nRandCountLevel", nRandCountLevel + 1)

	--记录属性id 和属性level
	local nIndex = 0;
	for nAttribId, nLevel in pairs(tbAttriIds) do
		nIndex = nIndex + 1;
		local nSaveId = Item.tbRefinement:AttribToSaveData(nAttribId, nLevel)
		self:SetItemIntVal(pEquip, "AttirbTypeLevel" .. nIndex, nSaveId)
		local nRand = MathRandom(self.MAX_ATTRI_VAL_RAND)
		self:SetItemIntVal(pEquip, "AttirbRand" .. nIndex, nRand)
	end
	pEquip.ReInit()
end

function tbPiFeng:InitEquip(pEquip)
	local tbAttribs = self:GetRandomAttrib(pEquip); --根据intval 转成 属性id 和等级是和洗练是一样的
	local nMaxQuality = 0;
	local nRefineValue = 0;
	local nRefinePower = 0;
	local tbAttribFightPowerSetting = self:GetAttribFightPowerSetting()
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local nQuality = Item.tbRefinement:GetAttribColor(pEquip.nLevel, tbAttrib.nAttribLevel);
		pEquip.SetRandAttrib(nIdx, tbAttrib.szAttrib, unpack(tbAttrib.tbValues))
		local tbFightPowerSeting = tbAttribFightPowerSetting[tbAttrib.nAttribLevel]
		nRefineValue = nRefineValue + tbFightPowerSeting.AttribValue
		nRefinePower = nRefinePower + tbFightPowerSeting.FightPower
		
		if nMaxQuality < nQuality then
			nMaxQuality = nQuality;
		end
	end
	
	return nRefinePower, nRefineValue, nMaxQuality;
end

function tbPiFeng:GetAttribValue( nAttribId, nLevel, nRand )
	local tbAttribLevel = self:GetAttribValueSetting()[nAttribId][nLevel]
	local fRate = nRand / self.MAX_ATTRI_VAL_RAND
	local tbRet = {}
	for i=1,3 do
		local nFrom, nTo = tbAttribLevel[1][i],tbAttribLevel[2][i]
		local nVal = math.floor(nFrom + (nTo - nFrom) * fRate + 0.5) 
		nVal = math.min(nTo, math.max( nFrom, nVal ));
		table.insert(tbRet, nVal)
	end
	return tbRet
end

function tbPiFeng:GetRandomAttribTempIds( pEquip)
	local tbAttribs = {};
	for i=1,self.MAX_ATTRI_COUNT do
		local nSaveData =  self:GetItemIntValue(pEquip, "TempAttirbType" .. i);
		if nSaveData == 0 then
			break;
		else
			local nAttribId, nAttribLevel 	= Item.tbRefinement:SaveDataToAttrib(nSaveData);
			local szAttrib 	= Item.tbRefinement:AttribIdToChar(nAttribId);
			local nRand = self:GetItemIntValue(pEquip, "AttirbRand" .. i)
			local tbValues  = self:GetAttribValue(nAttribId, nAttribLevel, nRand);
			table.insert(tbAttribs,
			{
				szAttrib 		= szAttrib,
				nAttribLevel 	= nAttribLevel;
				tbValues 		= tbValues;
				nAttribId 		= nAttribId,
				nSaveData 		= nSaveData;
			})
		end
	end
	return tbAttribs
end

function tbPiFeng:GetMaxAttribLevelByEquipLevel( nEquipLevel )
	local tbSetting = self:GetAttribLevelSetting()[nEquipLevel]
	local tbProb = tbSetting[#tbSetting].tbProb ;
	return tbProb[#tbProb].AttribLevel
end

function tbPiFeng:GetMaxRandomAttribValue( nAttribId, nEquipLevel )
	local tbSetting = self:GetAttribLevelSetting()[nEquipLevel]
	local tbProb = tbSetting[#tbSetting].tbProb ;
	local AttribLevel = tbProb[#tbProb].AttribLevel
	local tbAttribLevel = self:GetAttribValueSetting()[nAttribId][AttribLevel]
	return tbAttribLevel[2];
end

function tbPiFeng:GetRandomAttrib( pEquipOrTab )
	local tbAttribs = {};
	for i=1,self.MAX_ATTRI_COUNT do
		local nSaveData =  self:GetItemIntValue(pEquipOrTab, "AttirbTypeLevel" .. i);
		if nSaveData == 0 then
			break;
		else
			local nRand = self:GetItemIntValue(pEquipOrTab, "AttirbRand" .. i);
			local nAttribId, nAttribLevel 	= Item.tbRefinement:SaveDataToAttrib(nSaveData);
			local szAttrib 	= Item.tbRefinement:AttribIdToChar(nAttribId);
			local tbValues  = self:GetAttribValue(nAttribId, nAttribLevel, nRand);
			table.insert(tbAttribs,
			{
				szAttrib 		= szAttrib,
				nAttribLevel 	= nAttribLevel;
				tbValues 		= tbValues;
				nAttribId 		= nAttribId,
				nSaveData 		= nSaveData,
				nRand 			= nRand,
			})
		end
	end
	return tbAttribs;
end


function tbPiFeng:GetItemIntValue( pEquipOrTab, szKey )
	local nKey = self.tbIntValKeys[szKey]
	if not nKey then
		Log(debug.traceback(),szKey)
		return
	end
	if type(pEquipOrTab) == "table" then
		return pEquipOrTab[nKey] or 0
	else
		return pEquipOrTab.GetIntValue(nKey)
	end
end

function tbPiFeng:SetItemIntVal( pItem, szKey, nVal )
	local nKey = self.tbIntValKeys[szKey]
	if not nKey then
		Log(debug.traceback(),szKey, nVal)
		return
	end
	pItem.SetIntValue(nKey, nVal)
end

function tbPiFeng:RandAttriLevel( tbAttriIds, nRandCountLevel, nLevel )
	local tbSetting = self:GetAttribLevelSetting()[nLevel]
	local tbProb;
	for i,v in ipairs(tbSetting) do
		if nRandCountLevel <= v.nRandCount then
			tbProb = v.tbProb
			break;
		end
	end
	if not tbProb then
		tbProb = tbSetting[#tbSetting].tbProb
	end
	local nTotal = 0
	for i,v in ipairs(tbProb) do
		nTotal = nTotal + v.Probility
	end
	for k,v in pairs(tbAttriIds) do
		local nRand = MathRandom(nTotal)

		local nTemp = 0;
		for i2,v2 in ipairs(tbProb) do
			nTemp = nTemp + v2.Probility
			if nRand <= nTemp then
				tbAttriIds[k] = v2.AttribLevel
				Log("tbPiFeng:RandAttriLevel", nRandCountLevel, nLevel,k,nRand, v2.AttribLevel)
				break;
			end
		end
	end
end


function tbPiFeng:GetRandtbAttriTypes( nLevel, nRandCount, nAttriCount, tbForbitIds)
	local tbSetting = self:GetAttriGroupRandSetting()[nLevel]
	local tbProb = tbSetting[1].tbProb ;
	for i,v in ipairs(tbSetting) do
		if nRandCount >= v.nRandCount then
			tbProb = v.tbProb
		else
			break;
		end
	end
	local nTotal = 0;
	for i,v in ipairs(tbProb) do
		nTotal = nTotal + v.Prob;
	end
	
	local nGroup1Count = 0
	local nRand = MathRandom(nTotal)
	local nTemp = 0
	for i,v in ipairs(tbProb) do
		nTemp = nTemp + v.Prob
		if nRand <= nTemp then
			nGroup1Count = v. Group1Count
			break;
		end
	end	
	local tbRetAtrtiGroups = {}
	for j=1,nAttriCount do
		if j <= nGroup1Count then
			table.insert(tbRetAtrtiGroups, 1)
		else
			table.insert(tbRetAtrtiGroups, 2)
		end
	end
	local tbAttriIds = {}
	local tbAttriGroupSetting = Lib:CopyTB(self:GetAttriGroupSetting()) 
	if tbForbitIds and next(tbForbitIds) then
		for i1,v1 in ipairs(tbAttriGroupSetting) do
			for i2=#v1,1,-1 do
				if  tbForbitIds[v1[i2]] then
					table.remove(v1, i2)
				end
			end
		end
	end
	for i,nGroupId in ipairs(tbRetAtrtiGroups) do
		local tbGroups = tbAttriGroupSetting[nGroupId]
		if #tbGroups == 0 then
			Log(debug.traceback())
		else
			local nAttriId = table.remove(tbGroups, MathRandom(1,#tbGroups))
			table.insert(tbAttriIds, nAttriId)
		end
	end
	return tbAttriIds
end

function tbPiFeng:GetGenerateAttriCount( nLevel, nCostItemCount )
	local tbSetting = self:GetAttriCountSetting()[nLevel]
	local tbCountRand;
	for i,v in ipairs(tbSetting) do
		if nCostItemCount <= v.nCostItemCount then
			tbCountRand = v.tbCountRand
			break;
		end
	end
	if not tbCountRand then
		tbCountRand = tbSetting[#tbSetting].tbCountRand
	end
	local nTotal = 0;
	for i,v in ipairs(tbCountRand) do
		nTotal = nTotal + v;
	end
	local nRand = MathRandom(nTotal)
	local nTempTotal = 0;
	for i,v in ipairs(tbCountRand) do
		nTempTotal = nTempTotal + v;
		if nRand <= nTempTotal then
			return i, nRand;
		end
	end
end

function tbPiFeng:Unidentify( pPlayer, nItemId, nCostItemCount )
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		pPlayer.CenterMsg("道具不存在")
		return
	end
	if pItem.nUseLevel > pPlayer.nLevel then
		pPlayer.CenterMsg(string.format("%d级之后可使用", pItem.nUseLevel))
		return
	end
	local nCostMoney = self:GetIdentifyCost(pItem.dwTemplateId)
	if pPlayer.GetMoney(self.szIndentiyfyMoneyType) < nCostMoney then
		pPlayer.CenterMsg("鉴定消耗的银两不足")
		return
	end

	local nHaveItemCount2 = pPlayer.GetItemCountInBags(self.ADD_ATTRI_COUNT_ITEM_ID)
	if nHaveItemCount2 < nCostItemCount then
		pPlayer.CenterMsg(string.format("您的消耗道具数量不足%d个", nCostItemCount))
		return 
	end
	if not pPlayer.CostMoney(self.szIndentiyfyMoneyType, nCostMoney, Env.LogWay_IdentifyEquip) then
		return
	end
	local nEquipTemplateId = KItem.GetItemExtParam(pItem.dwTemplateId, 1);
	if pPlayer.ConsumeItem(pItem, 1, Env.LogWay_PiFeng) ~= 1 then
		return
	end
	local pItem = pPlayer.AddItem(nEquipTemplateId, 1, nil, Env.LogWay_PiFeng)
	tbPiFeng:ManualGenerate(pPlayer,pItem, nCostItemCount)
	pPlayer.CallClientScript("Item.tbPiFeng:OnClientUnidentifySuccess", pItem.dwId)
end

function tbPiFeng:DoEvolution( pPlayer, nItemId )
	local bRet,szMsg,pItemPass = Item.GoldEquip:CanEvolution(pPlayer, nItemId)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	local pCurEquip = pPlayer.GetEquipByPos(pItemPass.nEquipPos)
	local bEquiped = false
	if pCurEquip and pCurEquip.dwId == pItemPass.dwId then
		bEquiped = true
	end
	local tbItemInVals = {};
	for i=1,self.MAX_ATTRI_COUNT do
		local nVal = self:GetItemIntValue(pItemPass, "AttirbTypeLevel" .. i)
		if nVal > 0 then
			tbItemInVals["AttirbTypeLevel" .. i] = nVal;
		end
		local nVal = self:GetItemIntValue(pItemPass, "AttirbRand" .. i)
		if nVal > 0 then
			tbItemInVals["AttirbRand" .. i] = nVal;
		end
	end
	local nTemplateIdSrc = pItemPass.dwTemplateId
	local tbSetting = Item.GoldEquip.tbEvolutionSetting[nTemplateIdSrc]
	local tbConsumeSetting = Item.GoldEquip:GetEvolutionConsumeSetting(pPlayer, pItemPass)
	local tbHideID = { [nItemId] = 1 };
	for i,v in ipairs(tbConsumeSetting) do
		local nCosumeItem, nConsumeCount = unpack(v)
		if pPlayer.ConsumeItemInBag(nCosumeItem, nConsumeCount, Env.LogWay_GoldEquipEvo, tbHideID) ~= nConsumeCount then
			Log(pPlayer.dwID, debug.traceback())
			return
		end
	end
	local nOrgEquipLevel = pItemPass.nLevel
	if  pPlayer.ConsumeItem(pItemPass, 1, Env.LogWay_GoldEquipEvo) ~= 1 then
		Log(debug.traceback(), pPlayer.dwID)
		return
	end
	local pItemTar = pPlayer.AddItem(tbSetting.TarItem, 1, nil, Env.LogWay_GoldEquipEvo);
	if not pItemTar then
		Log(debug.traceback(), pPlayer.dwID)
		return
	end
	local nTarLevel = pItemTar.nLevel
	
	local nMaxAtrriCountOrg = Item.tbPiFeng:GetMaxAtrriCountByLevel(nOrgEquipLevel)
	local nMaxAtrriCountTar = Item.tbPiFeng:GetMaxAtrriCountByLevel(nTarLevel)
	local nAddAttriCount = nMaxAtrriCountTar - nMaxAtrriCountOrg;
	if nAddAttriCount > 0 then
		local tbForbitIds = {};
		local nCurAttriCount = 0
		for i=1,self.MAX_ATTRI_COUNT do
			local nVal = tbItemInVals["AttirbTypeLevel" .. i]
			if nVal and nVal > 0 then
				local nAttribId, nAttrLevel = Item.tbRefinement:SaveDataToAttrib(nVal)				
				tbForbitIds[nAttribId] = 1;
				nCurAttriCount = nCurAttriCount + 1;
			end
		end

		local tbAttriIdList = self:GetRandtbAttriTypes( nTarLevel, 1, nAddAttriCount, tbForbitIds)
		local tbAttriIds = {}
		for i,v in ipairs(tbAttriIdList) do
			tbAttriIds[v] = 1
		end
		self:RandAttriLevel(tbAttriIds, 0, nTarLevel)

		for nAttribId, nAttrLevel in pairs(tbAttriIds) do
			nCurAttriCount = nCurAttriCount + 1;
			tbItemInVals["AttirbTypeLevel" .. nCurAttriCount] = Item.tbRefinement:AttribToSaveData(nAttribId, nAttrLevel)
			tbItemInVals["AttirbRand" .. nCurAttriCount] = MathRandom(self.MAX_ATTRI_VAL_RAND);
		end
	end

	-- 多加一条指定的属性差
	for k,v in pairs(tbItemInVals) do
		self:SetItemIntVal(pItemTar, k,v)
	end
	self:SetItemIntVal( pItemTar, "nRandCountType", 1)
	pItemTar.ReInit();
	pPlayer.TLog("EquipFlow", pItemTar.nItemType, pItemTar.dwTemplateId, pItemTar.dwId, 1, Env.LogWay_GoldEquipEvo, 0, 2, pItemTar.GetIntValue(1),pItemTar.GetIntValue(2), pItemTar.GetIntValue(3), pItemTar.GetIntValue(4), pItemTar.GetIntValue(5),pItemTar.GetIntValue(6), 0, "");
	if bEquiped then
		Item:UseEquip(pItemTar.dwId, false, pItemTar.nEquipPos)
	end
	pPlayer.CallClientScript("Item.tbPiFeng:OnClientEvolutionSuccess")
end

function tbPiFeng:CanReRandomAttriNum( pPlayer, nItemId,nIndex )
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		return false, "道具不存在"
	end
	local nCostItemId = self.tbRAND_ATTRI_VAL_ITEM_ID[pItem.nLevel]
	if not nCostItemId then
		return false, "没有消耗道具配置"
	end
	local nCurHaveCount = pPlayer.GetItemCountInBags(nCostItemId)
	if nCurHaveCount <  self.RAND_ATTRI_VAL_ITEM_NUM then
		local tbItemBase = KItem.GetItemBaseProp(nCostItemId)
		return false, string.format("%s数量不足", tbItemBase.szName) 
	end
	return pItem,nil,nCostItemId
end

function tbPiFeng:CanReRandomAttriTypes( pPlayer, nItemId, nCostNumAddAttNum)
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		return false, "道具不存在"
	end
	local nCostItemNum = self.tbRAND_ATTRI_TYPE_ITEM_NUM[pItem.nLevel]
	if not nCostItemNum then
		return false, "没有消耗道具配置"
	end
	if pPlayer.GetItemCountInBags(self.ADD_ATTRI_COUNT_ITEM_ID) < nCostNumAddAttNum then
		local tbItemBase = KItem.GetItemBaseProp(self.ADD_ATTRI_COUNT_ITEM_ID)
		return false, string.format("%s数量不足%d个", tbItemBase.szName,nCostNumAddAttNum) 
	end
	local nCurHaveCount = pPlayer.GetItemCountInBags(self.RAND_ATTRI_TYPE_COST_ID)
	if nCurHaveCount < nCostItemNum then
		local tbItemBase = KItem.GetItemBaseProp(self.RAND_ATTRI_TYPE_COST_ID)
		return false, string.format("%s数量不足%d个", tbItemBase.szName,nCostItemNum) 
	end
	return pItem,nil,nCostItemNum
end

function tbPiFeng:ClientReRandomATChooseOld( nItemId )
	RemoteServer.PiFengReq("ReRandomATChooseOld", nItemId)
end

function tbPiFeng:ClientReRandomATChooseNew( nItemId )
	RemoteServer.PiFengReq("ReRandomATChooseNew", nItemId)
end

function tbPiFeng:ClientDoEvolution( nItemId )
	local bRet,szMsg,pItem = Item.GoldEquip:CanEvolution(me, nItemId)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	RemoteServer.PiFengReq("DoEvolution", nItemId)
end

function tbPiFeng:ClientRefineAttriNumPF( nItemId , nIndex)
	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	local nTempAttribIndex = Item.tbPiFeng:GetItemIntValue(pItem, "TempAttribIndex")
	if nTempAttribIndex == 0 then
		local pItem,szMsg,nCostItemNum = self:CanReRandomAttriNum(me, nItemId,nIndex)
		if not pItem then
			me.CenterMsg(szMsg)
			return
		end
		RemoteServer.PiFengReq("ReRandomAttriNum", nItemId, nIndex)	
	else
		if nTempAttribIndex ~= nIndex then
			me.CenterMsg("请选确定上次的属性选择")
			return
		end
		RemoteServer.PiFengReq("ConfirmReRandomAttriNum", nItemId)	
	end
	
end

function tbPiFeng:ClientReRandomAttriTypes( nItemId , bConfirm, nCostNumAddAttNum )
	nCostNumAddAttNum = nCostNumAddAttNum or 0
	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	if self:GetItemIntValue(pItem, "TempAttirbType" .. 1) > 0 and not bConfirm then
		Ui:CloseWindow("EquipTips")
		Ui:OpenWindow("CloakAttributeRandomPanel", nItemId)
		return
	end
	
	local fnYes = function ( )
		Ui:CloseWindow("EquipTips")
		RemoteServer.PiFengReq("ReRandomAttriTypes", nItemId,nCostNumAddAttNum)
	end
	if bConfirm then
		fnYes()
	else
		Ui:CloseWindow("EquipTips")
		Ui:OpenWindow("CloakAttributeRandomPanel", nItemId)
	end
end

function tbPiFeng:OnClientEvolutionSuccess( nItemId )
	me.CenterMsg("升阶成功")
	Ui:CloseWindow("CloakUpgradePanel")
end

function tbPiFeng:OnClientReRandomAttriTypes( nItemId , nCostNumAddAttNum)
	if not Ui:WindowVisible("CloakAttributeRandomPanel") then
		Ui:OpenWindow("CloakAttributeRandomPanel", nItemId,nCostNumAddAttNum)
	else
		UiNotify.OnNotify(UiNotify.emNOTIFY_PI_FENG_SYNC_DATA, "ReRandomAttriTypes", nItemId, nCostNumAddAttNum)	
	end
end

function tbPiFeng:OnClientReRandomAttriNum( nItemId )
	UiNotify.OnNotify(UiNotify.emNOTIFY_PI_FENG_SYNC_DATA, "ReRandomAttriNum", nItemId)	
end

function tbPiFeng:OnClientUnidentifySuccess( nItemId )
	Ui:CloseWindow("CloakAppraisalPanel")
	Ui:OpenWindow("BgBlackAll", false,Ui.LAYER_NORMAL,545015)
	Timer:Register(math.floor(Env.GAME_FPS * 1.3), function (  )
		Ui:CloseWindow("BgBlackAll")
		Item:ShowItemDetail({nItemId = nItemId, nFaction = me.nFaction, nSex = me.nSex});
	end)
end

function tbPiFeng:ReRandomATChooseOld( pPlayer, nItemId )
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	for i=1,self.MAX_ATTRI_COUNT do
		self:SetItemIntVal(pItem, "TempAttirbType" .. i, 0)
	end
	pPlayer.CallClientScript("Ui:CloseWindow", "CloakAttributeRandomPanel")
end

function tbPiFeng:ReRandomATChooseNew( pPlayer, nItemId )
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	local tbNewAttribs = Item.tbPiFeng:GetRandomAttribTempIds(pItem)

	for i,tbNew in ipairs(tbNewAttribs) do
		self:SetItemIntVal(pItem, "TempAttirbType" .. i, 0)
		self:SetItemIntVal(pItem, "AttirbTypeLevel" .. i, tbNew.nSaveData)
	end
	pItem.ReInit();
	FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(pItem.nEquipPos), pPlayer)
	pPlayer.CallClientScript("Ui:CloseWindow", "CloakAttributeRandomPanel")
end

function tbPiFeng:ConfirmReRandomAttriNum( pPlayer, nItemId )
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		pPlayer.CenterMsg("道具不存在")
		return
	end
	local nTempAttribIndex = Item.tbPiFeng:GetItemIntValue(pItem, "TempAttribIndex")
	if nTempAttribIndex == 0 then
		pPlayer.CenterMsg("无可确认的属性")
		return
	end
	local nNewRandIndex = Item.tbPiFeng:GetItemIntValue(pItem, "TempAttribIndex")
	local nNewRand = Item.tbPiFeng:GetItemIntValue(pItem, "TempAttribRand")
	local nOldRand = Item.tbPiFeng:GetItemIntValue(pItem, "AttirbRand" .. nNewRandIndex)
	local nNewLevel = self:GetItemIntValue(pItem,"TempAttirbTypeLevel")
	local nOldSaveId = self:GetItemIntValue(pItem, "AttirbTypeLevel" .. nNewRandIndex)
	local nAttribId, nOldAttribLevel 	= Item.tbRefinement:SaveDataToAttrib(nOldSaveId);

	self:SetItemIntVal(pItem, "TempAttribRand", 0)
	self:SetItemIntVal(pItem, "TempAttribIndex", 0)
	self:SetItemIntVal(pItem, "TempAttirbTypeLevel", 0)
	if  nNewLevel > nOldAttribLevel or (nNewLevel == nOldAttribLevel and nNewRand > nOldRand) then
		local nNewSaveId = Item.tbRefinement:AttribToSaveData(nAttribId, nNewLevel) 
		self:SetItemIntVal(pItem, "AttirbTypeLevel" .. nNewRandIndex, nNewSaveId)
		self:SetItemIntVal(pItem, "AttirbRand" .. nNewRandIndex, nNewRand)
		pItem.ReInit()
		FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(pItem.nEquipPos), pPlayer)
	end
	pPlayer.CallClientScript("Item.tbPiFeng:OnClientReRandomAttriNum", nItemId)
end

function tbPiFeng:ReRandomAttriNum( pPlayer, nItemId, nIndex )
	local pItem,szMsg,nCostItemId = self:CanReRandomAttriNum(pPlayer, nItemId,nIndex)
	if not pItem then
		pPlayer.CenterMsg(szMsg)
		return
	end
	local tbAttribs = self:GetRandomAttrib(pItem)
	local tbAttrib = tbAttribs[nIndex]
	if not tbAttrib then
		pPlayer.CenterMsg("您没有该条属性")
		return
	end
	if pPlayer.ConsumeItemInBag(nCostItemId, self.RAND_ATTRI_VAL_ITEM_NUM,Env.LogWay_PiFeng) ~= self.RAND_ATTRI_VAL_ITEM_NUM then
		pPlayer.CenterMsg("消耗失败")
		return
	end
	
	local nAttribId = tbAttrib.nAttribId
	local tbAttriIds = {[nAttribId] = 1}
	local nRandCountLevel = self:GetItemIntValue(pItem, "nRandCountLevel");
	self:RandAttriLevel(tbAttriIds, nRandCountLevel, pItem.nLevel)
	--如果是随到该等级最大属性等级，则 nRandCountLevel 重置到1
	local nMaxAttribLevel = self:GetMaxAttribLevelByEquipLevel(pItem.nLevel)
	if nMaxAttribLevel == tbAttriIds[nAttribId]  then
		self:SetItemIntVal(pItem, "nRandCountLevel", 1)	
	else
		self:SetItemIntVal(pItem, "nRandCountLevel", nRandCountLevel + 1)	
	end
	
	local nRand = MathRandom(self.MAX_ATTRI_VAL_RAND)
	self:SetItemIntVal(pItem, "TempAttirbTypeLevel", tbAttriIds[nAttribId])
	self:SetItemIntVal(pItem, "TempAttribRand", nRand)
	self:SetItemIntVal(pItem, "TempAttribIndex", nIndex)
	
	pPlayer.CallClientScript("Item.tbPiFeng:OnClientReRandomAttriNum", nItemId)
end

function tbPiFeng:ReRandomAttriTypes( pPlayer, nItemId ,nCostNumAddAttNum)
	local pItem,szMsg, nCostItemNum = self:CanReRandomAttriTypes(pPlayer, nItemId, nCostNumAddAttNum)
	if not pItem then
		pPlayer.CenterMsg(szMsg)
		return
	end
	if pPlayer.ConsumeItemInBag(self.RAND_ATTRI_TYPE_COST_ID, nCostItemNum,Env.LogWay_PiFeng) ~= nCostItemNum then
		return
	end
	if pPlayer.ConsumeItemInBag(self.ADD_ATTRI_COUNT_ITEM_ID, nCostNumAddAttNum,Env.LogWay_PiFeng) ~= nCostNumAddAttNum then
		return
	end
	local nEquipLevel = pItem.nLevel
	local nNewAttriCount, nRandVal = self:GetGenerateAttriCount(nEquipLevel,nCostNumAddAttNum)
	

	local tbOldAttribs = self:GetRandomAttrib( pItem )
	if #tbOldAttribs >= nNewAttriCount then
		nNewAttriCount = #tbOldAttribs
	else
		for i=#tbOldAttribs + 1,nNewAttriCount do
			self:SetItemIntVal(pItem, "AttirbRand" .. i, MathRandom(self.MAX_ATTRI_VAL_RAND))
		end
	end
	local nRandCountType = self:GetItemIntValue(pItem, "nRandCountType")
	local tbAttriIdList = self:GetRandtbAttriTypes(nEquipLevel, nRandCountType, nNewAttriCount)
	Log("tbPiFeng:ReRandomAttriTypes",pPlayer.dwID, nEquipLevel, nCostNumAddAttNum, nNewAttriCount, nRandVal,nRandCountType)
	self:SetItemIntVal( pItem, "nRandCountType", nRandCountType + 1)
	for i=1,self.MAX_ATTRI_COUNT do
		local nAttribId = tbAttriIdList[i]
		if nAttribId and nAttribId > 0 then
			local nAttribLevel;
			local tbOldAttrib = tbOldAttribs[i]	
			if tbOldAttrib then
				nAttribLevel = tbOldAttrib.nAttribLevel
			else
				local tbAttriIds = {[nAttribId] = 1}
				self:RandAttriLevel(tbAttriIds , 0, nEquipLevel )				
				nAttribLevel = tbAttriIds[nAttribId];
			end
			local nSaveId = Item.tbRefinement:AttribToSaveData(nAttribId, nAttribLevel) 
			self:SetItemIntVal(pItem, "TempAttirbType" .. i, nSaveId)
		else
			self:SetItemIntVal(pItem, "TempAttirbType" .. i, 0)
		end
	end

	pPlayer.CallClientScript("Item.tbPiFeng:OnClientReRandomAttriTypes", nItemId, nCostNumAddAttNum)
end

function tbPiFeng:HidePiFeng( pPlayer, bHide )
	local bCurHide = Item.tbChangeColor:IsResPartHide( pPlayer, Npc.NpcResPartsDef.npc_part_wing)
	if bHide == bCurHide then
		return
	end
	local nHide = bHide and 1 or 0;
	Item.tbChangeColor:ChangeResPartHide( pPlayer, Npc.NpcResPartsDef.npc_part_wing ,nHide)
end

function tbPiFeng:GetIdentifyCost(dwTemplateId)
	local tbBaseInfo = KItem.GetItemBaseProp(dwTemplateId)
	return math.floor(tbBaseInfo.nValue * 0.05)
end

function tbPiFeng:GetFightPowerFromSaveAttri( tbSaveRandomAttrib )
	local nRefinePower = 0
	local tbAttribs = self:GetRandomAttrib(tbSaveRandomAttrib)
	local tbAttribFightPowerSetting = self:GetAttribFightPowerSetting()
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local tbFightPowerSeting = tbAttribFightPowerSetting[tbAttrib.nAttribLevel]
		nRefinePower = nRefinePower + tbFightPowerSeting.FightPower
	end
	return nRefinePower
end


local tbInterFace = {
	Unidentify = 1;
	ReRandomAttriTypes = 1;
	ReRandomATChooseOld = 1;
	ReRandomATChooseNew = 1;
	ReRandomAttriNum = 1;
	ConfirmReRandomAttriNum = 1;
	DoEvolution = 1;
	HidePiFeng = 1;
}
function tbPiFeng:OnReq( pPlayer,szFunc, ... )
	if not tbInterFace[szFunc] then
		return
	end
	self[szFunc](self,pPlayer,...)
end

--todo
function tbPiFeng:DataCheck(  )
	-- 服务端检查 
	--每个group的属性条目数应该大于6条
	-- AttribGroup.tab 都有对应的id
	self:GetAttriCountSetting()
	self:GetAttriGroupSetting()
	assert(tbPiFeng.tbIntValKeys["AttirbTypeLevel" .. tbPiFeng.MAX_ATTRI_COUNT])   
	assert(tbPiFeng.tbIntValKeys["AttirbRand" .. tbPiFeng.MAX_ATTRI_COUNT])   
end
