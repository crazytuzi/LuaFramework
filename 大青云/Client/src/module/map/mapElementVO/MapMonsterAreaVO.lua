--[[
地图单位：大地图怪区
2015年4月11日17:34:39
haohu
]]

_G.MapMonsterAreaVO = MapElementVO:new();

function MapMonsterAreaVO:GetClass()
	return MapMonsterAreaVO;
end

function MapMonsterAreaVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_Small then
		return false;
	end
	return true;
end

function MapMonsterAreaVO:GetType()
	return MapConsts.Type_MonsterArea;
end

function MapMonsterAreaVO:GetLvlInfo(colorFormat)
	return MapUtils:GetMonsterTitle( self.id, colorFormat );
end

function MapMonsterAreaVO:GetLabelInfo()
	local labels, labelColor = {}, 0x29cc00;
	local cfg = t_monster[self.id];
	if cfg then
		labels = { cfg.name, string.format( StrConfig['map105'], cfg.level ) };
		local _;
		local lvlName = "";
		_, lvlName, labelColor = self:GetLvlInfo();
		table.push( labels, lvlName );
	end
	return labels, labelColor;
end

function MapMonsterAreaVO:GetUIData()
	local vo = {};
	vo.x = self.x;
	vo.y = self.y;
	local labels, labelColor = self:GetLabelInfo();
	if labels then
		for i = 1, #labels do
			vo["label"..i] = labels[i];
		end
	end
	vo.labelColor = labelColor;
	vo.uid = self:ToString();
	return UIData.encode(vo);
end

-- 获取地图图标label
function MapMonsterAreaVO:GetLabel()
	local cfg = t_monster[self.id];
	if not cfg then return "monster id error" end
	local isShowName = cfg.map_show == 0 -- 0:显示
	if isShowName then
		local _, _, labelColor = self:GetLvlInfo(true);
		return string.format( StrConfig['map120'], labelColor, cfg.name, cfg.level ) or ""
	end
	return ""
end

-- 获取地图图标tips文本
function MapMonsterAreaVO:GetTipsTxt()
	local cfg = t_monster[self.id];
	if cfg then
		return string.format( StrConfig["map111"], cfg.name, cfg.level );
	end
	return "tool tip config missing";
end

function MapMonsterAreaVO:GetAsLinkage()
	local cfg = t_monster[self.id];
	local monsterType = cfg and cfg.type;
	if monsterType == MonsterConsts.Type_Boss_Normal or
		monsterType == MonsterConsts.Type_Boss_World or
		monsterType == MonsterConsts.Type_Boss_Instance then
		return "monster_boss";
	end
	if monsterType == MonsterConsts.Type_Elite then
		return "monster_elite";
	end
	return "monster_normal";
end
