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
				name = "dt2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6614141,
				sizeY = 0.626698,
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
					name = "pg",
					posX = 0.5,
					posY = 0.4849749,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.03005,
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
					name = "z1",
					posX = 0.2435735,
					posY = 0.4739102,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4583079,
					sizeY = 0.9296713,
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
						name = "dz",
						posX = 0.4690724,
						posY = 0.4980876,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.056679,
						sizeY = 0.7497675,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "bgt",
							posX = 0.5388772,
							posY = 0.3314418,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.248781,
							sizeY = 1.475269,
							image = "zqbj#zqbj",
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd1",
						varName = "starRoot",
						posX = 1.56781,
						posY = 0.6830264,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.046968,
						sizeY = 0.1244416,
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
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx",
					varName = "horse_module",
					posX = 0.2386241,
					posY = 0.110276,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2045898,
					sizeY = 0.5762123,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mzd",
					posX = 0.7350917,
					posY = 0.8736893,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3295496,
					sizeY = 0.1108101,
					image = "chu1#zld",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zlt",
						posX = 0.2564197,
						posY = -0.5956527,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.125448,
						sizeY = 0.6400001,
						image = "tong#zl",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zl",
						varName = "battle_power",
						posX = 0.5930341,
						posY = -0.6,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7138616,
						sizeY = 1.061954,
						text = "45678",
						color = "FFFFE7AF",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB2722C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "horse_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6708811,
						sizeY = 1.003626,
						text = "坐骑名字",
						color = "FF966856",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9592167,
					posY = 0.9356079,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07677679,
					sizeY = 0.1396207,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.001869,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3118319,
					sizeY = 0.1152425,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ph",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3787879,
						sizeY = 0.4807693,
						image = "biaoti#phb",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.7308936,
					posY = 0.2937822,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4792443,
					sizeY = 0.5230644,
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
						name = "kk2",
						posX = 0.4926195,
						posY = 0.4976998,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.229873,
						sizeY = 1.038437,
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
									posX = 0.4311903,
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
								posX = 0.7381392,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3600475,
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
									posX = 0.4311903,
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
								posX = 0.7381392,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3600475,
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
									posX = 0.4311903,
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
								posX = 0.7381392,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3600475,
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
									posX = 0.4311903,
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
								posX = 0.7381392,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3600475,
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
									posX = 0.4311903,
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
								posX = 0.7381392,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3600475,
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
							posY = 0.9031136,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5631261,
							sizeY = 0.1305641,
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.7087255,
					posY = 0.2403404,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5882282,
					sizeY = 0.517639,
					image = "hua1#hua1",
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
	kuang = {
		kuang = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l = {
		l = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l2 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l2 = {
		l3 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l4 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	kuang2 = {
		kuang2 = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l3 = {
		l5 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l6 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l4 = {
		l7 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l8 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_kuang = {
		{0,"kuang", -1, 0},
		{2,"lizi", 1, 0},
		{2,"lizi2", 1, 0},
		{2,"lizi3", 1, 0},
		{2,"lizi4", 1, 0},
		{0,"l", -1, 0},
		{0,"l2", -1, 500},
	},
	c_kuang2 = {
		{2,"lizi5", 1, 0},
		{2,"lizi6", 1, 0},
		{2,"lizi7", 1, 0},
		{2,"lizi8", 1, 0},
		{0,"kuang2", -1, 0},
		{0,"l3", -1, 0},
		{0,"l4", -1, 500},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
