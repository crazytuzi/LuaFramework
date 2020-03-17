--[[
地图内跨区域寻路
lizhuangzhuang
2015年3月31日22:22:20
]]

--尼玛，先搞两个区域的

_G.AreaPathFinder = {};

local src,dis = _Vector2.new(),_Vector2.new()
--
AreaPathFinder.pathFinder = nil;
--是否有区域传送门
AreaPathFinder.areaT = false;
--区域传送门
AreaPathFinder.portals = nil;

--设置PathFinder
function AreaPathFinder:SetPathFinder(pathFinder)
	self.pathFinder = pathFinder;
	local mapId = CPlayerMap:GetCurMapID();
	if mapId == 0 then return; end
	local mapCfg = t_map[mapId];
	self.areaT = mapCfg.areaT;
	self.portals = {};
	if MapPoint[mapId] and MapPoint[mapId].portal then
		for i,vo in pairs(MapPoint[mapId].portal) do
			local portalCfg = t_portal[vo.id];
			if portalCfg and portalCfg.type==4 then
				table.push(self.portals,vo);
			end
		end
	end
end

function AreaPathFinder:CheckPoint(vecX,vecY)
	local checked = self.pathFinder:checkPoint(vecX,vecY);
	return checked
end

function AreaPathFinder:GetPathLine(vecSrc,vecDis)
	if not vecSrc then return false; end
	--如果目标点不可到达,直接返回
	local checked = self.pathFinder:checkPoint(vecDis.x,vecDis.y);
	-- if not checked then return false; end
	src.x, src.y = vecSrc.x, vecSrc.y;
    dis.x, dis.y = vecDis.x, vecDis.y;
	--
	local z = CPlayerMap.objSceneMap:getSceneHeight(vecDis.x, vecDis.y)
    if not z then return nil,false end;
	--
	local path = self.pathFinder:findPath(src, dis);
	if path then return path,checked; end
	--没有路径并且有区域传送门的,进行区域寻路
	if not self.areaT then return false; end
	local path1 = nil;--到传送门的路径
	local path2 = nil;--从传送门到目标的路径
	for i,portalVO in ipairs(self.portals) do
		src.x, src.y = vecSrc.x, vecSrc.y;
		dis.x, dis.y = portalVO.x,portalVO.y;
		path1 = self.pathFinder:findPath(src,dis);
		if path1 then
			--新手传送任务特殊处理
			local questPortal = QuestModel:GetQuestPortal()
			if questPortal == portalVO.id then
				return nil,false;
			end
			--
			local portalCfg = t_portal[portalVO.id];
			src.x, src.y = portalCfg.target_pos[1], portalCfg.target_pos[2];
			dis.x, dis.y = vecDis.x, vecDis.y;
			path2 = self.pathFinder:findPath(src,dis);
			if path2 then
				break;
			end
		end
	end
	if path1 and path2 then
		--标记传送点
		path1[#path1].portal = true;
		for i,vo in ipairs(path2) do
			table.push(path1,vo);
		end
		return path1, true;
	else
		return nil,false;
	end
end
