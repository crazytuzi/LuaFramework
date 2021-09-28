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
			etype = "Grid",
			name = "jt",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jiantou",
				posX = 0.6738009,
				posY = 0.577656,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1071429,
				sizeY = 0.08333334,
				image = "zdte2#jiantou",
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	dk = {
		jiantou = {
			moveP = {{0, {0.6738009,0.577656,0}}, {750, {0.72, 0.577656, 0}}, {1300, {0.6738009,0.577656,0}}, },
		},
	},
	c_dakai = {
		{0,"dk", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
