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
				posY = 0.5,
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
					etype = "Grid",
					name = "xiaozu",
					varName = "xiaozu",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1,
					sizeY = 1,
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
						sizeX = 1.046305,
						sizeY = 1.194828,
						image = "sjbbj2#sjbbj2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "xiaozu_content",
						posX = 0.4921299,
						posY = 0.413074,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9501638,
						sizeY = 0.7556543,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz",
						posX = 0.3209993,
						posY = -0.04228934,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "当前已竞猜：",
						color = "FF00FF00",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz2",
						varName = "count",
						posX = 0.3843981,
						posY = -0.04228934,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4691832,
						sizeY = 0.25,
						text = "0/3",
						color = "FF00FF00",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz3",
						posX = 0.7380281,
						posY = -0.02327212,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4583595,
						sizeY = 0.25,
						text = "点击队伍可以进行竞猜，并且绝对不会损失",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz4",
						varName = "deadline",
						posX = 0.7380281,
						posY = -0.06465079,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4583595,
						sizeY = 0.25,
						text = "截止日期：",
						color = "FF00FF00",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "taotai",
					varName = "taotai",
					posX = 0.5000001,
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
						name = "kk3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.046305,
						sizeY = 1.194828,
						image = "sjbbj1#sjbbj1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz5",
						posX = 0.3209993,
						posY = -0.04228934,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "当前已竞猜：",
						color = "FF00FF00",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz6",
						varName = "taotai_count",
						posX = 0.3843981,
						posY = -0.04228934,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4691832,
						sizeY = 0.25,
						text = "0/3",
						color = "FF00FF00",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz7",
						posX = 0.7380281,
						posY = -0.02327212,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4583595,
						sizeY = 0.25,
						text = "本页面显示淘汰赛进程",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "yzz8",
						posX = 0.7380281,
						posY = -0.06465079,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4583595,
						sizeY = 0.25,
						text = "若要竞猜请在小组赛介面进行",
						color = "FF00FF00",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "zu1",
						posX = 0.2599916,
						posY = 0.5992491,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4780472,
						sizeY = 0.3832392,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "gq1",
							varName = "p16_1",
							posX = 0.1626674,
							posY = 0.7966403,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "shijiebei#eluosi",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn1",
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
								etype = "Label",
								name = "mc1",
								varName = "t16_1",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq2",
							varName = "p16_2",
							posX = 0.1626674,
							posY = 0.5973423,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "shijiebei#eluosi",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn2",
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
								etype = "Label",
								name = "mc2",
								varName = "t16_2",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq3",
							varName = "p16_3",
							posX = 0.1626674,
							posY = 0.3396733,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "shijiebei#eluosi",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn3",
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
								etype = "Label",
								name = "mc3",
								varName = "t16_3",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq4",
							varName = "p16_4",
							posX = 0.1626674,
							posY = 0.1359912,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "shijiebei#eluosi",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn4",
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
								etype = "Label",
								name = "mc4",
								varName = "t16_4",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq5",
							varName = "p8_1",
							posX = 0.5351549,
							posY = 0.7140661,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn5",
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
								etype = "Label",
								name = "mc5",
								varName = "t8_1",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq6",
							varName = "p8_2",
							posX = 0.5351549,
							posY = 0.2589598,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn6",
								posX = 0.525,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "mc6",
								varName = "t8_2",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq7",
							varName = "p4_1",
							posX = 0.7492735,
							posY = 0.4461137,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn7",
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
								etype = "Label",
								name = "mc7",
								varName = "t4_1",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
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
						name = "zu2",
						posX = 0.2599916,
						posY = 0.2102783,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4780472,
						sizeY = 0.3832392,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "gq8",
							varName = "p16_5",
							posX = 0.1626674,
							posY = 0.8685077,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn8",
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
								etype = "Label",
								name = "mc8",
								varName = "t16_5",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq9",
							varName = "p16_6",
							posX = 0.1626674,
							posY = 0.6333333,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn9",
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
								etype = "Label",
								name = "mc9",
								varName = "t16_6",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq10",
							varName = "p16_7",
							posX = 0.1626674,
							posY = 0.3846623,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn10",
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
								etype = "Label",
								name = "mc10",
								varName = "t16_7",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq11",
							varName = "p16_8",
							posX = 0.1626674,
							posY = 0.1719823,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn11",
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
								etype = "Label",
								name = "mc11",
								varName = "t16_8",
								posX = 2.109293,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq12",
							varName = "p8_3",
							posX = 0.5351549,
							posY = 0.7724943,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn12",
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
								etype = "Label",
								name = "mc12",
								varName = "t8_3",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq13",
							varName = "p8_4",
							posX = 0.5351549,
							posY = 0.294989,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn13",
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
								etype = "Label",
								name = "mc13",
								varName = "t8_4",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq14",
							varName = "p4_2",
							posX = 0.7492734,
							posY = 0.4775055,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn14",
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
								etype = "Label",
								name = "mc14",
								varName = "t4_2",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
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
						name = "zu3",
						posX = 0.7385374,
						posY = 0.5992491,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4780472,
						sizeY = 0.3832392,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "gq15",
							varName = "p16_9",
							posX = 0.85,
							posY = 0.8055233,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn15",
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
								etype = "Label",
								name = "mc15",
								varName = "t16_9",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq16",
							varName = "p16_10",
							posX = 0.85,
							posY = 0.5928435,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn16",
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
								etype = "Label",
								name = "mc16",
								varName = "t16_10",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq17",
							varName = "p16_11",
							posX = 0.85,
							posY = 0.3486711,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn17",
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
								etype = "Label",
								name = "mc17",
								varName = "t16_11",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq18",
							varName = "p16_12",
							posX = 0.85,
							posY = 0.1404901,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn18",
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
								etype = "Label",
								name = "mc18",
								varName = "t16_12",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq19",
							varName = "p8_5",
							posX = 0.4681,
							posY = 0.7185079,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn19",
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
								etype = "Label",
								name = "mc19",
								varName = "t8_5",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq20",
							varName = "p8_6",
							posX = 0.4681,
							posY = 0.2589978,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn20",
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
								etype = "Label",
								name = "mc20",
								varName = "t8_6",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq21",
							varName = "p4_3",
							posX = 0.2567211,
							posY = 0.4460132,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn21",
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
								etype = "Label",
								name = "mc21",
								varName = "t4_3",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
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
						name = "zu4",
						posX = 0.7385374,
						posY = 0.2102783,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4780472,
						sizeY = 0.3832392,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "gq22",
							varName = "p16_13",
							posX = 0.85,
							posY = 0.8685076,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn22",
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
								etype = "Label",
								name = "mc22",
								varName = "t16_13",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq23",
							varName = "p16_14",
							posX = 0.85,
							posY = 0.651329,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn23",
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
								etype = "Label",
								name = "mc23",
								varName = "t16_14",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq24",
							varName = "p16_15",
							posX = 0.85,
							posY = 0.3891612,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn24",
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
								etype = "Label",
								name = "mc24",
								varName = "t16_15",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq25",
							varName = "p16_16",
							posX = 0.85,
							posY = 0.1719823,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn25",
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
								etype = "Label",
								name = "mc25",
								varName = "t16_16",
								posX = -0.997511,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq26",
							varName = "p8_7",
							posX = 0.4681,
							posY = 0.7769933,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn26",
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
								etype = "Label",
								name = "mc26",
								varName = "t8_7",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq27",
							varName = "p8_8",
							posX = 0.4681,
							posY = 0.2994879,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn27",
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
								etype = "Label",
								name = "mc27",
								varName = "t8_8",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "gq28",
							varName = "p4_4",
							posX = 0.2567211,
							posY = 0.4775055,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.08243719,
							sizeY = 0.1754554,
							image = "tb#yuanbao",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "bn28",
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
								etype = "Label",
								name = "mc28",
								varName = "t4_4",
								posX = 0.5,
								posY = -0.1655937,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 3.818931,
								sizeY = 1.474492,
								text = "俄罗斯",
								fontSize = 18,
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
						name = "gq29",
						varName = "p1_0",
						posX = 0.461739,
						posY = 0.398485,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03940887,
						sizeY = 0.06724139,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "bn29",
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
							etype = "Label",
							name = "mc29",
							varName = "t1_0",
							posX = 0.5,
							posY = -0.1655937,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 3.818931,
							sizeY = 1.474492,
							text = "俄罗斯",
							fontSize = 18,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gq30",
						varName = "p2_0",
						posX = 0.5406135,
						posY = 0.398485,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03940887,
						sizeY = 0.06724139,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "bn30",
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
							etype = "Label",
							name = "mc30",
							varName = "t2_0",
							posX = 0.5,
							posY = -0.1655937,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 3.818931,
							sizeY = 1.474492,
							text = "俄罗斯",
							fontSize = 18,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gq31",
						varName = "p3_0",
						posX = 0.461739,
						posY = 0.2016575,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03940887,
						sizeY = 0.06724139,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "bn31",
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
							etype = "Label",
							name = "mc31",
							varName = "t3_0",
							posX = 0.5,
							posY = -0.1655937,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 3.818931,
							sizeY = 1.474492,
							text = "俄罗斯",
							fontSize = 18,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gq32",
						varName = "p4_0",
						posX = 0.5406134,
						posY = 0.2016575,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03940887,
						sizeY = 0.06724139,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "bn32",
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
							etype = "Label",
							name = "mc32",
							varName = "t4_0",
							posX = 0.5,
							posY = -0.1655937,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 3.818931,
							sizeY = 1.474492,
							text = "俄罗斯",
							fontSize = 18,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gj1",
						varName = "g2_0",
						posX = 0.540328,
						posY = 0.4397492,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.03546798,
						sizeY = 0.04137931,
						image = "shijiebei#guanjun",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gj2",
						varName = "g3_0",
						posX = 0.461739,
						posY = 0.2435157,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.03546798,
						sizeY = 0.04137931,
						image = "shijiebei#yajun",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gj3",
						varName = "g4_0",
						posX = 0.540328,
						posY = 0.2435157,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.03546798,
						sizeY = 0.04137931,
						image = "shijiebei#yajun",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gj4",
						varName = "g1_0",
						posX = 0.461739,
						posY = 0.4397492,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.03546798,
						sizeY = 0.04137931,
						image = "shijiebei#guanjun",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "xiaozu_btn",
					posX = 0.08771828,
					posY = 0.8446684,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1339901,
					sizeY = 0.09827586,
					image = "shijiebei#yq1",
					imageNormal = "shijiebei#yq1",
					imagePressed = "shijiebei#yq2",
					imageDisable = "shijiebei#yq1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "yz",
						varName = "xiaozu_txt",
						posX = 0.5,
						posY = 0.5877193,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.589894,
						sizeY = 1.049829,
						text = "小组赛",
						color = "FF003646",
						fontSize = 22,
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
					name = "a3",
					varName = "taotai_btn",
					posX = 0.2441128,
					posY = 0.8446684,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1339901,
					sizeY = 0.09827586,
					image = "shijiebei#yq1",
					imageNormal = "shijiebei#yq1",
					imagePressed = "shijiebei#yq2",
					imageDisable = "shijiebei#yq1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "yz2",
						varName = "taotai_txt",
						posX = 0.5,
						posY = 0.5877193,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.589894,
						sizeY = 1.049829,
						text = "淘汰赛",
						color = "FF003646",
						fontSize = 22,
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
					name = "gb",
					varName = "close",
					posX = 0.9847408,
					posY = 0.9062726,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04926108,
					sizeY = 0.08793104,
					image = "shijiebei#gb",
					imageNormal = "shijiebei#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
