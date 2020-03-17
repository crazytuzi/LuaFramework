--[[
Map相关的常量及方法
lizhuangzhuang
2014年7月20日15:56:36
]]

_G.MapUtils = {};

local mat = _Matrix2D.new();
local vecPos = _Vector2.new();
--将3D坐标转换为平面2D坐标
function MapUtils:Point3Dto2D(posx,posy,mapId)
	local mapId = mapId or CPlayerMap:GetCurMapID();
	local mapPointCfg = MapPoint[mapId];
	if not mapPointCfg then
		Error("Cannot find config data in MapPoint. MapID:"..mapId);
		return;
	end
	local map2DCfg = Map2D[mapId];
	if not map2DCfg then
		print("Cannot find config in Map2D.MapID:"..mapId);
		return;
	end
	
	local mapW = mapPointCfg.mapW;--取地图宽
	local mapH = mapPointCfg.mapH;--取地图高
	local mapInfo =  t_map[mapId];
	--计算比例
	local wRate = map2DCfg.mW / mapW;
	local hRate = map2DCfg.mH / mapH;
	--旋转
	mat:identity();
	mat:setRotation( math.pi * map2DCfg.r/180 );
	mat:apply(posx,posy,vecPos);
	--缩放
	local x = vecPos.x*wRate;
	local y = vecPos.y*hRate
	--平移
	x = x + MapConsts.UIBigMapW/2 + map2DCfg.wOffset;
	y = y + MapConsts.UIBigMapH/2 + map2DCfg.hOffset;
	return x,y;
end

--将平面2D坐标转换为3D坐标
function MapUtils:Point2Dto3D(posx,posy,mapId)
	local mapId = mapId or CPlayerMap:GetCurMapID();
	local mapInfo = t_map[mapId];
	local wOffset = mapInfo.wOffset;
	local hOffset = mapInfo.hOffset;
	--
	local mapPointCfg = MapPoint[mapId];
	if not mapPointCfg then 
		Error("Cannot find config data in MapPoint. MapID:"..mapId);
		return; 
	end
	local map2DCfg = Map2D[mapId];
	if not map2DCfg then
		print("Cannot find config in Map2D.MapID:"..mapId);
		return;
	end
	
	local mapW = mapPointCfg.mapW;--取地图宽
	local mapH = mapPointCfg.mapH;--取地图高
	--计算比例
	local wRate = map2DCfg.mW / mapW;
	local hRate = map2DCfg.mH / mapH;
	--平移
	local x = posx - MapConsts.UIBigMapW/2 - map2DCfg.wOffset;
	local y = posy - MapConsts.UIBigMapH/2 - map2DCfg.hOffset;
	--缩放
	x = x / wRate;
	y = y / wRate;
	--旋转
	mat:identity();
	mat:setRotation( -math.pi * map2DCfg.r/180 );
	mat:apply(x,y,vecPos);
	return vecPos.x, vecPos.y;
end

--将3D弧度转化为平面2D角度
 function MapUtils:DirtoRotation(dir,mapId)
	local map2DCfg = Map2D[mapId];
	if not map2DCfg then
		print("Cannot find config in Map2D.MapID:"..mapId);
		return 0;
	end
	return dir/math.pi * 180 + 90 + toint(map2DCfg.r,-1);
 end

--获取两点之间距离
function MapUtils:GetDistance(vec1, vec2)
	return math.sqrt((vec1.x - vec2.x)^2 + (vec1.y - vec2.y)^2);
end
 
--获取两点之间距离(2D)
function MapUtils:Get2dDistance(vec1, vec2)
	-- print("坐标1 x位置:",vec1.x,vec1.y)
	-- print("坐标2 x位置:",vec2.x,vec2.y)
	local x1, y1 = self:Point3Dto2D(vec1.x, vec1.y);
	local x2, y2 = self:Point3Dto2D(vec2.x, vec2.y);
	return math.sqrt((x1 - x2)^2 + (y1 - y2)^2);
end

--确定大地图中显示Monster图标的点(config/map/MapPoint.lua同一个地图同一片Monster的几个随机点中相对居中那个点)--haohu2014年8月11日10:46:36
function MapUtils:GetMonsterAreaPos( monsterId, mapId )
	--数组，保存当前种类怪物的所有点
	local monsterPoints = {}
	local mapPoint = MapPoint[mapId];
	if not mapPoint then
		Error( string.format("cannot find mapId:%s in MapPoint.lua", mapId) );
	end
	for _, point in pairs(mapPoint.monster) do
		if point.id == monsterId then 
			table.push( monsterPoints, {x = point.x, y = point.y} );
		end
	end
	local num = #monsterPoints;
	if num == 0 then return nil end;
	local totalX, totalY = 0, 0;
	for i, point in pairs(monsterPoints) do
		totalX = totalX + point.x;
		totalY = totalY + point.y;
	end
	local averagePoint = {x = totalX / num, y = totalY / num};
	local centerPoint = nil;
	local tempSum = math.huge;
	-- 取和平均点坐标差的绝对值之和最小的点。
	for _, point in ipairs(monsterPoints) do
		local sum = math.abs(point.x - averagePoint.x) + math.abs(point.y - averagePoint.y);
		if sum < tempSum then
			centerPoint = point;
			tempSum = sum;
		end
	end
	return centerPoint;
end

--[[
地图Monster头衔(3 BOSS 红色, 2 精英 蓝色, 1 普通 绿色)
colorFormat 非nil 非false : 输出html字符串颜色值
colorFormat false, nil : 输出十六进制颜色值
--]]
function MapUtils:GetMonsterTitle(monsterId, colorFormat)
	local cfg = t_monster[monsterId];
	if not cfg then
		Error( string.format( "cannot find monster config in t_monster.lua ID:%s", monsterId ) );
	end
	local titleType, titleName, titleColor
	local monsterType = cfg.type;
	if monsterType == MonsterConsts.Type_Boss_Normal or  -- 3 BOSS 红色
		monsterType == MonsterConsts.Type_Boss_World or
		monsterType == MonsterConsts.Type_Boss_Instance then
		titleType = MonsterConsts.Boss
		titleName = StrConfig['monster3']
		titleColor = colorFormat and '#ff8f43' or 0xff8f43
	elseif monsterType == MonsterConsts.Type_Elite then --2 精英 蓝色
		titleType = MonsterConsts.Elite
		titleName = StrConfig['monster2']
		titleColor = colorFormat and '#47c0ff' or 0x47c0ff
	else --1 普通 绿色
		titleType = MonsterConsts.Normal
		titleName = StrConfig['monster1']
		titleColor = colorFormat and '#29cc00' or 0x29cc00
	end
	return titleType, titleName, titleColor
end

function MapUtils:GetMapName(mapId)
	local mapCfg = t_map[mapId];
	return mapCfg and mapCfg.name;
end

function MapUtils:GetMapBirthPoint(mapId)
	local cfg = _G.MapPoint[mapId];
	local birthPointMap = cfg and cfg.birth;
	local x, y;
	for _, point in pairs( birthPointMap ) do
		if point.id == 1 then -- 1 为 出生地
			return _Vector3.new( point.x, point.y, 0 );
		end
	end
end

-- 在野外（不可寻路/传送到其他地图的场景中，如副本&各种活动）
function MapUtils:CanTeleport()
	local mapId = CPlayerMap:GetCurMapID();
	local cfg = t_map[ mapId ];
	if not cfg then return end
	return cfg.can_teleport;
end

-- 获取主玩家地图图标的UID
function MapUtils:GetMainPlayerMapUid()
	local mainPlayerId = MainPlayerController:GetRoleID();
	return MapConsts.Type_MainPlayer .. mainPlayerId;
end

-- 显示飞鞋tips
function MapUtils:ShowTeleportTips()
	local tips = MapUtils:GetTeleportTips();
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end

function MapUtils:GetTeleportTips()
	-- vip等级满足显示无限传送，不满足显示剩余免费次数、剩余道具数量、次数恢复规则
	local _, itemId, freeVip = MapConsts:GetTeleportCostInfo();
	-- local isVipFree = MainPlayerModel.humanDetailInfo.eaVIPLevel >= freeVip
	local tips = ""
	if freeVip and freeVip == 1 then
		tips = StrConfig['map401']
	else
		local maxRegainFreeTime = MapConsts:GetTeleportMaxRegainFreeTime()
		local myFreeTime = MapModel:GetFreeTeleportTime()
		local myItemNum = BagModel:GetItemNumInBag( itemId )
		local prompt = myFreeTime >= maxRegainFreeTime and "" or StrConfig['map403']
		tips = string.format( StrConfig['map402'], myFreeTime, prompt, myItemNum )
	end
	return tips;
end

function MapUtils:IsQuestDailyCanTeleportMap(mapId)
	local mapCFG = t_map[mapId];
	if not mapCFG then return false; end
	return mapCFG.type == MapConsts.MapType_YeWai or mapCFG.type == MapConsts.MapType_ZhuCheng;
end