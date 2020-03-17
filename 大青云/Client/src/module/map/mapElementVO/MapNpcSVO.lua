--[[
地图单位：小地图Npc
2015年11月28日13:03:02
haohu
]]

_G.MapNpcSVO = MapNpcVO:new();

function MapNpcSVO:GetClass()
	return MapNpcSVO
end

function MapNpcSVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_Small then
		return true;
	end
	return false;
end

function MapNpcSVO:GetType()
	return MapConsts.Type_NpcS;
end