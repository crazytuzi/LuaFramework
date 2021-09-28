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
			name = "ffaa",
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
				etype = "Button",
				name = "v1",
				varName = "btn1",
				posX = 0.3178575,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6341525,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "v2",
				varName = "btn2",
				posX = 0.8517855,
				posY = 0.8311167,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2964289,
				sizeY = 0.3377666,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "v3",
				varName = "btn3",
				posX = 0.9488916,
				posY = 0.2874386,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1022168,
				sizeY = 0.574877,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "v4",
				varName = "btn4",
				posX = 0.700451,
				posY = 0.4351124,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3993432,
				sizeY = 0.8702248,
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
