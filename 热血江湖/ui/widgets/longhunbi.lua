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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "shouchong",
				varName = "ShouChong",
				posX = 0.5,
				posY = 0.4727888,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "nrt",
					posX = 0.5,
					posY = 0.5181408,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.036676,
					sizeY = 0.9863946,
					image = "longhunbi#longhunbi",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb",
					varName = "coinImg",
					posX = 0.4308366,
					posY = 0.8823926,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.0649115,
					sizeY = 0.09611609,
					image = "items4#longhunbi",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "coinBtn",
					posX = 0.5116875,
					posY = 0.886798,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2579066,
					sizeY = 0.1078872,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "coinNum",
					posX = 0.578718,
					posY = 0.8803847,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2155709,
					sizeY = 0.1177178,
					text = "5555",
					color = "FFFFFF00",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "dragonBuyList",
				posX = 0.5,
				posY = 0.3367328,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9884092,
				sizeY = 0.6802721,
				horizontal = true,
				showScrollBar = false,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb",
				posX = 0.5,
				posY = 0.02657731,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.097737,
				sizeY = 0.1499015,
				text = "龙魂币直购不获得贵族点数，不计入其他充值活动，可获得商誉值。",
				color = "FFFFFF00",
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
