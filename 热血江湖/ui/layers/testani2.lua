--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "chuizi",
			posX = 0.3402499,
			posY = 0.6900678,
			anchorX = 0,
			anchorY = 0,
			sizeX = 0.1744245,
			sizeY = 0.2692077,
			image = "chuizi.png",
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	chuizi = {
		chuizi = {
			rotate = {{0, {0}}, {200, {-60}}, {300, {-50}}, {400, {-60}}, {800, {0}}, },
			skew = {{0, {0,0,0}}, {300, {20, 0, 0}}, {800, {0,0,0}}, },
		},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
