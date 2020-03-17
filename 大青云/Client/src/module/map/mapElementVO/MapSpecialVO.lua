--[[
地图单位：地图特殊点()
2015年6月3日21:03:41
haohu
]]

_G.MapSpecialVO = MapElementVO:new();

function MapSpecialVO:GetClass()
	return MapSpecialVO;
end

function MapSpecialVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_Small then
		return false;
	end
	return true;
end

function MapSpecialVO:GetType()
	return MapConsts.Type_Special;
end

-- 获取地图图标label
function MapSpecialVO:GetLabel()
	local cfg = t_mapSpoint[self.id]
	return cfg and cfg.name or ""
end

-- 获取地图图标tips文本
function MapSpecialVO:GetTipsTxt()
	local cfg = t_mapSpoint[self.id];
	return cfg and cfg.tips or "tool tip config missing";
end

function MapSpecialVO:GetAsLinkage()
	local cfg = t_mapSpoint[self.id];
	return cfg.icon
end
