--[[
地图元素：战场地图单位
]]

_G.MapZhanchangUnitVO = MapElementVO:new();

MapZhanchangUnitVO.unitType = nil; -- 类型 1:交付点， 2:旗子点
MapZhanchangUnitVO.camp = nil; -- 阵营 是旗子点时: 6:B阵营 7:A阵营; 是交付点时:我的阵营

function MapZhanchangUnitVO:ParseFlag( flag )
	local dataType = type(flag);
	if dataType ~= "table" then
		Error("argument error of MapZhanchangUnitVO.ParseFlag, table expected, got" .. dataType );
		return;
	end
	self.unitType = flag.unitType;
	self.camp     = flag.camp;
end

function MapZhanchangUnitVO:GetClass()
	return MapZhanchangUnitVO;
end

function MapZhanchangUnitVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_Zhanchang or mapName == MapConsts.MapName_Curr or
			mapName == MapConsts.MapName_Small then
		return true;
	end
	return false;
end

function MapZhanchangUnitVO:GetType()
	return MapConsts.Type_ZhanchangUnits;
end

-- 获取地图图标tips文本
function MapZhanchangUnitVO:GetTipsTxt()
	if self.unitType == 1 then
		local myCamp = ActivityZhanChang:GetMyCamp();
		if myCamp == self.camp then
			return StrConfig["zhanchang112"];
		else
			return StrConfig["zhanchang126"]; -- 敌方
		end

		
	elseif self.unitType == 2 then
		local myCamp = ActivityZhanChang:GetMyCamp();
		if myCamp == self.camp then
			return StrConfig["zhanchang114"];
		else
			return StrConfig["zhanchang115"];
		end
	end
end

function MapZhanchangUnitVO:GetAsLinkage(mapName)
	if self.unitType == 1 then -- 交付点
		if self.camp == 6 then
			return "camp_APoint";
		elseif self.camp == 7 then
			return "camp_BPoint";
		end
	elseif self.unitType == 2 then -- 旗子点
		if self.camp == 6 then
			return "camp_B";
		elseif self.camp == 7 then
			return "camp_A";
		end
	end
end