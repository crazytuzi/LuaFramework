Require("CommonScript/Item/Define.lua")

Item.tbRefinement 	= Item.tbRefinement or {};
local tbRefinement 	= Item.tbRefinement;


local NORMAL_MAX_ATTRIB = 6;



local tbTypeSetting = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribType.tab",
	"ssddd", nil,
	{"EquipType", "Attrib", "Probility", "Delta", "WeightAdd"});

local tbTypeExSetting = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribTypeEx.tab",
	"sdddd", nil,
	{"EquipType", "ExternAttribGrp", "Probility", "Delta", "WeightAdd"});

local tbLevelSetting = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribLevel.tab",
	"ddd", nil,
	{"RealLevel", "AttribLevel", "Probility",});		-- XXX

local tbAttribQuality = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribQuality.tab",
	"ddd", nil,
	{"EquipLevel", "AttribLevel", "Quality",});		-- XXX


local tbCustomEquipSetting = LoadTabFile(
	"Setting/Item/CustomEquip.tab",
	"dsdsdsdsdsdsd", "TemplateId",
	{"TemplateId",
	"AttribType1","AttribLevel1",
	"AttribType2","AttribLevel2",
	"AttribType3","AttribLevel3",
	"AttribType4","AttribLevel4",
	"AttribType5","AttribLevel5",
	"AttribType6","AttribLevel6",});

function tbRefinement:GetRandomNumAndExtAttrib(  )
	if not self.tbRandomNum or not self.tbExtAttrib  then
		self.tbRandomNum = {}
		self.tbExtAttrib = {};
		local tbNumSetting = LoadTabFile(
			"Setting/Item/RandomAttrib/AttribNum.tab",
			"ddddddd", "RealLevel",
			{"RealLevel", "Count1", "Count2", "Count3", "Count4", "Count5", "ExtAttribLevel"});

		for nRealLevel,v in pairs(tbNumSetting) do
			self.tbRandomNum[nRealLevel] = {v.Count1, v.Count2, v.Count3, v.Count4, v.Count5};
			self.tbExtAttrib[nRealLevel] = v.ExtAttribLevel;
		end

	end
	return self.tbRandomNum, self.tbExtAttrib
end

function tbRefinement:TrimSetting()
	self.tbType = {};
	self.tbTypeWeightAdd = {};
	for _, v in pairs(tbTypeSetting) do
		self.tbType[v.EquipType] = self.tbType[v.EquipType] or {};
		self.tbType[v.EquipType][v.Attrib] = v.Probility;
		if v.Delta ~= 0 and v.WeightAdd ~= 0 then
			self.tbTypeWeightAdd[v.EquipType] = self.tbTypeWeightAdd[v.EquipType] or {};
			self.tbTypeWeightAdd[v.EquipType][v.Attrib] = v;
		end
	end

	self.tbTypeEx = {}
	self.tbTypeExWeightAdd = {}
	for _, v in pairs(tbTypeExSetting) do
		self.tbTypeEx[v.EquipType] = self.tbTypeEx[v.EquipType] or {};
		self.tbTypeEx[v.EquipType][v.ExternAttribGrp] = v.Probility;
		if v.Delta ~= 0 and v.WeightAdd ~= 0 then
			self.tbTypeExWeightAdd[v.EquipType] = self.tbTypeExWeightAdd[v.EquipType] or {};
			self.tbTypeExWeightAdd[v.EquipType][v.ExternAttribGrp] = v;
		end
	end

	self.tbLevel = {};
	for _,v in pairs(tbLevelSetting) do
		self.tbLevel[v.RealLevel] = self.tbLevel[v.RealLevel] or {};
		self.tbLevel[v.RealLevel][v.AttribLevel] = v.Probility;
	end

	self.tbColor = {};
	for _, v in pairs(tbAttribQuality) do
		self.tbColor[v.EquipLevel*100 + v.AttribLevel] = v.Quality;
	end

	self.tbTypeAttribValue = {}; --不同道具类型对应不同的属性表
	--不同装备类型对应的属性文件
	self.tbAttribFilePath = {
		[1] = "Setting/Item/RandomAttrib/AttribValWeapon.tab";
		[2] = "Setting/Item/RandomAttrib/AttribValCloth.tab";
		[3] = "Setting/Item/RandomAttrib/AttribValJewelry.tab";
		[4] = "Setting/Item/RandomAttrib/AttribValArmor.tab";
		[5] = "Setting/Item/RandomAttrib/AttribValZhenYuan.tab";
		[6] = "Setting/Item/RandomAttrib/AttribValSeriesWeapon.tab";
		[7] = "Setting/Item/RandomAttrib/AttribValSeriesJewelry.tab";
		[8] = "Setting/Item/RandomAttrib/AttribValSeriesCloth.tab";
		[9] = "Setting/Item/RandomAttrib/AttribValSeriesArmor.tab";
	};
	
	self.tbAttribItemTypeToFileType = 
	{
		[Item.EQUIP_WEAPON] = 1;
		[Item.EQUIP_ARMOR] = 2;
		[Item.EQUIP_RING] = 3;
		[Item.EQUIP_NECKLACE] = 3;
		[Item.EQUIP_AMULET] = 3;
		[Item.EQUIP_PENDANT] = 3;
		[Item.EQUIP_BOOTS] = 4;
		[Item.EQUIP_BELT] = 4;
		[Item.EQUIP_HELM] = 4;
		[Item.EQUIP_CUFF] = 4;
		[Item.EQUIP_ZHEN_YUAN] = 5;
		[Item.EQUIP_WEAPON_SERIES] = 6;
		[Item.EQUIP_RING_SERIES] = 7;
		[Item.EQUIP_NECKLACE_SERIES] = 7;
		[Item.EQUIP_AMULET_SERIES] = 7;
		[Item.EQUIP_PENDANT_SERIES] = 7;
		[Item.EQUIP_ARMOR_SERIES] = 8;
		[Item.EQUIP_BOOTS_SERIES] = 9;
		[Item.EQUIP_BELT_SERIES] = 9;
		[Item.EQUIP_HELM_SERIES] = 9;
		[Item.EQUIP_CUFF_SERIES] = 9;
	};
	for nItemType, nFindType in pairs(self.tbAttribItemTypeToFileType) do
		self.tbTypeAttribValue[nFindType] = self.tbTypeAttribValue[nFindType] or {}		
		local tbTypeAttribValue = self.tbTypeAttribValue[nFindType]
		local szEnName = Item.EQUIPTYPE_EN_NAME[nItemType]
		for szAttrib,v in pairs(self.tbType[szEnName]) do
			 tbTypeAttribValue[szAttrib] = {}		
		end
	end
	
	--只是洗练的用，因为存盘时转成了ID，ID值一旦添加后不能更改的,可以与C里的枚举值不一样,为兼顾前面数据就前面的取的是C里枚举值
	local tbAttribCharToId = {};
	local tbAttribIdToChar = {};
	local tbFile = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribSaveId.tab",
	"sd", nil,
	{"Attrib", "Id"});
	for i,v in ipairs(tbFile) do
		tbAttribCharToId[v.Attrib] = v.Id
		assert(not tbAttribIdToChar[v.Id], v.Attrib)
		tbAttribIdToChar[v.Id] = v.Attrib
	end

	if MODULE_GAMESERVER then
		for EquipType,v in pairs(self.tbType) do
			for Attrib, _ in pairs(v) do
				assert(tbAttribCharToId[Attrib], EquipType .. ", " .. Attrib)
			end
		end
	end

	self.tbAttribCharToId = tbAttribCharToId;
	self.tbAttribIdToChar = tbAttribIdToChar;

	local tbFile = LoadTabFile(
	"Setting/Item/RandomAttrib/SpecialAttribCount.tab",
	"dd", nil,
	{"ItemId",	"Count"});
	local tbSpecialAttribCount = {}
	for i,v in ipairs(tbFile) do
		tbSpecialAttribCount[v.ItemId] = v.Count
		assert(v.Count >= NORMAL_MAX_ATTRIB and v.Count <= 8, i)
	end
	self.tbSpecialAttribCount = tbSpecialAttribCount


	local tbCustomEquip = {};
	for _,tbAttribs in pairs(tbCustomEquipSetting) do
		local tbSaveIds = {}
		for i=1,6 do
			local szAttrib = tbAttribs["AttribType"..i];
			local nLevel = tbAttribs["AttribLevel"..i];
			if not Lib:IsEmptyStr(szAttrib) and nLevel ~= 0 then
				local nAttribId = self:AttribCharToId(szAttrib);
				local nSave = self:AttribToSaveData(nAttribId, nLevel);
				table.insert(tbSaveIds, nSave)
			end
		end
		tbCustomEquip[tbAttribs.TemplateId] = tbSaveIds
	end
	self.tbCustomEquip = tbCustomEquip;
end

function tbRefinement:LoadTypeAttribValue( nFileKind, nFromLevel, nToLevel, bAllType)
	Log("tbRefinement:LoadTypeAttribValue loading", nFileKind, nFromLevel, nToLevel)
	local tbAttribSetting = LoadTabFile(
			self.tbAttribFilePath[nFileKind],
			"sdddddds", nil,
			{"AttribType", "Level", "FightPower", "AttribValue", "Value1", "Value2", "Value3", "SpecialDesc"});

	local tbKindInfo = self.tbTypeAttribValue[nFileKind]
	for _,v in pairs(tbAttribSetting) do
		if bAllType then
			tbKindInfo[v.AttribType] = tbKindInfo[v.AttribType] or {}
		end
		if tbKindInfo[v.AttribType] and v.Level >= nFromLevel and v.Level <= nToLevel then
			tbKindInfo[v.AttribType][v.Level] =
			{
				tbMA = {v.Value1, v.Value2, v.Value3},
				nAttribValue = v.AttribValue,
				nFightPower = v.FightPower,
				szSpecialDesc = v.SpecialDesc,
			}
		end
	end
end

function tbRefinement:PreLoadTypeAttribValue( nPlayerLevel )
	local nLevel = math.max(1, math.floor(nPlayerLevel / 10 - 1 )) 
	local nFromLevel = math.max(1, 1 + 2*(nLevel - 1) - 5)
	local nToLevel = math.min(999, 1 + 2*(nLevel - 1) + 8)
	--todo 现在五行石是不预加载的
	for nFileKind=1,4 do
		local v =  self.tbTypeAttribValue[nFileKind]
		local szAttrib,tbLevelVal = next(v)
		if not tbLevelVal or not tbLevelVal[nFromLevel] or not tbLevelVal[nToLevel] then
			self:LoadTypeAttribValue(nFileKind, nFromLevel, nToLevel)
		end
	end
	local nFileKind = 5
	nLevel = math.max(1, math.floor(nPlayerLevel / 10 - 5 )) 
	nFromLevel = math.max(1, 2*nLevel - 1 - 5)
	nToLevel = math.min(999, 2*nLevel - 1 + 5)
	local v =  self.tbTypeAttribValue[nFileKind]
	local szAttrib,tbLevelVal = next(v)
	if not tbLevelVal or not tbLevelVal[nFromLevel] or not tbLevelVal[nToLevel] then
		self:LoadTypeAttribValue(nFileKind, nFromLevel, nToLevel)
	end
end

function tbRefinement:GetCustomAttri(dwTemplateId)
	local tbAttribs = self.tbCustomEquip[dwTemplateId]
	if tbAttribs then
		return Lib:CopyTB(tbAttribs)
	end
end

-- Server 属性生成
function tbRefinement:OnGenerate(pEquip)
	local tbSaveAttribs = {};

	local tbCustomAttri = self:GetCustomAttri(pEquip.dwTemplateId)
	if tbCustomAttri  then -- 定制装备没有随机属性
		tbSaveAttribs = tbCustomAttri
	else
		local tbForbid = {};
		local nCustomCount = 0;
		local nRealLevel, nEquipType = pEquip.nRealLevel, pEquip.nItemType;
		local szEquipType = Item.EQUIPTYPE_EN_NAME[nEquipType];
		local _,tbExtAttrib = self:GetRandomNumAndExtAttrib()
		if tbExtAttrib[nRealLevel] and tbExtAttrib[nRealLevel] > 0 then -- 稀有装备，额外多一条属性定制属性的等级。
			local nFixLevel = tbExtAttrib[nRealLevel]
			local szAttrib = self:RandomAttribType(szEquipType, tbForbid);
			local nAttribId = self:AttribCharToId(szAttrib);
			local nSave = self:AttribToSaveData(nAttribId, nFixLevel);
			if #tbSaveAttribs == 0 then -- 稀有属性为第一条属性
				table.insert(tbSaveAttribs, nSave);
			else
				local tbTemp = {};
				table.insert(tbTemp, nSave);
				for i,v in ipairs(tbSaveAttribs) do
					table.insert(tbTemp, v);
				end
				tbSaveAttribs = tbTemp;
			end
		end
		local nCreateCount = self:RandomCount(nRealLevel) - nCustomCount;
		for i = 1, nCreateCount do
			local szAttrib = self:RandomAttribType(szEquipType, tbForbid);
			local nLevel = self:RandomAttribLevel(nRealLevel);
			local nAttribId = self:AttribCharToId(szAttrib);	-- XXX
			local nSave = self:AttribToSaveData(nAttribId, nLevel);		-- 左移16位，ID为高16位，等级为低16位
			table.insert(tbSaveAttribs, nSave);
		end
	end

	for nPos, nSave in pairs(tbSaveAttribs) do
		self:ChangeRandomAttrib(pEquip, nPos, nSave);
	end
end

function tbRefinement:InitEquip(pEquip)
	local tbAttribs = self:GetRandomAttrib(pEquip);
	local nMaxQuality = 0;
	local nRefineValue = 0;
	local nRefinePower = 0;
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local nAttribLevel = tbAttrib.nAttribLevel
		local nQuality = self:GetAttribColor(pEquip.nLevel, nAttribLevel);
		--黄金装备加了额外的属性, 只加属性，不加价值和战力
		local nRealAttribLevel = Item.GoldEquip:GetRealUseAttribLevel(pEquip.nDetailType, pEquip.nLevel, nAttribLevel)
		local tbSetting = self:GetAttribSetting(tbAttrib.szAttrib, nRealAttribLevel, pEquip.nItemType);
		if tbSetting then
			pEquip.SetRandAttrib(nIdx, tbAttrib.szAttrib, unpack(tbSetting.tbMA))
		end
		if nRealAttribLevel ~= nAttribLevel then
			tbSetting = self:GetAttribSetting(tbAttrib.szAttrib, nAttribLevel, pEquip.nItemType);
		end
		if tbSetting then
			nRefineValue = nRefineValue + tbSetting.nAttribValue
			nRefinePower = nRefinePower + tbSetting.nFightPower
		end

		if nMaxQuality < nQuality then
			nMaxQuality = nQuality;
		end
	end
	 -- 充能的战力 和 基础属性
	 local tbRetModify = Item.GoldEquip:GetPlatinumSaveGoldAttr(pEquip)
	 if tbRetModify then
	 	if tbRetModify.nFightPower then
	 		nRefinePower = nRefinePower + tbRetModify.nFightPower
		end
		if tbRetModify.tbModifyAttri then
			local nUsedAtriIndex = #tbAttribs
			for k,v in pairs(tbRetModify.tbModifyAttri) do
				nUsedAtriIndex = nUsedAtriIndex + 1;
				pEquip.SetRandAttrib(nUsedAtriIndex, k, unpack(v))
			end
		end
	 end
	return nRefinePower, nRefineValue, nMaxQuality;
end

function tbRefinement:InitEquipEx(pEquip)
	local tbAttribs = self:GetRandomAttribEx(pEquip);
	local nMaxQuality = 0;
	local nRefineValue = 0;
	local nRefinePower = 0;
	for nIdx, tb in ipairs(tbAttribs) do
		local tbAttrib = KItem.GetExternAttrib(tb.nExternAttribGrp, tb.nAttribLevel)
		if not tbAttrib then
			Log("[x] tbRefinement:InitEquipEx", pEquip.dwTemplateId, tb.nExternAttribGrp, tb.nAttribLevel)
			return nil
		else
			for _, tbMagic in ipairs(tbAttrib) do
				pEquip.SetRandAttrib(nIdx, tbMagic.szAttribName, unpack(tbMagic.tbValue))
				break
			end
		end

		local nQuality = self:GetAttribColor(pEquip.nLevel, tb.nAttribLevel);
		if nMaxQuality < nQuality then
			nMaxQuality = nQuality;
		end

		nRefinePower = nRefinePower + Furniture.MagicBowl:GetAttribFightPower(tb.nExternAttribGrp, tb.nAttribLevel)
	end
	return nRefinePower, nRefineValue, nMaxQuality;
end

function tbRefinement:GetFightPowerFromSaveAttri(nLevel, tbSaveRandomAttrib, nItemType)
	if nItemType == Item.EQUIP_BACK2 then
		return Item.tbPiFeng:GetFightPowerFromSaveAttri(tbSaveRandomAttrib )
	end
	local nRefinePower = 0
	local tbAttribs = self:GetRandomAttribByTable(tbSaveRandomAttrib)
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local tbSetting = self:GetAttribSetting(tbAttrib.szAttrib, tbAttrib.nAttribLevel, nItemType);
		if tbSetting then
			nRefinePower = nRefinePower + tbSetting.nFightPower
		end
	end
	return nRefinePower
end

function tbRefinement:GetFightPowerFromSaveAttriEx(nLevel, tbSaveRandomAttrib, nItemType)
	local nRefinePower = 0
	local tbAttribs = self:GetRandomAttribByTableEx(tbSaveRandomAttrib)
	for _, tbAttrib in ipairs(tbAttribs) do
		nRefinePower = nRefinePower + Furniture.MagicBowl:GetAttribFightPower(tbAttrib.nExternAttribGrp, tbAttrib.nAttribLevel)
	end
	return nRefinePower
end



-- Server 属性生成 * 随属性条数
function tbRefinement:RandomCount(nRealLevel)
	local tbRandomNum = self:GetRandomNumAndExtAttrib()
	local tbNum = tbRandomNum[nRealLevel];
	if not tbNum then
		Log("[ERROR] RandomCount error in", nRealLevel);
		return 0;
	end
	local nAttribCount;

	local nRan = MathRandom(0, 1000);

	for nCount, nProb in pairs(tbNum) do
		nRan = nRan - nProb;
		if nRan <= 0 then
			nAttribCount = nCount;
			break;
		end
	end

	return nAttribCount;
end

-- Server 属性生成 * 随属性类别
function tbRefinement:RandomAttribType(szEquipType, tbForbid, tbCurAttribLevel, nTarAttribLevel)
	local szAttrib;
	local nTotoalProb = 0;
	local tbTypeAndProb = self.tbType[szEquipType]
	local tbTypeWeightAdd;
	if tbCurAttribLevel and nTarAttribLevel then
		tbTypeWeightAdd = self.tbTypeWeightAdd[szEquipType]
	end

	local tbfilter = {};
	for szType, nProb in pairs(tbTypeAndProb) do
		if not tbForbid[szType] then
			if tbTypeWeightAdd then
				local tbTypeWeightAddInfo = tbTypeWeightAdd[szType]
				if tbTypeWeightAddInfo then
					local nCurLevel = tbCurAttribLevel[szType]
					if not nCurLevel or nTarAttribLevel - nCurLevel > tbTypeWeightAddInfo.Delta then
						nProb = nProb + tbTypeWeightAddInfo.WeightAdd
					end
				end
			end

			table.insert(tbfilter, {szType, nProb});
			nTotoalProb = nTotoalProb + nProb;
		end
	end

	local nRan = MathRandom(0, nTotoalProb);
	for i, v in ipairs(tbfilter) do
		nRan = nRan - v[2];
		if nRan <= 0 then
			szAttrib = v[1];
			break;
		end
	end

	assert(szAttrib, "[ERROR] RandomAttribType NULL");
	tbForbid[szAttrib] = true;
	return szAttrib;
end

function tbRefinement:RandomAttribTypeEx(szEquipType, tbForbid, tbCurAttribLevel, nTarAttribLevel)
	local nExternAttribGrp = 0
	local nTotoalProb = 0;
	local tbTypeAndProb = self.tbTypeEx[szEquipType]
	local tbTypeWeightAdd;
	if tbCurAttribLevel and nTarAttribLevel then
		tbTypeWeightAdd = self.tbTypeExWeightAdd[szEquipType]
	end

	local tbfilter = {};
	for nGrpId, nProb in pairs(tbTypeAndProb) do
		if not tbForbid[nGrpId] then
			if tbTypeWeightAdd then
				local tbTypeWeightAddInfo = tbTypeWeightAdd[nGrpId]
				if tbTypeWeightAddInfo then
					local nCurLevel = tbCurAttribLevel[nGrpId]
					if not nCurLevel or nTarAttribLevel - nCurLevel > tbTypeWeightAddInfo.Delta then
						nProb = nProb + tbTypeWeightAddInfo.WeightAdd
					end
				end
			end

			table.insert(tbfilter, {nGrpId, nProb});
			nTotoalProb = nTotoalProb + nProb;
		end
	end

	local nRan = MathRandom(0, nTotoalProb);
	for i, v in ipairs(tbfilter) do
		nRan = nRan - v[2];
		if nRan <= 0 then
			nExternAttribGrp = v[1];
			break;
		end
	end

	assert(nExternAttribGrp > 0, string.format("[ERROR] RandomAttribTypeEx %s", tostring(nExternAttribGrp)))
	tbForbid[nExternAttribGrp] = true;
	return nExternAttribGrp;
end

-- Server 属性生成 * 随属性等级
function tbRefinement:RandomAttribLevel(nRealLevel)
	local nAttribLevel;
	local nTotoalProb = 0;

	local tbLevelAndProb = self.tbLevel[nRealLevel];
	for _, nProb in pairs(tbLevelAndProb) do
		nTotoalProb = nTotoalProb + nProb;
	end

	local nRan = MathRandom(0, nTotoalProb);
	for nLevel, nProb in pairs(tbLevelAndProb) do
		nRan = nRan - nProb;
		if nRan <= 0 then
			nAttribLevel = nLevel;
			break;
		end
	end

	return nAttribLevel;
end

function tbRefinement:GetFullRefineCount(pPlayer)
	local tbEquips =  pPlayer.GetEquips();
	local nFull = 0
	for _, nEquipId in pairs(tbEquips) do
		local pEquip = pPlayer.GetItemInBag(nEquipId);
		if pEquip then
			local tbEquipAttribs = self:GetRandomAttrib(pEquip);
			if #tbEquipAttribs >= 6 then
				nFull = nFull + 1
			end
		end
	end
	return nFull
end

-- Server 洗练
function tbRefinement:Refinement(pPlayer, nTarId, nSrcId, nTarPos, nSrcPos)
	local pItemTar = pPlayer.GetItemInBag(nTarId);
	local pItemSrc = pPlayer.GetItemInBag(nSrcId);

	if not pItemTar or not pItemSrc then
		return false;
	end

	if not pItemTar.IsEquip() then
		return false;
	end

	local tbSrcAttribs 		= self:GetRandomAttrib(pItemSrc);
	local tbTarAttribs 		= self:GetRandomAttrib(pItemTar);
	local tbSrcAttrib 		= tbSrcAttribs[nSrcPos];
	if not tbSrcAttrib then
		return false
	end

	if not self:CanDoRefinement(pItemTar, pItemSrc, tbTarAttribs, tbSrcAttrib, nTarPos) then
		return false
	end

	nTarPos = nTarPos or #tbTarAttribs + 1;

	local nItemType = pItemTar.nItemType
	if not pPlayer.CostMoney("Coin", self:GetRefineCost(tbSrcAttrib.nSaveData, pItemTar.nItemType), Env.LogWay_Refinement) then
		return false
	end

	self:ReduceRandomAttrib(pItemSrc, tbSrcAttrib.szAttrib);
	self:ChangeRandomAttrib(pItemTar, nTarPos, tbSrcAttrib.nSaveData);
	pItemTar.ReInit();
	FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(pItemTar.nEquipPos), pPlayer)

	EverydayTarget:AddCount(pPlayer, "EquipRefinement")

	pPlayer.TLog("EquipFlow", pItemTar.nItemType, pItemTar.dwTemplateId, pItemTar.dwId, 1, Env.LogWay_Refinement, 0, 2, pItemTar.GetIntValue(1),pItemTar.GetIntValue(2), pItemTar.GetIntValue(3), pItemTar.GetIntValue(4), pItemTar.GetIntValue(5),pItemTar.GetIntValue(6), pItemTar.GetIntValue(7), "");
	pPlayer.TLog("EquipFlow", pItemSrc.nItemType, pItemSrc.dwTemplateId, pItemSrc.dwId, 1, Env.LogWay_Refinement, 0, 3, pItemSrc.GetIntValue(1),pItemSrc.GetIntValue(2), pItemSrc.GetIntValue(3), pItemSrc.GetIntValue(4), pItemSrc.GetIntValue(5),pItemSrc.GetIntValue(6), pItemTar.GetIntValue(7), "");
	Log("Refinement", pPlayer.szAccount, pPlayer.dwID, pItemTar.dwTemplateId, pItemSrc.dwTemplateId, nTarPos, nSrcPos, nTarAttrLevel, tbSrcAttrib.nAttribLevel);

	--3.将一条粉色属性洗练到装备上
	local nItemTarLevel = pItemTar.nLevel
	local nColor =  self:GetAttribColor(nItemTarLevel, tbSrcAttrib.nAttribLevel, nItemType);
	if nColor == 6 then
		Achievement:AddCount(pPlayer, "EquipRefinement_3", 1);
	end

	--太多了... 这条不包括上面2种
	--之前有bug导致 公测玩家先完成了 身上所有装备洗满6条紫色以上属性 就一直没法完成4级的 将身上一件装备洗满6条紫色以上属性
	--1.成功完成一次装备洗练
	Achievement:AddCount(pPlayer, "EquipRefinement_1", 1);

	--2.将身上一件装备洗满6条属性
	tbTarAttribs = self:GetRandomAttrib(pItemTar);
	if #tbTarAttribs == 6 then
		Achievement:AddCount(pPlayer, "EquipRefinement_2", 1);
		TeacherStudent:OnEquipWashed(pPlayer)
		--5. 身上所有装备洗满6条紫色以上属性
		local tbEquips =  pPlayer.GetEquips();
		local nFullPurple = 0

		for _, nEquipId in pairs(tbEquips) do
			local pEquip = pPlayer.GetItemInBag(nEquipId);
			if pEquip then
				local tbEquipAttribs = self:GetRandomAttrib(pEquip);
				if #tbEquipAttribs < 6 then
					break;
				end
				local bBreak = false;
				for i, v in ipairs(tbEquipAttribs) do
					if self:GetAttribColor(nItemTarLevel, v.nAttribLevel, nItemType) < 4 then
						bBreak = true;
						break;
					end
				end
				if bBreak then
					break;
				end
			else
				break;
			end
			nFullPurple = nFullPurple + 1
		end
		if nFullPurple == Item.EQUIPPOS_MAIN_NUM  then
			Achievement:AddCount(pPlayer, "EquipRefinement_5", 1);
		else
			local bFullPurple = true
			for i, v in ipairs(tbTarAttribs) do
				if self:GetAttribColor(nItemTarLevel, v.nAttribLevel, nItemType) < 4 then
					bFullPurple = false
					break;
				end
			end
			if bFullPurple then
				Achievement:AddCount(pPlayer, "EquipRefinement_4", 1);
			end
		end
	end
	if pItemTar.nEquipPos == Item.EQUIPPOS_ZHEN_YUAN then
		Achievement:AddCount(pPlayer, "ZhenYuanRefinement_1", 1);
		--检查是否思维加持了
		if #tbTarAttribs >= 4 then
			local tbNeedAttri = {
				strength_v = 1;
				dexterity_v = 1;
				vitality_v = 1;
				energy_v = 1;
			};
			for i, v in ipairs(tbTarAttribs) do
				tbNeedAttri[v.szAttrib] = nil
			end
			if not next(tbNeedAttri) then
				Achievement:AddCount(pPlayer, "ZhenYuanRefinement_2", 1);
			end
		end
	end

	return true;
end

function tbRefinement:IsCanDoRefinementItemPos(nEquipPos)
	 if Item:IsMainEquipPos(nEquipPos) then
	 	return true
	 end
	 return nEquipPos == Item.EQUIPPOS_ZHEN_YUAN
end

function tbRefinement:CanDoRefinement(pItemTar, pItemSrc, tbTarAttribs, tbSrcAttrib, nTarPos)
	local nSrcItemType = pItemSrc.nItemType
	local nSrcEquipPos = pItemSrc.nEquipPos
	if pItemSrc.szClass == "RefineStone" then
		nSrcItemType = KItem.GetItemExtParam(pItemSrc.dwTemplateId, Item.tbRefinementStone.REFINE_STONE_PARAM_TYPE)
		nSrcEquipPos = Item.EQUIPTYPE_POS[nSrcItemType]
	end
	if pItemTar.nItemType ~= nSrcItemType then
		return false;
	end

	if not self:IsCanDoRefinementItemPos(pItemTar.nEquipPos) or not self:IsCanDoRefinementItemPos(nSrcEquipPos) then
		return false;
	end

	if not self:CanAddAttrib(pItemTar, tbSrcAttrib.nAttribId, tbSrcAttrib.nAttribLevel) then
		return false;
	end

	local bReplace = nTarPos ~= nil; -- 替换 or 新增
	local nTarAttrLevel;
	if self:IsExistSameTypeAttrib(tbTarAttribs, tbSrcAttrib.szAttrib) then
		if bReplace then
			local tbTarAttrib = tbTarAttribs[nTarPos];
			if tbTarAttrib.szAttrib ~= tbSrcAttrib.szAttrib then
				return;
			end
			nTarAttrLevel = tbTarAttrib.nAttribLevel;
			if nTarAttrLevel > tbSrcAttrib.nAttribLevel then
				return false, "不能将同类型属性洗练成低等级的"
			end
		else
			return false;
		end
	end

	local nFullCount = self:GetAttribFullCount(pItemTar.dwTemplateId);
	nTarPos = nTarPos or #tbTarAttribs + 1;
	if nTarPos > nFullCount  then
		return false;
	end
	return true
end

-- 假道具的洗练 客户端模拟
function tbRefinement:FakeRefinement(pPlayer, pItemTar, pItemSrc, nTarPos, nSrcPos, tbRecord)
	if not pItemTar or not pItemSrc or not tbRecord then
		return false;
	end

	local tbSrcAttribs 		= self:GetRandomAttrib(pItemSrc);
	local tbTarAttribs 		= self:GetRandomAttrib(pItemTar);
	local tbSrcAttrib 		= tbSrcAttribs[nSrcPos];
	if not tbSrcAttrib then
		return false
	end

	if not self:CanDoRefinement(pItemTar, pItemSrc, tbTarAttribs, tbSrcAttrib, nTarPos) then
		return false
	end

	local nTotalCost = tbRecord.nCoin + self:GetRefineCost(tbSrcAttrib.nSaveData, pItemTar.nItemType)
	if pPlayer.GetMoney("Coin") < nTotalCost then
		return false, "银两不足"
	end
	tbRecord.nCoin = nTotalCost

	nTarPos = nTarPos or #tbTarAttribs + 1;

	tbRecord.tbRefineIndex[nTarPos] = tbSrcAttrib.nSaveData  --源道具的val值的位置会在洗练后变化的, 所以不记录操作顺序了

	self:ReduceRandomAttrib(pItemSrc, tbSrcAttrib.szAttrib);
	self:ChangeRandomAttrib(pItemTar, nTarPos, tbSrcAttrib.nSaveData);

	return true;
end

function tbRefinement:GetAttribFullCount(nEquipTemplateId)
	local nAttribCount = self.tbSpecialAttribCount[nEquipTemplateId]
	if nAttribCount then
		return nAttribCount
	end
	return NORMAL_MAX_ATTRIB;
end


function tbRefinement:ReduceRandomAttrib(pEquip, szReduceAttrib)
	local tbAttribs = self:GetRandomAttrib(pEquip);
	local tbAfter = {};
	for i, _ in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local tbAttrib = tbAttribs[i];
		if tbAttrib then
			if tbAttrib.szAttrib ~= szReduceAttrib then
				table.insert(tbAfter, tbAttrib.nSaveData);
			end
		end
	end

	for i, _ in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData = tbAfter[i];
		self:ChangeRandomAttrib(pEquip, i, nSaveData or 0);
	end
	pEquip.ReInit();
end

function tbRefinement:ReduceRandomAttribEx(pEquip, nGrpId)
	local tbAttribs = self:GetRandomAttribEx(pEquip);
	local tbAfter = {};
	for i, _ in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local tbAttrib = tbAttribs[i];
		if tbAttrib then
			if tbAttrib.nExternAttribGrp ~= nGrpId then
				table.insert(tbAfter, tbAttrib.nSaveData);
			end
		end
	end

	for i, _ in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData = tbAfter[i];
		self:ChangeRandomAttrib(pEquip, i, nSaveData or 0);
	end
	pEquip.ReInit();
end


-- Server 转移
function tbRefinement:RefinementAll(pPlayer, nTarId, nSrcId)
	local pItemTar = pPlayer.GetItemInBag(nTarId);
	local pItemSrc = pPlayer.GetItemInBag(nSrcId);

	if not pItemTar or not pItemSrc then
		return false;
	end
	if pItemTar.nItemType ~= pItemTar.nItemType then
		return false;
	end
	if pItemTar.nLevel >= pItemSrc.nLevel then
		return false;
	end

	local tbTarAttribs = self:GetRandomAttrib(pItemTar);
	local tbSrcAttribs = self:GetRandomAttrib(pItemSrc);

	local nOrgFightPower = FightPower:CalcEquipFightPower(pPlayer);

	for i, _ in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local tbSrcAttrib = tbSrcAttribs[i];
		if tbSrcAttrib then
			self:ChangeRandomAttrib(pItemTar, i, tbSrcAttrib.nSaveData);
		else
			self:ChangeRandomAttrib(pItemTar, i, 0);
		end
		local tbTarAttrib = tbTarAttribs[i];
		if tbTarAttrib then
			self:ChangeRandomAttrib(pItemSrc, i, tbTarAttrib.nSaveData);
		else
			self:ChangeRandomAttrib(pItemSrc, i, 0);
		end
	end
	pItemSrc.ReInit();
	pItemTar.ReInit();

	local nCurFightPower = FightPower:CalcEquipFightPower(pPlayer);
	FightPower:SendInfoByChange(pPlayer, nCurFightPower - nOrgFightPower);

	return true;
end

function tbRefinement:IsExistSameTypeAttrib(tbAttribs, szAttrib)
	for _, tbAttrib in pairs(tbAttribs) do
		if tbAttrib.szAttrib == szAttrib then
			return true;
		end
	end

	return false;
end

function tbRefinement:IsExistSameTypeAttribEx(tbAttribs, nGrpId)
	for _, tbAttrib in pairs(tbAttribs) do
		if tbAttrib.nExternAttribGrp == nGrpId then
			return true;
		end
	end

	return false;
end

-- Server
function tbRefinement:ChangeRandomAttrib(pEquip, nPos, nSave)
	self:SetItemIntValue(pEquip, nPos, nSave)
end


function tbRefinement:SetItemIntValue(pEquip, index, val)
	local nSaveKey = Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY[index]
	if type(pEquip) == "table" then
		pEquip:SetIntValue(nSaveKey, val)
	else
		pEquip.SetIntValue(nSaveKey, val)
	end
end

function tbRefinement:GetItemIntValue(pEquip, index)
	local nSaveKey = Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY[index]
	if type(pEquip) == "table" then
		return pEquip:GetIntValue(nSaveKey)
	else
		return pEquip.GetIntValue(nSaveKey)
	end
end

-- C/S
function tbRefinement:GetRandomAttrib(pEquip)
	local tbAttribs = {};
	for i, _ in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData =  self:GetItemIntValue(pEquip, i);
		if nSaveData ~= 0 then
			local nAttribId, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			local szAttrib 					= self:AttribIdToChar(nAttribId);
			table.insert(tbAttribs,
			{
				szAttrib 		= szAttrib,
				nAttribLevel 	= nAttribLevel;
				nAttribId 		= nAttribId,
				nSaveData 		= nSaveData,
			})
		else
			break;
		end
	end
	return tbAttribs;
end

function tbRefinement:GetRandomAttribEx(pEquip)
	local tbAttribs = {};
	for i, _ in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData =  self:GetItemIntValue(pEquip, i);
		if nSaveData ~= 0 then
			local nExternAttribGrp, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			table.insert(tbAttribs,
			{
				nExternAttribGrp 		= nExternAttribGrp,
				nAttribLevel 	= nAttribLevel;
				nSaveData 		= nSaveData,
			})
		else
			break;
		end
	end
	return tbAttribs;
end

function tbRefinement:GetSaveRandomAttrib(pEquip)
	if not pEquip then
		return
	end
	local tbSaveRandomAttrib = {}
	for i,nKey in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		tbSaveRandomAttrib[nKey] = self:GetItemIntValue(pEquip, i)
	end
	return tbSaveRandomAttrib
end

function tbRefinement:GetRandomAttribByTable(tbSaveAttrib)
	local tbAttribs = {};
	for _, nSaveKey  in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData = tbSaveAttrib[nSaveKey]
		if not nSaveData or nSaveData == 0 then
			break;
		else
			local nAttribId, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			local szAttrib 					= self:AttribIdToChar(nAttribId);
			table.insert(tbAttribs,
			{
				szAttrib 		= szAttrib,
				nAttribLevel 	= nAttribLevel;
				nAttribId 		= nAttribId,
				nSaveData 		= nSaveData,
			})
		end
	end
	return tbAttribs;
end

function tbRefinement:GetRandomAttribByTableEx(tbSaveAttrib)
	local tbAttribs = {};
	for _, nSaveKey  in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData = tbSaveAttrib[nSaveKey]
		if not nSaveData or nSaveData == 0 then
			break;
		else
			local nExternAttribGrp, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			table.insert(tbAttribs,
			{
				nExternAttribGrp 		= nExternAttribGrp,
				nAttribLevel 	= nAttribLevel;
				nSaveData 		= nSaveData,
			})
		end
	end
	return tbAttribs;
end

function tbRefinement:GetRandomAttribLevel(pEquip)
	local tbAttribs = {};
	local nAttribCount = 0;
	for i,_  in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData = self:GetItemIntValue(pEquip, i)
		if nSaveData ~= 0 then
			local nAttribId, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			tbAttribs[nAttribId] = nAttribLevel;
			nAttribCount = nAttribCount + 1;
		end
	end
	return tbAttribs, nAttribCount;
end

function tbRefinement:GetRandomAttribTypeLevel(pEquip)
	local tbAttribs = {};
	for i,_  in ipairs(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY) do
		local nSaveData = self:GetItemIntValue(pEquip, i)
		if nSaveData ~= 0 then
			local nAttribId, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			local szAttrib 					= self:AttribIdToChar(nAttribId);
			tbAttribs[szAttrib] = nAttribLevel;
		end
	end
	return tbAttribs;
end

-- C/S
function tbRefinement:GetAttribColor(nEquipLevel, nAttribLevel, nItemType)
	if nItemType and nItemType == Item.EQUIP_ZHEN_YUAN then
		return Item.tbZhenYuan:GetAttribColor(nEquipLevel, nAttribLevel)
	end
	if nItemType and nItemType == Item.ITEM_INSCRIPTION then
		return Furniture.MagicBowl:GetAttribColor(nEquipLevel, nAttribLevel)
	end
	local nKey = nEquipLevel * 100 + nAttribLevel;
	local nAttribColor = self.tbColor[nKey]
	if not nAttribColor then
		Log("[ERROR] can find color in ".. nEquipLevel .." ".. nAttribLevel);
		return 1;
	else
		return nAttribColor;
	end
end

-- C/S
function tbRefinement:GetAttribValue(nSaveData, nItemType)
	if nSaveData == 0 then
		return 0;
	end
	local nAttribId, nAttribLevel = self:SaveDataToAttrib(nSaveData);
	local szAttrib = self:AttribIdToChar(nAttribId);
	local tbData = self:GetAttribSetting(szAttrib, nAttribLevel, nItemType)
	return tbData.nAttribValue;
end

function tbRefinement:GetRefineCost(nSaveData, nItemType)
	local nAttribValue = self:GetAttribValue(nSaveData, nItemType)
	if not nAttribValue then
		return 0
	end
	return math.floor(nAttribValue * 0.1 / 10)
end

-- C/S
function tbRefinement:GetAttribMA(tbAttrib, nItemType)
	if nItemType == Item.ITEM_INSCRIPTION then
		local tbExternAttrib = KItem.GetExternAttrib(tbAttrib.nExternAttribGrp, tbAttrib.nAttribLevel)
		if not tbExternAttrib or not tbExternAttrib[1] then
			Log("[x] InscriptionItem:GetTipOneAttrib", nDetailType, nItemType, nEquipLevel, tbAttrib.nExternAttribGrp, tbAttrib.nAttribLevel)
			return
		end
		return tbExternAttrib[1].tbValue, nil, tbExternAttrib[1].szAttribName
	end
	local szAttrib, nLevel = tbAttrib.szAttrib, tbAttrib.nAttribLevel;
	local tbData = self:GetAttribSetting(szAttrib, nLevel,nItemType)
	if tbData then
		return tbData.tbMA, tbData.szSpecialDesc;
	else
		Log(string.format("[ERROR]Refinement:GetAttribMA  Attrib:%s not exist level %d in Attrib.tab", szAttrib, nLevel));
	end
end

function tbRefinement:GetAttribSetting(szAttrib, nLevel, nItemType)
	local nFileKind = self.tbAttribItemTypeToFileType[nItemType]
	local tbLevels = self.tbTypeAttribValue[nFileKind][szAttrib]
	if not tbLevels or not tbLevels[nLevel] then
		Log(" Not Preload AttribSetting", szAttrib, nLevel, nFileKind)
		self:LoadTypeAttribValue(nFileKind, math.max(1, nLevel - 5) , nLevel + 7, true)
		tbLevels = self.tbTypeAttribValue[nFileKind][szAttrib]
	end
	return tbLevels[nLevel]
end

-- C/S
function tbRefinement:CanAddAttrib(pEquip, nAttribId, nAttribLevel)
	local szAttrib = self:AttribIdToChar(nAttribId);
	local szEquipType = Item.EQUIPTYPE_EN_NAME[pEquip.nItemType];
	local nEquipLevel = pEquip.nLevel;

	if self.tbType[szEquipType][szAttrib] then -- and self:CanAddAttribLevel(nEquipLevel, nAttribLevel) then
		return true;
	else
		return false;
	end
end

-- 可洗练

tbRefinement.tbForbitRefinemClass = {
	["SeriesStone"] = 1;
}
function tbRefinement:CanRefinement(pEquipTar, pEquipSrc, bCheckChange)
	if self.tbForbitRefinemClass[pEquipTar.szClass] then
		return false
	end
	local pEquipSrcRealLevel = pEquipSrc.nRealLevel;
	if pEquipSrc.szClass == "RefineStone" then
		pEquipSrcRealLevel = KItem.GetItemExtParam(pEquipSrc.dwTemplateId, Item.tbRefinementStone.REFINE_STONE_PARAM_LEVEL)
	end
	if pEquipSrcRealLevel > pEquipTar.nRealLevel then
		return false;
	end
	local tbAttribLevel, nAttribCount = self:GetRandomAttribLevel(pEquipTar);
	local tbSrcAttribs = self:GetRandomAttrib(pEquipSrc);

	local nEquipTarLevel = pEquipTar.nLevel;

	local _, nMinTarLevel = next(tbAttribLevel) ;
	for _, nLevel in pairs(tbAttribLevel) do
		if nLevel < nMinTarLevel then
			nMinTarLevel = nLevel
		end
	end
	nMinTarLevel = nMinTarLevel or 0;
	local nFullCount = self:GetAttribFullCount(pEquipTar.dwTemplateId);
	for _, tbSrcAttrib in ipairs(tbSrcAttribs) do
		if not tbAttribLevel[tbSrcAttrib.nAttribId] then --没有的属性，比身上高的，或者可添加的
			if tbSrcAttrib.nAttribLevel > nMinTarLevel then
				return true
			end
			if bCheckChange or nAttribCount < nFullCount then
				return true
			end
		else 	-- 有的属性 可提升属性等级
			if tbAttribLevel[tbSrcAttrib.nAttribId] < tbSrcAttrib.nAttribLevel then
				return true
			end
		end
	end
	return false
end


-- C/S
function tbRefinement:AttribCharToId(szName)
	local nId = self.tbAttribCharToId[szName]
	if not nId then
		Log("[ERROR] tbRefinement:AttribCharToId", szName);
		return
	end
	return nId
end

-- C/S
function tbRefinement:AttribIdToChar(nQueryId)
	local szName = self.tbAttribIdToChar[nQueryId]
	if not szName then
		Log("[ERROR] tbRefinement:AttribIdToChar", nQueryId);
		return ""
	end
	return szName
end

-- C/S
function tbRefinement:AttribToSaveData(nAttribId, nLevel)
	return nAttribId * 65536 + nLevel;
end

-- C/S
function tbRefinement:SaveDataToAttrib(nData)
	local nAttribId 	= math.floor(nData / 65536);
	local nLevel 		= math.floor(nData % 65536);

	return nAttribId, nLevel;
end

function tbRefinement:OnStartDataCheck()
--[[
	local tbAllPlatinumSaveAttr,  tbAllGoldSaveAttr = Item.GoldEquip:GetAllGoldPlatinumSaveAttr()
	local nMaxItemLevel = 0
	for k,v in pairs(tbAllPlatinumSaveAttr[Item.EQUIPPOS_WEAPON]) do
		if k > nMaxItemLevel then
			nMaxItemLevel = k;
		end
	end
	local nMaxAttribLevel = Item.GoldEquip.tbGoldExternAttrib[nMaxItemLevel]["nMaxLevel"..Item.DetailType_Platinum];
	for nItemType=Item.EQUIP_WEAPON,Item.EQUIP_PENDANT do
		local szType = Item.EQUIPTYPE_EN_NAME[nItemType]
		for szAttrib,v in pairs(self.tbType[szType]) do
			local tbSettingAttrib = self:GetAttribSetting(szAttrib, nMaxAttribLevel, nItemType)		
			assert(tbSettingAttrib)
			assert(tbSettingAttrib.tbMA[1] > 0)
			assert(tbSettingAttrib.nAttribValue > 0)
			assert(tbSettingAttrib.nFightPower > 0)
		end
	end
]]

    --服务端无此函数的定义
	--"CommonScript/Item/GoldEquip.lua"]:1106: attempt to call field 'GetEquipBaseProp' (a nil value)
    Log("SSSSSSSS[tbRefinement:OnStartDataCheck]TODO");
end

--C
function tbRefinement:OnRefinementResult(bRet, szMsg)
	if Ui:WindowVisible("RefinementPanel") == 1 then
		Ui("RefinementPanel"):OnRespond(bRet, szMsg);
	end
end

function tbRefinement:GetRefineItemType( pItem )
	if pItem.szClass == "RefineStone" then
		return KItem.GetItemExtParam(pItem.dwTemplateId, Item.tbRefinementStone.REFINE_STONE_PARAM_TYPE)
	else
		return pItem.nItemType
	end
end

tbRefinement:TrimSetting();