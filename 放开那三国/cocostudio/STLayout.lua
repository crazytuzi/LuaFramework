-- Filename: STLayout.lua
-- Author: bzx
-- Date: 2015-04-26
-- Purpose: 

STLayout = class("STLayout", function (color, size)
	return STLayerColor:create(color, size.width, size.height)
end)

function STLayout:create(color, size)
	color = color or ccc4(0, 0, 0, 0)
	size = size or g_winSize
	return STLayout.new(color, size)
end