--[[

--]]
TileUtil = TileUtil or {}


-- 网格大小
TileUtil.tileWidth = 30
-- 网格大小
TileUtil.tileHeight = 30

-- 将像素转成网格块
function TileUtil.changeXToTile( v )
	return math.ceil(v / TileUtil.tileWidth)
end
function TileUtil.changeYToTile( v )
	return math.ceil(v / TileUtil.tileHeight)
end
-- 将网格块转成像素
function TileUtil.changeXToPixs( v )
	return v * TileUtil.tileWidth - 15
end
function TileUtil.changeYToPixs( v )
	return v * TileUtil.tileHeight - 15
end

-- 转换场景坐标到格子坐标
function TileUtil.changeToTilePoint( point )
	if point == nil then return nil end
	local x = TileUtil.changeXToTile(point.x)
	local y = TileUtil.changeYToTile(point.y)
	return cc.p(x, y)
end

-- 转换格子坐标到场景坐标
function TileUtil.changeToPixsPoint( point )
	if point == nil then return nil end
	local x = TileUtil.changeXToPixs(point.x)
	local y = TileUtil.changeYToPixs(point.y)
	return cc.p(x, y)
end
