--[[
地图元素：帮派王城战地图单位
]]

_G.MapUnionCityUnitVO = MapElementVO:new();

--flag:  
---------神兽--------------复活点----------------
--|index| name | type	| name			| type 	|
-------------------------------------------------
--|	1	| 青龙 | "ql"	| 青龙复活点	| "pql" |
--|	2	| 白虎 | "bh"	| 白虎复活点	| "pbh" |
--|	3	| 朱雀 | "zq"	| 朱雀复活点	| "pzq" |
--|	4	| 玄武 | "xw"	| 玄武复活点	| "pxw" |
--|	5	| 王座 | "wz"	| 进攻方复活点	| "jgp" |
--|	6	| 	   | 		| 防守方复活点	| "fsp" |

MapUnionCityUnitVO.bType = nil;  -- 神兽 1, 复活点 2
MapUnionCityUnitVO.index = nil;  -- index 帮派王城config中的索引
MapUnionCityUnitVO.sType  = nil;  --sType 帮派王城config中的type
MapUnionCityUnitVO.tipsType  = nil;  --tips的状态

function MapUnionCityUnitVO:ParseFlag( flag )
	local dataType = type(flag);
	if dataType ~= "table" then
		Error("argument error of MapUnionCityUnitVO.ParseFlag, table expected, got" .. dataType );
		return;
	end
	self.bType = flag.bType;
	self.index = flag.index;
	self.sType = flag.sType;
	self.tipsType = flag.tipsType
end

function MapUnionCityUnitVO:GetClass()
	return MapUnionCityUnitVO;
end

function MapUnionCityUnitVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_UnionCityWar or mapName == MapConsts.MapName_Curr or mapName == MapConsts.MapName_Small then
		return true;
	end
	return false;
end

function MapUnionCityUnitVO:GetType()
	return MapConsts.Type_UnionCityUnits;
end

-- 获取地图图标tips文本
function MapUnionCityUnitVO:GetTipsTxt()
	local bType, index, sType = self.bType, self.index, self.tipsType;
	------------------building------------------
	if bType == 1 then
		local cfg = UnionCityWarModel.citySuperState;
		local unionName = cfg[index].unionName;
		if sType == "ql" then
			return string.format( StrConfig["unioncitywar807"], unionName );
		elseif sType == "bh" then
			return string.format( StrConfig["unioncitywar808"], unionName );
		elseif sType == "zq" then
			return string.format( StrConfig["unioncitywar809"], unionName );
		elseif sType == "xw" then
			return string.format( StrConfig["unioncitywar810"], unionName );
		elseif sType == "wz" then
			return StrConfig["unioncitywar822"];
		end
	-----------------复活点-------------------
	elseif bType == 2 then
		if sType == "Yjgp" then
			return StrConfig["unioncitywar812"];
		elseif sType == "Yfsp" then
			return StrConfig["unioncitywar813"]
		end
		local state = UnionCityWarModel:GetLifePointState(index);
		local vo = unioncityWarlifePoint[index]
		local name = StrConfig["unioncitywar_"..vo.type]
		if state == 1 then -- 进攻
			return string.format( StrConfig["unioncitywar821"], name );
		elseif state == 2 then -- 防守
			return string.format( StrConfig["unioncitywar820"], name, name);
		end
	end
end

function MapUnionCityUnitVO:GetAsLinkage()
	return "CityUnion_" .. self.sType;
end

function MapUnionCityUnitVO:ToString()
	local typeStr = self:GetType();
	return string.format( "%s%s%s%s", typeStr, self.cid, self.bType, self.sType );
end