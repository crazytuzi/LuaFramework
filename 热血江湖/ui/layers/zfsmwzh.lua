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
				varName = "close_btn",
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
				etype = "Grid",
				name = "ysjm2",
				posX = 0.5007801,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				fontOutlineColor = "FFA47848",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.48713,
					posY = 0.5046632,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5311581,
					sizeY = 0.7109511,
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
						name = "wasd2",
						posX = 0.5,
						posY = 0.4760335,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.022222,
						sizeY = 0.900775,
						image = "b#cs",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.2,
						scale9Bottom = 0.7,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "aa",
						posX = 0.2321281,
						posY = 0.6418164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3903674,
						sizeY = 0.2889539,
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
							name = "bb",
							varName = "quality",
							posX = 0.2601957,
							posY = 0.4691913,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3541772,
							sizeY = 0.6355169,
							image = "djk#kzi",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "b1",
								varName = "icon",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8229166,
								sizeY = 0.8125,
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "cc",
							varName = "name",
							posX = 0.7481984,
							posY = 0.5788988,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.575866,
							sizeY = 0.25,
							text = "者·水密文",
							color = "FFFF7E2D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "cc2",
							varName = "level",
							posX = 0.7481984,
							posY = 0.3666459,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.575866,
							sizeY = 0.25,
							text = "（3级）",
							color = "FFFF7E2D",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kk2",
						posX = 0.7606807,
						posY = 0.509999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4464734,
						sizeY = 0.5919301,
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
							name = "xlb",
							varName = "scroll",
							posX = 0.5015665,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9570861,
							sizeY = 0.9339934,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ee",
							posX = 0.5,
							posY = 0.989543,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.576798,
							sizeY = 0.1106108,
							image = "chu1#top2",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "e1",
								posX = 0.4999997,
								posY = 0.5517713,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6,
								sizeY = 0.9429236,
								text = "消耗",
								color = "FF966856",
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
						etype = "Button",
						name = "zh",
						varName = "ok",
						posX = 0.7606807,
						posY = 0.1218999,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2360982,
						sizeY = 0.1189458,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "hc1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.5938512,
							text = "置换",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
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
						name = "consume",
						posX = 0.2262847,
						posY = 0.240337,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4049916,
						sizeY = 0.3168425,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.2,
						scale9Right = 0.2,
						scale9Top = 0.2,
						scale9Bottom = 0.2,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "sc2",
							varName = "scroll2",
							posX = 0.4996365,
							posY = 0.424733,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9209596,
							sizeY = 0.7509853,
							horizontal = true,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ee2",
							posX = 0.5,
							posY = 0.9872428,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6755122,
							sizeY = 0.2219662,
							image = "chu1#top2",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "e2",
								posX = 0.4999997,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6,
								sizeY = 0.9429236,
								text = "消耗",
								fontOutlineEnable = true,
								fontOutlineColor = "FF966856",
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
						etype = "Button",
						name = "gb1",
						varName = "close",
						posX = 0.9757732,
						posY = 0.8744746,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09560478,
						sizeY = 0.1230746,
						image = "baishi#x",
						imageNormal = "baishi#x",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jt",
						posX = 0.4838475,
						posY = 0.6209353,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.09987397,
						sizeY = 0.1145631,
						image = "sui#jt",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top2",
					posX = 0.5,
					posY = 0.8098397,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.20625,
					sizeY = 0.07222223,
					image = "chu1#top",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hy2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5113636,
						sizeY = 0.4807692,
						image = "biaoti#miwenzhihuan",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
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
