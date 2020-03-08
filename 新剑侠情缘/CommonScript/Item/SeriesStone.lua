Require("CommonScript/Item/Refinement.lua")

Item.tbSeriesStone 	= Item.tbSeriesStone or {};
local tbSeriesStone 	= Item.tbSeriesStone;
local tbRefinement 	= Item.tbRefinement;
tbSeriesStone.COLOR_ACTIVE = "ffffff"
tbSeriesStone.COLOR_UN_ACTIVE = "b4b4b4"

tbSeriesStone.TYPE_LIGHT = 1;
tbSeriesStone.TYPE_DARK = 2;
tbSeriesStone.SERIES_KEY = 1; --五行的key
tbSeriesStone.ATTRI_KEY = {
	[tbSeriesStone.TYPE_LIGHT] = { 2,3,4 };
	[tbSeriesStone.TYPE_DARK] = { 6,7 }; --激活规则是最多2条
}
tbSeriesStone.ACTIVE_KEY = { 8,9 };

tbSeriesStone.tbSeriesActiveMap = { --五行的激活顺序
	[1] = 3;
	[3] = 2;
	[2] = 4;
	[4] = 5;
	[5] = 1;
}
tbSeriesStone.tbSeriesActiveMapBack = {}
for k,v in pairs(tbSeriesStone.tbSeriesActiveMap) do
	tbSeriesStone.tbSeriesActiveMapBack[v] = k
end

tbSeriesStone.tbPosActiveGroup = {
	[1] = {  Item.EQUIPPOS_BOOTS_SERIES, Item.EQUIPPOS_AMULET_SERIES };
	[2] = {  Item.EQUIPPOS_BELT_SERIES,Item.EQUIPPOS_PENDANT_SERIES };
	[3] = {  Item.EQUIPPOS_ARMOR_SERIES, Item.EQUIPPOS_RING_SERIES };
	[4] = {  Item.EQUIPPOS_CUFF_SERIES, Item.EQUIPPOS_NECKLACE_SERIES };
	[5] = {  Item.EQUIPPOS_HELM_SERIES, Item.EQUIPPOS_WEAPON_SERIES };
}

tbSeriesStone.tbPosActiveMapFront = { --装备的激活顺序 nPos 能激活的2个位置
	[1] = 2;
	[2] = 3;
	[3] = 4;
	[4] = 5;
	[5] = 1;
}

tbSeriesStone.tbPosNormalTo = {
	[Item.EQUIPPOS_HEAD] 		= Item.EQUIPPOS_HELM_SERIES;
	[Item.EQUIPPOS_BODY]		= Item.EQUIPPOS_ARMOR_SERIES,
	[Item.EQUIPPOS_BELT]		= Item.EQUIPPOS_BELT_SERIES,
	[Item.EQUIPPOS_WEAPON]		= Item.EQUIPPOS_WEAPON_SERIES,
	[Item.EQUIPPOS_FOOT]		= Item.EQUIPPOS_BOOTS_SERIES,
	[Item.EQUIPPOS_CUFF]		= Item.EQUIPPOS_CUFF_SERIES,
	[Item.EQUIPPOS_AMULET]		= Item.EQUIPPOS_AMULET_SERIES,
	[Item.EQUIPPOS_RING]		= Item.EQUIPPOS_RING_SERIES,
	[Item.EQUIPPOS_NECKLACE]	= Item.EQUIPPOS_NECKLACE_SERIES,
	[Item.EQUIPPOS_PENDANT]		= Item.EQUIPPOS_PENDANT_SERIES,
};
--nPos  被2个位置激活
tbSeriesStone.tbPosActiveMapBack = {}
for nPos,v1 in pairs(tbSeriesStone.tbPosActiveMapFront) do
	tbSeriesStone.tbPosActiveMapBack[v1] = nPos
end

function tbSeriesStone:GetPosGroup( nPosTar )
	if not self.tbCachePosGroup then
		self.tbCachePosGroup = {};
		for nGroup,v in pairs(self.tbPosActiveGroup) do
			for _,nPos in ipairs(v) do
				self.tbCachePosGroup[nPos] = nGroup
			end
		end
	end
	return self.tbCachePosGroup[nPosTar]
end

function tbSeriesStone:TrimSetting()
	self.tbNumSetting = LoadTabFile(
	"Setting/Item/RandomAttrib/SeriesAttribSetting.tab", 
	"dddd", "RealLevel", 
	{"RealLevel", "LightNum", "DarkNum", "AttribLevel"});
	--TODO datacheck. 最大属性数是少于savekey的数量的
end

tbSeriesStone:TrimSetting()

function tbSeriesStone:GetBackActiveEquipPosName( nEquipPos , nSeries, tbActiveDark, nActiveBackPos)
	local nPosGroup = self:GetPosGroup(nEquipPos)
	local nActiveBackGroup = self.tbPosActiveMapBack[nPosGroup]
	local tbBackActivePos = self.tbPosActiveGroup[nActiveBackGroup]
	local tbPosName = {};
	local nBackActive = self.tbSeriesActiveMapBack[nSeries]
	for i,v in ipairs(tbBackActivePos) do
	-- 如果是一个就要根据位置来判断了，可能是任意一个激活了
		local szTxtColor ;
		if nActiveBackPos then
			szTxtColor = v == nActiveBackPos and  self.COLOR_ACTIVE or self.COLOR_UN_ACTIVE 	
		else
			szTxtColor = tbActiveDark[i] and self.COLOR_ACTIVE or self.COLOR_UN_ACTIVE 	
		end

		table.insert(tbPosName, string.format("[%s]%s（%s）[-]", szTxtColor,  Item.EQUIPPOS_NAME[v], Npc.Series[nBackActive]))
	end
	return table.concat( tbPosName, "  ")
end

function tbSeriesStone:UpdateEquips( pPlayer, nEquipPos)
	local nPosGroup = self:GetPosGroup(nEquipPos)
	local tbCurUseSeries = {};
	for i,v in ipairs(self.tbPosActiveGroup[nPosGroup]) do
		local pCurEquip = pPlayer.GetEquipByPos(v)
		if pCurEquip then
			table.insert(tbCurUseSeries, pCurEquip.GetIntValue(self.SERIES_KEY))	
		end
	end
	local nActiveFrontGroup = self.tbPosActiveMapFront[nPosGroup]
	for i,v in ipairs(self.tbPosActiveGroup[nActiveFrontGroup]) do
		local pCurEquip = pPlayer.GetEquipByPos(v)
		if pCurEquip then
			local nCurSeries = pCurEquip.GetIntValue(self.SERIES_KEY)
			local nBackActiveSeries = self.tbSeriesActiveMapBack[nCurSeries]
			local nCanActiveCount = 0
			for _, v2 in pairs(tbCurUseSeries) do
				if v2 == nBackActiveSeries then
					nCanActiveCount = nCanActiveCount + 1;
				end
			end
			local bChangeVal = false
			for nActive, nActvieKey in ipairs(self.ACTIVE_KEY) do
				local nOldVal = pCurEquip.GetIntValue(nActvieKey)
				local nNewVal = nOldVal
				if nActive <= nCanActiveCount then
					nNewVal = 1;
				else
					nNewVal = 0;
				end
				if nNewVal ~= nOldVal then
					bChangeVal = true
					pCurEquip.SetIntValue(nActvieKey, nNewVal)
				end
			end
			if bChangeVal then
				pCurEquip.ReInit()
			end
		end
	end

	
	local pCurEquip = pPlayer.GetEquipByPos(nEquipPos)
	if pCurEquip then
		local nActiveBackGroup = self.tbPosActiveMapBack[nPosGroup]
		local tbCurUseSeriesBack = {};
		for i,v in ipairs(self.tbPosActiveGroup[nActiveBackGroup]) do
			local pCurEquip = pPlayer.GetEquipByPos(v)
			if pCurEquip then
				table.insert(tbCurUseSeriesBack, pCurEquip.GetIntValue(self.SERIES_KEY))
			end
		end

		local nCurSeries = pCurEquip.GetIntValue(self.SERIES_KEY)
		local nBackActiveSeries = self.tbSeriesActiveMapBack[nCurSeries]
		local nCanActiveCount = 0
		for _, v2 in pairs(tbCurUseSeriesBack) do
			if v2 == nBackActiveSeries then
				nCanActiveCount = nCanActiveCount + 1;
			end
		end

		local bChangeVal = false
		for nActive, nActvieKey in ipairs(self.ACTIVE_KEY) do
			local nOldVal = pCurEquip.GetIntValue(nActvieKey)
			local nNewVal = nOldVal
			if nActive <= nCanActiveCount then
				nNewVal = 1
			else
				nNewVal = 0
			end
			if nNewVal ~= nOldVal then
				bChangeVal = true
				pCurEquip.SetIntValue(nActvieKey, nNewVal)
			end
		end
		if bChangeVal then
			pCurEquip.ReInit()
		end
	end
end

function tbSeriesStone:AfterUseEquip( pPlayer, pEquip)
	self:UpdateEquips( pPlayer, pEquip.nEquipPos)
end

function tbSeriesStone:AfterUnuseEquip( pPlayer, pEquip, nPos )
	local bChangeVal = false
	for nActive, nActvieKey in ipairs(self.ACTIVE_KEY) do
		local nOldVal = pCurEquip.GetIntValue(nActvieKey)
		if nOldVal ~= 0 then
			pEquip.SetIntValue(nActvieKey, 0)
			bChangeVal = true
		end
	end
	if bChangeVal then
		pEquip.ReInit()
	end
	self:UpdateEquips( pPlayer, nPos)
end


function tbSeriesStone:OnGenerate( pEquip )
	--随机明暗属性， 默认暗属性是不生效，暗属性是穿上去后如果生效重新设置再 reinit
	
	local nRealLevel, nEquipType = pEquip.nRealLevel, pEquip.nItemType;
	local szEquipType = Item.EQUIPTYPE_EN_NAME[nEquipType];
	local tbNumInfo = self.tbNumSetting[nRealLevel]
	local tbAttriNum = {tbNumInfo.LightNum, tbNumInfo.DarkNum};
	local nAttribLevel = tbNumInfo.AttribLevel
	local nRandSeries = MathRandom(1, #Npc.Series)
	pEquip.SetIntValue(self.SERIES_KEY, nRandSeries)
	for nType, nAttriNum in ipairs(tbAttriNum) do
		if nType == self.TYPE_DARK then
			szEquipType = Item.EQUIPTYPE_EN_NAME[nEquipType] .. "Dark"
		end
		local tbSaveAttribs = {  };
		local tbForbid = {};
		for i = 1, nAttriNum do
			local szAttrib = tbRefinement:RandomAttribType(szEquipType, tbForbid);
			local nAttribId = tbRefinement:AttribCharToId(szAttrib);	-- XXX
			local nSave = tbRefinement:AttribToSaveData(nAttribId, nAttribLevel);		-- 左移16位，ID为高16位，等级为低16位
			table.insert(tbSaveAttribs, nSave);
		end	
		for nPos, nSave in pairs(tbSaveAttribs) do
			self:ChangeRandomAttrib(nType, pEquip, nPos, nSave);
		end
	end
end

function tbSeriesStone:ChangeRandomAttrib(nType, pEquip, nPos, nSave)
	local nSaveKey = self.ATTRI_KEY[nType][nPos]
	pEquip.SetIntValue(nSaveKey, nSave)	
end

function tbSeriesStone:InitEquip(pEquip)
	local tbAttribs, tbActiveDark = self:GetRandomAttrib(pEquip);
	local nMaxQuality = 0;
	local nRefineValue = 0;
	local nRefinePower = 0;
	local nUseIndx = 0
	for nType,v1 in ipairs(tbAttribs) do
		for nIdx, tbAttrib in ipairs(v1) do
			local nAttribLevel = tbAttrib.nAttribLevel
			local nQuality = tbRefinement:GetAttribColor(pEquip.nLevel, nAttribLevel);
			--黄金装备加了额外的属性, 只加属性，不加价值和战力
			local tbSetting = tbRefinement:GetAttribSetting(tbAttrib.szAttrib, nAttribLevel, pEquip.nItemType);
			if tbSetting then
				if nType ~= self.TYPE_DARK or tbActiveDark[nIdx] then
					nUseIndx = nUseIndx + 1;
					pEquip.SetRandAttrib(nUseIndx, tbAttrib.szAttrib, unpack(tbSetting.tbMA))	
				end
				nRefineValue = nRefineValue + tbSetting.nAttribValue
				nRefinePower = nRefinePower + tbSetting.nFightPower
			end
			if nMaxQuality < nQuality then
				nMaxQuality = nQuality;
			end
		end	
	end
	
	return nRefinePower, nRefineValue, nMaxQuality;
end

function tbSeriesStone:GetRandomAttrib(pEquip)
	local tbAttribs = {{},{}};
	for nType,v1 in ipairs(self.ATTRI_KEY) do
		for i,nSaveKey in ipairs(v1) do
			local nSaveData = pEquip.GetIntValue(nSaveKey)
			if nSaveData ~= 0 then
				local nAttribId, nAttribLevel 	= tbRefinement:SaveDataToAttrib(nSaveData);
				local szAttrib 					= tbRefinement:AttribIdToChar(nAttribId);
				table.insert(tbAttribs[nType], 
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
	end
	local tbActiveDark = {}
	for i, nActiveKey in ipairs(self.ACTIVE_KEY) do
		local nActive = pEquip.GetIntValue(nActiveKey)
		if nActive == 1 then
			tbActiveDark[i] = true
		else
			break;
		end
	end
	local nSeries = pEquip.GetIntValue(self.SERIES_KEY)
	return tbAttribs, tbActiveDark, nSeries
end

function tbSeriesStone:GetRandomAttribByTable( tbSaveAttrib )
	local tbAttribs = {{},{}};
	
	for nType,v1 in ipairs(self.ATTRI_KEY) do
		for i,nSaveKey in ipairs(v1) do
			local nSaveData = tbSaveAttrib[nSaveKey]
			if nSaveData and nSaveData ~= 0 then
				local nAttribId, nAttribLevel 	= tbRefinement:SaveDataToAttrib(nSaveData);
				local szAttrib 					= tbRefinement:AttribIdToChar(nAttribId);
				table.insert(tbAttribs[nType], 
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
	end
	local tbActiveDark = {}
	for i, nActiveKey in ipairs(self.ACTIVE_KEY) do
		local nActive = tbSaveAttrib[nActiveKey]
		if nActive == 1 then
			tbActiveDark[i] = true
		else
			break;
		end
	end
	local nSeries = tbSaveAttrib[self.SERIES_KEY];
	return tbAttribs, tbActiveDark, nSeries
end

function tbSeriesStone:GetOnEquipAttrib( pPlayer, nEquipPos )
	local nStonePos = self.tbPosNormalTo[nEquipPos]
	if not nStonePos then
		return
	end
	local pEquip = pPlayer.GetEquipByPos(nStonePos)
	if not pEquip then
		return
	end
	local tbAttribGroups, tbActiveDark, nSeries = self:GetRandomAttrib(pEquip)

	local tbTipGroup = { {},{} };
	local nItemType = pEquip.nItemType
	local tbEquip = Item:GetClass("equip");
	for i, tbAttribs in ipairs(tbAttribGroups) do
		for _, tbAttrib in ipairs(tbAttribs) do
			local vOne, nQuality = tbEquip:GetTipOneAttrib(nil, nItemType, pEquip.nLevel, tbAttrib)
			if vOne then
				table.insert(tbTipGroup[i], vOne);	
			end
		end	
	end

	--还是要给出单独的激活位置的,不然2个位置都激活一个不知道是哪个位置的激活的
	local nActiveBackPos;
	if #tbActiveDark == 1 then
		local nPosGroup = self:GetPosGroup(nStonePos)
		local nActiveBackGroup = self.tbPosActiveMapBack[nPosGroup]
		local tbBackActivePos = self.tbPosActiveGroup[nActiveBackGroup]

		local nBackActiveSeries = self.tbSeriesActiveMapBack[nSeries]

		for i,nPos in ipairs(tbBackActivePos) do
			local _pEquip = pPlayer.GetEquipByPos(nPos)
			if _pEquip and _pEquip.GetIntValue(self.SERIES_KEY) == nBackActiveSeries then
				nActiveBackPos = nPos
				break;
			end
		end
	end

	return { 
				nStonePos = nStonePos, 
				nSeries = nSeries,
				tbAttribs = tbTipGroup,
				tbActiveDark = tbActiveDark,
				nActiveBackPos = nActiveBackPos,
			};

end