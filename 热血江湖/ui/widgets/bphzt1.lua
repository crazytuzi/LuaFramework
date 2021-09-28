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
			name = "pz12",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1760431,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "sz12",
				varName = "levelBtn",
				posX = 0.4992561,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9985128,
				sizeY = 1,
				alpha = 0.5,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pzz12",
				varName = "levelLabel",
				posX = 0.4992561,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9985128,
				sizeY = 1,
				text = "全选",
				color = "FFF1DDC1",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian11",
				posX = 0.4992561,
				posY = 0.06666663,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9985128,
				sizeY = 0.05255328,
				image = "b#xian",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
