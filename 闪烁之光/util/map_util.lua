--[[
   场景工具方法
   @author zwx 
   @date 2015.11.20
--]]
MapUtil = MapUtil or {}

MapUtil.c_w = 256
MapUtil.c_h = 256


MapUtil.c_sw = 1024
MapUtil.c_sh = 1024

MapUtil.half_w = display.width/2 -- 半屏
MapUtil.half_h = display.height/2 -- 半屏

---[[地图类型 前场中后景
MapUtil.b = "b"
MapUtil.m = "m"
MapUtil.f = "f"
MapUtil.s = "s"
MapUtil.e = "e"
--]]

---[[战斗类型 前场中后景
MapUtil.front = "front"
MapUtil.back = "back"
--]]

-- 中间缓空间大小
-- -E-----------C--A--m--B--D-----------F-
-- -E-----------C--A--m--B--D-----------F-
-- -E-----------C--A--m--B--D-----------F-
-- -E-----------C--A--m--B--D-----------F-
-- -E-----------C--A--m--B--D-----------F-
------ A<>C, B<>D区间，不动镜头不移动块
------ A->F,B->E 方向只动镜头
------ C->E,D->F 方向只动镜头+MoveTo动作移动块
------ [E<>B][C<>F] 已经到边沿，不动镜头不移动块

-- 区间
MapUtil.moveArea = 300
MapUtil.abA = MapUtil.moveArea
-- MapUtil.cdA = MapUtil.moveArea * 2
-- MapUtil.acA = MapUtil.moveArea / 2
-- MapUtil.bdA = MapUtil.moveArea / 2
MapUtil.adA = -MapUtil.moveArea * 1.5
MapUtil.bcA = MapUtil.moveArea * 1.5

-- 点|线
MapUtil.mp = MapUtil.half_w
MapUtil.ep = 0
MapUtil.cp = MapUtil.mp - MapUtil.moveArea
MapUtil.ap = MapUtil.mp - MapUtil.moveArea / 2
MapUtil.bp = MapUtil.mp + MapUtil.moveArea / 2
MapUtil.dp = MapUtil.mp + MapUtil.moveArea
MapUtil.fp = SCREEN_WIDTH

MapUtil.toLeft = false
-- --[[
-- 	目的地 target
-- 	起始点 start
-- ]]
-- function MapUtil.getDir(target, start)
-- 	if target.x > start.x then
-- 		return MapUtil.RIGHT
-- 	else
-- 		return MapUtil.LEFT
-- 	end
-- end

-- 获取两点得距离值
function MapUtil.getDist( curPos, target )
	if curPos == nil then return 0 end
	local dx = curPos.x - target.x
	local dy = curPos.y - target.y
	return math.abs(dx*dx + dy*dy)
end

-- 获取两点得距离值
function MapUtil.getDistanceSquared( curPos, target )
	if curPos == nil then return 0 end
	local dx = curPos.x - target.x
	local dy = curPos.y - target.y
	return math.sqrt(math.abs(dx*dx + dy*dy))
end

-- 是否在最小距离的范围内
function MapUtil.isOnRange( curPos, target, range )
	return MapUtil.getDistanceSquared( curPos, target ) <= range
end
