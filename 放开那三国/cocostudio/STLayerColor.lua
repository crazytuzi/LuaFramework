-- Filename: STLayerColor.lua
-- Author: bzx
-- Date: 2015-04-25
-- Purpose: 

STLayerColor = class("STLayerColor", function (color, width, height)
	local ret = STNode:create()
	local subnode = CCLayerColor:create(color, width, height)
	ret:setSubnode(subnode)
	return ret
end)

ccs.combine(STLayer, STLayerColor)

function STLayerColor:create( color, width, height )
	color = color or ccc4(0, 0, 0, 0)
	width = width or g_winSize.width
	height = height or g_winSize.height
	return STLayerColor.new(color, width, height)
end