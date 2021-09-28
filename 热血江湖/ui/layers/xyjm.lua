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
						sizeX = 0.9507388,
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
					etype = "Grid",
					name = "jd",
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
						name = "bj",
						posX = 0.3565366,
						posY = 0.4926235,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6279737,
						sizeY = 0.8630288,
						image = "xingpanbj#xingpanbj",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dt2",
							posX = 0.3580195,
							posY = 0.6336086,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6636405,
							sizeY = 0.7291881,
							image = "xigpand#xinpand",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "fh",
							varName = "starBg",
							posX = 0.3580195,
							posY = 0.6176262,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.6970084,
							sizeY = 0.7479363,
							image = "xplan#lan",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "sm",
							varName = "additionText",
							posX = 0.3564506,
							posY = 0.2044353,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6249602,
							sizeY = 0.1376202,
							text = "本档位。。。。\n本档位。。。。",
							fontOutlineColor = "FF008080",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "starScroll",
						posX = 0.2673766,
						posY = 0.5957201,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3924586,
						sizeY = 0.5972943,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dw",
						posX = 0.7206892,
						posY = 0.4926235,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4650246,
						sizeY = 0.8630288,
						image = "b#d5",
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
							name = "sxlb",
							varName = "propScroll",
							posX = 0.5,
							posY = 0.701831,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.3625338,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pb",
							posX = 0.5021155,
							posY = 0.385935,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.2852124,
							image = "b#xpd",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
							scale9Top = 0.45,
							scale9Bottom = 0.45,
						},
						children = {
						{
							prop = {
								etype = "RichText",
								name = "ts2",
								varName = "propText",
								posX = 0.5051525,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.923017,
								sizeY = 1,
								text = "#身法豁免几率提升15%\n#造成伤害时10%忽视对方防御",
								color = "FF966856",
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bt",
							posX = 0.5,
							posY = 0.936797,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5911017,
							sizeY = 0.09988878,
							image = "xingpan#zld",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zl",
								posX = 0.2696738,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.125448,
								sizeY = 0.64,
								image = "tong#zl",
							},
						},
						{
							prop = {
								etype = "Label",
								name = "zlz",
								varName = "powerText",
								posX = 0.7007152,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6,
								sizeY = 0.9080371,
								text = "55555",
								color = "FFFFE7AF",
								fontSize = 22,
								fontOutlineEnable = true,
								fontOutlineColor = "FFB2722C",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "te1",
						varName = "lead",
						posX = 0.7206851,
						posY = 0.2278147,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4650246,
						sizeY = 0.3241053,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "yjzb",
							varName = "leadBtn",
							posX = 0.5,
							posY = 0.2022048,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.3072034,
							sizeY = 0.2925827,
							image = "chu1#an1",
							imageNormal = "chu1#an1",
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "ys2",
								posX = 0.5,
								posY = 0.5181818,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9120977,
								sizeY = 1.156784,
								text = "设为引导",
								fontSize = 22,
								fontOutlineEnable = true,
								fontOutlineColor = "FFB35F1D",
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
						etype = "Grid",
						name = "te2",
						varName = "use",
						posX = 0.7206851,
						posY = 0.2278147,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4650246,
						sizeY = 0.3241053,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ts3",
							varName = "useText",
							posX = 0.5,
							posY = 0.4842691,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8686673,
							sizeY = 0.4568602,
							text = "星耀已启动，可以装备此星耀",
							color = "FF65944D",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "plcs2",
							varName = "useBtn",
							posX = 0.5,
							posY = 0.2022047,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.3072034,
							sizeY = 0.2925827,
							image = "chu1#an2",
							imageNormal = "chu1#an2",
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "ys4",
								varName = "useBtnText",
								posX = 0.5,
								posY = 0.5151515,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9120977,
								sizeY = 1.156784,
								text = "装备星耀",
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
						etype = "Button",
						name = "plcs3",
						varName = "lockBtn",
						posX = 0.2688505,
						posY = 0.1312977,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1428572,
						sizeY = 0.09482758,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys5",
							posX = 0.5,
							posY = 0.5181818,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "直接启动",
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
					etype = "Button",
					name = "gb",
					varName = "close",
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
					etype = "Label",
					name = "w",
					varName = "starName",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					text = "朱雀之怒",
					color = "FF7F4920",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
