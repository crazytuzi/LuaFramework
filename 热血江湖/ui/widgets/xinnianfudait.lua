--version = 1
local l_fileType = "node"

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
			name = "tj1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3304687,
			sizeY = 0.07222223,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zt",
				varName = "imgScore",
				posX = 0.07728372,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1086309,
				sizeY = 0.576923,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jdd",
				posX = 0.9434394,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07092199,
				sizeY = 0.576923,
				image = "chu1#gxd",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ms1",
				varName = "txtDescpt",
				posX = 0.5785964,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8293828,
				sizeY = 0.7800522,
				text = "条件五个字",
				color = "FFF1E9D7",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ms2",
				varName = "txtScore",
				posX = 0.09833333,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1755259,
				sizeY = 0.7800522,
				text = "20积分",
				color = "FFFFD118",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "imgSuccess",
				posX = 0.9481676,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08983453,
				sizeY = 0.6538461,
				image = "chu1#dj",
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
