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
			name = "yq",
			posX = 0.7869189,
			posY = 0.474329,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.08133358,
			sizeY = 0.1266614,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xue",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.01918,
				sizeY = 1.284467,
				image = "yaoqing#yaoqing",
				alphaCascade = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
				posX = 0.5006358,
				posY = 0.3876984,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.04713,
				sizeY = 1.022719,
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
	ss = {
		xue = {
			alpha = {{0, {1}}, {500, {1}}, {1500, {0}}, {2500, {1}}, {3000, {1}}, },
		},
	},
	bj = {
	},
	c_dakai = {
		{0,"ss", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
