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
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.02057244,
						posY = 0.1628659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05421687,
						sizeY = 0.3755943,
						image = "zhu#zs1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.9442027,
						posY = 0.1851488,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1592083,
						sizeY = 0.4057052,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.4844976,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bj",
						posX = 0.4823971,
						posY = 0.7754251,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.926351,
						sizeY = 0.3931035,
						image = "gq#gq",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "gqwz",
							posX = 0.5,
							posY = 0.6622803,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7157699,
							sizeY = 0.364035,
							image = "gq#gqwz",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.9650654,
					posY = 0.9355491,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 0.9752649,
					posY = 0.1540154,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06009852,
					sizeY = 0.1137931,
					image = "tong#bz",
					imageNormal = "tong#bz",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd2",
					varName = "wizardUI",
					posX = 0.5011473,
					posY = 0.3937877,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9977059,
					sizeY = 0.6979172,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d6",
						posX = 0.4862362,
						posY = 0.5048452,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8754385,
						sizeY = 0.8840908,
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
							name = "bt3",
							posX = 0.4990576,
							posY = 0.8581078,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.005487,
							sizeY = 0.2714675,
							image = "d#bt",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "zl34",
								varName = "desc",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 0.6834688,
								sizeY = 0.833261,
								text = "活动描述配置在这里",
								color = "FF65944D",
								fontSize = 22,
								fontOutlineColor = "FF06100F",
								hTextAlign = 1,
								vTextAlign = 1,
								colorTL = "FF85FFE4",
								colorTR = "FF85FFE4",
								colorBR = "FF28F7FF",
								colorBL = "FF28F7FF",
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lieb",
						varName = "wizardScroll",
						posX = 0.4863614,
						posY = 0.5127658,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8721645,
						sizeY = 0.8682612,
						showScrollBar = false,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8751824,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tt",
					varName = "titleImg",
					posX = 0.5037879,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5075758,
					sizeY = 0.4807692,
					image = "biaoti#jyzg",
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
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	gy = {
	},
	gy3 = {
	},
	di = {
		di = {
			bezier = {{0, {886.6704, 315.4837, 886.6704, 315.4837, 886.6704, 315.4837}}, {500, {459.6706, 311.4837, 751.6707, 420.4841, 588.6708, 219.4838}}, },
		},
	},
	d2 = {
		di2 = {
			bezier = {{0, {886.6704, 315.4837, 886.6704, 315.4837, 886.6704, 315.4837}}, {500, {459.6706, 311.4837, 751.6707, 420.4841, 588.6708, 219.4838}}, },
		},
	},
	d3 = {
		di3 = {
			bezier = {{0, {886.6704, 315.4837, 886.6704, 315.4837, 886.6704, 315.4837}}, {500, {459.6706, 311.4837, 751.6707, 420.4841, 588.6708, 219.4838}}, },
		},
	},
	xtdd6 = {
		xtdd6 = {
			alpha = {{0, {1}}, {100, {1}}, {500, {0}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_guang = {
		{0,"di", 1, 0},
		{0,"d2", 1, 0},
		{0,"d3", 1, 0},
		{0,"xtdd6", 1, 450},
		{2,"di", 1, 0},
		{2,"di2", 1, 0},
		{2,"di3", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
