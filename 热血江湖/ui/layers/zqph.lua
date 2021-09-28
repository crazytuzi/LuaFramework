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
				varName = "close_left",
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
						name = "zs11",
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
						name = "zs12",
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
					name = "pg",
					posX = 0.5,
					posY = 0.4849749,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.03005,
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
						name = "yxbj",
						posX = 0.260172,
						posY = 0.4559037,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5044335,
						sizeY = 0.7766613,
						image = "zqbj#zqbj",
					},
					children = {
					{
						prop = {
							etype = "Grid",
							name = "jd1",
							varName = "starRoot",
							posX = 0.5,
							posY = 0.1909538,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.7400522,
							sizeY = 0.1077586,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "xxd",
								posX = 0.0,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd2",
								posX = 0.125,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd3",
								posX = 0.25,
								posY = 0.4518357,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd4",
								posX = 0.375,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd5",
								posX = 0.5,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd6",
								posX = 0.625,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd7",
								posX = 0.75,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd8",
								posX = 0.875,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xxd9",
								posX = 1.0,
								posY = 0.4518356,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1144027,
								sizeY = 0.8348497,
								image = "zq#xxa",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx",
								varName = "star1",
								posX = 0.0,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx2",
								varName = "star2",
								posX = 0.125,
								posY = 0.4359152,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx3",
								varName = "star3",
								posX = 0.25,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx4",
								varName = "star4",
								posX = 0.375,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx5",
								varName = "star5",
								posX = 0.5,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx6",
								varName = "star6",
								posX = 0.625,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx7",
								varName = "star7",
								posX = 0.75,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx8",
								varName = "star8",
								posX = 0.875,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "xx9",
								varName = "star9",
								posX = 1.0,
								posY = 0.435915,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.1165212,
								sizeY = 0.899069,
								image = "zq#xxl",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pinjie",
							varName = "breakImage",
							posX = 0.5195009,
							posY = 0.162147,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6835937,
							sizeY = 0.2413793,
							image = "zq#tonglingjie",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "lyk",
						posX = 0.2597082,
						posY = 0.836086,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2147783,
						sizeY = 0.08536579,
						image = "wh#top",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mz",
							varName = "steed_name",
							posX = 0.5000001,
							posY = 0.4215668,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7680789,
							sizeY = 1.414115,
							text = "坐骑名称",
							color = "FFFFDF8C",
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
						etype = "Image",
						name = "zl",
						posX = 0.2567526,
						posY = 0.1350995,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2495656,
						sizeY = 0.07478362,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zl2",
							posX = 0.3401037,
							posY = 0.579102,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1381711,
							sizeY = 0.7162377,
							image = "tong#zl",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "dj2",
							varName = "pracLvlLabel",
							posX = 0.7300878,
							posY = 0.5488322,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4645474,
							sizeY = 1.529086,
							text = "50",
							color = "FFF7D54F",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA85209",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Sprite3D",
						name = "hymx",
						varName = "model",
						posX = 0.2567526,
						posY = 0.2956609,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1970443,
						sizeY = 0.4679473,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dk",
						posX = 0.7028248,
						posY = 0.5488852,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4630542,
						sizeY = 0.6801357,
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
							name = "lb",
							varName = "rank_scroll",
							posX = 0.5,
							posY = 0.4417027,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.8834055,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ding",
							posX = 0.5,
							posY = 0.9365864,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.069644,
							sizeY = 0.1330504,
							image = "phb#top4",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "wb",
								posX = 0.1532349,
								posY = 0.5064138,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3390133,
								sizeY = 1.066037,
								text = "排名",
								color = "FF966856",
								fontSize = 22,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wb2",
								posX = 0.3788097,
								posY = 0.5064139,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3390133,
								sizeY = 1.066037,
								text = "名称",
								color = "FF966856",
								fontSize = 22,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wb3",
								posX = 0.6369954,
								posY = 0.5064136,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3390133,
								sizeY = 1.066037,
								text = "职业",
								color = "FF966856",
								fontSize = 22,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wb4",
								posX = 0.8299593,
								posY = 0.5064139,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3390133,
								sizeY = 1.066037,
								text = "战力",
								color = "FF966856",
								fontSize = 22,
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
						etype = "Label",
						name = "hd",
						posX = 0.5009305,
						posY = 0.1387514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1534424,
						sizeY = 0.09867541,
						text = "超过本服",
						color = "FF82411B",
						fontSize = 22,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "tsa",
						varName = "get_stronger",
						posX = 0.8649219,
						posY = 0.140719,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.137931,
						sizeY = 0.09708266,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tsz",
							posX = 0.5,
							posY = 0.5344828,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8635832,
							sizeY = 0.8004062,
							text = "提 升",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF347468",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "hd2",
						varName = "yourRank",
						posX = 0.6268446,
						posY = 0.1387514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09836106,
						sizeY = 0.09867541,
						text = "100%",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FFC64B00",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFFFFFA0",
						colorTR = "FFFFFFA0",
						colorBR = "FFFEC353",
						colorBL = "FFFEC353",
						useQuadColor = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "hd3",
						posX = 0.7483325,
						posY = 0.1387514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1465581,
						sizeY = 0.09867541,
						text = "的玩家",
						color = "FF82411B",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.7781304,
					posY = 0.2382324,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4906404,
					sizeY = 0.4775862,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9650654,
					posY = 0.9355491,
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
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "topz",
					varName = "rankName",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7991753,
					sizeY = 0.6544847,
					text = "xxxxx排行榜",
					color = "FF764C24",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "qita",
				varName = "infoRoot",
				posX = 0.3081208,
				posY = 0.48752,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.3338273,
				sizeY = 0.6711205,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.523958,
					posY = 0.4855367,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9263806,
					sizeY = 1.045454,
					image = "b#kuang",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.7,
					scale9Bottom = 0.2,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "zzz",
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
						name = "kk3",
						posX = 0.4779423,
						posY = 0.3458513,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8650876,
						sizeY = 0.6245042,
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
							name = "top2",
							posX = 0.5,
							posY = 0.9967328,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2064128,
							sizeY = 0.07488057,
							image = "zq#xg",
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "qm10",
							varName = "attrRoot1",
							posX = 0.5,
							posY = 0.7106149,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.1560012,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dwt10",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9,
								sizeY = 0.95,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "mc8",
									varName = "nameLabel1",
									posX = 0.3403387,
									posY = 0.5000006,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.342347,
									sizeY = 1.052631,
									text = "气血：",
									color = "FF966856",
									fontSize = 22,
									fontOutlineColor = "FF27221D",
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "js6",
								varName = "attrLabel1",
								posX = 0.7075603,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4624265,
								sizeY = 0.9999994,
								text = "666（+12）",
								color = "FF966856",
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "qm11",
							varName = "attrRoot2",
							posX = 0.5000001,
							posY = 0.5618728,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.1560012,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dwt11",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9,
								sizeY = 0.95,
								image = "d#bt",
								alpha = 0.5,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "mc9",
									varName = "nameLabel2",
									posX = 0.3403387,
									posY = 0.5000006,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.342347,
									sizeY = 1.052631,
									text = "气血：",
									color = "FF966856",
									fontSize = 22,
									fontOutlineColor = "FF27221D",
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "js7",
								varName = "attrLabel2",
								posX = 0.7075601,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4624265,
								sizeY = 0.9999994,
								text = "666（+12）",
								color = "FF966856",
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "qm12",
							varName = "attrRoot3",
							posX = 0.5000001,
							posY = 0.4131306,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.1560012,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dwt12",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9,
								sizeY = 0.95,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "mc10",
									varName = "nameLabel3",
									posX = 0.3403387,
									posY = 0.5000006,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.342347,
									sizeY = 1.052631,
									text = "气血：",
									color = "FF966856",
									fontSize = 22,
									fontOutlineColor = "FF27221D",
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "js8",
								varName = "attrLabel3",
								posX = 0.7075601,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4624265,
								sizeY = 0.9999994,
								text = "666（+12）",
								color = "FF966856",
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "qm13",
							varName = "attrRoot4",
							posX = 0.5,
							posY = 0.2643885,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.1560012,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dwt13",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9,
								sizeY = 0.95,
								image = "d#bt",
								alpha = 0.5,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "mc11",
									varName = "nameLabel4",
									posX = 0.3403387,
									posY = 0.5000006,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.342347,
									sizeY = 1.052631,
									text = "气血：",
									color = "FF966856",
									fontSize = 22,
									fontOutlineColor = "FF27221D",
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "js9",
								varName = "attrLabel4",
								posX = 0.7075603,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4624265,
								sizeY = 0.9999994,
								text = "666（+12）",
								color = "FF966856",
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "qm14",
							varName = "attrRoot5",
							posX = 0.5,
							posY = 0.1156464,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.1560012,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dwt14",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9,
								sizeY = 0.95,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "mc12",
									varName = "nameLabel5",
									posX = 0.3403387,
									posY = 0.5000006,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.342347,
									sizeY = 1.052631,
									text = "气血：",
									color = "FF966856",
									fontSize = 22,
									fontOutlineColor = "FF27221D",
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "js10",
								varName = "attrLabel5",
								posX = 0.7075603,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4624265,
								sizeY = 0.9999994,
								text = "666（+12）",
								color = "FF966856",
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "top3",
							posX = 0.5,
							posY = 0.9001058,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8205876,
							sizeY = 0.1014324,
							image = "chu1#top3",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "topa2",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6128178,
								sizeY = 1.280721,
								text = "坐骑属性",
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
						name = "lyk2",
						posX = 0.4823164,
						posY = 0.8880813,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6619948,
						sizeY = 0.100956,
						image = "wh#top",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mz2",
							varName = "player_name",
							posX = 0.5,
							posY = 0.4215668,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9166319,
							sizeY = 1.414115,
							text = "玩家名字七个字",
							color = "FFFFDF8C",
							fontSize = 22,
							fontOutlineColor = "FF102E21",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd2",
						varName = "starRoot2",
						posX = 0.4797899,
						posY = 0.7897573,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.861497,
						sizeY = 0.08907884,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xxd6",
							posX = 0.0,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd7",
							posX = 0.125,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd8",
							posX = 0.25,
							posY = 0.4518357,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd9",
							posX = 0.375,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd10",
							posX = 0.5,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd11",
							posX = 0.625,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd12",
							posX = 0.75,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd13",
							posX = 0.875,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xxd14",
							posX = 1.0,
							posY = 0.4518356,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1144027,
							sizeY = 0.8348497,
							image = "zq#xxa",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx6",
							varName = "star6",
							posX = 0.0,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx7",
							varName = "star7",
							posX = 0.125,
							posY = 0.4359152,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx8",
							varName = "star8",
							posX = 0.25,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx9",
							varName = "star9",
							posX = 0.375,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx10",
							varName = "star10",
							posX = 0.5,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx11",
							varName = "star11",
							posX = 0.625,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx12",
							varName = "star12",
							posX = 0.75,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx13",
							varName = "star13",
							posX = 0.875,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx14",
							varName = "star14",
							posX = 1.0,
							posY = 0.435915,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1165212,
							sizeY = 0.899069,
							image = "zq#xxl",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zl3",
						posX = 0.4812157,
						posY = 0.6923634,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6399257,
						sizeY = 0.08844125,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zl4",
							posX = 0.3401037,
							posY = 0.579102,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1381711,
							sizeY = 0.7162377,
							image = "tong#zl",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "dj3",
							varName = "pracLvlLabel2",
							posX = 0.7300878,
							posY = 0.5488322,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4645474,
							sizeY = 1.529086,
							text = "50",
							color = "FFF7D54F",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA85209",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tlj",
						varName = "breakImage2",
						posX = 0.4797835,
						posY = 0.7806306,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8841925,
						sizeY = 0.2217073,
						image = "zq#tonglingjie",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
