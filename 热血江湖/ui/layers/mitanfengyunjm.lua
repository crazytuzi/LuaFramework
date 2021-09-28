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
			name = "jsjm",
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
				name = "z2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
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
					sizeX = 0.7533598,
					sizeY = 0.8610906,
					image = "mitanfengyun#db",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.4999992,
					posY = 0.498517,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8590856,
					sizeY = 0.8715346,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dz2",
						varName = "need_lvl",
						posX = 0.4458025,
						posY = 0.2726642,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5701572,
						sizeY = 0.07908211,
						text = "进入等级：60",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz4",
						varName = "activity_time",
						posX = 0.4458026,
						posY = 0.1647613,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5701572,
						sizeY = 0.07908211,
						text = "开放时间：10：00~12：30",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz6",
						varName = "open_time",
						posX = 0.6177573,
						posY = 0.2726642,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5701572,
						sizeY = 0.07908211,
						text = "开放日期：1月1日~1月1日",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz3",
						varName = "week_day",
						posX = 0.6177574,
						posY = 0.2185259,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5701572,
						sizeY = 0.07908211,
						text = "开启日期：60",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cj",
						varName = "enter_btn",
						posX = 0.7479837,
						posY = 0.2399356,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1520939,
						sizeY = 0.09869891,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "asc",
							posX = 0.4942529,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8778636,
							sizeY = 0.8319753,
							text = "单人报名",
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
						name = "zd13",
						varName = "residue_times",
						posX = 0.4458025,
						posY = 0.2185259,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5701572,
						sizeY = 0.07908211,
						text = "剩余次数：2",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "t5",
						varName = "activity_day",
						posX = 0.4448127,
						posY = 0.1115791,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5701572,
						sizeY = 0.07908211,
						text = "本期活动第3天",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cj2",
						varName = "team_enter_btn",
						posX = 0.7478432,
						posY = 0.1391992,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1520939,
						sizeY = 0.09869891,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "asc2",
							posX = 0.4844813,
							posY = 0.466683,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9689626,
							sizeY = 0.9333662,
							text = "组队报名",
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
						name = "th1",
						posX = 0.1778788,
						posY = 0.775439,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02969296,
						sizeY = 0.0511043,
						image = "mitanfengyun#th",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "th2",
						posX = 0.1778788,
						posY = 0.5369614,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02969296,
						sizeY = 0.0511043,
						image = "mitanfengyun#th",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
					posX = 0.48387,
					posY = 0.4132994,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4718813,
					sizeY = 0.1666667,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "a",
						posX = 0.5809512,
						posY = 0.7679141,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.140545,
						sizeY = 1.233819,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "jdtd1",
							posX = 0.5584514,
							posY = 0.09040669,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7621972,
							sizeY = 0.1422449,
							image = "rcb#jdd",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
						},
					},
					{
						prop = {
							etype = "LoadingBar",
							name = "jdt1",
							varName = "slider2",
							posX = 0.5584514,
							posY = 0.09040666,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7621972,
							sizeY = 0.1422449,
							image = "rcb#jdt",
							percent = 99,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bxdt1",
							posX = 0.3921028,
							posY = 0.3399498,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1210923,
							sizeY = 0.2133674,
							image = "rcb#bxd",
						},
						children = {
						{
							prop = {
								etype = "Grid",
								name = "tx1",
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
									name = "diguang28",
									posX = 0.5127509,
									posY = 1.260542,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.119283,
									sizeY = 5.415948,
									image = "uieffect/001guangyun.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang29",
									posX = 0.5235927,
									posY = 1.149501,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.271214,
									sizeY = 5.804207,
									image = "uieffect/016fangshe.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang30",
									posX = 0.5235927,
									posY = 1.232915,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 1.902253,
									sizeY = 4.861315,
									image = "uieffect/shanguang_00058.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "bx",
								varName = "box21",
								posX = 0.5154326,
								posY = 1.065139,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8695652,
								sizeY = 2.25,
								image = "rcb#bx1",
							},
						},
						{
							prop = {
								etype = "Button",
								name = "a1",
								varName = "box_btn21",
								posX = 0.5,
								posY = 1.13889,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.168886,
								sizeY = 2.61643,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "kbx",
								varName = "box_used21",
								posX = 0.6518981,
								posY = 1.22086,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 1.152174,
								sizeY = 2.5,
								image = "rcb#bx1k",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "hhd1",
								varName = "value_img1",
								posX = 0.5000442,
								posY = -0.4985655,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6630435,
								sizeY = 1.111111,
								image = "rcb#jdjd1",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "hyd",
									varName = "text21",
									posX = 0.5,
									posY = 0.4,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.149065,
									sizeY = 0.9340368,
									text = "3",
									color = "FFF5D410",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FF2B1300",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Particle",
								name = "qianlz9",
								sizeXAB = 149.5295,
								sizeYAB = 54.31384,
								posXAB = 117.0432,
								posYAB = 55.41568,
								posX = 1.52705,
								posY = 1.875103,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.950895,
								sizeY = 1.83782,
								duration = 999999,
								emitterType = 0,
								rotationStartVariance = 50,
								finishParticleSize = 0,
								startParticleSize = 60,
								startParticleSizeVariance = 20,
								gravityy = 40,
								maxParticles = 7,
								particleLifespan = 1,
								sourcePositionVariancex = 35,
								sourcePositionVariancey = 20,
								startColorBlue = 1,
								startColorGreen = 1,
								startColorRed = 1,
								textureFileName = "uieffect/lizi041161121.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bxdt2",
							posX = 0.6429263,
							posY = 0.3399496,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1210923,
							sizeY = 0.2133674,
							image = "rcb#bxd",
						},
						children = {
						{
							prop = {
								etype = "Grid",
								name = "tx3",
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
									name = "diguang22",
									posX = 0.5562289,
									posY = 1.260542,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.119283,
									sizeY = 5.415948,
									image = "uieffect/001guangyun.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang23",
									posX = 0.5235927,
									posY = 1.149501,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.271214,
									sizeY = 5.804207,
									image = "uieffect/016fangshe.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang24",
									posX = 0.5235927,
									posY = 1.232915,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 1.902253,
									sizeY = 4.861315,
									image = "uieffect/shanguang_00058.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "bx3",
								varName = "box22",
								posX = 0.5154326,
								posY = 1.065139,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8913043,
								sizeY = 2.277777,
								image = "rcb#bx2",
							},
						},
						{
							prop = {
								etype = "Button",
								name = "an2",
								varName = "box_btn22",
								posX = 0.5,
								posY = 1.13889,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.168886,
								sizeY = 2.61643,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "kbx3",
								varName = "box_used22",
								posX = 0.6627676,
								posY = 1.165343,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 1.184783,
								sizeY = 2.444444,
								image = "rcb#bx2k",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "hhd3",
								varName = "value_img3",
								posX = 0.5000442,
								posY = -0.4985655,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6630435,
								sizeY = 1.111111,
								image = "rcb#jdjd1",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "hyd12",
									varName = "text22",
									posX = 0.5,
									posY = 0.4,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.149065,
									sizeY = 0.9340368,
									text = "5",
									color = "FFF5D410",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FF2B1300",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Particle",
								name = "qianlz10",
								sizeXAB = 149.5295,
								sizeYAB = 54.31384,
								posXAB = 117.0432,
								posYAB = 55.41568,
								posX = 1.52705,
								posY = 1.875103,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.950895,
								sizeY = 1.83782,
								duration = 999999,
								emitterType = 0,
								rotationStartVariance = 50,
								finishParticleSize = 0,
								startParticleSize = 60,
								startParticleSizeVariance = 20,
								gravityy = 40,
								maxParticles = 7,
								particleLifespan = 1,
								sourcePositionVariancex = 35,
								sourcePositionVariancey = 20,
								startColorBlue = 1,
								startColorGreen = 1,
								startColorRed = 1,
								textureFileName = "uieffect/lizi041161121.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bxdt3",
							posX = 0.8937498,
							posY = 0.3399495,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1210923,
							sizeY = 0.2133674,
							image = "rcb#bxd",
						},
						children = {
						{
							prop = {
								etype = "Grid",
								name = "tx5",
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
									name = "diguang16",
									posX = 0.5127509,
									posY = 1.260542,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.119283,
									sizeY = 5.415948,
									image = "uieffect/001guangyun.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang17",
									posX = 0.5235927,
									posY = 1.149501,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.271214,
									sizeY = 5.804207,
									image = "uieffect/016fangshe.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang18",
									posX = 0.5235927,
									posY = 1.232915,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 1.902253,
									sizeY = 4.861315,
									image = "uieffect/shanguang_00058.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "bx5",
								varName = "box23",
								posX = 0.5154326,
								posY = 1.065139,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.923913,
								sizeY = 2.25,
								image = "rcb#bx3",
							},
						},
						{
							prop = {
								etype = "Button",
								name = "a3",
								varName = "box_btn23",
								posX = 0.5,
								posY = 1.13889,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.168886,
								sizeY = 2.61643,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "kbx5",
								varName = "box_used23",
								posX = 0.6627676,
								posY = 1.109787,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 1.23913,
								sizeY = 2.333333,
								image = "rcb#bx3k",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "hhd5",
								varName = "value_img5",
								posX = 0.5000442,
								posY = -0.4985655,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6630435,
								sizeY = 1.111111,
								image = "rcb#jdjd1",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "hyd14",
									varName = "text23",
									posX = 0.5,
									posY = 0.4,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.149065,
									sizeY = 0.9340368,
									text = "9",
									color = "FFF5D410",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FF2B1300",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Particle",
								name = "qianlz6",
								sizeXAB = 149.5295,
								sizeYAB = 54.31384,
								posXAB = 117.0432,
								posYAB = 55.41568,
								posX = 1.52705,
								posY = 1.875103,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.950895,
								sizeY = 1.83782,
								duration = 999999,
								emitterType = 0,
								rotationStartVariance = 50,
								finishParticleSize = 0,
								startParticleSize = 60,
								startParticleSizeVariance = 20,
								gravityy = 40,
								maxParticles = 7,
								particleLifespan = 1,
								sourcePositionVariancex = 35,
								sourcePositionVariancey = 20,
								startColorBlue = 1,
								startColorGreen = 1,
								startColorRed = 1,
								textureFileName = "uieffect/lizi041161121.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dt2",
							posX = 0.02785654,
							posY = 0.3871548,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1200707,
							sizeY = 0.5847976,
							image = "mitanfengyun#xdb",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "sz",
								varName = "score2",
								posX = 0.4769841,
								posY = 0.4399158,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.469774,
								sizeY = 0.3329072,
								text = "300",
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wz",
								posX = 0.486967,
								posY = 0.840413,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8801257,
								sizeY = 0.3583649,
								text = "当前次数",
								fontSize = 16,
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
						name = "b",
						posX = 0.5809511,
						posY = 2.010012,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.140545,
						sizeY = 1.233819,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "jdtd2",
							posX = 0.5584514,
							posY = 0.09040669,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7621972,
							sizeY = 0.1422449,
							image = "rcb#jdd",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
						},
					},
					{
						prop = {
							etype = "LoadingBar",
							name = "jdt2",
							varName = "slider1",
							posX = 0.5584514,
							posY = 0.09040666,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7621972,
							sizeY = 0.1422449,
							image = "rcb#jdt",
							percent = 99,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bxdt4",
							posX = 0.3921028,
							posY = 0.3399498,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1210923,
							sizeY = 0.2133674,
							image = "rcb#bxd",
						},
						children = {
						{
							prop = {
								etype = "Grid",
								name = "tx2",
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
									name = "diguang31",
									posX = 0.5127509,
									posY = 1.260542,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.119283,
									sizeY = 5.415948,
									image = "uieffect/001guangyun.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang32",
									posX = 0.5235927,
									posY = 1.149501,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.271214,
									sizeY = 5.804207,
									image = "uieffect/016fangshe.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang33",
									posX = 0.5235927,
									posY = 1.232915,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 1.902253,
									sizeY = 4.861315,
									image = "uieffect/shanguang_00058.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "bx2",
								varName = "box11",
								posX = 0.5154326,
								posY = 1.065139,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8695652,
								sizeY = 2.25,
								image = "rcb#bx1",
							},
						},
						{
							prop = {
								etype = "Button",
								name = "a4",
								varName = "box_btn11",
								posX = 0.5,
								posY = 1.13889,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.168886,
								sizeY = 2.61643,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "kbx2",
								varName = "box_used11",
								posX = 0.6518981,
								posY = 1.22086,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 1.152174,
								sizeY = 2.5,
								image = "rcb#bx1k",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "hhd2",
								posX = 0.5000442,
								posY = -0.4985655,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6630435,
								sizeY = 1.111111,
								image = "rcb#jdjd1",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "hyd2",
									varName = "text11",
									posX = 0.5,
									posY = 0.4,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.149065,
									sizeY = 0.9340368,
									text = "100",
									color = "FFF5D410",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FF2B1300",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Particle",
								name = "qianlz11",
								sizeXAB = 149.5295,
								sizeYAB = 54.31384,
								posXAB = 117.0432,
								posYAB = 55.41568,
								posX = 1.52705,
								posY = 1.875103,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.950895,
								sizeY = 1.83782,
								duration = 999999,
								emitterType = 0,
								rotationStartVariance = 50,
								finishParticleSize = 0,
								startParticleSize = 60,
								startParticleSizeVariance = 20,
								gravityy = 40,
								maxParticles = 7,
								particleLifespan = 1,
								sourcePositionVariancex = 35,
								sourcePositionVariancey = 20,
								startColorBlue = 1,
								startColorGreen = 1,
								startColorRed = 1,
								textureFileName = "uieffect/lizi041161121.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bxdt5",
							posX = 0.6429263,
							posY = 0.3399496,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1210923,
							sizeY = 0.2133674,
							image = "rcb#bxd",
						},
						children = {
						{
							prop = {
								etype = "Grid",
								name = "tx4",
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
									name = "diguang25",
									posX = 0.5562289,
									posY = 1.260542,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.119283,
									sizeY = 5.415948,
									image = "uieffect/001guangyun.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang26",
									posX = 0.5235927,
									posY = 1.149501,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.271214,
									sizeY = 5.804207,
									image = "uieffect/016fangshe.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang27",
									posX = 0.5235927,
									posY = 1.232915,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 1.902253,
									sizeY = 4.861315,
									image = "uieffect/shanguang_00058.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "bx4",
								varName = "box12",
								posX = 0.5154326,
								posY = 1.065139,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.8913043,
								sizeY = 2.277777,
								image = "rcb#bx2",
							},
						},
						{
							prop = {
								etype = "Button",
								name = "a5",
								varName = "box_btn12",
								posX = 0.5,
								posY = 1.13889,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.168886,
								sizeY = 2.61643,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "kbx4",
								varName = "box_used12",
								posX = 0.6627675,
								posY = 1.165343,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 1.184783,
								sizeY = 2.444444,
								image = "rcb#bx2k",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "hhd4",
								varName = "value_img4",
								posX = 0.5000442,
								posY = -0.4985655,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6630435,
								sizeY = 1.111111,
								image = "rcb#jdjd1",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "hyd13",
									varName = "text12",
									posX = 0.5,
									posY = 0.4,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.149065,
									sizeY = 0.9340368,
									text = "150",
									color = "FFF5D410",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FF2B1300",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Particle",
								name = "qianlz12",
								sizeXAB = 149.5295,
								sizeYAB = 54.31384,
								posXAB = 117.0432,
								posYAB = 55.41568,
								posX = 1.52705,
								posY = 1.875103,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.950895,
								sizeY = 1.83782,
								duration = 999999,
								emitterType = 0,
								rotationStartVariance = 50,
								finishParticleSize = 0,
								startParticleSize = 60,
								startParticleSizeVariance = 20,
								gravityy = 40,
								maxParticles = 7,
								particleLifespan = 1,
								sourcePositionVariancex = 35,
								sourcePositionVariancey = 20,
								startColorBlue = 1,
								startColorGreen = 1,
								startColorRed = 1,
								textureFileName = "uieffect/lizi041161121.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bxdt6",
							posX = 0.8937498,
							posY = 0.3399495,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1210923,
							sizeY = 0.2133674,
							image = "rcb#bxd",
						},
						children = {
						{
							prop = {
								etype = "Grid",
								name = "tx6",
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
									name = "diguang19",
									posX = 0.5127509,
									posY = 1.260542,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.119283,
									sizeY = 5.415948,
									image = "uieffect/001guangyun.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang20",
									posX = 0.5235927,
									posY = 1.149501,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 2.271214,
									sizeY = 5.804207,
									image = "uieffect/016fangshe.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "diguang21",
									posX = 0.5235927,
									posY = 1.232915,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 1.902253,
									sizeY = 4.861315,
									image = "uieffect/shanguang_00058.png",
									alpha = 0,
									blendFunc = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "bx6",
								varName = "box13",
								posX = 0.5154326,
								posY = 1.065139,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.923913,
								sizeY = 2.25,
								image = "rcb#bx3",
							},
						},
						{
							prop = {
								etype = "Button",
								name = "a6",
								varName = "box_btn13",
								posX = 0.5,
								posY = 1.13889,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.168886,
								sizeY = 2.61643,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "kbx6",
								varName = "box_used13",
								posX = 0.6627676,
								posY = 1.109787,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 1.23913,
								sizeY = 2.333333,
								image = "rcb#bx3k",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "hhd6",
								varName = "value_img6",
								posX = 0.5000442,
								posY = -0.4985655,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6630435,
								sizeY = 1.111111,
								image = "rcb#jdjd1",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "hyd15",
									varName = "text13",
									posX = 0.5,
									posY = 0.4,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.149065,
									sizeY = 0.9340368,
									text = "200",
									color = "FFF5D410",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FF2B1300",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Particle",
								name = "qianlz7",
								sizeXAB = 149.5295,
								sizeYAB = 54.31384,
								posXAB = 117.0432,
								posYAB = 55.41568,
								posX = 1.52705,
								posY = 1.875103,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.950895,
								sizeY = 1.83782,
								duration = 999999,
								emitterType = 0,
								rotationStartVariance = 50,
								finishParticleSize = 0,
								startParticleSize = 60,
								startParticleSizeVariance = 20,
								gravityy = 40,
								maxParticles = 7,
								particleLifespan = 1,
								sourcePositionVariancex = 35,
								sourcePositionVariancey = 20,
								startColorBlue = 1,
								startColorGreen = 1,
								startColorRed = 1,
								textureFileName = "uieffect/lizi041161121.png",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dt3",
							posX = 0.02785663,
							posY = 0.3593063,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1200707,
							sizeY = 0.5847976,
							image = "mitanfengyun#xdb",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "sz2",
								varName = "score1",
								posX = 0.4769993,
								posY = 0.4151708,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.469774,
								sizeY = 0.3329072,
								text = "10",
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wz1",
								posX = 0.4999815,
								posY = 0.8699363,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8801258,
								sizeY = 0.3583649,
								text = "当前积分",
								fontSize = 16,
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
					etype = "Button",
					name = "an7",
					varName = "close_btn",
					posX = 0.8105025,
					posY = 0.6850717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05271818,
					sizeY = 0.2375422,
					image = "jz#gb2",
					imageNormal = "jz#gb2",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "bxsm1",
					varName = "desc1",
					posX = 0.5161281,
					posY = 0.7400562,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5551794,
					sizeY = 0.04434406,
					text = "宝箱说明",
					fontOutlineColor = "FFFFFFFF",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "bxsm2",
					varName = "desc2",
					posX = 0.5161281,
					posY = 0.5366688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5551794,
					sizeY = 0.04434406,
					text = "宝箱说明",
					fontOutlineColor = "FFFFFFFF",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an6",
				varName = "help_btn",
				posX = 0.8000805,
				posY = 0.2171628,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04765625,
				sizeY = 0.09166667,
				image = "tong#bz",
				imageNormal = "tong#bz",
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
	diguang29 = {
		diguang29 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang28 = {
		diguang28 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang30 = {
		diguang30 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx1 = {
		bx = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang17 = {
		diguang17 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang16 = {
		diguang16 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang18 = {
		diguang18 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx5 = {
		bx5 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	bx6 = {
		bx6 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang20 = {
		diguang20 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang19 = {
		diguang19 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang21 = {
		diguang21 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx4 = {
		bx4 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang23 = {
		diguang23 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang22 = {
		diguang22 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang24 = {
		diguang24 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx3 = {
		bx3 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang26 = {
		diguang26 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang25 = {
		diguang25 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang27 = {
		diguang27 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx2 = {
		bx2 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang31 = {
		diguang31 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang32 = {
		diguang32 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang33 = {
		diguang33 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx2 = {
		bx2 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	c_bx21 = {
		{0,"diguang29", -1, 0},
		{0,"diguang28", -1, 0},
		{0,"diguang30", -1, 0},
		{0,"bx1", -1, 0},
		{2,"qianlz9", 1, 0},
	},
	c_bx23 = {
		{0,"diguang17", -1, 0},
		{0,"diguang16", -1, 0},
		{0,"diguang18", -1, 0},
		{0,"bx5", -1, 0},
		{2,"qianlz6", 1, 0},
	},
	c_bx13 = {
		{0,"diguang20", -1, 0},
		{0,"diguang19", -1, 0},
		{0,"diguang21", -1, 0},
		{0,"bx6", -1, 0},
		{2,"qianlz7", 1, 0},
	},
	c_bx22 = {
		{0,"diguang23", -1, 0},
		{0,"diguang22", -1, 0},
		{0,"diguang24", -1, 0},
		{0,"bx3", -1, 0},
		{2,"qianlz10", 1, 0},
	},
	c_bx12 = {
		{0,"diguang26", -1, 0},
		{0,"diguang25", -1, 0},
		{0,"diguang27", -1, 0},
		{0,"bx4", -1, 0},
		{2,"qianlz12", 1, 0},
	},
	c_bx11 = {
		{0,"diguang31", -1, 0},
		{0,"diguang32", -1, 0},
		{0,"diguang33", -1, 0},
		{0,"bx2", -1, 0},
		{2,"qianlz11", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
