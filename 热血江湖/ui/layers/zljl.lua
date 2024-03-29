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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "closeBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3125,
				sizeY = 0.6111111,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "a1",
					posX = 0.4962534,
					posY = 0.4965953,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.215503,
					sizeY = 0.7828034,
					image = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.217166,
					sizeY = 0.800927,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dww",
						posX = 0.5,
						posY = 0.2173257,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.2933803,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj1",
							varName = "itemBg1",
							posX = 0.1349573,
							posY = 0.4903278,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2157522,
							sizeY = 0.8995109,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bt1",
								varName = "itemBtn1",
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
								name = "tb1",
								varName = "itemIcon1",
								posX = 0.4999839,
								posY = 0.5191099,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7986894,
								sizeY = 0.8373264,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj2",
							varName = "itemBg2",
							posX = 0.3752963,
							posY = 0.4903278,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2157522,
							sizeY = 0.8995109,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bt2",
								varName = "itemBtn2",
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
								name = "tb2",
								varName = "itemIcon2",
								posX = 0.4999839,
								posY = 0.5191099,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7986894,
								sizeY = 0.8373264,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj3",
							varName = "itemBg3",
							posX = 0.6156353,
							posY = 0.4903278,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2157522,
							sizeY = 0.8995109,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bt3",
								varName = "itemBtn3",
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
								name = "tb3",
								varName = "itemIcon3",
								posX = 0.4999839,
								posY = 0.5191099,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7986894,
								sizeY = 0.8373264,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj4",
							varName = "itemBg4",
							posX = 0.8559744,
							posY = 0.4903278,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2157522,
							sizeY = 0.8995109,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bt4",
								varName = "itemBtn4",
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
								name = "tb4",
								varName = "itemIcon4",
								posX = 0.4999839,
								posY = 0.5191099,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7986894,
								sizeY = 0.8373264,
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top3",
						posX = 0.5,
						posY = 0.4329748,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5771604,
						sizeY = 0.09080388,
						image = "chu1#top3",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "taz3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7293959,
							sizeY = 0.9861619,
							text = "占领奖励",
							color = "FFF1E9D7",
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd1",
					posX = 0.5,
					posY = 0.759788,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.106969,
					sizeY = 0.1883251,
					image = "d#tyd",
					alpha = 0.5,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "faction_icon",
					posX = 0.1616758,
					posY = 0.7577033,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2625,
					sizeY = 0.2386364,
					image = "bptb2#101",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z5",
					varName = "faction_name",
					posX = 0.6771974,
					posY = 0.7553075,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6189634,
					sizeY = 0.1250911,
					text = "道具类型",
					color = "FF00500D",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFFCEBCF",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb1",
					posX = 0.3577342,
					posY = 0.612482,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1885323,
					text = "累积占领时间：",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "occupyTime",
					posX = 0.7620727,
					posY = 0.612482,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1885323,
					text = "累积占领时间：",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb3",
					posX = 0.3577342,
					posY = 0.5353303,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1885323,
					text = "发奖励倒计时：",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb4",
					varName = "awardTime",
					posX = 0.7620727,
					posY = 0.5353303,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1885323,
					text = "累积占领时间：",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
