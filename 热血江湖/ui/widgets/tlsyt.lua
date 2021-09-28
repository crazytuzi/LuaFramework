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
			name = "jie1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.0712132,
			sizeY = 0.1402778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "bt",
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
				name = "djt1",
				varName = "grade_icon",
				posX = 0.5,
				posY = 0.592593,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9028379,
				sizeY = 0.8148147,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "das1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5416668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "item_value",
					posX = 0.5,
					posY = -0.09340152,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.895841,
					sizeY = 0.6075608,
					text = "100万",
					color = "FF966856",
					fontSize = 18,
					fontOutlineColor = "FF102E21",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "item_count",
					posX = 0.2954552,
					posY = 0.2061861,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.215958,
					sizeY = 0.4679778,
					text = "x50",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1936272,
					posY = 0.2276858,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3181818,
					sizeY = 0.3181818,
					image = "tb#suo",
				},
			},
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
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
