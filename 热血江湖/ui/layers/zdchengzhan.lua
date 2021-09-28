--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "dyjd_root",
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
					posX = 0.3186943,
					posY = 0.4567561,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6122284,
					sizeY = 0.5088356,
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
						etype = "Scroll",
						name = "rwlb",
						varName = "scroll",
						posX = 0.4982125,
						posY = 0.287536,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9744787,
						sizeY = 0.536718,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "d2",
						posX = 0.5,
						posY = 0.8689734,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.037395,
						sizeY = 0.2622893,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "djs4",
							varName = "target",
							posX = 0.5,
							posY = 0.09651892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8997009,
							sizeY = 0.7911705,
							text = "击败目标，进入内城并尽快占领王座",
							color = "FFFFFF00",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "djs5",
							varName = "myCount",
							posX = 0.5,
							posY = 0.6515389,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8997009,
							sizeY = 0.7911705,
							text = "我方积分：",
							color = "FFFFFF00",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "djs6",
							varName = "count",
							posX = 0.6834602,
							posY = 0.6515389,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5327805,
							sizeY = 0.7911705,
							text = "66666",
							color = "FFFFFF00",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "LoadingBar",
						name = "jdt",
						varName = "bossblood",
						posX = 0.6711649,
						posY = 0.6235053,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6052247,
						sizeY = 0.05823026,
						image = "zd#xt",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jdd",
						posX = 0.6711649,
						posY = 0.6235053,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6125165,
						sizeY = 0.06550904,
						image = "zd#xk",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "djs7",
						posX = 0.5,
						posY = 0.6235054,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9333453,
						sizeY = 0.2075155,
						text = "将军血量：",
						color = "FFFFFF00",
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ys",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "ti",
				varName = "unrideCar",
				posX = 0.950799,
				posY = 0.2969036,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05625,
				sizeY = 0.2111111,
				image = "zdte2#qiche",
				imageNormal = "zdte2#qiche",
				disablePressScale = true,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "xs",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "cy",
				varName = "memberbt",
				posX = 0.7256621,
				posY = 0.8621294,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0484375,
				sizeY = 0.1944444,
				image = "zd#chengyuan",
				imageNormal = "zd#chengyuan",
				disablePressScale = true,
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
