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
			scale9Left = 0.1,
			scale9Right = 0.1,
			scale9Top = 0.1,
			scale9Bottom = 0.1,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "bgBtn",
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
			sizeX = 0.7,
			sizeY = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.45,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.85,
				sizeY = 0.8,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.01,
					sizeY = 1.02,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hehua",
						posX = 0.7374876,
						posY = 0.3470826,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6474124,
						sizeY = 0.6735333,
						image = "hua1#hua1",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sqxx",
					varName = "fujin",
					posX = 0.4993737,
					posY = 0.4844649,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9450951,
					sizeY = 0.562073,
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
						name = "lbt",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.98,
						sizeY = 0.94,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wza",
						varName = "noApply",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.8832758,
						sizeY = 0.7440081,
						text = "暂时还没有玩家愿意加入您的麾下",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF69360B",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wddw",
					varName = "teamInfo",
					posX = 0.4993737,
					posY = 0.4844649,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9450951,
					sizeY = 0.562073,
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
						name = "rw7",
						varName = "addPlayer4",
						posX = 0.8679118,
						posY = 0.4985627,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.1486556,
						sizeY = 0.4721397,
						image = "dw#dw_jia.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj11",
							varName = "addBtn4",
							posX = 0.4904645,
							posY = 0.507686,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510792,
							sizeY = 0.954426,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "rw6",
						varName = "addPlayer3",
						posX = 0.6217541,
						posY = 0.4985628,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.1486556,
						sizeY = 0.4721397,
						image = "dw#dw_jia.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj10",
							varName = "addBtn3",
							posX = 0.4904645,
							posY = 0.507686,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510792,
							sizeY = 0.954426,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "rw5",
						varName = "addPlayer2",
						posX = 0.3755963,
						posY = 0.4985627,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.1486556,
						sizeY = 0.4721397,
						image = "dw#dw_jia.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj9",
							varName = "addBtn2",
							posX = 0.4904645,
							posY = 0.507686,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510792,
							sizeY = 0.954426,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "rw1",
						varName = "player1",
						posX = 0.1294385,
						posY = 0.4985628,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2472962,
						sizeY = 0.9222168,
						image = "dw#dw_d1.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj1",
							varName = "playerBtn1",
							posX = 0.4910978,
							posY = 0.5029467,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510792,
							sizeY = 0.954426,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ddt7",
							posX = 0.5,
							posY = 0.1072442,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.911204,
							sizeY = 0.1706162,
							image = "b#d5",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							alpha = 0.3,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "txk",
							varName = "iconType1",
							posX = 0.5,
							posY = 0.6062335,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8258428,
							sizeY = 0.5645933,
							image = "zdtx#txd",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx",
								varName = "icon1",
								posX = 0.5054789,
								posY = 0.6925332,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.7210885,
								sizeY = 1.110169,
								image = "jstx#nan_lian2_tou2_fase3",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "zyb",
								varName = "type1",
								posX = 0.9276423,
								posY = 0.9961644,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.3061225,
								sizeY = 0.3813559,
								image = "zy#daoke",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djd",
								posX = 0.8002977,
								posY = 0.255477,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.2857143,
								sizeY = 0.3644068,
								image = "zdte#djd2",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "dj",
									varName = "levelLabel1",
									posX = 0.5,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.9174806,
									sizeY = 1.368822,
									text = "30",
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
							name = "dzb",
							posX = 0.2642883,
							posY = 0.8730481,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.522472,
							sizeY = 0.291866,
							image = "dw#lsdz",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz1",
							varName = "nameLabel1",
							posX = 0.5,
							posY = 0.2551125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.006999,
							sizeY = 0.1614683,
							text = "我是一个大大棒槌",
							color = "FF966856",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zl1",
							posX = 0.2256062,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3273922,
							sizeY = 0.1624278,
							text = "战力:",
							color = "FFC93034",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zlz1",
							varName = "powerLabel1",
							posX = 0.7091287,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6297794,
							sizeY = 0.1624278,
							text = "12134569",
							color = "FFC93034",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "rw2",
						varName = "player2",
						posX = 0.3755963,
						posY = 0.4985627,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2472962,
						sizeY = 0.9222168,
						image = "dw#dw_d1.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj2",
							varName = "playerBtn2",
							posX = 0.4910978,
							posY = 0.5029467,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510792,
							sizeY = 0.954426,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ddt6",
							posX = 0.5,
							posY = 0.1072442,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.911204,
							sizeY = 0.1706162,
							image = "b#d5",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							alpha = 0.3,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "txk2",
							varName = "iconType2",
							posX = 0.5,
							posY = 0.6062335,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8258428,
							sizeY = 0.5645933,
							image = "zdtx#txd",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx2",
								varName = "icon2",
								posX = 0.5054789,
								posY = 0.6925332,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.7210885,
								sizeY = 1.110169,
								image = "jstx#nan_lian3_tou3_fase2",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "zyb2",
								varName = "type2",
								posX = 0.9450341,
								posY = 0.9961644,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.3061225,
								sizeY = 0.3813559,
								image = "zy#daoke",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djd2",
								posX = 0.8002977,
								posY = 0.2554773,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.2857143,
								sizeY = 0.3644068,
								image = "zdte#djd2",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "dj3",
									varName = "levelLabel2",
									posX = 0.5,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.9174806,
									sizeY = 1.368822,
									text = "30",
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
							etype = "Label",
							name = "mz2",
							varName = "nameLabel2",
							posX = 0.5,
							posY = 0.2551125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.006999,
							sizeY = 0.1614683,
							text = "我是一个大大棒槌",
							color = "FF966856",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zl2",
							posX = 0.2256062,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3273922,
							sizeY = 0.1624278,
							text = "战力:",
							color = "FFC93034",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zlz2",
							varName = "powerLabel2",
							posX = 0.7091287,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6297794,
							sizeY = 0.1624278,
							text = "12134569",
							color = "FFC93034",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "rw3",
						varName = "player3",
						posX = 0.6217541,
						posY = 0.4985627,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2472962,
						sizeY = 0.9222168,
						image = "dw#dw_d1.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj4",
							varName = "playerBtn3",
							posX = 0.4910978,
							posY = 0.5029467,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510792,
							sizeY = 0.954426,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ddt5",
							posX = 0.5,
							posY = 0.1072442,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.911204,
							sizeY = 0.1706162,
							image = "b#d5",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							alpha = 0.3,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "txk3",
							varName = "iconType3",
							posX = 0.5,
							posY = 0.6062335,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8258428,
							sizeY = 0.5645933,
							image = "zdtx#txd",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx3",
								varName = "icon3",
								posX = 0.5054789,
								posY = 0.6925332,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.7210885,
								sizeY = 1.110169,
								image = "jstx#nan_lian2_tou2_fase3",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "zyb3",
								varName = "type3",
								posX = 0.9276423,
								posY = 0.9961644,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.3061225,
								sizeY = 0.3813559,
								image = "zy#daoke",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djd3",
								posX = 0.8002977,
								posY = 0.2554773,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.2857143,
								sizeY = 0.3644068,
								image = "zdte#djd2",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "dj5",
									varName = "levelLabel3",
									posX = 0.5,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.9174806,
									sizeY = 1.368822,
									text = "30",
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
							etype = "Label",
							name = "mz3",
							varName = "nameLabel3",
							posX = 0.5,
							posY = 0.2551125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.006999,
							sizeY = 0.1614683,
							text = "我是一个大大棒槌",
							color = "FF966856",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zl3",
							posX = 0.2256062,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3273922,
							sizeY = 0.1624278,
							text = "战力:",
							color = "FFC93034",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zlz3",
							varName = "powerLabel3",
							posX = 0.7091287,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6297794,
							sizeY = 0.1624278,
							text = "12134569",
							color = "FFC93034",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "rw4",
						varName = "player4",
						posX = 0.8679118,
						posY = 0.4985628,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2472962,
						sizeY = 0.9222168,
						image = "dw#dw_d1.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj6",
							varName = "playerBtn4",
							posX = 0.4910978,
							posY = 0.5029467,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510792,
							sizeY = 0.954426,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ddt4",
							posX = 0.5,
							posY = 0.1072442,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.911204,
							sizeY = 0.1706162,
							image = "b#d5",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							alpha = 0.3,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "txk4",
							varName = "iconType4",
							posX = 0.5,
							posY = 0.6062335,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8258428,
							sizeY = 0.5645933,
							image = "zdtx#txd",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx4",
								varName = "icon4",
								posX = 0.5054789,
								posY = 0.6925332,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.7210885,
								sizeY = 1.110169,
								image = "jstx#nan_lian2_tou2_fase3",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "zyb4",
								varName = "type4",
								posX = 0.9276423,
								posY = 0.9757572,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.3061225,
								sizeY = 0.3813559,
								image = "zy#daoke",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djd4",
								posX = 0.8002977,
								posY = 0.255477,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.2857143,
								sizeY = 0.3644068,
								image = "zdte#djd2",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "dj7",
									varName = "levelLabel4",
									posX = 0.5,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.9174806,
									sizeY = 1.368822,
									text = "30",
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
							etype = "Label",
							name = "mz4",
							varName = "nameLabel4",
							posX = 0.5,
							posY = 0.2551125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.006999,
							sizeY = 0.1614683,
							text = "我是一个大大棒槌",
							color = "FF966856",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zl4",
							posX = 0.2256062,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3273922,
							sizeY = 0.1624278,
							text = "战力:",
							color = "FFC93034",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "zlz4",
							varName = "powerLabel4",
							posX = 0.7091287,
							posY = 0.1070361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6297794,
							sizeY = 0.1624278,
							text = "12134569",
							color = "FFC93034",
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
					name = "a1",
					varName = "myTeamBtn",
					posX = 0.1422988,
					posY = 0.8456529,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2022059,
					sizeY = 0.1438492,
					image = "chu1#fy1",
					imageNormal = "chu1#fy1",
					imagePressed = "chu1#fy2",
					imageDisable = "chu1#fy1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dsa",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8042395,
						sizeY = 0.7393813,
						text = "我的队伍",
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
					name = "a2",
					varName = "applyInfoBtn",
					posX = 0.3568547,
					posY = 0.8456529,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2022059,
					sizeY = 0.1438492,
					image = "chu1#fy1",
					imageNormal = "chu1#fy1",
					imagePressed = "chu1#fy2",
					imageDisable = "chu1#fy1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xhd",
						varName = "haveApply",
						posX = 0.9392969,
						posY = 0.7811786,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1588235,
						sizeY = 0.4912282,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dsa2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8042395,
						sizeY = 0.7393813,
						text = "申请资讯",
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
					name = "a3",
					varName = "mateBtn",
					posX = 0.7898394,
					posY = 0.1012472,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2284664,
					sizeY = 0.1636905,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						varName = "mateLabel",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9196994,
						sizeY = 0.8712597,
						text = "开始匹配",
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
					etype = "Button",
					name = "sx",
					varName = "refreshBtn",
					posX = 0.8318107,
					posY = 0.8456529,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1497625,
					sizeY = 0.1864055,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "sad",
						posX = 0.6742027,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3857649,
						sizeY = 0.5455124,
						image = "te#sx",
						imageNormal = "te#sx",
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a5",
					varName = "quitRoom",
					posX = 0.2005979,
					posY = 0.1012472,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2284664,
					sizeY = 0.1636905,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "quitLabel",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9196994,
						sizeY = 0.8712597,
						text = "离开房间",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
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
					name = "dwbh6",
					varName = "waitLabel",
					posX = 0.7484289,
					posY = 0.8456531,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3780743,
					sizeY = 0.1461784,
					text = "已等待10分20秒",
					color = "FFC93034",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.4999991,
				posY = 0.8553224,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2946429,
				sizeY = 0.1031746,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dwbh2",
					varName = "teamId",
					posX = 0.1155347,
					posY = 0.6041471,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.08142906,
					sizeY = 0.8954078,
					text = "123.",
					fontSize = 22,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dwbh3",
					varName = "teamName",
					posX = 0.3402771,
					posY = 0.6041465,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3402777,
					sizeY = 0.8954078,
					text = "什么什么的队伍",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gg2",
					varName = "titleIcon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5113636,
					sizeY = 0.4807693,
					image = "biaoti#hwfj",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.9086128,
				posY = 0.7908078,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07477678,
				sizeY = 0.1507937,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
