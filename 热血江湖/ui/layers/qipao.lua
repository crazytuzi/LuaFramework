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
			posY = 0.5,
			anchorX = 0,
			anchorY = 0,
			sizeX = 0.234375,
			sizeY = 0.08472222,
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
				sizeX = 0.5512082,
				sizeY = 1,
				image = "b#lank",
				scale9 = true,
				scale9Left = 0.65,
				scale9Right = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lv",
				varName = "lv",
				posX = 0,
				posY = 0.5,
				anchorX = 0,
				anchorY = 0.5,
				sizeX = 0.5512082,
				sizeY = 1,
				image = "b#lvk",
				scale9 = true,
				scale9Left = 0.65,
				scale9Right = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hong",
				varName = "hong",
				posX = 0,
				posY = 0.5,
				anchorX = 0,
				anchorY = 0.5,
				sizeX = 0.5512082,
				sizeY = 1,
				image = "b#hongk",
				scale9 = true,
				scale9Left = 0.65,
				scale9Right = 0.3,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "wz",
				varName = "text",
				posX = 0.5124218,
				posY = 0.6140726,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9318035,
				sizeY = 0.7186268,
				text = "四个字啊",
				fontSize = 18,
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
