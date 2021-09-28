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
			name = "zy",
			varName = "zhiyinpanel",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1171875,
			sizeY = 0.2083333,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "zhedang1",
				posX = 0.5,
				posY = 5.660926,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 9.333335,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "zhedang2",
				posX = 0.5,
				posY = -4.666163,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 9.333335,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an3",
				varName = "zhedang3",
				posX = -8.32778,
				posY = 0.4933429,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 16.66667,
				sizeY = 9.333335,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an4",
				varName = "zhedang4",
				posX = 9.005922,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 16,
				sizeY = 9.333335,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhiyin",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8533334,
				sizeY = 0.8533335,
				image = "uieffect/zhiyin.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
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
		zhiyin = {
			scale = {{0, {1,1,1}}, {350, {1.1, 1.1, 1}}, {700, {1,1,1}}, },
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
