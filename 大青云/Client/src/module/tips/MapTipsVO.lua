--[[
地图tip VO
haohu
2014年9月9日12:36:45
]]

_G.MapTipsVO = {}

MapTipsVO.tipsType = TipsConsts.Type_Map;
MapTipsVO.tipsShowType = TipsConsts.ShowType_Normal;
MapTipsVO.mapId = nil;

function MapTipsVO:new(mapId)
	local obj = {};
	for k, v in pairs(self) do
		obj[k] = v;
	end
	obj.mapId = mapId or 0;
	return obj;
end

function MapTipsVO:GetId()
	return self.mapId;
end

function MapTipsVO:GetCfg()
	return t_map[self.mapId];
end

function MapTipsVO:GetName()
	local cfg = self:GetCfg();
	return cfg.name;
end

function MapTipsVO:CanPk()
	local cfg = self:GetCfg();
	return cfg.canPk;
end

function MapTipsVO:GetLimitLvl()
	local cfg = self:GetCfg();
	return cfg.limitLv;
end

function MapTipsVO:GetRecomandLvl()
	local cfg = self:GetCfg();
	return cfg.rcmdLv;
end

function MapTipsVO:InitMapMonster()
end

--获取boss信息
function MapTipsVO:GetBossInfo()
	local mapId = self.mapId;
	local mapPoint = MapPoint[mapId];
	if not mapPoint then
		print(debug.traceback());
		Error( string.format("cannot find mapId:%s in MapPoint.lua", mapId) );
		return nil;
	end
	for _, point in pairs( mapPoint.monster ) do
		local id = point.id;
		local title = MapUtils:GetMonsterTitle( id );
		if title == MonsterConsts.Boss then
			local cfg = t_monster[id];
			if not cfg then
				Error( string.format( "cannot find monster config in t_monster.lua ID:%s", id ) );
				return nil;
			end
			local bossType;
			if cfg.type == MonsterConsts.Type_Boss_Normal then
				bossType = StrConfig['map302'];
			elseif cfg.type == MonsterConsts.Type_Boss_World then
				bossType = StrConfig['map303'];
			elseif cfg.type == MonsterConsts.Type_Boss_Instance then
				bossType = StrConfig['map304'];
			else
				bossType = StrConfig['map301'];
			end
			return self:NewMonsterInfo( id, cfg.name, bossType, cfg.level, title, "#c9753a" );
		end
	end
	return nil;
end

--获取精英怪信息
function MapTipsVO:GetEliteInfo()
	local mapId = self.mapId;
	local mapPoint = MapPoint[mapId];
	if not mapPoint then
		Error( string.format("cannot find mapId:%s in MapPoint.lua", mapId) );
		return nil;
	end
	for _, point in pairs( mapPoint.monster ) do
		local id = point.id;
		local title = MapUtils:GetMonsterTitle( id );
		if title == MonsterConsts.Elite then
			local cfg = t_monster[id];
			if not cfg then
				Error( string.format( "cannot find monster config in t_monster.lua ID:%s", id ) );
				return nil;
			end
			return self:NewMonsterInfo( id, cfg.name, StrConfig['map305'], cfg.level, title, "#2994c4" );
		end
	end
	return nil;
end

--获取普通怪信息
function MapTipsVO:GetNormalMonsterInfo()
	local mapId = self.mapId;
	local normalMonsterInfo = {};
	local exist = {};
	local mapPoint = MapPoint[mapId];
	if not mapPoint then
		Error( string.format("cannot find mapId:%s in MapPoint.lua", mapId) );
		return normalMonsterInfo;
	end
	for _, point in pairs( mapPoint.monster ) do
		local id = point.id;
		if not exist[ id ] then
			exist[ id ] = true;
			local title = MapUtils:GetMonsterTitle( id );
			if title == MonsterConsts.Normal then
				local cfg = t_monster[id];
				if not cfg then
					Error( string.format( "cannot find monster config in t_monster.lua ID:%s", id ) );
					return normalMonsterInfo;
				end
				local info = self:NewMonsterInfo( id, cfg.name, StrConfig['map306'], cfg.level, title, "#22c50b" );
				table.push( normalMonsterInfo, info );
			end
		end
	end
	return normalMonsterInfo;
end

function MapTipsVO:NewMonsterInfo(id, name, monsterType, level, title, titleColor)
	local info = {}
	info.id          = id;
	info.name        = name;
	info.monsterType = monsterType;
	info.level       = level;
	info.title       = title;
	info.titleColor  = titleColor;
	return info;
end