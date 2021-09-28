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
			etype = "Button",
			name = "an",
			varName = "close_btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "k",
			varName = "rootView",
			posX = 0.5,
			posY = 0.4423894,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.115,
			sizeY = 0.6503202,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wk",
				posX = 0.5,
				posY = 0.5341665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9578805,
				sizeY = 1.174941,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scroll",
				posX = 0.4999996,
				posY = 0.5373634,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8689511,
				sizeY = 1.155752,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
