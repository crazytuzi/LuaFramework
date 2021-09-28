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
			name = "jd",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "rootBg",
				posX = 0.6046031,
				posY = 0.3063759,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.3884243,
				sizeY = 0.2198748,
				image = "d#tst",
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an4",
				varName = "descBtn",
				posX = 0.5594198,
				posY = 0.3035196,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.053125,
				sizeY = 0.1349206,
				image = "chu1#sx2",
				imageNormal = "chu1#sx2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb2",
				varName = "scroll",
				posX = 0.5272982,
				posY = 0.3074879,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.2842958,
				sizeY = 0.1686508,
				horizontal = true,
				showScrollBar = false,
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
	c_box = {
		{2,"gy", 1, 0},
		{2,"gy2", 1, 0},
		{2,"liz", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
