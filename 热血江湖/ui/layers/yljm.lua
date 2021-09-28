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
			name = "yajm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1216764,
				sizeY = 0.2163136,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.4820319,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0515625,
				sizeY = 0.1388889,
				image = "lt#ht2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "y1",
				posX = 0.5327278,
				posY = 0.5526904,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/yy.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "y2",
				posX = 0.5311652,
				posY = 0.5235235,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/yy1.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "y3",
				posX = 0.5288213,
				posY = 0.4999122,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/yy2.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "y4",
				posX = 0.5264776,
				posY = 0.4721342,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/yy3.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "y5",
				posX = 0.5241337,
				posY = 0.4457451,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/yy4.png",
				alpha = 0,
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
	y1 = {
		y1 = {
			alpha = {{0, {1}}, {350, {1}}, {400, {0}}, {600, {0}}, },
		},
	},
	y2 = {
		y2 = {
			alpha = {{0, {1}}, {400, {1}}, {450, {0}}, {600, {0}}, },
		},
	},
	y3 = {
		y3 = {
			alpha = {{0, {1}}, {450, {1}}, {500, {0}}, {600, {0}}, },
		},
	},
	y4 = {
		y4 = {
			alpha = {{0, {1}}, {500, {1}}, {550, {0}}, {600, {0}}, },
		},
	},
	y5 = {
		y5 = {
			alpha = {{0, {1}}, {550, {1}}, {600, {0}}, },
		},
	},
	c_dakai = {
		{0,"y1", -1, 200},
		{0,"y2", -1, 150},
		{0,"y3", -1, 100},
		{0,"y4", -1, 50},
		{0,"y5", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
