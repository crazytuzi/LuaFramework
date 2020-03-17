--[[
地图元素：帮派战建筑物（王座、神像、图腾）
]]

_G.MapUnionWarBuildingVO = MapElementVO:new();
								 
MapUnionWarBuildingVO.type = nil;  -- 1王座，2神像，3图腾	
MapUnionWarBuildingVO.state = nil; --vo.type == 类型， vo.state = 状态

function MapUnionWarBuildingVO:GetClass()
	return MapUnionWarBuildingVO;
end

function MapUnionWarBuildingVO:ParseFlag( flag )
	self.type = flag.type;
	self.state = flag.state;
end

function MapUnionWarBuildingVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_UnionWar or mapName == MapConsts.MapName_Curr or
			mapName == MapConsts.MapName_Small then
		return true
	end
	return false
end

function MapUnionWarBuildingVO:GetType()
	return MapConsts.Type_UnionWarBuilding;
end

-- 获取地图图标tips文本
function MapUnionWarBuildingVO:GetTipsTxt()
	if self.type == 1 then  --flag: 王座1
		local name = UnionWarModel:GetOccUnionName()
		return string.format( StrConfig["unionwar222"], name );
	elseif self.type == 2 then  --flag: 神像2
		return StrConfig["unionwar221"];
	elseif self.type == 3 then  --flag: 图腾3
		return StrConfig["unionwar220"];
	end
end

function MapUnionWarBuildingVO:GetAsLinkage()
	if self.state == 0 then 
		if self.type == 1 then  --flag: 王座1
			return "building_throneGray";
		elseif self.type == 2 then  --flag: 神像2
			return "building_statueGray";
		elseif self.type == 3 then  --flag: 图腾3
			return "building_totemGray";
		end
	end;
	if self.type == 1 then  --flag: 王座1
		return "building_throne";
	elseif self.type == 2 then  --flag: 神像2
		return "building_statue";
	elseif self.type == 3 then  --flag: 图腾3
		return "building_totem";
	end
end