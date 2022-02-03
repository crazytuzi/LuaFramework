-- --------------------------------------------------+
-- 家园 45度交错坐标处理
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

HomeTile = HomeTile or {}
local W_GRID_W = 20
local W_GRID_H = 30
local SCREEN_HALF_TILE_W = 4
local SCREEN_HALF_TILE_H = 8
local W_INDEX = 1000

-- 格子类型
HOME_TILE_TYPE_LAND = 20    -- 地板格子类型
HOME_TILE_TYPE_L_WALL = 21  -- 左墙格子类型
HOME_TILE_TYPE_R_WALL = 22  -- 右墙格子类型

-- 设置格子中线半径
function HomeTile.init(tile_w, tile_h, width, height) 
    HomeTile.tile_w = tile_w
    HomeTile.tile_h = tile_h
    HomeTile.width = width
    HomeTile.height = height
    HomeTile.tile_max_w = math.floor(width / tile_w) + 1
    HomeTile.tile_max_h = math.floor(height / tile_h) + 1
    HomeTile.grid_max_w = math.floor(HomeTile.tile_max_w / W_GRID_W)
    HomeTile.grid_max_h = math.floor(HomeTile.tile_max_h / W_GRID_H)
end

-- %% 转化成当前九宫格
function HomeTile.gridList(x, y)
    local gx = math.floor(x / W_GRID_W)
    local gy = math.floor(y / W_GRID_H)
    local x0 = x % W_GRID_W
    local y0 = y % W_GRID_H
    local gx1,gx2,gy1,gy2 = gx, gx, gy, gy
    if gx > 0 and x0 < SCREEN_HALF_TILE_W then
        gx1 = gx - 1
    elseif gx < HomeTile.grid_max_w and W_GRID_W - x0 < SCREEN_HALF_TILE_W then
        gx2 = gx + 1
    end
    if gy > 0 and y0 < SCREEN_HALF_TILE_H then
        gy1 = gy - 1
    elseif gy < HomeTile.grid_max_h and W_GRID_H - y0 < SCREEN_HALF_TILE_H then
        gy2 = gy + 1
    end
    local grids = {}
    for i = gx1, gx2 do
        for j = gy1, gy2 do
            table.insert(grids, {i, j})
        end
    end
    return grids
end

-- 行军线计算当前位置速度
function HomeTile.lineInfo(startIndex, endIndex, startTime, endTime, speedTime, speedS)
    local x2, y2 = HomeTile.indexPixel(HOME_TILE_TYPE_LAND, endIndex)
    local t = endTime - speedTime
    local nowTime = GameNet:getInstance():getTime()
    if t > 0 and endTime > nowTime then
        local x1, y1 = HomeTile.indexPixel(HOME_TILE_TYPE_LAND, startIndex)
        local speed = speedS / t
        local move_dir = cc.pSub(cc.p(x2, y2), cc.p(x1, y1))
        local total_s = cc.pGetLength(move_dir)  
        local move_s = total_s - (endTime - nowTime) * speed
        move_dir = cc.pNormalize(move_dir)
        local mov_dir = cc.pMul(move_dir, move_s) 
        return cc.pAdd(cc.p(x1, y1), mov_dir), speed, false
    else -- 到了结束点
        return cc.p(x2, y2), 200, true
    end
end

-- 索引转象素
function HomeTile.indexPixel(tileType, index) 
    local x, y = HomeTile.indexTile(index)
    return HomeTile.toPixel(tileType, x, y)
end

-- 索引转坐标
function HomeTile.indexTile(index) 
    return math.floor(index / W_INDEX), index % W_INDEX
end

-- 坐标转索引
function HomeTile.tileIndex(x, y) 
    return x * W_INDEX + y
end

-- 格子转中点像素
function HomeTile.toPixel(tileType, x, y)
    if tileType == HOME_TILE_TYPE_L_WALL then
        return (x-1+y%2/2)*HomeTile.tile_w*2+HomeTile.tile_w*0.5, (y-1) * HomeTile.tile_h+HomeTile.tile_h*0.5
    elseif tileType == HOME_TILE_TYPE_R_WALL then
        return (x-1+y%2/2)*HomeTile.tile_w*2+HomeTile.tile_w*0.5, (y-1) * HomeTile.tile_h-HomeTile.tile_h*0.5
    else
        return (x-1+y%2/2)*HomeTile.tile_w*2, (y-1) * HomeTile.tile_h
    end
end

-- 格子转左顶点像素
function HomeTile.toPixelLeft(tileType, x, y)
    if tileType == HOME_TILE_TYPE_L_WALL then
        return (x-1+y%2/2)*HomeTile.tile_w*2, y * HomeTile.tile_h
    elseif tileType == HOME_TILE_TYPE_R_WALL then
        return (x-1+y%2/2)*HomeTile.tile_w*2, y * HomeTile.tile_h
    else
        return (x-1.5+y%2/2)*HomeTile.tile_w*2, (y-1) * HomeTile.tile_h
    end
end

-- 格子转右顶点像素
function HomeTile.toPixelRight(tileType, x, y)
    if tileType == HOME_TILE_TYPE_L_WALL then
        return (x-0.5+y%2/2)*HomeTile.tile_w*2, (y-1) * HomeTile.tile_h
    elseif tileType == HOME_TILE_TYPE_R_WALL then
        return (x-0.5+y%2/2)*HomeTile.tile_w*2, (y-3) * HomeTile.tile_h
    else
        return (x-0.5+y%2/2)*HomeTile.tile_w*2, (y-1) * HomeTile.tile_h
    end
end

-- 格子转上顶点像素
function HomeTile.toPixelTop(tileType, x, y)
    if tileType == HOME_TILE_TYPE_L_WALL then
        return (x-1+y%2/2)*HomeTile.tile_w*2 + HomeTile.tile_w, y * HomeTile.tile_h + HomeTile.tile_h
    elseif tileType == HOME_TILE_TYPE_R_WALL then
        return (x-0.5+y%2/2)*HomeTile.tile_w*2, (y-1) * HomeTile.tile_h
    else
        return (x-1+y%2/2)*HomeTile.tile_w*2, y * HomeTile.tile_h
    end
end

-- 格子转下顶点像素
function HomeTile.toPixelBottom(tileType, x, y)
    if tileType == HOME_TILE_TYPE_L_WALL then
        return (x-1+y%2/2)*HomeTile.tile_w*2, (y-2) * HomeTile.tile_h
    elseif tileType == HOME_TILE_TYPE_R_WALL then
        return (x-1+y%2/2)*HomeTile.tile_w*2, (y-2) * HomeTile.tile_h
    else
        return (x-1+y%2/2)*HomeTile.tile_w*2, (y-2) * HomeTile.tile_h
    end
end

-- 像素转格子坐标(格子任意点)
function HomeTile.toTile(tileType, x, y)
    local tx0, ty0 = math.ceil(x / HomeTile.tile_w), math.ceil(y / HomeTile.tile_h)
    local tx1, ty1 = math.ceil((tx0+(ty0-1)%2)/2), ty0
    local tx2, ty2 = math.ceil((tx0+ty0%2)/2), ty0+1
    local x1, y1 = HomeTile.toPixel(tileType, tx1, ty1)
    local x2, y2 = HomeTile.toPixel(tileType, tx2, ty2)
    if math.abs(x1-x) + math.abs(y1-y) < math.abs(x2-x) + math.abs(y2-y) then
        return tx1, ty1
    else
        return tx2, ty2
    end
end

-- 格子偏移处理
function HomeTile.tileOffset(x, y, i, j)
    local a = i - j
    if a % 2 == 0 then
        return x + math.floor(a/2), y + i + j
    else
        return x + math.floor(a/2) + y % 2, y + i + j
    end
end

-- 批量格子偏移处理
function HomeTile.tilesOffset(x, y, list)
    local tmp = {}
    for k, v in pairs(list or {{0,0}}) do
        tmp[k] = {}
        tmp[k][1], tmp[k][2] = HomeTile.tileOffset(x, y, v[1], v[2])
    end
    return tmp
end

-- 获取2个格子的偏移值
function HomeTile.getOffset(x1, y1, x2, y2)
    local x0 = x2 - x1
    local y0 = y2 - y1
    if y0 % 2 == 0 then
        return math.ceil(x0 + y0 / 2), math.floor(y0 / 2 - x0)
    else
        return math.ceil((x0 - y1 % 2) + y0 / 2), math.floor(y0 / 2 - x0)
    end
end

-- 取格子范围所有格子集
function HomeTile.tileRange(x, y, w, h)
    w = math.max(1, w or 1)
    h = math.max(1, h or 1)
    local list = {}
    local n = -math.floor(w / 2)
    local m = -math.floor(h / 2)
    local a, x1, y1
    for i = n, n + w - 1 do
        for j = m, m + h - 1 do
            x1, y1 = HomeTile.tileOffset(x, y, i, j)
            table.insert(list, {x1, y1})
        end
    end
    return list
end

-- 取格子范围中心像素
function HomeTile.tileRangePixel(tileType, x, y, w, h)
    w = math.max(1, w or 1)
    h = math.max(1, h or 1)
    if w % 2 == 0 and h % 2 == 0 then 
        return HomeTile.toPixelTop(tileType, x, y)
    elseif w % 2 == 1 and h % 2 == 1 then 
        return HomeTile.toPixel(tileType, x, y)
    elseif w % 2 == 0 and h % 2 == 1 then 
        local x1,y1 = HomeTile.toPixelTop(tileType, x, y)
        local x2,y2 = HomeTile.toPixelRight(tileType, x, y)
        return (x1+x2)/2, (y1+y2)/2
    else
        local x1,y1 = HomeTile.toPixelLeft(tileType, x, y)
        local x2,y2 = HomeTile.toPixelTop(tileType, x, y)
        return (x1+x2)/2, (y1+y2)/2
    end
end

-- 取格子范围(0.5, 0)像素点
function HomeTile.tileRangePixel2( tileType, x, y, list )
    local pos_x = HomeTile.toPixel(tileType, x, y)

    -- 取出最靠下的格子
    local temp_off = {0, 0}
    for k,v in pairs(list) do
        if temp_off[2] > v[2] then
            temp_off = v
        end
    end
    local x1, y1 = HomeTile.tileOffset(x, y, temp_off[1], temp_off[2])
    local _, pos_y = HomeTile.toPixelRight(tileType, x1, y1)
    return pos_x, pos_y
end

-- 格子距离
function HomeTile.tileDistance(x1, y1, x2, y2)
    local x, y = HomeTile.getOffset(x1, y1, x2, y2)
    return math.max(math.abs(x), math.abs(y))
end
