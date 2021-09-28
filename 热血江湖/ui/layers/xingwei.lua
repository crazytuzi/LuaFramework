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
				posY = 0.4979201,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6820313,
				sizeY = 0.9625,
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
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.02400887,
						posY = 0.1628659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07216495,
						sizeY = 0.3419913,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.9270202,
						posY = 0.1707188,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2119129,
						sizeY = 0.3694084,
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
						sizeX = 1.008018,
						sizeY = 1,
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
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.9581924,
					posY = 0.9571942,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07674685,
					sizeY = 0.1096681,
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
						etype = "Grid",
						name = "jie",
						varName = "partRoot",
						posX = 0.2443107,
						posY = 0.8175907,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1580756,
						sizeY = 0.1962482,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kk3",
						varName = "items",
						posX = 0.2392586,
						posY = 0.3672692,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4757358,
						sizeY = 0.6435786,
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
							name = "top3",
							posX = 0.5,
							posY = 0.9967328,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.4793815,
							sizeY = 0.0807175,
							image = "chu1#top2",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "taz3",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7293959,
								sizeY = 0.9861619,
								text = "重置消耗",
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
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.5252462,
							posY = 0.8532393,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9510799,
							sizeY = 0.2017937,
							horizontal = true,
							showScrollBar = false,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "w2",
							posX = 0.5,
							posY = 0.222378,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9078657,
							sizeY = 0.1294887,
							text = "彩孔可以匹配任何颜色",
							color = "FFB55D52",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "k9",
							posX = 0.773416,
							posY = 0.6266692,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.443299,
							sizeY = 0.2491457,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "z17",
								varName = "itemName2",
								posX = 0.7749821,
								posY = 0.6677976,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5965493,
								sizeY = 0.5,
								text = "道具名称",
								color = "FF81453B",
								fontSize = 18,
								fontOutlineColor = "FF27221D",
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djk9",
								varName = "itemBg2",
								posX = 0.188087,
								posY = 0.48,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.4345234,
								sizeY = 0.7199491,
								image = "djk#kbai",
							},
							children = {
							{
								prop = {
									etype = "Image",
									name = "t9",
									varName = "itemImg2",
									posX = 0.5,
									posY = 0.5323104,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 0.7976579,
									sizeY = 0.8092182,
									image = "items#items_gaojijinengshu.png",
								},
							},
							{
								prop = {
									etype = "Image",
									name = "suo9",
									varName = "itemLockImg2",
									posX = 0.2162216,
									posY = 0.2616932,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.3368421,
									sizeY = 0.3333333,
									image = "tb#tb_suo.png",
								},
							},
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "z18",
								varName = "itemNum2",
								posX = 0.7749821,
								posY = 0.3229562,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5965493,
								sizeY = 0.5,
								text = "500/3222",
								color = "FF81453B",
								fontSize = 18,
								fontOutlineColor = "FF27221D",
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Button",
								name = "a11",
								varName = "itemBtn2",
								posX = 0.1860861,
								posY = 0.4888075,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5,
								sizeY = 0.8342211,
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "k10",
							posX = 0.773416,
							posY = 0.4046266,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.443299,
							sizeY = 0.2491457,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "z19",
								varName = "itemName1",
								posX = 0.7749821,
								posY = 0.6677976,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5965493,
								sizeY = 0.5,
								text = "道具名称",
								color = "FF81453B",
								fontSize = 18,
								fontOutlineColor = "FF27221D",
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djk10",
								varName = "itemBg1",
								posX = 0.188087,
								posY = 0.48,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4345234,
								sizeY = 0.7199491,
								image = "djk#kbai",
							},
							children = {
							{
								prop = {
									etype = "Image",
									name = "t10",
									varName = "itemImg1",
									posX = 0.5,
									posY = 0.5323104,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 0.7976579,
									sizeY = 0.8092182,
									image = "items#items_gaojijinengshu.png",
								},
							},
							{
								prop = {
									etype = "Image",
									name = "suo10",
									varName = "itemLockImg1",
									posX = 0.2162216,
									posY = 0.2616932,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.3368421,
									sizeY = 0.3333333,
									image = "tb#tb_suo.png",
								},
							},
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "z20",
								varName = "itemNum1",
								posX = 0.7749821,
								posY = 0.3229562,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5965493,
								sizeY = 0.5,
								text = "500/3222",
								color = "FF81453B",
								fontSize = 18,
								fontOutlineColor = "FF27221D",
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Button",
								name = "a12",
								varName = "itemBtn1",
								posX = 0.1860861,
								posY = 0.4888075,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5,
								sizeY = 0.8342211,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xian",
							posX = 0.5,
							posY = 0.7350402,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.006726458,
							image = "h#xian",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xian2",
							posX = 0.5,
							posY = 0.5134294,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.006726458,
							image = "h#xian",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xian3",
							posX = 0.5,
							posY = 0.2918186,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.006726458,
							image = "h#xian",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xian4",
							posX = 0.7834744,
							posY = 1.046507,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4330512,
							sizeY = 0.02910073,
							image = "d2#fgt",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xian5",
							posX = 0.2165438,
							posY = 1.046507,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4330512,
							sizeY = 0.02910073,
							image = "d2#fgt",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
							flippedX = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kk4",
						posX = 0.131157,
						posY = 0.4452861,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2116043,
						sizeY = 0.1453228,
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
							name = "gxd",
							posX = 0.09069796,
							posY = 0.7088848,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1623987,
							sizeY = 0.2978888,
							image = "chu1#gxd",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj",
							varName = "chooseImg1",
							posX = 0.09069806,
							posY = 0.7088848,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.205705,
							sizeY = 0.3376074,
							image = "chu1#dj",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "bn1",
							varName = "chooseBtn1",
							posX = 0.09069805,
							posY = 0.7088849,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2014564,
							sizeY = 0.3673963,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "ms1",
							posX = 0.4969384,
							posY = 0.3419416,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9748796,
							sizeY = 0.5275825,
							text = "形状不会改变",
							color = "FFC93034",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sy",
							posX = 0.5051343,
							posY = 0.7088847,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.4,
							text = "锁定形状",
							color = "FF81453B",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kk5",
						posX = 0.131157,
						posY = 0.3023842,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2116043,
						sizeY = 0.1453228,
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
							name = "gxd2",
							posX = 0.09069806,
							posY = 0.7088848,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1623987,
							sizeY = 0.2978888,
							image = "chu1#gxd",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj2",
							varName = "chooseImg2",
							posX = 0.09069806,
							posY = 0.7088845,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.205705,
							sizeY = 0.3376074,
							image = "chu1#dj",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "bn2",
							varName = "chooseBtn2",
							posX = 0.09069801,
							posY = 0.7088847,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2014564,
							sizeY = 0.3673963,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "ms2",
							posX = 0.4969384,
							posY = 0.3412388,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9748796,
							sizeY = 0.5275825,
							text = "重置后必然出现彩孔",
							color = "FFC93034",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sy2",
							posX = 0.5051343,
							posY = 0.7088847,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.4,
							text = "生成彩孔",
							color = "FF81453B",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kk6",
						posX = 0.7207055,
						posY = 0.4803445,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4711605,
						sizeY = 0.8697292,
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
							name = "top4",
							posX = 0.5,
							posY = 1.037905,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.6900211,
							sizeY = 0.08295694,
							image = "xingpan#zld",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "taz4",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
								text = "期望形状",
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
						etype = "Button",
						name = "dj1",
						varName = "setBtn1",
						posX = 0.727618,
						posY = 0.7554017,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.233677,
						sizeY = 0.2712843,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dzz",
							varName = "text1",
							posX = 0.5,
							posY = 0.4414894,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6929045,
							sizeY = 0.6929045,
							text = "点击设置",
							color = "FFFFE1BD",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF755A3F",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "mustChange1",
							varName = "mustChange1",
							posX = 0.5,
							posY = -0.2544324,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8529411,
							sizeY = 0.3510638,
							image = "chu1#an1",
							imageNormal = "chu1#an1",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "tt",
								posX = 0.5119174,
								posY = 0.5152355,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.101135,
								sizeY = 0.9133782,
								text = "强制变更形状",
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
						etype = "Button",
						name = "dj3",
						varName = "setBtn2",
						posX = 0.7332318,
						posY = 0.3808369,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.233677,
						sizeY = 0.2712843,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dzz2",
							varName = "text2",
							posX = 0.5,
							posY = 0.4414893,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.6929045,
							sizeY = 0.6929045,
							text = "点击设置",
							color = "FFFFE1BD",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF755A3F",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "mustChange2",
							varName = "mustChange2",
							posX = 0.5,
							posY = -0.2544324,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8529411,
							sizeY = 0.3510638,
							image = "chu1#an1",
							imageNormal = "chu1#an1",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "tt2",
								posX = 0.5119174,
								posY = 0.5152355,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.101135,
								sizeY = 0.9133782,
								text = "强制变更形状",
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
						etype = "Button",
						name = "plcs2",
						varName = "resetBtn",
						posX = 0.2421101,
						posY = 0.09407296,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1570342,
						sizeY = 0.07503608,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "重 置",
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
				{
					prop = {
						etype = "Grid",
						name = "czjd",
						varName = "newPart",
						posX = 0.2421101,
						posY = 0.81756,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4436059,
						sizeY = 0.2068966,
					},
					children = {
					{
						prop = {
							etype = "Grid",
							name = "jie4",
							varName = "part",
							posX = 0.2268372,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3589246,
							sizeY = 0.9488294,
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "jie5",
							varName = "part1",
							posX = 0.775822,
							posY = 0.4999997,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3589246,
							sizeY = 0.9488294,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jjt",
							posX = 0.5,
							posY = 0.4999996,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.09812328,
							sizeY = 0.2650312,
							image = "xingpan#jt",
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "plcs3",
						varName = "resetBtn1",
						posX = 0.3604934,
						posY = 0.09407297,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1570342,
						sizeY = 0.07503608,
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
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "重 置",
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
				{
					prop = {
						etype = "Button",
						name = "plcs4",
						varName = "saveBtn",
						posX = 0.1288776,
						posY = 0.09407296,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1570342,
						sizeY = 0.07503608,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "保 存",
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
						etype = "Image",
						name = "b",
						posX = 0.7195617,
						posY = 0.08096892,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4711605,
						sizeY = 0.06809618,
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
							etype = "Label",
							name = "tss",
							posX = 0.4940361,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							text = "当随机到您期望的目标后会提示您，请务必留意",
							color = "FF825F40",
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
						name = "bg",
						posX = 0.2421101,
						posY = 0.9519461,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1942361,
						sizeY = 0.08704279,
						image = "xingpan#bgd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "qian",
							varName = "partText",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2094862,
							sizeY = 0.5111111,
							image = "xingpan#qian",
						},
					},
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
