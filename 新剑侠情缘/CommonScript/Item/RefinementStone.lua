Require("CommonScript/Item/Refinement.lua") 

Item.tbRefinementStone 	= Item.tbRefinementStone or {};
local tbRefinementStone 	= Item.tbRefinementStone;
local tbRefinement 	= Item.tbRefinement;
tbRefinementStone.REFINE_STONE_PARAM_TYPE 	= 1;
tbRefinementStone.REFINE_STONE_PARAM_LEVEL 	= 2;

local tbNumSetting = LoadTabFile(
	"Setting/Item/RandomAttribRefineStone/AttribNum.tab", 
	"ddddddd", "RealLevel", 
	{"RealLevel", "Count1", "Count2", "Count3", "Count4", "Count5", "ExtAttribLevel"});

local tbTypeSetting = LoadTabFile(
	"Setting/Item/RandomAttribRefineStone/AttribType.tab", 
	"ssd", nil, 
	{"EquipType", "Attrib", "Probility"});

local tbLevelSetting = LoadTabFile(
	"Setting/Item/RandomAttribRefineStone/AttribLevel.tab", 
	"ddd", nil, 
	{"RealLevel", "AttribLevel", "Probility",});		-- XXX

function tbRefinementStone:TrimSetting()
	self.tbRandomNum = {}
	self.tbExtAttrib = {};
	for nRealLevel,v in pairs(tbNumSetting) do
		self.tbRandomNum[nRealLevel] = {v.Count1, v.Count2, v.Count3, v.Count4, v.Count5};
		self.tbExtAttrib[nRealLevel] = v.ExtAttribLevel;
	end

	self.tbType = {};
	for _, v in pairs(tbTypeSetting) do
		self.tbType[v.EquipType] = self.tbType[v.EquipType] or {};
		self.tbType[v.EquipType][v.Attrib] = v.Probility;
	end

	self.tbLevel = {};
	for _,v in pairs(tbLevelSetting) do
		self.tbLevel[v.RealLevel] = self.tbLevel[v.RealLevel] or {};
		self.tbLevel[v.RealLevel][v.AttribLevel] = v.Probility;
	end
end
tbRefinementStone:TrimSetting()

function tbRefinementStone:GetEquipPosByTemplateId( dwTemplateId )
	local nEquipType = KItem.GetItemExtParam(dwTemplateId, self.REFINE_STONE_PARAM_TYPE)
	return Item.EQUIPTYPE_POS[nEquipType]
end

-- Server 属性生成
function tbRefinementStone:OnGenerate(pEquip)
	local tbSaveAttribs = {};
	
	local tbForbid = {};
	local dwTemplateId = pEquip.dwTemplateId
	local nEquipType = KItem.GetItemExtParam(dwTemplateId, self.REFINE_STONE_PARAM_TYPE)
	local nRealLevel = KItem.GetItemExtParam(dwTemplateId, self.REFINE_STONE_PARAM_LEVEL)
	local szEquipType = Item.EQUIPTYPE_EN_NAME[nEquipType];
	if self.tbExtAttrib[nRealLevel] and self.tbExtAttrib[nRealLevel] > 0 then -- 稀有装备，额外多一条属性定制属性的等级。
		local nFixLevel = self.tbExtAttrib[nRealLevel]
		local szAttrib = self:RandomAttribType(szEquipType, tbForbid);
		local nAttribId = tbRefinement:AttribCharToId(szAttrib);
		local nSave = tbRefinement:AttribToSaveData(nAttribId, nFixLevel);
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
	local nCreateCount = self:RandomCount(nRealLevel);
	for i = 1, nCreateCount do
		local szAttrib = self:RandomAttribType(szEquipType, tbForbid);
		local nLevel = self:RandomAttribLevel(nRealLevel);
		local nAttribId = tbRefinement:AttribCharToId(szAttrib);	-- XXX
		local nSave = tbRefinement:AttribToSaveData(nAttribId, nLevel);		-- 左移16位，ID为高16位，等级为低16位
		table.insert(tbSaveAttribs, nSave);
	end

	for nPos, nSave in pairs(tbSaveAttribs) do
		pEquip.SetIntValue(nPos, nSave)	
	end
end

function tbRefinementStone:InitEquip(pEquip)
	local tbAttribs = tbRefinement:GetRandomAttrib(pEquip);
	local nMaxQuality = 0;
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local nAttribLevel = tbAttrib.nAttribLevel
		local nQuality = tbRefinement:GetAttribColor(pEquip.nLevel, nAttribLevel);
		if nMaxQuality < nQuality then
			nMaxQuality = nQuality;
		end
	end
	return nMaxQuality;
end

function tbRefinementStone:RandomAttribType(szEquipType, tbForbid)
	local szAttrib;
	local nTotoalProb = 0;
	local tbTypeAndProb = self.tbType[szEquipType]
	 
	local tbfilter = {};
	for szType, nProb in pairs(tbTypeAndProb) do
		if not tbForbid[szType] then
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

function tbRefinementStone:RandomCount(nRealLevel)
	local tbNum = self.tbRandomNum[nRealLevel];
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

function tbRefinementStone:RandomAttribLevel(nRealLevel)
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

