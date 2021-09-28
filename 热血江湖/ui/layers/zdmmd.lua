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
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn1",
				varName = "hugBtn",
				posX = 0.3385501,
				posY = 0.3028451,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1587302,
				image = "zdte2#fxw",
				imageNormal = "zdte2#fxw",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn2",
				varName = "kissBtn",
				posX = 0.4656559,
				posY = 0.3028451,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1587302,
				image = "zdte2#mmd",
				imageNormal = "zdte2#mmd",
				disablePressScale = true,
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
