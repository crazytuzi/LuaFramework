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
			etype = "Button",
			name = "gb",
			varName = "close_btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			disablePressScale = true,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zjd",
			posX = 0.7858183,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4265639,
			sizeY = 1,
			layoutType = 6,
			layoutTypeW = 6,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "renwu",
				varName = "taskRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "htj",
					posX = 0.4065935,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07875432,
					sizeY = 0.2527778,
					image = "lt#lt_an.png",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zzz",
					posX = 0.7151138,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5697724,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.714094,
					posY = 0.4697773,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5860787,
					sizeY = 0.9395548,
					image = "b#db2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hh",
						posX = 0.499996,
						posY = 0.7273437,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.40118,
						sizeY = 0.3358753,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll_damage",
						posX = 0.5,
						posY = 0.7431109,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9749418,
						sizeY = 0.3573413,
						alphaCascade = true,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scroll_schedule",
						posX = 0.5,
						posY = 0.3153345,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9749418,
						sizeY = 0.3880515,
						alphaCascade = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jdd",
						posX = 0.500006,
						posY = 0.07922318,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7581048,
						sizeY = 0.04765537,
						image = "chu1#jdd",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "LoadingBar",
							name = "jdt",
							varName = "dungeon_bar",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9531915,
							sizeY = 0.6249999,
							image = "tong#jdt2",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "fbjd",
						varName = "dungeon_bar_lable",
						posX = 0.5000061,
						posY = 0.07922318,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.800491,
						sizeY = 0.1156398,
						text = "副本进度：32%",
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "fbjd2",
						posX = 0.5,
						posY = 0.03923732,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8834832,
						sizeY = 0.1156398,
						text = "用最快速度击败所有怪物",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top1",
						posX = 0.5,
						posY = 0.9534695,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9064998,
						sizeY = 0.04765537,
						image = "chu1#top3",
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "fbjd3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8602042,
							sizeY = 1.749327,
							text = "积 分",
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
				{
					prop = {
						etype = "Image",
						name = "top2",
						posX = 0.5,
						posY = 0.5386841,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9064998,
						sizeY = 0.04765537,
						image = "chu1#top3",
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "fbjd4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8602042,
							sizeY = 1.749327,
							text = "副本进度",
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
					name = "btd",
					posX = 0.7140942,
					posY = 0.9645239,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5677335,
					sizeY = 0.06388889,
					image = "zd#cdd",
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zb",
						varName = "dungeon_title",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9011545,
						sizeY = 1,
						text = "名字六七个字团本",
						color = "FFC4FCFF",
						fontSize = 24,
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
	ren = {
		renwu = {
			moveP = {{0, {0.5,0.5,0}}, {200, {1.2, 0.5, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	chu = {
		renwu = {
			moveP = {{0, {1.2, 0.5, 0}}, {300, {0.5,0.5,0}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ren", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
