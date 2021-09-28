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
						posX = 0.4832516,
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
						etype = "Button",
						name = "qh9",
						varName = "wuhunBtn",
						posX = 0.9672412,
						posY = 0.7623994,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09753694,
						sizeY = 0.2637931,
						image = "tong#yq1",
						imageNormal = "tong#yq1",
						imagePressed = "chu1#yq2",
						imageDisable = "tong#yq1",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dsa",
							posX = 0.499558,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3136712,
							sizeY = 0.8094339,
							text = "武魂",
							color = "FFEBC6B4",
							fontSize = 26,
							fontOutlineColor = "FF51361C",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "qh10",
						varName = "xingyaoBtn",
						posX = 0.9672412,
						posY = 0.5601734,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09753694,
						sizeY = 0.2637931,
						image = "tong#yq1",
						imageNormal = "tong#yq1",
						imagePressed = "chu1#yq2",
						imageDisable = "tong#yq1",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dsa2",
							posX = 0.499558,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3136712,
							sizeY = 0.8094339,
							text = "星耀",
							color = "FFEBC6B4",
							fontSize = 26,
							fontOutlineColor = "FF51361C",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "qh11",
						varName = "shendouBtn",
						posX = 0.9672412,
						posY = 0.3579474,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09753694,
						sizeY = 0.2637931,
						image = "tong#yq1",
						imageNormal = "tong#yq1",
						imagePressed = "chu1#yq2",
						imageDisable = "tong#yq1",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dsa3",
							posX = 0.499558,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3136712,
							sizeY = 0.8094339,
							text = "天枢",
							color = "FFEBC6B4",
							fontSize = 26,
							fontOutlineColor = "FF51361C",
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
						name = "dw",
						posX = 0.8015734,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.237274,
						sizeY = 0.8692617,
						image = "b#d2",
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
							name = "to1",
							posX = 0.5,
							posY = 0.9502074,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.9979296,
							sizeY = 0.07803866,
							image = "xingpan#zld",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zl",
								posX = 0.2539807,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.125448,
								sizeY = 0.6399999,
								image = "tong#zl",
							},
						},
						{
							prop = {
								etype = "Label",
								name = "zlz",
								varName = "powerText",
								posX = 0.6727828,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6,
								sizeY = 1.003204,
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
					{
						prop = {
							etype = "Scroll",
							name = "sxlb",
							varName = "propScroll",
							posX = 0.5,
							posY = 0.4505439,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.9029716,
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
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5151516,
					sizeY = 0.4807692,
					image = "biaoti#xyxx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "xp",
				varName = "starRoot",
				posX = 0.3903864,
				posY = 0.4788387,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.559204,
				sizeY = 0.6968052,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9152036,
					sizeY = 1,
					image = "xingpanbj#xingpanbj",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dt2",
						posX = 0.3597977,
						posY = 0.4882196,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6457173,
						sizeY = 0.7275268,
						image = "xigpand#xinpand",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "fh",
							varName = "starBg",
							posX = 0.5,
							posY = 0.4808221,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.8144065,
							sizeY = 0.9934945,
							image = "xplan#lan",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "xlb",
					varName = "starScroll",
					posX = 0.3703336,
					posY = 0.4726598,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5481494,
					sizeY = 0.6925042,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd1",
					varName = "part1",
					posX = 0.7366825,
					posY = 0.863058,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd2",
					varName = "part8",
					posX = 0.7366824,
					posY = 0.6252742,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd3",
					varName = "part7",
					posX = 0.7366825,
					posY = 0.3866473,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd4",
					varName = "part6",
					posX = 0.7366825,
					posY = 0.1480204,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd5",
					varName = "part2",
					posX = 0.8743505,
					posY = 0.8630579,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd6",
					varName = "part3",
					posX = 0.8743505,
					posY = 0.6252742,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd7",
					varName = "part4",
					posX = 0.8743505,
					posY = 0.3866473,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd8",
					varName = "part5",
					posX = 0.8743505,
					posY = 0.1480204,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1397075,
					sizeY = 0.1993224,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top1",
					posX = 0.3716863,
					posY = 0.8960017,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.297577,
					sizeY = 0.08969508,
					image = "xingpan#top",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ztz",
						varName = "starName",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6039791,
						sizeY = 0.7979075,
						text = "绿龙之原谅",
						color = "FFF1E9D7",
						fontOutlineColor = "FFC04000",
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
	gy55 = {
	},
	gy56 = {
	},
	gy57 = {
	},
	gy58 = {
	},
	gy59 = {
	},
	gy60 = {
	},
	gy61 = {
	},
	gy62 = {
	},
	gy63 = {
	},
	gy64 = {
	},
	gy65 = {
	},
	gy66 = {
	},
	gy67 = {
	},
	gy68 = {
	},
	gy69 = {
	},
	gy70 = {
	},
	gy71 = {
	},
	gy72 = {
	},
	gy73 = {
	},
	gy74 = {
	},
	gy75 = {
	},
	gy76 = {
	},
	gy77 = {
	},
	gy78 = {
	},
	gy79 = {
	},
	gy80 = {
	},
	gy81 = {
	},
	gy82 = {
	},
	gy83 = {
	},
	gy84 = {
	},
	gy85 = {
	},
	gy86 = {
	},
	gy87 = {
	},
	gy88 = {
	},
	gy89 = {
	},
	gy90 = {
	},
	gy91 = {
	},
	gy92 = {
	},
	gy93 = {
	},
	gy94 = {
	},
	gy95 = {
	},
	gy96 = {
	},
	gy97 = {
	},
	gy98 = {
	},
	gy99 = {
	},
	gy100 = {
	},
	gy101 = {
	},
	gy102 = {
	},
	gy103 = {
	},
	gy104 = {
	},
	gy105 = {
	},
	gy106 = {
	},
	gy107 = {
	},
	gy108 = {
	},
	gy109 = {
	},
	gy110 = {
	},
	gy111 = {
	},
	gy112 = {
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
