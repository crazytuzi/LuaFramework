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
			name = "jd1",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "dyjd",
				varName = "teamRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gg",
					varName = "leftRoots",
					posX = 0.2540683,
					posY = 0.4622322,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4829763,
					sizeY = 0.3386227,
					image = "b#rwd",
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
						name = "top",
						posX = 0.5,
						posY = 0.9126694,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.1750009,
						image = "bpzd#db",
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "mz",
						varName = "titleName",
						posX = 0.5,
						posY = 0.9120522,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.941409,
						sizeY = 0.25,
						text = "武道会",
						color = "FFD7B886",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ch",
						varName = "selfLives",
						posX = 0.5056853,
						posY = 0.4228766,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9240305,
						sizeY = 0.25,
						text = "我方存活：5",
						color = "FFFFC64D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ch2",
						varName = "enemyLives",
						posX = 0.5056853,
						posY = 0.2654848,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9240305,
						sizeY = 0.25,
						text = "我方存活：5",
						color = "FFBE9AFF",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ch3",
						varName = "selfHonor",
						posX = 0.5056853,
						posY = 0.108093,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9240305,
						sizeY = 0.25,
						text = "我的荣誉：5",
						color = "FF4CFFA9",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.6595965,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9533259,
						sizeY = 0.2843764,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tx",
					posX = 0.3415768,
					posY = 0.7772578,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06026786,
					sizeY = 0.04629629,
					image = "zd#shengming",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "ownLives",
						posX = 0.739949,
						posY = 0.1437439,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.449844,
						sizeY = 1.042395,
						text = "5",
						fontOutlineEnable = true,
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
	c_dakai3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
