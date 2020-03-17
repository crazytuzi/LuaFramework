--[[
地图单位：小地图怪物
2015年4月12日10:52:31
haohu
]]

_G.MapMonsterVO = MapElementVO:new()

function MapMonsterVO:GetClass()
	return MapMonsterVO;
end

function MapMonsterVO:IsAvailableInMap(mapName)
	--[[
	if mapName == MapConsts.MapName_Small then
		return true;
	end
	--]]
	if mapName == MapConsts.MapName_Curr then
		return true;
	end
	return false;
end

function MapMonsterVO:GetType()
	return MapConsts.Type_Monster;
end

-- 获取地图图标tips文本
function MapMonsterVO:GetTipsTxt()
	local cfg = t_monster[self.id];
	if cfg then
		return string.format( StrConfig["map111"], cfg.name, cfg.level );
	end
	return "tool tip config missing";
end

function MapMonsterVO:GetAsLinkage()
	local cfg = t_monster[self.id];
	local type = cfg and cfg.type;
	if type == MonsterConsts.Type_Boss_Normal or type == MonsterConsts.Type_Boss_World or type == MonsterConsts.Type_Boss_Instance then
		return "monster_boss";
	end
	return "monster";
end
