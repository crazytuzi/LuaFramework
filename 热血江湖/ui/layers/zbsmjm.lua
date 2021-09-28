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
				name = "dt3",
				posX = 0.3599926,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.26875,
				sizeY = 0.9,
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
					name = "wk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.03,
					sizeY = 1.03,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz8",
					varName = "nameLabel",
					posX = 0.7228652,
					posY = 0.9561474,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.802144,
					sizeY = 0.06800295,
					text = "名字写六七个字",
					color = "FFCE81FF",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zbd2",
					varName = "gradeIcon",
					posX = 0.1723413,
					posY = 0.9082684,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2758618,
					sizeY = 0.1481481,
					image = "djk#kzi",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zbt2",
						varName = "icon",
						posX = 0.4894737,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8241493,
						sizeY = 0.8155648,
						image = "ls#ls_jinggangtoukui.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zld2",
					posX = 0.4385176,
					posY = 0.8867689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8072587,
					sizeY = 0.04938272,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zhandouli1",
						posX = 0.4103827,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1258993,
						sizeY = 0.9999999,
						image = "tong#zl",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zl4",
						varName = "powerLabel",
						posX = 0.8376921,
						posY = 0.4814698,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6562645,
						sizeY = 1.177395,
						text = "12345+12345",
						color = "FFFFD97F",
						fontOutlineEnable = true,
						fontOutlineColor = "FF895F30",
						fontOutlineSize = 2,
						vTextAlign = 1,
						colorTL = "FFF3EE30",
						colorTR = "FFF3EE30",
						colorBR = "FFE77676",
						colorBL = "FFE77676",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz9",
					varName = "levelLabel",
					posX = 0.8416829,
					posY = 0.8205273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.337496,
					sizeY = 0.05553387,
					text = "Lv.20",
					color = "FF029133",
					fontSize = 22,
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz11",
					varName = "typeLabel",
					posX = 0.7177647,
					posY = 0.8205273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.337496,
					sizeY = 0.06323721,
					text = "武器",
					color = "FF966856",
					fontOutlineColor = "FF400000",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk2",
					posX = 0.5,
					posY = 0.5250415,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9367711,
					sizeY = 0.5122869,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb3",
					varName = "scroll",
					posX = 0.5,
					posY = 0.5077152,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.95,
					sizeY = 0.5269111,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz12",
					varName = "zhiyeLabel",
					posX = 0.2408305,
					posY = 0.8205273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.337496,
					sizeY = 0.06323721,
					text = "职业",
					color = "FF966856",
					fontOutlineColor = "FF400000",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz14",
					varName = "transLabel",
					posX = 0.3998086,
					posY = 0.8205274,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.337496,
					sizeY = 0.06323721,
					text = "几转",
					color = "FF966856",
					fontOutlineColor = "FF400000",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz13",
					posX = 0.2456782,
					posY = 0.2258953,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.337496,
					sizeY = 0.06323721,
					text = "售价",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF400000",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "srd",
					posX = 0.5739307,
					posY = 0.221621,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6792828,
					sizeY = 0.07632804,
					image = "b#srk",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "EditBox",
						name = "srz",
						sizeXAB = 170.2286,
						sizeYAB = 35.98783,
						posXAB = 135.0897,
						posYAB = 17.97995,
						varName = "priceInput",
						posX = 0.5781137,
						posY = 0.3635209,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7284898,
						sizeY = 0.7276064,
						color = "FFFFF4E4",
						fontSize = 24,
						phText = "输入价格",
						phColor = "FFFFF4E4",
						phFontSize = 24,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yub",
						posX = 0.124105,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.213974,
						sizeY = 1.010906,
						image = "tb#yuanbao",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gh",
					varName = "putOnBtn",
					posX = 0.7394708,
					posY = 0.04815344,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3575581,
					sizeY = 0.08950617,
					image = "chu1#an4",
					imageNormal = "chu1#an4",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z1",
						posX = 0.5,
						posY = 0.5344827,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7268257,
						sizeY = 1.102202,
						text = "上 架",
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
			{
				prop = {
					etype = "Button",
					name = "gh2",
					varName = "cancel",
					posX = 0.2489432,
					posY = 0.04815344,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3575581,
					sizeY = 0.08950617,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						posX = 0.5,
						posY = 0.5344827,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7268257,
						sizeY = 1.102202,
						text = "取 消",
						fontSize = 22,
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
					name = "mz10",
					varName = "PriceRange",
					posX = 0.5,
					posY = 0.1164438,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8319283,
					sizeY = 0.05553387,
					text = "价格区间",
					color = "FFC93034",
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "llb1",
					varName = "nScroll",
					posX = 0.4220498,
					posY = 0.7511693,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6796776,
					sizeY = 0.04938272,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz21",
					varName = "bwLabel",
					posX = 0.5587866,
					posY = 0.8205273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.337496,
					sizeY = 0.06323721,
					text = "正",
					color = "FF966856",
					fontOutlineColor = "FF400000",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz22",
					varName = "noLimit",
					posX = 0.5,
					posY = 0.156567,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8319283,
					sizeY = 0.05553387,
					text = "最大出售价格无限制",
					color = "FF65944D",
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "rightRoot",
				posX = 0.6384438,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.26875,
				sizeY = 0.9,
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
					name = "wk3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.03,
					sizeY = 1.03,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz15",
					posX = 0.4793828,
					posY = 0.9453835,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.802144,
					sizeY = 0.06800295,
					text = "其他玩家售价（仅供参考）",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF400000",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "wj1",
					varName = "root1",
					posX = 0.5,
					posY = 0.8258522,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.1635803,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ds1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.943396,
						image = "d#tyd",
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zbd3",
							varName = "gradeIcon1",
							posX = 0.1803828,
							posY = 0.47,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2358239,
							sizeY = 0.8197734,
							image = "djk#kzi",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zbt3",
								varName = "icon1",
								posX = 0.4894737,
								posY = 0.5416668,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8241493,
								sizeY = 0.8155648,
								image = "ls#ls_jinggangtoukui.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz16",
							varName = "nameLabel1",
							posX = 0.6237537,
							posY = 0.717141,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5684682,
							sizeY = 0.3645737,
							text = "名字写六七个字",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "yb",
							posX = 0.4070948,
							posY = 0.3202222,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1453488,
							sizeY = 0.5,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "sl",
								varName = "priceLabel1",
								posX = 2.382414,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 2.328578,
								sizeY = 0.8138098,
								text = "6545",
								color = "FF966856",
								fontSize = 22,
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
						name = "dj1",
						varName = "btn1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "wj2",
					varName = "root2",
					posX = 0.5,
					posY = 0.645593,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.1635803,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ds2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.943396,
						image = "d#tyd",
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zbd4",
							varName = "gradeIcon2",
							posX = 0.1803828,
							posY = 0.47,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2358239,
							sizeY = 0.8197734,
							image = "djk#kzi",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zbt4",
								varName = "icon2",
								posX = 0.4894737,
								posY = 0.5416668,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8241493,
								sizeY = 0.8155648,
								image = "ls#ls_jinggangtoukui.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz17",
							varName = "nameLabel2",
							posX = 0.6237537,
							posY = 0.717141,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5684682,
							sizeY = 0.3645737,
							text = "名字写六七个字",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "yb2",
							posX = 0.4070948,
							posY = 0.3202222,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1453488,
							sizeY = 0.5,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "sl2",
								varName = "priceLabel2",
								posX = 2.382414,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 2.328578,
								sizeY = 0.8138098,
								text = "6545",
								color = "FF966856",
								fontSize = 22,
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
						name = "dj2",
						varName = "btn2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "wj3",
					varName = "root3",
					posX = 0.5,
					posY = 0.4653338,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.1635803,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ds3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.943396,
						image = "d#tyd",
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zbd5",
							varName = "gradeIcon3",
							posX = 0.1803828,
							posY = 0.47,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2358239,
							sizeY = 0.8197734,
							image = "djk#kzi",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zbt5",
								varName = "icon3",
								posX = 0.4894737,
								posY = 0.5416668,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8241493,
								sizeY = 0.8155648,
								image = "ls#ls_jinggangtoukui.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz18",
							varName = "nameLabel3",
							posX = 0.6237537,
							posY = 0.717141,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5684682,
							sizeY = 0.3645737,
							text = "名字写六七个字",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "yb3",
							posX = 0.4070948,
							posY = 0.3202222,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1453488,
							sizeY = 0.5,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "sl3",
								varName = "priceLabel3",
								posX = 2.382414,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 2.328578,
								sizeY = 0.8138098,
								text = "6545",
								color = "FF966856",
								fontSize = 22,
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
						name = "dj3",
						varName = "btn3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "wj4",
					varName = "root4",
					posX = 0.5,
					posY = 0.2850745,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.1635803,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ds4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.943396,
						image = "d#tyd",
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zbd6",
							varName = "gradeIcon4",
							posX = 0.1803828,
							posY = 0.47,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2358239,
							sizeY = 0.8197734,
							image = "djk#kzi",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zbt6",
								varName = "icon4",
								posX = 0.4894737,
								posY = 0.5416668,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8241493,
								sizeY = 0.8155648,
								image = "ls#ls_jinggangtoukui.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz19",
							varName = "nameLabel4",
							posX = 0.6237537,
							posY = 0.717141,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5684682,
							sizeY = 0.3645737,
							text = "名字写六七个字",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "yb4",
							posX = 0.4070948,
							posY = 0.3202222,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1453488,
							sizeY = 0.5,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "sl4",
								varName = "priceLabel4",
								posX = 2.382414,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 2.328578,
								sizeY = 0.8138098,
								text = "6545",
								color = "FF966856",
								fontSize = 22,
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
						name = "dj4",
						varName = "btn4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "wj6",
					varName = "root5",
					posX = 0.5,
					posY = 0.1048153,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.1635803,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ds5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.943396,
						image = "d#tyd",
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zbd7",
							varName = "gradeIcon5",
							posX = 0.1803828,
							posY = 0.47,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2358239,
							sizeY = 0.8197734,
							image = "djk#kzi",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zbt7",
								varName = "icon5",
								posX = 0.4894737,
								posY = 0.5416668,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8241493,
								sizeY = 0.8155648,
								image = "ls#ls_jinggangtoukui.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz20",
							varName = "nameLabel5",
							posX = 0.6237537,
							posY = 0.717141,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5684682,
							sizeY = 0.3645737,
							text = "名字写六七个字",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "yb5",
							posX = 0.4070948,
							posY = 0.3202222,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1453488,
							sizeY = 0.5,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "sl5",
								varName = "priceLabel5",
								posX = 2.382414,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 2.328578,
								sizeY = 0.8138098,
								text = "6545",
								color = "FF966856",
								fontSize = 22,
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
						name = "dj5",
						varName = "btn5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
