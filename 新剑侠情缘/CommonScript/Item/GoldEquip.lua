Require("CommonScript/Item/Define.lua")

Item.GoldEquip 			= Item.GoldEquip or {};
local GoldEquip 		= Item.GoldEquip;
GoldEquip.COLOR_ACTVIED 	= "ActiveGreen"; --激活的熟悉颜色
GoldEquip.COLOR_UN_ACTVIED 	= "ASctiveGrey"; --未激活的属性颜色

GoldEquip.UP_TO_PLATINUM_MIN_LEVEL = 10; --最低是10阶的黄金装备才可以进化到白金
GoldEquip.tbAchieventmentPos = {
	[Item.DetailType_Gold] = {
		[Item.EQUIPPOS_BODY] = "GoldArmor";
		[Item.EQUIPPOS_HEAD] = "GoldHead";
	};
	[Item.DetailType_Platinum] = {
		[Item.EQUIPPOS_BODY] = "PlatinumArmor";
		[Item.EQUIPPOS_HEAD] = "PlatinumHead";
	};
}

-- GoldEquip.GOLD_QUALITY_COLOR = 7;
GoldEquip.DetailTypeColorQuality = { --黄金，白金的品质颜色
	[Item.DetailType_Gold] = 7;
	[Item.DetailType_Platinum] = 9;
}
--随机属性加成等级对应的颜色quality
GoldEquip.tbAddExtAttriColorQuality = {
	[1] =  5;
	[2] =  6;
	[3] =  7;
}

--享有黄金以上装备特效的类型，强化、镶嵌跟等级走
GoldEquip.DetailTypeGoldUp = {
	[Item.DetailType_Gold] = "黄金";
	[Item.DetailType_Platinum] = "白金";
};

GoldEquip.MAX_ATTRI_NUM = 3
GoldEquip.MAX_TRAIN_ATTRI_LEVEL = 15 ;--养成属性的最大属性等级为15级
GoldEquip.UPGRADE_MAX_TIMEFRAME_C = 10;
function GoldEquip:Init()
	self.tbEvolutionSetting = LoadTabFile(
	"Setting/Item/GoldEquip/Evolution.tab",
	"dddddddddddds", "SrcItem",
	{"SrcItem", "TarItem", "CosumeItem1", "ConsumeCount1", "CosumeItem2", "ConsumeCount2", "CosumeItem3", "ConsumeCount3", "CosumeItemBAK1","ConsumeCountBAK1","CosumeItemBAK2","ConsumeCountBAK2", "TimeFrame"});

	local szCols = "ddddd"
	local tbCols = {"SrcItem", "TarItem", "CosumeItem", "Cosume2Item", "Consume2Count"};
	for i=1,self.UPGRADE_MAX_TIMEFRAME_C do
		szCols = szCols .. "sd"
		table.insert(tbCols, "TimeFrame" .. i)
		table.insert(tbCols, "ConsumeCount" .. i)
	end
	self.tbEvolutionUpgradeSetting = LoadTabFile(
	"Setting/Item/GoldEquip/EvolutionUpgrade.tab", szCols, "SrcItem", tbCols);

	self.tbSuitIndex = LoadTabFile("Setting/Item/GoldEquip/SuitEquip.tab","ddd", "ItemId", {"SuitIndex", "Level", "ItemId" });
	local tbCols = {"SuitIndex"}
	local szCols = "d"
	for i=1, self.MAX_ATTRI_NUM do
		table.insert(tbCols, "ActiveNum" .. i)
		szCols = szCols .. "d";
	end
	self.tbSuitActiveSetting = LoadTabFile(
		"Setting/Item/GoldEquip/SuitActive.tab",
		szCols, "SuitIndex", tbCols);
	local tbFile = LoadTabFile(
		"Setting/Item/GoldEquip/SuitLevelAttrib.tab",
		"ddd", nil, {"SuitIndex","ActiveLevel","AttriGroup"});
	self.tbSuitLevelAttrib = {};
	for i,v in ipairs(tbFile) do
		self.tbSuitLevelAttrib[v.SuitIndex] = self.tbSuitLevelAttrib[v.SuitIndex] or {};
		self.tbSuitLevelAttrib[v.SuitIndex][v.ActiveLevel] = v.AttriGroup;
	end



	local tbCols = {"Item",	"AttribGroup", "CostItemId"};
	local szCols = "ddd";
	for i=1,self.MAX_TRAIN_ATTRI_LEVEL do
		table.insert(tbCols, "CostItemCount" .. i)
		table.insert(tbCols, "CostCoin" .. i)
		szCols = szCols .. "d";
	end
	self.tbTrainAttriSetting = LoadTabFile(
		"Setting/Item/GoldEquip/TrainAtriEquip.tab",
		szCols, "Item",
		 tbCols);

	self.tbGoldExternAttrib = LoadTabFile(
	"Setting/Item/GoldEquip/GoldExternAttrib.tab",
	"dddddd", "nEquipLevel",
	{"nEquipLevel","nModifyLevel", "nAddLevel4", "nMaxLevel4", "nAddLevel5", "nMaxLevel5"});

	self.tbGoldEquipTypeAddLevel = {};
	local tbItemType = {Item.EQUIP_WEAPON;
					Item.EQUIP_HELM;
					Item.EQUIP_NECKLACE;
					Item.EQUIP_CUFF;
					Item.EQUIP_RING;
					Item.EQUIP_ARMOR;
					Item.EQUIP_PENDANT;
					Item.EQUIP_BELT;
					Item.EQUIP_AMULET;
					Item.EQUIP_BOOTS;
				}
	for i,v in ipairs(tbItemType) do
		self.tbGoldEquipTypeAddLevel[v] = i -1;
	end

	self.tbExternSetting = LoadTabFile(
	"Setting/Item/GoldEquip/GoldExternSetting.tab",
	"dddd", nil,
	{"nPlayerLevel", "nEquipLevel",	"nHoleCount", "nInsetLevel"});
end



GoldEquip:Init()


function GoldEquip:GetSuitEquipPosSetting( nSuitIndex )
	if not self.tbSuitEquipPosSetting then
		self.tbSuitEquipPosSetting = {};
		for ItemId,v in pairs(self.tbSuitIndex) do
			local SuitIndex = v.SuitIndex
			self.tbSuitEquipPosSetting[SuitIndex] = self.tbSuitEquipPosSetting[SuitIndex] or {};
			local nEquipPos = KItem.GetEquipPos(ItemId)
			if nEquipPos then
				self.tbSuitEquipPosSetting[SuitIndex][nEquipPos] = 1;
			end
		end
	end
	return self.tbSuitEquipPosSetting[nSuitIndex]
end

function GoldEquip:GetCosumeItemToTarItem(SrcItem)
	local tbInfo = self.tbEvolutionSetting[SrcItem]
	if tbInfo then
		return tbInfo.TarItem
	end
end

function GoldEquip:GetExternSetting( nPlayerLevel, nItemType )
	local tbSetting;
	local nAddLevel = self.tbGoldEquipTypeAddLevel[nItemType]
	if not nAddLevel then
		return
	end
	nPlayerLevel = nPlayerLevel - nAddLevel
	local nNeedLevel;
	for i,v in ipairs(self.tbExternSetting) do
		if v.nPlayerLevel <= nPlayerLevel then
			tbSetting = v;
			nNeedLevel = v.nPlayerLevel + nAddLevel
		else
			break;
		end
	end
	return tbSetting, nNeedLevel
end

function GoldEquip:GetExternSettingNeedPlayerLevel( nEquipLevel, nItemType )
	local nAddLevel = self.tbGoldEquipTypeAddLevel[nItemType]
	if not nAddLevel then
		return
	end
	for i,v in ipairs(self.tbExternSetting) do
		if v.nEquipLevel == nEquipLevel then
			return v.nPlayerLevel + nAddLevel
		end
	end
end


--获取所有初始的黄金装备6阶装备
function GoldEquip:GetAllInitEvolutionTarItems()
	if not self.tbAllInitEvolutionTarItems then
		self.tbAllInitEvolutionTarItems = {};
		for SrcItem, v in pairs(self.tbEvolutionSetting) do
			if v.CosumeItem1 == 2804 and v.CosumeItem2 == 0 then
				self.tbAllInitEvolutionTarItems[v.TarItem] = SrcItem;
			end
		end
	end
	return self.tbAllInitEvolutionTarItems
end

--根据装备位置获取所有初始的白金装10阶装备
function GoldEquip:GetInitPlattinumSrcItemByPos( nPos )
	if not self.tbPosToInitPlattinumSrcItem then
		self.tbPosToInitPlattinumSrcItem = {};
		for SrcItem, v in pairs(self.tbEvolutionSetting) do
			if v.CosumeItem1 == 10014 and v.CosumeItem2 == 0 then
				local tbItemBase = KItem.GetItemBaseProp(v.TarItem)
				local nPos = Item.EQUIPTYPE_POS[tbItemBase.nItemType];
            	self.tbPosToInitPlattinumSrcItem[nPos] = SrcItem
			end
		end
	end
	return self.tbPosToInitPlattinumSrcItem[nPos]
end


function GoldEquip:GetRealUseAttribLevel(nDetailType, nEquipLevel, nCurAttribLevel)
	if not nDetailType then
		return nCurAttribLevel
	end
	local tbSet = self.tbGoldExternAttrib[nEquipLevel]
	if not tbSet then
		return nCurAttribLevel
	end
	local nAddLevel = tbSet["nAddLevel" .. nDetailType]
	if not nAddLevel then
		return nCurAttribLevel
	end
	if (nDetailType == Item.DetailType_Platinum) then
		if nCurAttribLevel < tbSet.nModifyLevel or nCurAttribLevel + 1 > tbSet["nMaxLevel" .. nDetailType] then
			return nCurAttribLevel + 1;
		end
	end
	if nCurAttribLevel < tbSet.nModifyLevel then
		return nCurAttribLevel
	end
	return math.max(nCurAttribLevel, math.min(nCurAttribLevel + nAddLevel, tbSet["nMaxLevel" .. nDetailType]))
end

function GoldEquip:Evolution(pPlayer, nItemId)
	local pItemPass = pPlayer.GetItemInBag(nItemId)
	if not pItemPass then
		return false
	end

	local bEquiped = false;
	local bRet,_,pKeySrcItem = self:CanEvolution(pPlayer, nItemId)
	if not bRet then
		return false
	end
	if not pKeySrcItem then
		pKeySrcItem = pItemPass
	end
	local tbItemInVals;
	local nOldEquipLevel;--黄金进化到白金时记录之前的阶数
	if pItemPass.IsEquip() then
		local pCurEquip = pPlayer.GetEquipByPos(pItemPass.nEquipPos)
		if pCurEquip and pCurEquip.dwId == pItemPass.dwId then
			bEquiped = true
		end
		tbItemInVals = Item.tbRefinement:GetSaveRandomAttrib(pItemPass)
		if pItemPass.nDetailType == Item.DetailType_Gold and pItemPass.nLevel > self.UP_TO_PLATINUM_MIN_LEVEL then
			nOldEquipLevel = pItemPass.nLevel
		end
	end


	local nTemplateIdSrc = pKeySrcItem.dwTemplateId

	local tbSetting = self.tbEvolutionSetting[nTemplateIdSrc]

	local tbConsumeSetting = self:GetEvolutionConsumeSetting(pPlayer, pKeySrcItem)
	local tbHideID = { [nItemId] = 1 };
	for i,v in ipairs(tbConsumeSetting) do
		local nCosumeItem, nConsumeCount = unpack(v)
		if pPlayer.ConsumeItemInBag(nCosumeItem, nConsumeCount, Env.LogWay_GoldEquipEvo, tbHideID) ~= nConsumeCount then
			Log(pPlayer.dwID, debug.traceback())
			return
		end
	end

	if pKeySrcItem.dwId ~= pItemPass.dwId then
		if  pPlayer.ConsumeItem(pKeySrcItem, 1, Env.LogWay_GoldEquipEvo) ~= 1 then
			Log(debug.traceback(), pPlayer.dwID)
			return
		end
	end

	if  pPlayer.ConsumeItem(pItemPass, 1, Env.LogWay_GoldEquipEvo) ~= 1 then
		Log(debug.traceback(), pPlayer.dwID)
		return
	end

	local pItemTar = pPlayer.AddItem(tbSetting.TarItem, 1, nil, Env.LogWay_GoldEquipEvo);
	if not pItemTar then
		Log(debug.traceback(), pPlayer.dwID)
		return
	end


	local tbTrainSetting = self.tbTrainAttriSetting[tbSetting.TarItem]
	if tbTrainSetting then
		pItemTar.SetIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL, 1)
	end
	if tbItemInVals then
		for k,v in pairs(tbItemInVals) do
			pItemTar.SetIntValue(k, v);
		end
	end
	if nOldEquipLevel then
		pItemTar.SetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL, nOldEquipLevel)
		Log("GoldEquip Evolution To Platinum", pPlayer.dwID, nOldEquipLevel)
	end
	pItemTar.ReInit();


	pPlayer.TLog("EquipFlow", pItemTar.nItemType, pItemTar.dwTemplateId, pItemTar.dwId, 1, Env.LogWay_GoldEquipEvo, 0, 2, pItemTar.GetIntValue(1),pItemTar.GetIntValue(2), pItemTar.GetIntValue(3), pItemTar.GetIntValue(4), pItemTar.GetIntValue(5),pItemTar.GetIntValue(6), 0, "");

	if bEquiped then
		Item:UseEquip(pItemTar.dwId, false, pItemTar.nEquipPos)
	end
	if self.tbAchieventmentPos[pItemTar.nDetailType] then
		local szAchiment = self.tbAchieventmentPos[pItemTar.nDetailType][pItemTar.nEquipPos]
		if szAchiment then
			Achievement:SetCount(pPlayer, szAchiment, pItemTar.nLevel)
		end
	end


	if  Item:IsMainEquipPos(pItemTar.nEquipPos) then
		local szKinPrefix = "";
		if pPlayer.dwKinId ~= 0 then
			local tbKin = Kin:GetKinById(pPlayer.dwKinId)
			if tbKin then
				szKinPrefix = string.format("%s家族的", tbKin.szName)
			end
		end
		local szEquipName = Item:GetItemTemplateShowInfo(tbSetting.TarItem, pPlayer.nFaction, pPlayer.nSex);
		local szNameType = self.DetailTypeGoldUp[pItemTar.nDetailType]
		local szWorldMsg = string.format("恭喜%s「%s」成功打造出%d阶%s装备<%s>。", szKinPrefix, pPlayer.szName, pItemTar.nLevel, szNameType, szEquipName);
		local szKinMsg = string.format("恭喜家族成员「%s」成功打造出%d阶%s装备<%s>。", pPlayer.szName, pItemTar.nLevel, szNameType, szEquipName)
		KPlayer.SendWorldNotify(1, 999, szWorldMsg, 0, 1)
		local tbRandomAtrrib = Item.tbRefinement:GetSaveRandomAttrib(pItemTar) ;
		local tbData = {
			nCount = 1,
			nLinkType = ChatMgr.LinkType.Item,
			nFaction = pPlayer.nFaction,
			nSex = pPlayer.nSex,
			nTemplateId = tbSetting.TarItem,
			szName = szEquipName,
			bIsEquip = true,
			tbRandomAtrrib = tbRandomAtrrib,
		}
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szWorldMsg, 0, tbData)
		if pPlayer.dwKinId ~= 0 then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId, tbData)
		end

		Achievement:AddCount(pPlayer, "Equip_3", 1)
	end

	pPlayer.CallClientScript("Item.GoldEquip:OnEvolutionSuccess")
end

function GoldEquip:CanEvolutionTarItem(dwTemplateId)
	local tbSetting = self.tbEvolutionSetting[dwTemplateId]
	if tbSetting then
		if not Lib:IsEmptyStr(tbSetting.TimeFrame) and GetTimeFrameState(tbSetting.TimeFrame) ~= 1 then
			return
		end
		return tbSetting.TarItem
	end
end

function GoldEquip:CanEvolution(pPlayer, dwItemId)
	local pEquip = pPlayer.GetItemInBag(dwItemId)
	if not pEquip then
		return false, "无对应装备"
	end

	local pSrcItem = pEquip
	if pEquip.nDetailType == Item.DetailType_Gold then
		if pEquip.nLevel < self.UP_TO_PLATINUM_MIN_LEVEL then
			return false, string.format("%d阶或以上的黄金装备才可进化", self.UP_TO_PLATINUM_MIN_LEVEL)
		end
		local nSrcItem = self:GetInitPlattinumSrcItemByPos(pEquip.nEquipPos)
		if not nSrcItem then
			return false, "配置错误2"
		end
		local tbFindItems = pPlayer.FindItemInPlayer(nSrcItem)
		pSrcItem = tbFindItems[1]
		if not pSrcItem then
			local tbItemBase = KItem.GetItemBaseProp(nSrcItem)
			return false, string.format("您身上没有%s", tbItemBase.szName)
		end
	end
	local dwTemplateId = pSrcItem.dwTemplateId
	local tbSetting = self.tbEvolutionSetting[dwTemplateId]
	if not tbSetting then
		return false, "无打造配置"
	end
	if not Lib:IsEmptyStr(tbSetting.TimeFrame) and GetTimeFrameState(tbSetting.TimeFrame) ~= 1 then
		return false, "当前未开放"
	end
	local tbItemBase = KItem.GetItemBaseProp(tbSetting.TarItem)
	if not tbItemBase then
		return false, "配置错误"
	end

--[[
	if tbItemBase.nRequireLevel > pPlayer.nLevel then
		return false, string.format("您的等级不足%d级，不能升阶该装备，提升等级后再试试", tbItemBase.nRequireLevel)
	end
]]

	local tbConsumeSetting = self:GetEvolutionConsumeSetting(pPlayer, pSrcItem)
	if not next(tbConsumeSetting) then
		return false, "消耗配置错误"
	end

	local tbHideID = { [pEquip.dwId] = 1 };

	for i,v in ipairs(tbConsumeSetting) do
		local nCosumeItem, nConsumeCount = unpack(v)
		local nHasCount = pPlayer.GetItemCountInBags(nCosumeItem, tbHideID)
		if nHasCount < nConsumeCount then
			return false, "所需材料不足"
		end
	end

	return true, nil, pSrcItem;
end

function GoldEquip:GetSuitAttrib(dwTemplateId, pPlayer)
	local tbSetting = self.tbSuitIndex[dwTemplateId]
	if not tbSetting then
		return
	end
	local tbActiedSuitIndex = pPlayer and pPlayer.tbActiedSuitIndex or {};
	local tbSuitIndexEquipNum = pPlayer and pPlayer.tbSuitIndexEquipNum or {};
	--todo 目前是每激活一档只是一个属性,不然现有结构无法用
	local tbAttris = {}
	local nSuitLevel, nSuitIndex = tbSetting.Level, tbSetting.SuitIndex
	local tbSuitInfo = {0,0}

	local nEquipTypeNum = tbSuitIndexEquipNum[nSuitIndex] and tbSuitIndexEquipNum[nSuitIndex][nSuitLevel]
	if nEquipTypeNum then
		tbSuitInfo[2] = nEquipTypeNum
	end
	local tbSuitActiveSetting = self.tbSuitActiveSetting[nSuitIndex]
	for ActiveLevel= 1, self.MAX_ATTRI_NUM do
		local nActiveNeedNum = tbSuitActiveSetting["ActiveNum" .. ActiveLevel]
		if nActiveNeedNum ~= 0 then
			tbSuitInfo[1] = nActiveNeedNum
			local tbExtAttrib = KItem.GetExternAttrib(self.tbSuitLevelAttrib[nSuitIndex][ActiveLevel], nSuitLevel);
			for nIndex, v in ipairs(tbExtAttrib) do
				local szDesc  = FightSkill:GetMagicDesc(v.szAttribName, v.tbValue) or "";
				local  nColor = self.COLOR_UN_ACTVIED;
				if tbActiedSuitIndex[nSuitIndex] and tbActiedSuitIndex[nSuitIndex][nSuitLevel] and tbActiedSuitIndex[nSuitIndex][nSuitLevel][ActiveLevel] then
					nColor = self.COLOR_ACTVIED
				end
				table.insert(tbAttris, {string.format("%s  %s", string.format("(%d件)", nActiveNeedNum), szDesc) , nColor})
			end
		else
			break;
		end
	end
	if pPlayer then
		local tbSuitEquipPosInfo = {};--这个装备位置对应的套装的装备情况
		local tbSuitEquipPosSetting = self:GetSuitEquipPosSetting(nSuitIndex)
		for nEquipPos,v in pairs(tbSuitEquipPosSetting) do
			local nHasEquipType = 0;
			local pEquip = pPlayer.GetEquipByPos(nEquipPos)
			if pEquip then
				local pSelSetting = self.tbSuitIndex[pEquip.dwTemplateId]
				if pSelSetting and pSelSetting.SuitIndex == nSuitIndex and pSelSetting.Level >= nSuitLevel then
					nHasEquipType = 1;
				end
			end
			tbSuitEquipPosInfo[nEquipPos] = nHasEquipType
		end
		tbSuitInfo[3] = tbSuitEquipPosInfo
	end

	return tbAttris, tbSuitInfo
end

function GoldEquip:GetTrainAttrib(dwTemplateId, nLevel)
	local tbSetting = self.tbTrainAttriSetting[dwTemplateId]
	if not tbSetting then
		return
	end
	if not nLevel or  nLevel == 0  then
		nLevel = 1
	end
	if nLevel > self.MAX_TRAIN_ATTRI_LEVEL then
		return
	end
	local tbExtAttrib = KItem.GetExternAttrib(tbSetting.AttribGroup, nLevel);
	if not tbExtAttrib then
		return
	end

	local tbAttris = {}
	for nIndex, v in ipairs(tbExtAttrib) do
		local szDesc  = FightSkill:GetMagicDesc(v.szAttribName, v.tbValue) or "";
		table.insert(tbAttris, {szDesc , 0}) --无用功能
	end
	return tbAttris
end

function GoldEquip:GetActiedSuitIndexFromEquips( tbEquips )
	local tbSuitIndexs = {}
	for _, nItemId in pairs(tbEquips) do
		local pEquip = KItem.GetItemObj(nItemId)
		if pEquip then
			local tbSuitInfo = self.tbSuitIndex[pEquip.dwTemplateId]
			if tbSuitInfo then
				local SuitIndex, nSuitLevel = tbSuitInfo.SuitIndex, tbSuitInfo.Level
				tbSuitIndexs[SuitIndex] = tbSuitIndexs[SuitIndex] or {};
				for nLevel=1,nSuitLevel do
					tbSuitIndexs[SuitIndex][nLevel] = (tbSuitIndexs[SuitIndex][nLevel] or 0)  + 1;
				end
			end
		end
	end

	local tbUseExtRet = {};
	for SuitIndex, v1 in pairs(tbSuitIndexs) do
		for nLevel, nEquipNum in ipairs(v1) do
			local tbSetting = self.tbSuitActiveSetting[SuitIndex]
			for i = 1, self.MAX_ATTRI_NUM do
				local nActiveNeedNum = tbSetting["ActiveNum" .. i]
				if nActiveNeedNum ~= 0 and nEquipNum >= nActiveNeedNum then
					tbUseExtRet[SuitIndex] = tbUseExtRet[SuitIndex] or {};
			    	tbUseExtRet[SuitIndex][nLevel] = tbUseExtRet[SuitIndex][nLevel] or {}
			    	tbUseExtRet[SuitIndex][nLevel][i] = nEquipNum;
			    	if tbUseExtRet[SuitIndex][nLevel - 1] then
			    		tbUseExtRet[SuitIndex][nLevel - 1][i] = nil;
			    	end
				else
					break;
				end
			end
		end
	end
	return tbUseExtRet, tbSuitIndexs
end

-- 登陆 脱穿装备时 更新
function GoldEquip:UpdateSuitAttri(pPlayer)
	if pPlayer.tbActiedSuitIndex then --玩家 身上已经激活的套装属性
		for SuitIndex,v1 in pairs(pPlayer.tbActiedSuitIndex) do
			for nLevel,v2 in pairs(v1) do
				for ActiveLevel, _ in pairs(v2) do
					pPlayer.RemoveExternAttrib(self.tbSuitLevelAttrib[SuitIndex][ActiveLevel])
				end
			end
		end
	end


	local tbSaveAsyncVals = {}
	local tbEquips = pPlayer.GetEquips()
	local tbActiedSuitIndex, tbSuitIndexEquipNum = self:GetActiedSuitIndexFromEquips(tbEquips)
	pPlayer.tbActiedSuitIndex = tbActiedSuitIndex
	pPlayer.tbSuitIndexEquipNum = tbSuitIndexEquipNum
	-- [SuitIndex][nLevel][ActiveLevel]
	for SuitIndex,v1 in pairs(tbActiedSuitIndex) do
		for nLevel,v2 in pairs(v1) do
			for ActiveLevel, nIsApply in pairs(v2) do
				if nIsApply ~= 0 then
					local AttriGroup = self.tbSuitLevelAttrib[SuitIndex][ActiveLevel];
					pPlayer.ApplyExternAttrib(AttriGroup, nLevel)
					table.insert(tbSaveAsyncVals, AttriGroup * 100 + nLevel) --一个激活属性一条了
				end
			end
		end
	end

	if MODULE_GAMESERVER then
		local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
		if pAsyncData then
			if #tbSaveAsyncVals > 10 then
				Log(debug.traceback())
			end
			for i = 1,10 do
				local nVal = tbSaveAsyncVals[i] or 0
				pAsyncData.SetSuit(i, nVal)
				if nVal == 0 then
					break;
				end
			end
		end
	end
end

--异步数据加载时用到
function GoldEquip:UpdateTrainAttriToNpc(pNpc, tbEquipTemplates, tbEquipTranLevels)
	for nPos, nAttriLevel in pairs(tbEquipTranLevels) do
		local dwTemplateId = tbEquipTemplates[nPos]
		local tbSetting = self.tbTrainAttriSetting[dwTemplateId]
		if tbSetting then
			pNpc.ApplyExternAttrib(tbSetting.AttribGroup, nAttriLevel)
		end
	end
end

--这个 登陆，脱穿时 最好是跟着C里脱穿装备走
function GoldEquip:UpdateTrainAttri(pPlayer, nEquipPos)
	local tbApplyedTrainAttri = pPlayer.tbApplyedTrainAttri or {};

	local nActiveGroup = tbApplyedTrainAttri[nEquipPos]
	if nActiveGroup then
		pPlayer.RemoveExternAttrib(nActiveGroup)
		tbApplyedTrainAttri[nEquipPos] = nil;
	end

	local pEquip = pPlayer.GetEquipByPos(nEquipPos)
	if pEquip then
		local tbSetting = self.tbTrainAttriSetting[pEquip.dwTemplateId]
		if tbSetting then
			local nLevel = pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL)
			if nLevel > 0 then
				pPlayer.ApplyExternAttrib(tbSetting.AttribGroup, nLevel)
				tbApplyedTrainAttri[nEquipPos] = tbSetting.AttribGroup
			end
		end
	end

	pPlayer.tbApplyedTrainAttri = tbApplyedTrainAttri;
end

function GoldEquip:OnLogin(pPlayer)
	self:UpdateSuitAttri(pPlayer)
	for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		self:UpdateTrainAttri(pPlayer, nEquipPos)
	end
end

function GoldEquip:UpgradeEquipTrainLevel(pPlayer, nItemId)
	local pEquip = pPlayer.GetItemInBag(nItemId)
	if not pEquip then
		return
	end
	local nNowLevel = pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL)
	if nNowLevel == 0 then
		return
	end
	local tbSetting = self.tbTrainAttriSetting[pEquip.dwTemplateId]
	if not tbSetting then
		return
	end

	local nNextLevel = nNowLevel + 1
	if nNextLevel > self.MAX_TRAIN_ATTRI_LEVEL then
		return
	end

	local nCousumeCount, nConsumeCoin = tbSetting["CostItemCount" .. nNextLevel], tbSetting["CostCoin" .. nNextLevel]
	if not  nCousumeCount or not nConsumeCoin then
		Log(debug.traceback(), pEquip.dwTemplateId, nNextLevel)
		return
	end

	if not pPlayer.CostMoney("Coin", nConsumeCoin, Env.LogWay_TrainEquipAttri) then
		return
	end

	if pPlayer.ConsumeItemInAllPos(tbSetting.CostItemId, nCousumeCount, Env.LogWay_TrainEquipAttri) ~= nCousumeCount then
		Log(debug.traceback(), pEquip.dwTemplateId, nNextLevel)
		return
	end

	pEquip.SetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL, nNextLevel)
	Log("GoldEquip:UpgradeEquipTrainLevel", pPlayer.dwID, pEquip.dwTemplateId, nNextLevel, nItemId)
	self:UpdateTrainAttri(pPlayer, pEquip.nEquipPos)

	pPlayer.CallClientScript("Item.GoldEquip:OnUpgradeEquipTrainLevelSuc", pEquip.nEquipPos)
end

function GoldEquip:CanEquipTrainAttris(pPlayer, nItemId)
	local pEquip = pPlayer.GetItemInBag(nItemId)
	if not pEquip then
		return
	end
	local nNowLevel = pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL)
	if nNowLevel == 0 then
		return false, "未打造过"
	end
	local tbSetting = self.tbTrainAttriSetting[pEquip.dwTemplateId]
	if not tbSetting then
		return
	end

	local nNextLevel = nNowLevel + 1
	local tbExtAttrib = KItem.GetExternAttrib(tbSetting.AttribGroup, nNextLevel);
	if not tbExtAttrib then
		return
	end
	if pPlayer.GetItemCountInAllPos(tbSetting.CostItemId) <  tbSetting["CostItemCount" .. nNextLevel] then
		return false, "所需材料不足"
	end
	if pPlayer.GetMoney("Coin") < tbSetting["CostCoin" .. nNextLevel] then
		return false, "所需银两不足"
	end

	return true;
end

--C
function GoldEquip:OnEvolutionSuccess()
	UiNotify.OnNotify(UiNotify.emNOTIFY_EQUIP_EVOLUTION, true)
end

--C
function GoldEquip:OnUpgradeEquipTrainLevelSuc(nEquipPos)
	self:UpdateTrainAttri(me, nEquipPos)
	me.CenterMsg("精炼成功！")
	UiNotify.OnNotify(UiNotify.emNOTIFY_EQUIP_TRAIN_ATTRIB, true)
end

function GoldEquip:GetEvolutionSetting(dwTemplateId)
	return self.tbEvolutionSetting[dwTemplateId]
end

function GoldEquip:GetTrainAttriSetting( dwTemplateId )
	return self.tbTrainAttriSetting[dwTemplateId]
end


--进阶
function GoldEquip:CanUpgradeTarItem(dwTemplateId)
	local tbSetting = self.tbEvolutionUpgradeSetting[dwTemplateId]
	if tbSetting then
		return tbSetting.TarItem
	end
end

function GoldEquip:GetUpgradeSetting(dwTemplateId)
	return self.tbEvolutionUpgradeSetting[dwTemplateId]
end

function GoldEquip:GetUpgradeConsumCount(tbSetting)
	local ConsumeCount;
	local ConsumeCountOrg = tbSetting["ConsumeCount1"]
	for i=1,self.UPGRADE_MAX_TIMEFRAME_C do
		local szTimeFrame = tbSetting["TimeFrame" .. i]
		if not Lib:IsEmptyStr(szTimeFrame) and GetTimeFrameState(szTimeFrame) == 1 then
			ConsumeCount = tbSetting["ConsumeCount" .. i]
		else
			break;
		end
	end
	if ConsumeCountOrg == ConsumeCount then
		ConsumeCountOrg = nil
	end
	return ConsumeCount,ConsumeCountOrg
end

function GoldEquip:CanUpgrade(pPlayer, pItemSrc)
	local dwTemplateId = pItemSrc.dwTemplateId
	local tbSetting = self.tbEvolutionUpgradeSetting[dwTemplateId]
	if not tbSetting then
		return false, "无升阶配置"
	end
	local nEquipPos = pItemSrc.nEquipPos
	if not nEquipPos then
		return false
	end
	local pCurEquip = pPlayer.GetEquipByPos(nEquipPos)
	if not pCurEquip or pCurEquip.dwId ~= pItemSrc.dwId then
		return false, "您未装备该道具"
	end

	local tbConsumeSetting = self:GetUpgradeConsumeSetting(pItemSrc)
	if not next(tbConsumeSetting)  then
		return false, "当前未开放"
	end
	for i,v in ipairs(tbConsumeSetting) do
		if pPlayer.GetItemCountInAllPos(v[1]) < v[2] then
			return false, "所需材料不足"
		end
	end

	local tbItemBase = KItem.GetItemBaseProp(tbSetting.TarItem)
	if not tbItemBase then
		return false, "配置错误"
	end

--[[
	if tbItemBase.nRequireLevel > pPlayer.nLevel then
		return false, string.format("您的等级不足%d级，不能升阶该装备，提升等级后再试试", tbItemBase.nRequireLevel)
	end
]]
	return true, nil, tbConsumeSetting;
end



function GoldEquip:CheckDoUpgradeParam(pPlayer, tbRefinemRecord)
	local pSrcItem = pPlayer.GetItemInBag(tbRefinemRecord.SrcItemId) --消耗T7稀有
	if not pSrcItem then
		return false, "1"
	end
	local pCostItem = pPlayer.GetItemInBag(tbRefinemRecord.CostItemId)--消耗掉的T6黄金
	if not pCostItem then
		return false, "2"
	end

	local tbSetting = self.tbEvolutionUpgradeSetting[pCostItem.dwTemplateId]
	if not tbSetting then
		return false, "3"
	end

	if tbSetting.CosumeItem1 ~= pSrcItem.dwTemplateId then
		return false, "4"
	end

	local tbRefineIndex = tbRefinemRecord.tbRefineIndex
	if tbRefinemRecord.nCoin == 0  then
		if next(tbRefineIndex) then
			return false, "5"
		end
	else

		if not next(tbRefineIndex) then
			return false, "6"
		end
		local nCostTotal = 0
		local tbOldAllVals = {}
		for i=1,6 do
			table.insert(tbOldAllVals, pSrcItem.GetIntValue(i))
		end
		--检查是否所有的 nSrcVal 都在pSrcItem 里出现
		for nTarPos, nSrcVal in pairs(tbRefineIndex) do
			local bFound = false
			for k,v in pairs(tbOldAllVals) do
				if nSrcVal == v then
					bFound = true
					tbOldAllVals[k] = nil;
					break;
				end
			end
			if not bFound then
				return false, "6" .. nTarPos
			end
		end

		for nTarPos, nSrcVal in pairs(tbRefineIndex) do
			if nTarPos < 1 or nTarPos > 6 then
				return false, "7"
			end
			if nSrcVal == 0 then
				return false, "9"
			end
			local nCurCost = Item.tbRefinement:GetRefineCost(nSrcVal, pSrcItem.nItemType)
			if nCurCost == 0 then
				return false, "10"
			end
			nCostTotal = nCostTotal + nCurCost

		end

		if nCostTotal ~= tbRefinemRecord.nCoin then
			return false, "11"
		end


		if pPlayer.GetMoney("Coin") < nCostTotal then
			return false, "银两不足"
		end
	end
	return true
end

function GoldEquip:ClientPorcessUpgrade(tbRefinemRecord)
	local nFakeSrcId = tbRefinemRecord.nFakeSrcId
	local nFakeTarId = tbRefinemRecord.nFakeTarId
	tbRefinemRecord.nFakeSrcId = nil;
	tbRefinemRecord.nFakeTarId = nil;

	local bRet, szMsg = self:CheckDoUpgradeParam(me, tbRefinemRecord)
	if bRet then
		RemoteServer.RequestEquipUpgrade(tbRefinemRecord)
	else
		me.CenterMsg( szMsg or "装备进阶参数错误", true)
	end

	Item:RemoveFakeItem(nFakeSrcId)
	Item:RemoveFakeItem(nFakeTarId)
end


function GoldEquip:ServerDoEquipUpgrade(pPlayer, nSrcItemId)
	local pSrcItem = pPlayer.GetItemInBag(nSrcItemId)
	if not pSrcItem then
		return
	end

	local tbSetting = self.tbEvolutionUpgradeSetting[pSrcItem.dwTemplateId]
	if not tbSetting then
		return
	end

	local bRet, szMsg, tbConsumeSetting = self:CanUpgrade(pPlayer, pSrcItem)
	if not bRet then
		return
	end
	for i,v in ipairs(tbConsumeSetting) do
		if v[2] > 0 then
			if pPlayer.ConsumeItemInAllPos(v[1], v[2], Env.LogWay_GoldEquipUpgrade) ~= v[2] then
				Log(pPlayer.dwID, debug.traceback())
				return
			end
		end
	end

	local tbItemInVals = Item.tbRefinement:GetSaveRandomAttrib(pSrcItem)
	local nOldEquipLevel = pSrcItem.GetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL)

	if not pSrcItem.Delete(Env.LogWay_GoldEquipUpgrade) then
		Log(pPlayer.dwID, debug.traceback())
		return
	end

	local pItemTar = pPlayer.AddItem(tbSetting.TarItem, 1, nil, Env.LogWay_GoldEquipUpgrade)
	if not pItemTar then
		Log(pPlayer.dwID, debug.traceback())
		return
	end

	for k,v in pairs(tbItemInVals) do
		pItemTar.SetIntValue(k, v);
	end
	if nOldEquipLevel > pItemTar.nLevel then
		pItemTar.SetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL, nOldEquipLevel)
	end

	pItemTar.ReInit();

	pPlayer.TLog("EquipFlow", pItemTar.nItemType, pItemTar.dwTemplateId, pItemTar.dwId, 1, Env.LogWay_GoldEquipUpgrade, 0, 2, pItemTar.GetIntValue(1),pItemTar.GetIntValue(2), pItemTar.GetIntValue(3), pItemTar.GetIntValue(4), pItemTar.GetIntValue(5),pItemTar.GetIntValue(6),0, "");

	local pNowEquip = pPlayer.GetEquipByPos(pItemTar.nEquipPos)
	if not pNowEquip then
		Item:UseEquip(pItemTar.dwId, false, pItemTar.nEquipPos)
	end

	local szKinPrefix = "";
	if pPlayer.dwKinId ~= 0 then
		local tbKin = Kin:GetKinById(pPlayer.dwKinId)
		if tbKin then
			szKinPrefix = string.format("%s家族的", tbKin.szName)
		end
	end
	if self.tbAchieventmentPos[pItemTar.nDetailType] then
		local szAchiment = self.tbAchieventmentPos[pItemTar.nDetailType][pItemTar.nEquipPos]
		if szAchiment then
			if pItemTar.nDetailType == Item.DetailType_Platinum  then
				if pItemTar.nLevel > nOldEquipLevel then
					local szAchiGold = self.tbAchieventmentPos[Item.DetailType_Gold][pItemTar.nEquipPos]
					if szAchiGold then
						Achievement:SetCount(pPlayer, szAchiGold, pItemTar.nLevel)
					end
				end
			end
			Achievement:SetCount(pPlayer, szAchiment, pItemTar.nLevel)
		end
	end
	local szEquipName = Item:GetItemTemplateShowInfo(tbSetting.TarItem, pPlayer.nFaction, pPlayer.nSex);
	local szNameType = self.DetailTypeGoldUp[pItemTar.nDetailType]
	local szWorldMsg = string.format("恭喜%s「%s」成功通过%s装备升阶获得%d阶%s装备<%s>。", szKinPrefix, pPlayer.szName,  szNameType,  pItemTar.nLevel, szNameType, szEquipName);
	local szKinMsg = string.format("恭喜家族成员「%s」成功通过%s装备升阶获得%d阶%s装备<%s>。", pPlayer.szName, szNameType, pItemTar.nLevel, szNameType, szEquipName)
	KPlayer.SendWorldNotify(1, 999, szWorldMsg, 0, 1)
	local tbData = {
		nCount = 1,
		nLinkType = ChatMgr.LinkType.Item,
		nFaction = pPlayer.nFaction,
		nSex = pPlayer.nSex,
		nTemplateId = tbSetting.TarItem,
		szName = szEquipName,
		bIsEquip = true,
		tbRandomAtrrib = tbItemInVals,
	}
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szWorldMsg, 0, tbData)
	if pPlayer.dwKinId ~= 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId, tbData)
	end

	pPlayer.CallClientScript("Item.GoldEquip:OnEvolutionSuccess")
	Achievement:AddCount(pPlayer, "Equip_3", 1)
end

function GoldEquip:IsShowHorseUpgradeRed(pPlayer)
	for nEquipPos,v in pairs(Item.tbHorseItemPos) do
		local pEquip2 = pPlayer.GetEquipByPos(nEquipPos);
		if pEquip2 and Item.GoldEquip:CanEvolution(pPlayer, pEquip2.dwId) then
			return true
		end
	end
	return false
end

function GoldEquip:IsShowPiFengUpgradeRed( pPlayer )
	local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_BACK2)
	if not pEquip then
		return  false
	end
	if self:CanEvolution(pPlayer, pEquip.dwId) then
		return true
	end
	return false
end

function GoldEquip:IsHaveHorseUpgradeItem(pPlayer)
	for nEquipPos,v in pairs(Item.tbHorseItemPos) do
		local pEquip2 = pPlayer.GetEquipByPos(nEquipPos);
		if pEquip2 and self:CanEvolutionTarItem(pEquip2.dwTemplateId) then
			return true
		end
	end
	return false
end

--如果没有第二套的话则显示第一套，有第二套齐全的话优先显示第二套
function GoldEquip:GetEvolutionConsumeSetting(pPlayer, pSrcItem, nSrcTemplateId)
	if not nSrcTemplateId and pSrcItem then
		nSrcTemplateId = pSrcItem.dwTemplateId
	end
	if not nSrcTemplateId then
		return
	end
	local tbSetting = self.tbEvolutionSetting[nSrcTemplateId]
	local tbConsumeSetting = {};
	if not tbSetting then
		return tbConsumeSetting
	end
	local tbHideID = {  };
	if pSrcItem then
		tbHideID[pSrcItem.dwId] = 1
	end

	if tbSetting.CosumeItemBAK1 ~= 0  and tbSetting.ConsumeCountBAK1 ~= 0 then
		local nCount = pPlayer.GetItemCountInBags(tbSetting.CosumeItemBAK1, tbHideID)
		if nCount >= tbSetting.ConsumeCountBAK1 then
			table.insert(tbConsumeSetting, {tbSetting.CosumeItemBAK1, tbSetting.ConsumeCountBAK1})
			if tbSetting.CosumeItemBAK2 ~= 0  and tbSetting.ConsumeCountBAK2 ~= 0 then
				table.insert(tbConsumeSetting, {tbSetting.CosumeItemBAK2, tbSetting.ConsumeCountBAK2})
			end
		end

		if next(tbConsumeSetting) then
			return tbConsumeSetting
		end
	end

	if tbSetting.CosumeItem1 ~= 0  and tbSetting.ConsumeCount1 ~= 0 then
		table.insert(tbConsumeSetting, {tbSetting.CosumeItem1, tbSetting.ConsumeCount1})
	end

	if tbSetting.CosumeItem2 ~= 0  and tbSetting.ConsumeCount2 ~= 0 then
		table.insert(tbConsumeSetting, {tbSetting.CosumeItem2, tbSetting.ConsumeCount2})
	end
	if tbSetting.CosumeItem3 ~= 0  and tbSetting.ConsumeCount3 ~= 0 then
		table.insert(tbConsumeSetting, {tbSetting.CosumeItem3, tbSetting.ConsumeCount3})
	end
	return  tbConsumeSetting
end

function GoldEquip:GetUpgradeConsumeSetting(pItemSrc)
	local dwTemplateId = pItemSrc.dwTemplateId
	local tbSetting = self.tbEvolutionUpgradeSetting[dwTemplateId]
	local tbConsumeSetting = {};
	if not tbSetting then
		return tbConsumeSetting
	end
	local nCousumeCount, nCousumeCountOrg = self:GetUpgradeConsumCount(tbSetting)
	if not nCousumeCount then
		return tbConsumeSetting
	end
	--现在只有消耗1是按时间轴打折，2是固定的，  --nCousumeCount 可能是0，充能状态
	if pItemSrc.nDetailType == Item.DetailType_Platinum then
		if pItemSrc.nLevel < pItemSrc.GetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL) then
			nCousumeCount = 0;
		end
	end

	table.insert(tbConsumeSetting, {tbSetting.CosumeItem, nCousumeCount, nCousumeCountOrg})
	if tbSetting.Cosume2Item ~= 0 and tbSetting.Consume2Count ~= 0 then
		table.insert(tbConsumeSetting, {tbSetting.Cosume2Item, tbSetting.Consume2Count})
	end
	return  tbConsumeSetting
end

function GoldEquip:GetAllGoldPlatinumSaveAttr(  )
	if not self.tbAllPlatinumSaveAttr then
		self.tbAllPlatinumSaveAttr = {};
		self.tbAllGoldSaveAttr = {};
		local tbAllItemIds = {};
		for dwTemplteId,v in pairs(self.tbEvolutionUpgradeSetting) do
			tbAllItemIds[dwTemplteId] = 1;
			tbAllItemIds[v.TarItem] = 1;
		end
		for k, _ in pairs(tbAllItemIds) do
			if (not k) or (not KItem.GetItemBaseProp(k)) then
			    Log("eeeeeeee[GoldEquip:GetAllGoldPlatinumSaveAttr]1,", k);
			end

			local tbItemBase = KItem.GetItemBaseProp(k)
			local nDetailType = tbItemBase.nDetailType
			local tbSetData;
			if nDetailType == Item.DetailType_Platinum then
				tbSetData = self.tbAllPlatinumSaveAttr
			elseif nDetailType == Item.DetailType_Gold then
				tbSetData = self.tbAllGoldSaveAttr
			end
			if tbSetData then
			    if (not k) or (not KItem.GetEquipBaseProp(k)) then
			        Log("eeeeeeee[GoldEquip:GetAllGoldPlatinumSaveAttr]2,", k, tbEquipBase);
			    end
				
				local tbEquipBase = KItem.GetEquipBaseProp(k)
				local tbData = {
					tbAttrib = tbEquipBase.tbBaseAttrib;
					nFightPower = tbEquipBase.nFightPower;
					nTemplateId = k;
				};
				local nEquipPos = KItem.GetEquipPos(k)
				tbSetData[nEquipPos] = tbSetData[nEquipPos] or {};
				tbSetData[nEquipPos][tbItemBase.nLevel] = tbData;
			end
		end
	end
	return self.tbAllPlatinumSaveAttr, self.tbAllGoldSaveAttr
end

function GoldEquip:GetTemplateIdFromTypeAndLevel( nDetailType,nEquipPos, nLevel )
	local tbSet;
	local tbAllPlatinumSaveAttr,  tbAllGoldSaveAttr = self:GetAllGoldPlatinumSaveAttr()
	if nDetailType == Item.DetailType_Platinum then
		tbSet = tbAllPlatinumSaveAttr
	elseif nDetailType == Item.DetailType_Gold then
		tbSet = tbAllGoldSaveAttr;
	end
	if not tbSet then
		return
	end
	if not tbSet[nEquipPos] then
		return
	end
	local tbInfo = tbSet[nEquipPos][nLevel]
	if tbInfo then
		return tbInfo.nTemplateId
	end
end

function GoldEquip:GetPlatinumSaveGoldAttr( pEquip, nDetailType, nOldEquipLevel, nNewEquipLevel )
	--主动传nOldEquipLevel 只是打造时的比较tip用
	if not nDetailType then
		nDetailType = pEquip.nDetailType
		nOldEquipLevel = pEquip.GetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL)
		nNewEquipLevel = pEquip.nLevel
	end
	if nDetailType ~= Item.DetailType_Platinum then
		return
	end
	if nOldEquipLevel <= nNewEquipLevel then
		return
	end
	local nEquipPos = pEquip.nEquipPos;
	local tbAllPlatinumSaveAttr,  tbAllGoldSaveAttr = self:GetAllGoldPlatinumSaveAttr()
	local tbPlatinum = tbAllPlatinumSaveAttr[nEquipPos][nNewEquipLevel]
	local tbGold = tbAllGoldSaveAttr[nEquipPos][nOldEquipLevel]
	if not tbGold or not tbPlatinum then
		Log(debug.traceback(), nEquipPos, nPlatinumLevel, nGoldLevel)
		return
	end
	local tbRet = {
		nFightPower = tbGold.nFightPower - tbAllGoldSaveAttr[nEquipPos][nNewEquipLevel].nFightPower
	};
	local tbModifyAttri = {}
	for i,v in pairs(tbPlatinum.tbAttrib) do
		local v2 = tbGold.tbAttrib[i]
		local x1,x2,x3 = unpack(v.tbValue)
		local y1,y2,y3 = unpack(v2.tbValue)
		if y1 > x1 or y2 > x2 or y3 > x3 then
			tbModifyAttri[v.szName] = { y1 - x1, y2 - x2 , y3 - x3  };
		end
	end
	if next(tbModifyAttri) then
		tbRet.tbModifyAttri = tbModifyAttri
	end
	return tbRet
end