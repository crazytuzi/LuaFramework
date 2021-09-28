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
			etype = "Button",
			name = "cc1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.075,
			sizeY = 0.1638889,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "sld",
				posX = 0.5,
				posY = 0.1355922,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8541667,
				sizeY = 0.1864407,
				image = "jingfang#sld",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk1",
				varName = "icon_bg",
				posX = 0.5118598,
				posY = 0.5865014,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9791667,
				sizeY = 0.7966101,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5127688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ss1",
				varName = "item_count",
				posX = 0.5,
				posY = 0.08200619,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.309372,
				sizeY = 0.296635,
				text = "222/333",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "suo",
				posX = 0.2345012,
				posY = 0.3545522,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2916667,
				sizeY = 0.2372881,
				image = "tb#tb_suo.png",
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
