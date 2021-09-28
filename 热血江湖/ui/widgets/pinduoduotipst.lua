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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3225082,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "dw1",
				varName = "labelDesc",
				posX = 0.3503647,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7007296,
				sizeY = 1,
				text = "参团人数达到100",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lhb",
				varName = "icon",
				posX = 0.5654048,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09689671,
				sizeY = 0.8888889,
				image = "items4#longhunbi",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dw2",
				varName = "labelCount",
				posX = 0.7648172,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.268445,
				sizeY = 1,
				text = "25000",
				color = "FFFFFF00",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.5,
				posY = 0.02222222,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.04444445,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
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
