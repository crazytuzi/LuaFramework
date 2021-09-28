MapUtil = {}

-- 前后端单位转换
MapUtil.S2C = 0.01
MapUtil.C2S = 100

-- c 格子=>位置
MapUtil.GC_W = 0.5
-- c 位置=>格子
MapUtil.CG_W = 2

-- 服务:格子
MapUtil.SG_H = 50
-- 格子:服务
MapUtil.GS_H = 1/50



MapUtil.NoDirMark = 999999 --无转向标记
MapUtil.NoTargetMark = "NoTargetMark" --无攻击标记
	
--[[单元转换
	-- v=tf.position x, z -> sx, sy
	function MapUtil.LocalToServer( v )
		return  math.floor(v.x * MapUtil.C2S), math.floor(v.z * MapUtil.C2S)
	end
	-- tf.position x -> sx
	function MapUtil.LocalToServerX( v )
		return math.floor(v * MapUtil.C2S)
	end

	-- sx, sy -> tf.position x, z
	function MapUtil.ServerToLocal( v )
		return v.x * MapUtil.S2C, v.y * MapUtil.S2C
	end
	-- sx -> tf.position.x
	function MapUtil.ServerToLocalX( v )
		return v * MapUtil.S2C
	end
--]]
-- 本地坐标 格子转换
	-- tf.position x,z -> gx, gy
	function MapUtil.LocalToGrid( v )
		return math.floor(v.x*MapUtil.CG_W+1), math.floor(v.z*MapUtil.CG_W+1)
	end
	-- tf.position.x -> gx
	function MapUtil.LocalToGridX( v )
		return math.floor(v*MapUtil.CG_W+1)
	end
	-- gx, gy -> tf.position x,z
	function MapUtil.GridToLocal( v )
		return v.x*MapUtil.GC_W, v.y*MapUtil.GC_W
	end
	-- gx -> tf.position.x
	function MapUtil.GridToLocalX( v )
		return v*MapUtil.GC_W
	end

--[[后端坐标 格子转换
	-- sx, sy -> gx, gy
	function MapUtil.ServerToGrid( v )
		return v.x*MapUtil.GS_H, v.y*MapUtil.GS_H
	end
	-- gx -> sx
	function MapUtil.ServerToGridX( v )
		return v*MapUtil.GS_H
	end
	-- sx, sy -> gx, gy
	function MapUtil.GridToServer( v )
		return v.x*MapUtil.SG_H, v.y*MapUtil.SG_H
	end
	-- sx -> gx
	function MapUtil.GridToServerX( v )
		return v*MapUtil.SG_H
	end
--]]
-- s c distance (cm -> m)
	function MapUtil.DistanceSC( v ) -- s(cm) c(m)
		return v * MapUtil.S2C
	end
	function MapUtil.DistanceCS( v )
		return v * MapUtil.C2S
	end

-- 获取pos3之间的距离
function MapUtil.GetDistanceByV3( a, b )
	if not a or not b then return 0 end
	return Vector3.Distance(a, b)
end
-- 是否在b点附近
function MapUtil.IsNearByV3( a, b, dist )
	dist = dist or 0
	if not a or not b then return false end
	return MapUtil.GetDistanceByV3( a, b ) <= dist
end
-- 获取pos2之间的距离
function MapUtil.GetDistanceByxy( x1, y1, x2, y2 )
	return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end
function MapUtil.GetDistanceByV2( a, b )
	return Vector2.Distance(a, b)
end
function MapUtil.GetV3DistanceByXZ( a, b )
	return math.sqrt((a.x-b.x)^2 + (a.z-b.z)^2)
end
function MapUtil.IsNearV3DistanceByXZ( a, b, dist )
	return math.sqrt((a.x-b.x)^2 + (a.z-b.z)^2) < dist
end
-- 是否在b点附近
function MapUtil.IsNearByxy( x1,y1, x2,y2, dist )
	dist = dist or 0
	return MapUtil.GetDistanceByxy( x1,y1, x2, y2 ) < dist
end
function MapUtil.IsNearByV2( a, b, dist )
	dist = dist or 0
	return Vector2.Distance(a, b) < dist
end

-- 获得指定位置到目标位置的角度
function MapUtil.GetRotation(curPos, targetPos, newUp)
	newUp = newUp or Vector3.up
	targetPos = Vector3.New(targetPos.x, curPos.y, targetPos.z)
	return Quaternion.LookRotation(targetPos - curPos, newUp)
end

-- 计算两点间的角度 Vector3
function MapUtil.CaculateAngle(from, to) 
	return (MapUtil.CaculateRadian(from, to) / Mathf.PI) * 180
end

-- 计算两点间的孤度
function MapUtil.CaculateRadian(from, to)
	return Mathf.Atan2 (to.x - from.x, to.z - from.z)
end

------------------------------战斗相关 start----------------------------------------
--获取范围内的最近的目标
function MapUtil.GetRangeNearestTarget(source, targets, dist)
	local targetRangeList = {}
	local fightTarget = nil
	local srcTf = source.transform
	if ToLuaIsNull(srcTf) then return end
	for i = 1, #targets do
		target = targets[i]
		if target then
			local tarTf = target.transform
			if not ToLuaIsNull(tarTf) and not target:IsDie() then 
				if source.guid ~= target.guid and MapUtil.IsOnCircle(srcTf, tarTf, dist) then
					targetRangeList[target] = Vector3.Distance(srcTf.position, tarTf.position)
				end
			end
		end
	end
	
	for k, v in pairs(targetRangeList) do 
		if not fightTarget then
			fightTarget = k
		else
			if targetRangeList[fightTarget] > v  then
				fightTarget = k
			end
		end
	end

	return fightTarget
end

--获取范围内的最小夹角对象
function MapUtil.GetRangeMinAngleTarget(transform, targets, angle, dist)
	local target = nil
	local compareAngle = angle*0.5
	local resultTarget = nil
	local curMinAngel = nil
	for i = 1, #targets do
		if ToLuaIsNull(transform) then return end
		target = targets[i]
		if target and not ToLuaIsNull(target.transform) and not target:IsDie() then 
			local targetTf = target.transform
			local targetPos = targetTf.position
			local pos = transform.position
			local distance = Vector3.Distance(pos, targetPos) -- 距离
			if distance <= dist then
				local norVec = transform.rotation * Vector3.forward
				local temVec = targetPos - pos
				local jiajiao = Mathf.Acos(Vector3.Dot(norVec.normalized, temVec.normalized)) * Mathf.Rad2Deg -- 两向量夹角nil
				if jiajiao <= compareAngle then
					if not resultTarget then
						curMinAngel = jiajiao
						resultTarget = target
					else
						if jiajiao < curMinAngel then
							curMinAngel = jiajiao
							resultTarget = target
						end
					end
				end
			end
		end

	end
	return resultTarget
end

--获取指定夹角范围内的对象列表
function MapUtil.GetRangeTargets(transform, targets, angle, dist)
	local target = nil
	local compareAngle = angle*0.5
	local resultTarget = {}
	local curMinAngel = nil
	for i = 1, #targets do
		if ToLuaIsNull(transform) then return end
		target = targets[i]
		if target and not ToLuaIsNull(target.transform) and not target:IsDie() then
			local targetTf = target.transform
			local targetPos = targetTf.position
			local pos = transform.position
			local distance = Vector3.Distance(pos, targetPos) -- 距离
			if distance <= dist then
				local norVec = transform.rotation * Vector3.forward
				local temVec = targetPos - pos
				local jiajiao = Mathf.Acos(Vector3.Dot(norVec.normalized, temVec.normalized)) * Mathf.Rad2Deg -- 两向量夹角nil
				if jiajiao <= compareAngle then
					table.insert(resultTarget, target)
				end
			end
		end

	end
	return resultTarget
end

--获取A相对于B正方向的夹角
function MapUtil.GetARelativeBAngle(aTransform, bTransform)
	local norVec = bTransform.rotation * Vector3.forward
	local temVec = aTransform.position - bTransform.position
	local jiajiao = Mathf.Acos(Vector3.Dot(norVec.normalized, temVec.normalized)) * Mathf.Rad2Deg -- 两向量夹角nil
	return jiajiao
end

function MapUtil.GetNearestTarget(transform, targets)
	if #targets < 1 then return nil end
	if #targets < 2 then return targets[1] end
	local result = targets[1]
	local pos = transform.position
	local curMinDist = Vector3.Distance(pos, result.transform.position)
	for i = 1, #targets do
		local target = targets[i]
		local distance = Vector3.Distance(pos, target.transform.position) -- 距离
		if distance < curMinDist then
			result = target
			curMinDist = distance
		end
	end
	return result
end
------------------------------战斗相关 end----------------------------------------

-- 目标位置在扇形内 curPos 一般为技能发起者位置 target 为查询目标位置 angle, dist 技能扇形角度(左右各一半)与距离
function MapUtil.IsOnSector( transform, target, angle, dist, draw)
	local distance = Vector3.Distance(transform.position, target.position) -- 距离
	if distance < 0.01 then return true end
	if distance <= dist then
		local norVec = transform.rotation * Vector3.forward
		local curPos = transform.position
		local targetPos = target.position
		local temVec = target.position - transform.position
		local jiajiao = Mathf.Acos(Vector3.Dot(norVec.normalized, temVec.normalized)) * Mathf.Rad2Deg -- 两向量夹角
		if jiajiao <= angle * 0.5 then
			return true
		end
	end
	return false
end

-- 对象在圆内（半径内）
function MapUtil.IsOnCircle( transform, target, radius)
	if not target then return false end
	return MapUtil.IsNearByV3( transform.position, target.position, radius)
end

-- 目标位置在三角形内 
function MapUtil.IsOnTriangle( transform, target, angle, dist)
	if not target then return false end
	local direction = target.position - transform.position
	if Vector3.Angle(direction, transform.forward) <= angle then
		if Vector3.Distance(target.position, transform.position) <= dist then
			return true
		end
	end
	return false
end

-- 对象在矩形内
local function Multiply(p1x, p1y, p2x, p2y, p0x, p0y)
	return ((p1x - p0x) * (p2y - p0y) - (p2x - p0x) * (p1y - p0y))
end
local function IsInRect(target, leftEnd, rightEnd, right, left)
	if not target then return false end
	local x, y = target.x, target.z
	local v0x, v0y = leftEnd.x, leftEnd.z
	local v1x, v1y = rightEnd.x, rightEnd.z
	local v2x, v2y = right.x, right.z
	local v3x, v3y = left.x, left.z
	if Multiply(x, y, v0x, v0y, v1x, v1y) * Multiply(x, y, v3x, v3y, v2x, v2y) <= 0 
		and Multiply(x, y, v3x, v3y, v0x, v0y) * Multiply(x, y, v2x, v2y, v1x, v1y) <= 0 then
		return true
	else
		return false
	end
end
-- rl Dist: 左右各跨度(分左右等距), forwardDist : 前方跨度
function MapUtil.IsOnRect( transform, target, rlDist, forwardDist)
	if not target then return false end
	local r = transform.rotation
	local pos = transform.position
	local left = pos + (r * Vector3.left) * rlDist
	local right = pos + (r * Vector3.right) * rlDist
	local leftEnd = left + (r * Vector3.forward) * forwardDist
	local rightEnd = right + (r * Vector3.forward) * forwardDist
	if IsInRect(target.position, leftEnd, rightEnd, right, left) then
		return true
	else
		return false
	end
end

-- 跨场景搜索(返回 查寻存在状态及结果) isReverse 倒序查找
MapUtil.doorMap = {} -- 缓存记录查过的传送门所有场景
function MapUtil.GetScenePath(start, target, __parent, __isStart, isReverse)
	local startDoors = MapUtil.GetSceneDoor(start, isReverse)
	if __isStart == nil then
		MapUtil.pathes = {} -- 路径结果
		MapUtil.Opens = {}
		if start == target then return true end
		if #startDoors == 0 then return false end
		local targetDoors = MapUtil.GetSceneDoor(target)
		if #targetDoors == 0 then return false end
		MapUtil.cacheNode = {} -- 缓存节点
		MapUtil.closeList = {} -- 已经检查列表
	end
	local founds = {}
	local unFounds = {}
	local isFound = false

	for _, v in ipairs(startDoors) do
		if v.toMapId == target then
			table.insert(founds, v)
			MapUtil.closeList[v.mapId] = true
			isFound = true
		else
			if not MapUtil.closeList[v.toMapId] then
				if not MapUtil.Opens[v.mapId] then
					table.insert(unFounds, v)
				end
			end
		end
	end
	for i, node in ipairs(unFounds) do
		MapUtil.Opens[node.mapId] = true
		local result = MapUtil.GetScenePath(node.toMapId, target, {node=node, parent=__parent}, false, isReverse)
		if result then
			isFound = true
		end
	end
	for _,v in ipairs(founds) do
		table.insert(MapUtil.cacheNode, {node=v, parent=__parent})
	end

	if __isStart == nil then
		-- 再倒序查找一次
		MapUtil.Opens = {}
		MapUtil.closeList = {}
		MapUtil.GetScenePath(start, target, nil, false, true)

		if next(MapUtil.cacheNode) then
			for i,v in ipairs(MapUtil.cacheNode) do
				local path = {}
				MapUtil._GetPath(path, v)
				table.insert(MapUtil.pathes, path)
			end
			return true
		else
			return false
		end
	end
	return isFound
end
-- 获取得所有节点拼成路径
function MapUtil._GetPath(path, node)
	table.insert(path, node.node)
	if node.parent then
		MapUtil._GetPath( path, node.parent )
	end
end

-- 遍历场景所存在的传送门
function MapUtil.GetSceneDoor(sceneId, isReverse)
	local cfg = GetCfgData("transfer")
	local doors = MapUtil.doorMap[sceneId]
	if not doors then
		doors = {}
		for id, v in pairs(cfg) do
			if type(v) ~= "function" then
				if v.mapId == sceneId then
					table.insert(doors, v)
				end
			end
		end
		SortTableByKey( doors, "toMapId", true )
		MapUtil.doorMap[sceneId] = doors
	elseif isReverse then
		doors = {}
		for id, v in pairs(cfg) do
			if type(v) ~= "function" then
				if v.mapId == sceneId then
					table.insert(doors, v)
				end
			end
		end
		SortTableByKey( doors, "toMapId", false )
	end
	return doors
end
-- 传送门是否在场景中
function MapUtil.IsDoorIdOnScene(doorId, sceneId)
	local doors = MapUtil.GetSceneDoor(sceneId)
	local door = nil
	for i=1,#doors do
		door = doors[i]
		if door.id == doorId then
			return door
		end
	end
	return false
end
