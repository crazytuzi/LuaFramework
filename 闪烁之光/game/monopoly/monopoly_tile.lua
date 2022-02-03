--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-10-11 11:37:18
-- @description    : 
		-- 大富翁格子处理
---------------------------------
MonopolyTile = MonopolyTile or {}

local W_INDEX = 1000

function MonopolyTile.init(tile_w, tile_h, width, height) 
    MonopolyTile.tile_w = tile_w
    MonopolyTile.tile_h = tile_h
    MonopolyTile.width = width
    MonopolyTile.height = height
    MonopolyTile.tile_max_w = math.floor(width / tile_w) + 1
    MonopolyTile.tile_max_h = math.floor(height / tile_h) + 1
end

-- 索引转象素
function MonopolyTile.indexPixel(index)
    local x, y = MonopolyTile.indexTile(index)
    return MonopolyTile.toPixel(x, y)
end

-- 索引转坐标
function MonopolyTile.indexTile(index) 
    return math.floor(index / W_INDEX), index % W_INDEX
end

-- 坐标转索引
function MonopolyTile.tileIndex(x, y) 
    return x * W_INDEX + y
end

-- 格子转中点像素
function MonopolyTile.toPixel(x, y)
    return (x-1+y%2/2)*MonopolyTile.tile_w*2, (y-1) * MonopolyTile.tile_h
end

-- 像素转格子坐标(格子任意点)
function MonopolyTile.toTile(x, y)
    local tx0, ty0 = math.ceil(x / MonopolyTile.tile_w), math.ceil(y / MonopolyTile.tile_h)
    local tx1, ty1 = math.ceil((tx0+(ty0-1)%2)/2), ty0
    local tx2, ty2 = math.ceil((tx0+ty0%2)/2), ty0+1
    local x1, y1 = MonopolyTile.toPixel(tx1, ty1)
    local x2, y2 = MonopolyTile.toPixel(tx2, ty2)
    if math.abs(x1-x) + math.abs(y1-y) < math.abs(x2-x) + math.abs(y2-y) then
        return tx1, ty1
    else
        return tx2, ty2
    end
end

-- 获取2个格子的偏移值
function MonopolyTile.getOffset(x1, y1, x2, y2)
    local x0 = x2 - x1
    local y0 = y2 - y1
    if y0 % 2 == 0 then
        return math.ceil(x0 + y0 / 2), math.floor(y0 / 2 - x0)
    else
        return math.ceil((x0 - y1 % 2) + y0 / 2), math.floor(y0 / 2 - x0)
    end
end

-- 格子距离
function MonopolyTile.tileDistance(x1, y1, x2, y2)
    local x, y = MonopolyTile.getOffset(x1, y1, x2, y2)
    return math.max(math.abs(x), math.abs(y))
end