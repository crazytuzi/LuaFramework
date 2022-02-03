---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/11/27 19:10:57
-- @description: 位面冒险格子处理
---------------------------------

PlanesTile = PlanesTile or {}

local W_INDEX = 1000

PlanesTile.planes_type = 1  --位面类型
PlanesTile.year_monster_type = 2 --年兽类型
-- 设置格子中线半径
--@player_type 玩法类型 1 位面 2 年兽
function PlanesTile.init(tile_w, tile_h, width, height, player_type) 
    PlanesTile.tile_w = tile_w or 192
    PlanesTile.tile_h = tile_h or 96
    PlanesTile.width = width
    PlanesTile.height = height
    PlanesTile.tile_max_w = math.floor(width / tile_w) + 1
    PlanesTile.tile_max_h = math.floor(height / tile_h) + 1

    PlanesTile.player_type = player_type or PlanesTile.planes_type
end

-- 索引转象素
function PlanesTile.indexPixel(index) 
    local x, y = PlanesTile.indexTile(index)
    return PlanesTile.toPixel(x, y)
end

-- 索引转坐标
function PlanesTile.indexTile(index) 
    return math.floor(index / W_INDEX), index % W_INDEX
end

-- 坐标转索引
function PlanesTile.tileIndex(x, y) 
    return x * W_INDEX + y
end

-- 格子转中点像素
function PlanesTile.toPixel(x, y)
    return (x-1+y%2/2)*PlanesTile.tile_w*2, (y-1) * PlanesTile.tile_h
end

-- 格子转左顶点像素
function PlanesTile.toPixelLeft(x, y)
    return (x-1.5+y%2/2)*PlanesTile.tile_w*2, (y-1) * PlanesTile.tile_h
end

-- 格子转右顶点像素
function PlanesTile.toPixelRight(x, y)
    return (x-0.5+y%2/2)*PlanesTile.tile_w*2, (y-1) * PlanesTile.tile_h
end

-- 格子转上顶点像素
function PlanesTile.toPixelTop(x, y)
    return (x-1+y%2/2)*PlanesTile.tile_w*2, y * PlanesTile.tile_h
end

-- 格子转下顶点像素
function PlanesTile.toPixelBottom(x, y)
    return (x-1+y%2/2)*PlanesTile.tile_w*2, (y-2) * PlanesTile.tile_h
end

-- 像素转格子坐标(格子任意点)
function PlanesTile.toTile(x, y)
    local tx0, ty0 = math.ceil(x / PlanesTile.tile_w), math.ceil(y / PlanesTile.tile_h)
    local tx1, ty1 = math.ceil((tx0+(ty0-1)%2)/2), ty0
    local tx2, ty2 = math.ceil((tx0+ty0%2)/2), ty0+1
    local x1, y1 = PlanesTile.toPixel(tx1, ty1)
    local x2, y2 = PlanesTile.toPixel(tx2, ty2)
    if math.abs(x1-x) + math.abs(y1-y) < math.abs(x2-x) + math.abs(y2-y) then
        return tx1, ty1
    else
        return tx2, ty2
    end
end

-- 格子偏移处理
function PlanesTile.tileOffset(x, y, i, j)
    local a = i - j
    if a % 2 == 0 then
        return x + math.floor(a/2), y + i + j
    else
        return x + math.floor(a/2) + y % 2, y + i + j
    end
end

-- 批量格子偏移处理
function PlanesTile.tilesOffset(x, y, list)
    local tmp = {}
    for k, v in pairs(list or {{0,0}}) do
        tmp[k] = {}
        tmp[k][1], tmp[k][2] = PlanesTile.tileOffset(x, y, v[1], v[2])
    end
    return tmp
end

-- 获取2个格子的偏移值
function PlanesTile.getOffset(x1, y1, x2, y2)
    local x0 = x2 - x1
    local y0 = y2 - y1
    if y0 % 2 == 0 then
        return math.ceil(x0 + y0 / 2), math.floor(y0 / 2 - x0)
    else
        return math.ceil((x0 - y1 % 2) + y0 / 2), math.floor(y0 / 2 - x0)
    end
end

-- 取格子范围所有格子集
function PlanesTile.tileRange(x, y, w, h)
    w = math.max(1, w or 1)
    h = math.max(1, h or 1)
    local list = {}
    local n = -math.floor(w / 2)
    local m = -math.floor(h / 2)
    local a, x1, y1
    for i = n, n + w - 1 do
        for j = m, m + h - 1 do
            x1, y1 = PlanesTile.tileOffset(x, y, i, j)
            table.insert(list, {x1, y1})
        end
    end
    return list
end

-- 取格子范围中心像素
function PlanesTile.tileRangePixel(x, y, w, h)
    w = math.max(1, w or 1)
    h = math.max(1, h or 1)
    if w % 2 == 0 and h % 2 == 0 then 
        return PlanesTile.toPixelTop(x, y)
    elseif w % 2 == 1 and h % 2 == 1 then 
        return PlanesTile.toPixel(x, y)
    elseif w % 2 == 0 and h % 2 == 1 then 
        local x1,y1 = PlanesTile.toPixelTop(x, y)
        local x2,y2 = PlanesTile.toPixelRight(x, y)
        return (x1+x2)/2, (y1+y2)/2
    else
        local x1,y1 = PlanesTile.toPixelLeft(x, y)
        local x2,y2 = PlanesTile.toPixelTop(x, y)
        return (x1+x2)/2, (y1+y2)/2
    end
end

-- 取格子范围(0.5, 0)像素点
function PlanesTile.tileRangePixel2( x, y, list )
    local pos_x = PlanesTile.toPixel(x, y)

    -- 取出最靠下的格子
    local temp_off = {0, 0}
    for k,v in pairs(list) do
        if temp_off[2] > v[2] then
            temp_off = v
        end
    end
    local x1, y1 = PlanesTile.tileOffset(x, y, temp_off[1], temp_off[2])
    local _, pos_y = PlanesTile.toPixelRight(x1, y1)
    return pos_x, pos_y
end

-- 格子距离
function PlanesTile.tileDistance(x1, y1, x2, y2)
    local x, y = PlanesTile.getOffset(x1, y1, x2, y2)
    return math.max(math.abs(x), math.abs(y))
end

-- a星寻路
function PlanesTile.astar(start_pos, end_pos, walkable) 
    PlanesTile.walkable = walkable
    if start_pos.x == end_pos.x and start_pos.y == end_pos.y then
        return false
    elseif PlanesTile.isBlock(end_pos.x, end_pos.y, true) then
        return false
    end
    local all_point = {}
    local open = Heap.New('f') 
    local point = PlanesTile.newPoint(start_pos.x, start_pos.y)
    open:insert(point)
    local parent, nextList, x, y, dir, cost, g
    while not open:IsEmpty() do
        parent = open:take_smallest()
        parent.close = 1
        nextList = {
            {-1,0,1,1}
            ,{1,0,2,1}
            ,{0,-1,3,1.2}
            ,{0,1,4,1.2}
        }
        for _, test in pairs(nextList) do 
            x, y = PlanesTile.tileOffset(parent.x, parent.y, test[1], test[2])
            dir = test[3]
            cost = test[4]
            if x == start_pos.x and y == start_pos.y then
            elseif all_point[x] and all_point[x][y] then -- 之前访问过了
                point = all_point[x][y]
                g = parent.g + cost 
                if point.close == nil and g < point.g then -- 还在开启状态 G值较小 更新信息
                    point.g = g
                    point.f = point.g + point.h
                    point.parent = parent
                    point.dir = dir
                    point.n = parent.n + 1
                end
            elseif x == end_pos.x and y == end_pos.y then -- 目标点
                PlanesTile.walkable = nil
                return PlanesTile.newPoint(x, y, parent, dir, cost)
            elseif not PlanesTile.isBlock(x, y) then -- 可行走 -- 之前未访问过
                point = PlanesTile.newPoint(x, y, parent, dir, cost)
                if all_point[x] == nil then 
                    all_point[x] = {}
                end
                all_point[x][y] = point
                open:insert(point)
            end
        end
    end
end

-- 判断是否为不可行走区域(格子和事件同时判断)
function PlanesTile.isBlock(x, y, is_check_status)
    local index = PlanesTile.tileIndex(x, y)

    if PlanesTile.player_type == PlanesTile.planes_type then
        -- is_check_status: 为true 时，忽略格子配置是否可行走，有事件且事件未完成，则可行走
        if is_check_status and PlanesController:getInstance():getModel():checkEvtCanWalkByGridIndex(index, is_check_status) then
            return false
        elseif PlanesTile.walkable[y] and PlanesTile.walkable[y][x] and PlanesTile.walkable[y][x] > 1 and PlanesController:getInstance():getModel():checkEvtCanWalkByGridIndex(index) then -- 格子是否可行走
            return false
        end
    elseif PlanesTile.player_type == PlanesTile.year_monster_type then
        if is_check_status and ActionyearmonsterController:getInstance():getModel():checkEvtCanWalkByGridIndex(index, is_check_status) then
            return false
        elseif PlanesTile.walkable[y] and PlanesTile.walkable[y][x] and PlanesTile.walkable[y][x] > 1 and ActionyearmonsterController:getInstance():getModel():checkEvtCanWalkByGridIndex(index) then -- 格子是否可行走
            return false
        end
    end
    return true
end

function PlanesTile.newPoint(x, y, parent, dir, cost)
    if parent == nil then
        return {x = x, y = y, g = 0, h = 0, f = 0, n = 0, dir = 0}
    else 
        local g = parent.g + cost
        local h = 1.5
        if parent.dir == 0 or parent.dir == dir then
            h = 1
        end
        return {x = x, y = y, g = g, h = h, f = g + h, parent = parent, dir = dir, n = parent.n + 1}
    end
end

function PlanesTile.test(walkable)
    local path = PlanesTile.astar({x=3, y=16}, {x=3, y=12}, walkable)
    while path do
        local x = path.x
        local y = path.y
        local node = walkable[y][x]
        if node.txt then
            node.txt:setString(string.format("%s,g=%s", node.tile_res, path.g))
        end
        path = path.parent
    end
end
