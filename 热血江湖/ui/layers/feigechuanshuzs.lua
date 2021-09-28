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
			name = "ysjm",
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
				name = "ltd",
				varName = "background",
				posX = 0.6810167,
				posY = 0.6566858,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2953125,
				sizeY = 0.2625,
				image = "fgcs#qing",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.6,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5037435,
					posY = 0.5052867,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8266844,
					sizeY = 0.6444442,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close",
				posX = 0.8065285,
				posY = 0.750983,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.06484375,
				sizeY = 0.1111111,
				image = "qymm#gb2",
				imageNormal = "qymm#gb2",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
