
Furniture.tbNormalFurniture =
{
	[1]  = 	{ szName = "床", 			szKey = "TYPE_BED" },
	[2]  = 	{ szName = "柜子", 			szKey = "TYPE_CUPBOARD", },
	[3]  = 	{ szName = "桌子", 			szKey = "TYPE_DESK", },
	[4]  = 	{ szName = "椅子", 			szKey = "TYPE_CHAIR", },
	[5]  = 	{ szName = "浴盆", 			szKey = "TYPE_BATHTUB", },
	[6]  = 	{ szName = "摆设(大)", 		szKey = "TYPE_STUFF_L", },
	[7]  = 	{ szName = "摆设(中)", 		szKey = "TYPE_STUFF_M", },
	[8]  = 	{ szName = "摆设(小)", 		szKey = "TYPE_STUFF_S", },
	[9]  = 	{ szName = "挂饰", 			szKey = "TYPE_HANG", },
	[10] = 	{ szName = "院景(大)", 		szKey = "TYPE_GARDEN_L", },
	[11] = 	{ szName = "院景(小)", 		szKey = "TYPE_GARDEN_S", },
	[12] =  { szName = "聚宝盆", 		szKey = "TYPE_MAGIC_BOWL", nIdx=1 },
}

Furniture.tbCantSellNormalTypes =
{
	[12] = true,
}

Furniture.tbExistCountLimits = {
	[12] = 1,
}

Furniture.SPECIAL_BASE_INDEX = 1000;
Furniture.tbSpecialFurniture =
{
	[1]  = 	{ szName = "限定", 			szKey = "TYPE_LIMIT" },
	[2]  = 	{ szName = "苗圃", 			szKey = "TYPE_LAND" },
	[3]  = 	{ szName = "桃树", 			szKey = "TYPE_PEACH" },
}

Furniture.nSyncMapFurnitureBatch = 200	--单次下发家具数量

function Furniture:LoadTypeSetting()
	for nType, tbInfo in ipairs(Furniture.tbNormalFurniture) do
		local szKey = tbInfo.szKey;
		Furniture[szKey] = nType;
	end

	for nIndex, tbInfo in ipairs(Furniture.tbSpecialFurniture) do
		local nType = Furniture.SPECIAL_BASE_INDEX + nIndex;
		local szKey = tbInfo.szKey;
		Furniture[szKey] = nType;
	end
end
Furniture:LoadTypeSetting();

function Furniture:GetTypeSetting(nType)
	if not nType then
		return nil;
	end
	if nType < Furniture.SPECIAL_BASE_INDEX then
		return Furniture.tbNormalFurniture[nType];
	else 
		return Furniture.tbSpecialFurniture[nType - Furniture.SPECIAL_BASE_INDEX];
	end
end

function Furniture:GetTypeName(nType)
	local tbSetting = self:GetTypeSetting(nType);
	return tbSetting and tbSetting.szName;
end

function Furniture:CanSell(nItemTemplateId)
	local bSpecial, nType = self:IsSpecialFurniture(nItemTemplateId)
	if bSpecial then
		return false
	end
	return not self.tbCantSellNormalTypes[nType]
end

function Furniture:IsSpecialFurniture(nItemTemplateId)
	local tbFurniture = House:GetFurnitureInfo(nItemTemplateId);
	if not tbFurniture then
		return false;
	end
	return self:IsSpecialType(tbFurniture.nType), tbFurniture.nType;
end

function Furniture:IsSpecialType(nType)
	local nIndex = nType - Furniture.SPECIAL_BASE_INDEX;
	return Furniture.tbSpecialFurniture[nIndex] and true or false;
end
