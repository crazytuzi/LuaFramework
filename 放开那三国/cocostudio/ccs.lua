-- Filename: cocostudio.lua
-- Author: bzx
-- Date: 2015-04-24
-- Purpose: 

ccs = ccs or {}

ccs.combine = function (src, dest)
    local functions = {}
    functions.__create = true
    functions.__cname = true
    functions.new = true
    for k, v in pairs(src) do
        if functions[k] ~= true then
            dest[k] = v
        end
    end
end

ccs.point = function ( x, y, node )
    if node then
        if x <= 1 and x >= -1 then
            x = node:getContentSize().width * x
        end
        if y <= 1 and y >= -1 then
            y = node:getContentSize().height * y
        end
    end
    return ccp(x, y)
end

ccs.isInPolygon = function (polygon, point )
	local cross = 0
	local pointsCount = #polygon
	for i = 1, pointsCount do
		local p1 = polygon[i]
		local p2 = polygon[i % pointsCount + 1]
		if p1[2] ~= p2[2] then
			if point.y >= math.min(p1[2], p2[2]) and point.y < math.max(p1[2], p2[2]) then
				local crossX = (point.y - p1[2]) * (p2[1] - p1[1]) / (p2[2] - p1[2]) + p1[1]
				if crossX > point.x then
					cross = cross + 1
				end
			end
		end
	end
	local ret = cross % 2 == 1
	return ret
end

reloadPath = {
}

btimport = function ( path , isRequire)
	if reloadPath[path] then
		deleteLoaded(path)
	end
	if isRequire then
		deleteLoaded(path)
	end
	require(path)
end

deleteLoaded = function(path)
	local dirs = string.split(path, "/")
	local moduleName = dirs[#dirs]
	_G[moduleName] = nil
	package.loaded[moduleName] = nil
	package.loaded[path] = nil
end

btimport "script/cocostudio/STDef"
btimport "script/cocostudio/STTouchDispatcher"
btimport "script/cocostudio/STNode"
btimport "script/cocostudio/STLayer"
btimport "script/cocostudio/STLayerColor"
btimport "script/cocostudio/STSprite"
btimport "script/cocostudio/STButton"
btimport "script/cocostudio/STLayout"
btimport "script/cocostudio/STTableViewCell"
btimport "script/cocostudio/STScale9Sprite"
btimport "script/cocostudio/STLabel"
btimport "script/cocostudio/STScrollView"
btimport "script/cocostudio/STTableView"