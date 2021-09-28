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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "yinliang",
				varName = "listen",
				posX = 0.5110644,
				posY = 0.1993428,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1111111,
				image = "zdte#zdy1",
				imageNormal = "zdte#zdy1",
				imagePressed = "zdte#zdy2",
				imageDisable = "zdte#zdy1",
				disablePressScale = true,
				propagateToChildren = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "shuohua",
				varName = "speak",
				posX = 0.5741689,
				posY = 0.1993428,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1111111,
				image = "zdte#zdh1",
				imageNormal = "zdte#zdh1",
				imagePressed = "zdte#zdh2",
				imageDisable = "zdte#zdh1",
				disablePressScale = true,
				propagateToChildren = true,
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
	jn6 = {
	},
	bj = {
	},
	c_hld = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
