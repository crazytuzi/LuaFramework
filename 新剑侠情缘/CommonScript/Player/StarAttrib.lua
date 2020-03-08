
local tbStarAttribSetting = LoadTabFile(
        "Setting/Item/StarAttrib.tab", 
        "ddsddd", nil,
        {"Star","Order", "AttribType", "Value1", "Value2", "Value3"});

StarAttrib.tbStarAttrib = {};
StarAttrib.tbStarLevel = {};
for _, v in pairs(tbStarAttribSetting) do
	StarAttrib.tbStarAttrib[v.Star] = StarAttrib.tbStarAttrib[v.Star] or {};
	StarAttrib.tbStarAttrib[v.Star][v.Order] = {szName = v.AttribType, tbValue = {v.Value1, v.Value2, v.Value3}};

	if StarAttrib.tbStarLevel[#StarAttrib.tbStarLevel] ~= v.Star then
		table.insert(StarAttrib.tbStarLevel, v.Star);
	end
end

function StarAttrib:GetStarMagicAttrib(nStarLevel)
	local tbAttribs = self.tbStarAttrib[nStarLevel];
	return tbAttribs or {};
end

function StarAttrib:GetStarLevel(nStar)
	local nCount = Lib:CountTB(self.tbStarLevel);
	
	local nStarLevel = self.tbStarLevel[1]
	if nCount == 0 or nStar < nStarLevel then
		return nil, nStarLevel;
	end

	for i = 1, nCount do
		nStarLevel = self.tbStarLevel[i];
		if i == nCount then
			return nStarLevel, nil;
		else
			local nNextStartLevel = self.tbStarLevel[i + 1]
			if nStar >= nStarLevel and nStar < nNextStartLevel then
				return nStarLevel, nNextStartLevel;
			end
		end
	end

	Log("EROOR IN StarAttrib:GetStarLevel");
end

function StarAttrib:CalcTotalStar(pPlayer)
	local nTotalStar = 0;
	local tbEquips = pPlayer.GetEquips();
	for nEquipPos, nEquipId in pairs(tbEquips) do
		
		-- local nInsetValue = StoneMgr:GetInsetValue(pPlayer, nEquipPos);
		-- local nStrengthenValue = Strengthen:GetStrengthenValue(pPlayer, nEquipPos);

		local pEquip = KItem.GetItemObj(nEquipId);
		local tbInfo = KItem.GetItemBaseProp(pEquip.dwTemplateId);
		local nEquipValue = pEquip.nValue;

		-- local nTotalValue = nInsetValue + nStrengthenValue + nEquipValue;
		local nStar = Item:GetStarLevel(tbInfo.nItemType, nEquipValue);
		nTotalStar = nTotalStar + nStar;
	end

	return nTotalStar;
end

--client
function StarAttrib:GetEquipAttachValue(pPlayer, nEquipPos)
	local nInsetValue = StoneMgr:GetInsetValue(pPlayer, nEquipPos);
	local nStrengthenValue = Strengthen:GetStrengthenValue(pPlayer, nEquipPos);

	return nInsetValue + nStrengthenValue;
end
