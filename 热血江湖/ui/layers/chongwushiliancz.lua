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
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
						posX = 0.5,
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db1",
					posX = 0.5,
					posY = 0.6360487,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8773991,
					sizeY = 0.5921077,
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
						etype = "Scroll",
						name = "lbt1",
						varName = "scroll",
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
					etype = "Image",
					name = "tx1",
					varName = "petRoot1",
					posX = 0.1671351,
					posY = 0.1931868,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1507389,
					sizeY = 0.2275862,
					image = "dw#dw_txd.png",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "petBtn1",
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
						name = "txd1",
						varName = "petIconBg1",
						posX = 0.4625,
						posY = 0.4712229,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7166085,
						sizeY = 0.8335562,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txt1",
							varName = "petIcon1",
							posX = 0.5,
							posY = 0.5451064,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.83,
							sizeY = 0.83,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "wk3",
							posX = 0.4580873,
							posY = 0.5515568,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9368423,
							sizeY = 0.8749999,
							image = "cl#sck",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xx1",
						varName = "petStar1",
						posX = 0.46875,
						posY = 0.1518918,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.842719,
						sizeY = 0.1960487,
						image = "scxx#scxx5.png",
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd1",
						varName = "petBlood1",
						posX = 0.4999999,
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
						name = "djd",
						posX = 0.150499,
						posY = 0.8088301,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3137255,
						sizeY = 0.3636364,
						image = "suic#djk",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dj1",
							varName = "petLvl1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							text = "99",
							color = "FFFFE7AF",
							fontOutlineEnable = true,
							fontOutlineColor = "FF975E1F",
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
					name = "jtx1",
					varName = "noPetRoot1",
					posX = 0.1671351,
					posY = 0.1931868,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1507389,
					sizeY = 0.2275862,
					image = "dw#dw_txd2.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jy1",
						posX = 0.4159518,
						posY = 0.4717633,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6209151,
						sizeY = 0.7954546,
						image = "dw#dw_kong.png",
						alpha = 0.7,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw",
					varName = "power",
					posX = 0.3264714,
					posY = 0.2265043,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2049261,
					sizeY = 0.07413793,
					image = "dw#mjd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zl2",
						varName = "powerLabel",
						posX = 0.4232862,
						posY = -1.064459,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7873148,
						sizeY = 1.520377,
						text = "999999",
						color = "FFC93034",
						fontSize = 26,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zdl",
						posX = 0.4232862,
						posY = 0.4984187,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3894231,
						sizeY = 0.8604651,
						image = "dw#zl",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.965085,
					posY = 0.9337791,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
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
					name = "jr",
					varName = "join",
					posX = 0.8432813,
					posY = 0.1832653,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1714286,
					sizeY = 0.1137931,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jrz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9942393,
						sizeY = 0.9564725,
						text = "进入试炼",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
				name = "top",
				posX = 0.5,
				posY = 0.8779602,
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
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#xzsc",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
