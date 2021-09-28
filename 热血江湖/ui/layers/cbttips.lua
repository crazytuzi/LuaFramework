--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "qipaoroot",
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
			varName = "qipao",
			posX = 0.5,
			posY = 0.4972258,
			anchorX = 1,
			anchorY = 1,
			sizeX = 0.234375,
			sizeY = 0.221857,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lan",
				varName = "lan",
				posX = 0,
				posY = 0.5,
				anchorX = 0,
				anchorY = 0.5,
				sizeX = 0.9251436,
				sizeY = 1,
				image = "b#lank",
				scale9 = true,
				scale9Left = 0.65,
				scale9Right = 0.3,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "wz",
				varName = "text",
				posX = 0.4608897,
				posY = 0.3341121,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8020178,
				sizeY = 0.5868531,
				text = "四个字啊",
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				posX = 0.4677259,
				posY = 0.7541485,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8149945,
				sizeY = 0.3332904,
				text = "名字写在这",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
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
