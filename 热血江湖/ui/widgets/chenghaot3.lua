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
			name = "zmcyt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2695313,
			sizeY = 0.1458333,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dj",
				varName = "showTipsBtn",
				posX = 0.4017499,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7839981,
				sizeY = 0.9111055,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cyd",
				varName = "isHave",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.94,
				sizeY = 0.94,
				image = "b#chd2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zs1",
					posX = 0.9198264,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1480111,
					sizeY = 0.8105372,
					image = "bgchu#chzs",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					posX = 0.08325621,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1480111,
					sizeY = 0.8105372,
					image = "bgchu#chzs",
					flippedX = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk",
				varName = "headBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.484058,
				sizeY = 1.219048,
				image = "ch/zldw1",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "cktp",
					varName = "head",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2499999,
					sizeY = 0.5000001,
					image = "tianxiawudi",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm",
				varName = "name_label",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.5888012,
				sizeY = 0.5280567,
				text = "棒槌一共八个汉字",
				color = "FFFFF554",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF1C4034",
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
