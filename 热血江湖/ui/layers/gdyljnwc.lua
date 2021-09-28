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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1.00382,
			sizeY = 1.006678,
			image = "b#dd",
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "closeBtn",
				posX = 0.501165,
				posY = 0.4993107,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9937822,
				sizeY = 0.9931148,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "a",
			posX = 0.4996092,
			posY = 0.4986127,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9960201,
			sizeY = 0.9928124,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wc",
				posX = 0.5,
				posY = 0.7042395,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.14354,
				sizeY = 0.09093136,
				image = "guidaoyuling1#xuexiwanc",
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
