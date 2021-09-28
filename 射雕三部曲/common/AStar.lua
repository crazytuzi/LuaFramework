--[[
    文件名: AStar.lua
    描述: A*寻路算法，用于夺宝等
    创建人: heguanghui
    创建时间: 2017.04.27
--]]

local AStar = class("AStar", function(params)
    return {}
end)

--[[
-- 参数
    worldFiles: 编辑器生成的lua文件列表{"xx.lua", "xxx.lua"}
]]
function AStar:ctor(worldFiles)
    self.worldMap = {}
    self.worldSize = {width = 0, height = 0}
    for i,v in ipairs(worldFiles) do
        local collusion = require(v)
        if self.itemSize and (self.itemSize ~= collusion.itemSize or self.worldSize.width ~= collusion.width) then
            print("A星地图文件" .. v .. "格子大小或宽度与其它不符")
        else
            -- 每格大小
            self.itemSize = collusion.itemSize
            -- 地图格子大小(从左下角开始算起)
            self.worldSize.width = collusion.width
            self.worldSize.height = self.worldSize.height + collusion.height
            -- 地图的障碍数据
            table.insertto(self.worldMap, collusion.data, 0)
        end
    end
end

-- 传入cocos坐标计算当前格子状态(0:可走，1:需要半透明, 2:不可走)
-- 返回值widthIndex: 从0开始的计数
-- 返回值heightIndex: 从0开始的计数
function AStar:getPixelCollusion(pos)
    local widthIndex = math.floor(pos.x / self.itemSize)
    local heightIndex = math.floor(pos.y / self.itemSize)
    -- 边界判断
    if widthIndex < 0 or widthIndex >= self.worldSize.width or 
        heightIndex < 0 or heightIndex >= self.worldSize.height then
        return 2, 0, 0
    end
    local dataIndex = heightIndex * self.worldSize.width + widthIndex + 1
    -- worldMap是从1开始的
    return self.worldMap[dataIndex] or 2, widthIndex, heightIndex
end

-- 传入开始坐标和结束坐标，返回中途坐标点列表(寻路失败返回空列表)
function AStar:calcTrack(startPos, endPos)
    if self:getPixelCollusion(endPos) >= 2 then
        return {} -- 目的地不可达
    end
	-- 位置转换为格子坐标
	local curPos = {x = math.ceil((startPos.x+0.5) / self.itemSize), y = math.ceil((startPos.y+0.5) / self.itemSize), gs = 0}
	curPos.parent = {x = curPos.x, y = curPos.y}
	local disPos = {x = math.ceil((endPos.x+0.5) / self.itemSize), y = math.ceil((endPos.y+0.5) / self.itemSize)}
	-- 清空open表，开始计算路径
	self.openTrack = {}
	local lastTrack = self:backCalcTrack(curPos, disPos)
	-- 位置转换为cocos坐标(包括起始和结束位置)
	if #lastTrack > 1 then
		local cocosTrack = {startPos}
		for i=2, #lastTrack-1 do
			-- 转换到cocos item中间位置
			local indexPos = lastTrack[i]
			table.insert(cocosTrack, {x = (indexPos.x - 0.5) * self.itemSize, y = (indexPos.y - 0.5) * self.itemSize})
            -- print("way:", indexPos.x, indexPos.y) -- 测试用
		end
		table.insert(cocosTrack, endPos)

        -- 重置行走数据
        self.targetStepList = {}
        self.xOrienList = {}    -- x方向上的转向
        self.yOrienList = {}    -- y方向上的转向
        self.endPos = endPos
        self.lastTrack = cocosTrack
        return cocosTrack
	end
	return {}
end

-- 计算当前行走所在的位置
--[[
-- params:
    playerPos: 当前玩家位置
    speed: 移动的速度
    dt: 当前更新的时间
    tag: 多个寻路的tag(组队副本跟随使用)
-- return:
    1. 是否已经走到终点
    2. 当前更新的玩家位置
    3. 方向是否是向上
    4. 左右的偏转角度(setRotationSkewY角度)
    5. 是否需要半透明显示
]]
-- 根据传入的路径返回当前的位置, 是否向上, 左右翻转角度, 是否半透明
function AStar:getCurrentStepInfo(playerPos, speed, dt, tag)
    local isArrived, retPos = false, playerPos
    if not self.lastTrack or #self.lastTrack < 2 then
        return true, retPos, false, 0, false
    end
    -- 判断是否需要新增tag, 默认值为2
    local curTag = tag or 1
    self.targetStepList[curTag] = self.targetStepList[curTag] or 2
    local itemPos = self.lastTrack[self.targetStepList[curTag]]
    if not itemPos then
        return true, retPos, false, 0, false
    end
    -- 本次预计移动距离
    local planLength = speed * dt
    while (planLength > 0) do
        -- 移动到下一步的距离
        local itemLength = cc.pGetLength(cc.pSub(itemPos, retPos))
        -- 如到下一步不够距离，则判断下下一步
        if planLength > itemLength then
            self.targetStepList[curTag] = self.targetStepList[curTag] + 1
            if not self.lastTrack[self.targetStepList[curTag]] then
                -- 判断是否已经走到终点
                retPos = self.endPos
                isArrived = true
                break
            end
            retPos = itemPos
            itemPos = self.lastTrack[self.targetStepList[curTag]]
        else
            -- 取当前到下一步的线性位置
            retPos = cc.pLerp(retPos, itemPos, planLength/itemLength)
        end
        planLength = planLength - itemLength
    end
    local offset = cc.pSub(itemPos, playerPos)

    -- 惯性转向，x/y为0时不转向
    self.xOrienList[curTag] = offset.x == 0 and (self.xOrienList[curTag] or false) or offset.x > 0
    self.yOrienList[curTag] = offset.y == 0 and (self.yOrienList[curTag] or false) or offset.y > 0
    return isArrived, retPos, self.yOrienList[curTag], self.xOrienList[curTag] and 0 or -180, self:getPixelCollusion(retPos) == 1
end

-- 取中心点范围内的可移动随机点位
-- centerPos: 中心点
-- scope: 半径范围，取正方形
-- count: 需要返回的数量
function AStar:randomScopePoints(centerPos, scope, count)
    local isObstacle, widthIndex, heightIndex = self:getPixelCollusion(centerPos)
    if isObstacle >= 2 or scope < 1 or count < 1 then
        return {centerPos}
    end
    -- 计算半径格子数
    local maxPos = cc.p(self.worldSize.width - 1, self.worldSize.height - 1)
    local itemCount = math.ceil(scope / self.itemSize)
    local xStart, yStart = widthIndex - itemCount, heightIndex - itemCount
    local startIndexPos = cc.pGetClampPoint(cc.p(xStart, yStart), cc.p(0, 0), maxPos)
    local xEnd, yEnd = widthIndex + itemCount, heightIndex + itemCount
    local endIndexPos = cc.pGetClampPoint(cc.p(xEnd, yEnd), cc.p(0, 0), maxPos)
    -- 计算半径方形区域内所有的可移动格子
    local indexList = {}
    for i=startIndexPos.x, endIndexPos.x do
        for j=startIndexPos.y, endIndexPos.y do
            local dataIndex = j * self.worldSize.width + i + 1
            -- worldmap是从1开始的, i,j是从0开始的
            if self.worldMap[dataIndex] < 2 then
                table.insert(indexList, cc.p(i, j))
            end
        end
    end
    -- 在格子内随机取count个目标
    if #indexList > 0 then
        local retList = {}
        for i=1,count do
            -- 随机点数
            local listIndex = math.random(1, #indexList)
            local listX, listY = indexList[listIndex].x * self.itemSize, indexList[listIndex].y * self.itemSize
            table.insert(retList, cc.p(listX + math.random(1, self.itemSize) - 1, listY + math.random(1, self.itemSize) - 1))
            -- 删除此位置，避免被再次取到
            if #indexList > 1 then
                table.remove(indexList, listIndex)
            end
        end
        return retList
    else
        return {centerPos}
    end
end

-- ====================== 请求服务器相关函数(需要调用 CacheBattle 中相关的函数) =========================

-- 内部计算方法(A*算法，参考"http://www.cnblogs.com/zhoug2020/p/3468167.html")
-- 和"http://dev.gameres.com/Program/Abstract/Arithmetic/A%20Pathfinding%20for%20Beginners.htm"
function AStar:backCalcTrack(curPos, disPos)
	local closeTrack = {}
	-- 加入初始点
    table.insert(self.openTrack, curPos)
    while(#self.openTrack > 0)
    do
    	-- 获取open表中路径最短位置
        local calcPos = self:getLowestScorePos(disPos)
        -- 从open表中删除并加入close表
        table.insert(closeTrack, calcPos)
        local openIndex = self:isContainsPos(self.openTrack, calcPos)
        if openIndex then
            table.remove(self.openTrack, openIndex)
        end
        -- 如close表中已有终点位置，表示寻路完成
        local closeIndex = self:isContainsPos(closeTrack, disPos)
        if closeIndex then
            break
        end

        -- 计算可行走的位置
        local walkables = self:curWalkablePoss(calcPos)
        for i,v in ipairs(walkables) do
        	-- 如可走位置在close表中，直接忽略
            if not self:isContainsPos(closeTrack, v) then
            	-- 如可走位置不在open表中，则将新位置加入open表
                if not self:isContainsPos(self.openTrack, v) then
                    table.insert(self.openTrack, v)
                else
                	-- 新位置已在open表中，不处理，下一轮会重新计算
                end
            end
        end
    end

    -- close表中记录着所有查找过的位置, 从表中挑出路径
    local trackCount = #closeTrack
	local trackPos = closeTrack[trackCount]
	if trackPos.x == disPos.x and trackPos.y == disPos.y then
		local lastTrack = {trackPos}
		-- 根据parent倒着查找路径
	    for i=trackCount-1, 1, -1 do
	        local parentPos = trackPos.parent
	        if parentPos.x == closeTrack[i].x and parentPos.y == closeTrack[i].y then
	            trackPos = closeTrack[i]
	            table.insert(lastTrack, 1, trackPos)
	        end
	    end
	    return lastTrack
	else
		-- 未找到路径或不可到达
		return {}
	end
end

-- 计算open表所有点中离终点最短的位置(disPos仅用作计算F值用)
function AStar:getLowestScorePos(disPos)
	-- 计算传入点到终点的F值(F=G+H, G为继承父结点并+x, H为抛除障碍后的直接计算位置)
    local function calToDisScore(curPos)
        local parent = curPos.parent or {}
        -- 计算H值
        local hs = (math.abs(disPos.x - curPos.x) + math.abs(disPos.y - curPos.y)) * 10
        local xOffset = math.abs(curPos.x - (parent.x or 0))
        local yOffset = math.abs(curPos.y - (parent.y or 0))
        -- 继承G值
        local gs = (parent.gs or 0)
        if xOffset > 0 and yOffset > 0 then
            gs = gs + 14 -- 斜线上权重为14
        elseif xOffset > 0 or yOffset > 0 then
            gs = gs + 10 -- 直线为10
        end
        return gs, hs, gs + hs
    end

    local lowestPos = nil
    local curScore = 9999
    -- 查找open表中最近结点
    for i=#self.openTrack,1,-1 do
        local gs, hs, fs = calToDisScore(self.openTrack[i])
        if fs < curScore then
            curScore = fs
            lowestPos = self.openTrack[i]
            lowestPos.gs = gs -- 继承父结点G值
        end
    end
    return lowestPos
end


function AStar:curWalkablePoss(curPos)
	-- 结点是否可走(是否为障碍或边界), worldIndex是从1开始的
    local function isPosValid(pos)
        local worldIndex = (pos.y - 1) * self.worldSize.width + pos.x
        if pos.x >= 1 and pos.x <= self.worldSize.width and 
            pos.y >= 1 and pos.y <= self.worldSize.height and 
            self.worldMap[worldIndex] < 2 then
            -- 1:半透明可走，2:障碍不可走
            return true
        end
        return false
    end
    -- 当前位置向周围8个方向扩散
    local offsets = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1},}
    local walkables = {}
    for i,v in ipairs(offsets) do
        local tempPos = {x = curPos.x + v[1], y = curPos.y + v[2]}
        if isPosValid(tempPos) then
        	-- 记录下可走位置
            tempPos.parent = {x = curPos.x, y = curPos.y, gs = curPos.gs}
            table.insert(walkables, tempPos)
        end
    end
    return walkables
end

function AStar:isContainsPos(track, pos)
    local findIndex = nil
    for i=1,#track do
        if track[i].x == pos.x and track[i].y == pos.y then
            findIndex = i
            break
        end
    end
    return findIndex
end

return AStar