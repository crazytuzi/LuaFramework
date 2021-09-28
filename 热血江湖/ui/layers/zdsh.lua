--version = 1
local l_fileType = "layer"

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
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "findRoot",
				posX = 0.4150329,
				posY = 0.2885487,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3884243,
				sizeY = 0.1502462,
				image = "zd#ltd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an4",
					varName = "rightBtn",
					posX = 0.8458809,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2494051,
					sizeY = 0.7659386,
					image = "chu1#sn1",
					imageNormal = "chu1#sn1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "as4",
						posX = 0.5,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.069936,
						sizeY = 1.023591,
						text = "右",
						color = "FF914A15",
						fontSize = 24,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an5",
					varName = "leftBtn",
					posX = 0.5045158,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2494051,
					sizeY = 0.7659386,
					image = "chu1#sn1",
					imageNormal = "chu1#sn1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "as5",
						posX = 0.5,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.069936,
						sizeY = 1.023591,
						text = "左",
						color = "FF914A15",
						fontSize = 24,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an6",
					varName = "defenseBtn",
					posX = 0.1631508,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2494051,
					sizeY = 0.7659386,
					image = "chu1#sn1",
					imageNormal = "chu1#sn1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "as6",
						posX = 0.5,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.069936,
						sizeY = 1.023591,
						text = "回 防",
						color = "FF914A15",
						fontSize = 24,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
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
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	chu = {
		dyjd = {
			moveP = {{0, {-0.3, 0.5, 0}}, {300, {0.5, 0.5, 0}}, },
		},
	},
	ru = {
		dyjd = {
			moveP = {{0, {0.5, 0.5, 0}}, {200, {-0.3, 0.5, 0}}, },
		},
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
	c_chu = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ru", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
