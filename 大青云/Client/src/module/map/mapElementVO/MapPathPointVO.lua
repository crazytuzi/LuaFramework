--[[
地图元素：寻路点
2015年4月12日11:08:04
haohu
]]

_G.MapPathPointVO = MapElementVO:new();

function MapPathPointVO:GetClass()
	return MapPathPointVO;
end

function MapPathPointVO:IsInteractive()
	return false;
end

function MapPathPointVO:IsAvailableInMap(mapName)
	local map = BaseMap:GetMap( mapName );
	local scale = map:GetScale();
	local number = self.flag * scale;
	local delta = math.abs( number - toint(number, 0.5) );
	return delta < 0.17;
end

function MapPathPointVO:GetType()
	return MapConsts.Type_Path;
end

function MapPathPointVO:GetAsLinkage()
	return "point_path";
end
