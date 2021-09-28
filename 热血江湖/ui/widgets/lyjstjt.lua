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
			name = "jid",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08203125,
			sizeY = 0.1513889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cl1",
				varName = "pracGradeIcon",
				posX = 0.5,
				posY = 0.5905125,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8095238,
				sizeY = 0.7633992,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp2",
					varName = "pracIcon",
					posX = 0.5029108,
					posY = 0.5261399,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8163366,
					sizeY = 0.841324,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "wwe1",
					varName = "pracBtn",
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
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1828649,
					posY = 0.2240639,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3294118,
					sizeY = 0.3364959,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "cl3",
				varName = "pracCountLabel",
				posX = 0.5,
				posY = 0.129722,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9059572,
				sizeY = 0.4460071,
				text = "5/10",
				color = "FF634624",
				fontSize = 18,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
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
