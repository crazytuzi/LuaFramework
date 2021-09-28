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
			posX = 0.4992208,
			posY = 0.5041591,
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
				sizeX = 0.5880963,
				sizeY = 0.6111111,
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
					sizeX = 0.9641914,
					sizeY = 1.100401,
					image = "b#db5",
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
						name = "text1",
						posX = 0.2922265,
						posY = 0.8831388,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4485539,
						sizeY = 0.1146887,
						text = "每次打开宝箱必然获得",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dtt",
						posX = 0.4999998,
						posY = 0.7309391,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8624482,
						sizeY = 0.2185656,
						image = "shilizhanchoujiang#dt",
						scale9 = true,
						scale9Left = 0.1,
						scale9Right = 0.8,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "text2",
						posX = 0.5,
						posY = 0.5628911,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8913335,
						sizeY = 0.1505233,
						text = "点击开启宝箱匣",
						fontOutlineEnable = true,
						fontOutlineColor = "FF966856",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dt1",
						posX = 0.1988335,
						posY = 0.3324867,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.330666,
						sizeY = 0.4956871,
						image = "shilizhanchoujiang#dt1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dt2",
						posX = 0.5049571,
						posY = 0.3324867,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.330666,
						sizeY = 0.4956871,
						image = "shilizhanchoujiang#dt1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dt3",
						posX = 0.8138319,
						posY = 0.3324866,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.330666,
						sizeY = 0.4956871,
						image = "shilizhanchoujiang#dt1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bxdt1",
						posX = 0.1960819,
						posY = 0.2430439,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1267553,
						sizeY = 0.07435306,
						image = "shilizhanc#bxd",
					},
					children = {
					{
						prop = {
							etype = "Grid",
							name = "tx9",
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
								name = "diguang2",
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
								name = "diguang5",
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
								name = "diguang6",
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
							name = "bx9",
							varName = "reward_icon9",
							posX = 0.521708,
							posY = 1.702946,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 1.954402,
							sizeY = 4.994582,
							image = "shilizhanchoujiang#bx1",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an4",
							varName = "btn1",
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
							name = "kbx9",
							varName = "reward_get_icon9",
							posX = 0.521708,
							posY = 1.702946,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.954402,
							sizeY = 4.994582,
							image = "shilizhanchoujiang#bx2",
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "qianlz2",
							sizeXAB = 179.4823,
							sizeYAB = 66.16152,
							posXAB = 140.4886,
							posYAB = 67.50371,
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
						posX = 0.5049569,
						posY = 0.2430439,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1267553,
						sizeY = 0.07435306,
						image = "rcb#bxd",
					},
					children = {
					{
						prop = {
							etype = "Grid",
							name = "tx10",
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
								name = "diguang3",
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
								name = "diguang7",
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
								name = "diguang8",
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
							name = "bx10",
							varName = "reward_icon10",
							posX = 0.5,
							posY = 1.702946,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 1.954402,
							sizeY = 4.994582,
							image = "shilizhanchoujiang#bx1",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an5",
							varName = "btn2",
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
							name = "kbx10",
							varName = "reward_get_icon10",
							posX = 0.5000001,
							posY = 1.619733,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.954402,
							sizeY = 4.994582,
							image = "shilizhanchoujiang#bx2",
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "qianlz3",
							sizeXAB = 179.4823,
							sizeYAB = 66.16152,
							posXAB = 140.4886,
							posYAB = 67.50371,
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
						posX = 0.8138319,
						posY = 0.2430439,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1267553,
						sizeY = 0.07435306,
						image = "rcb#bxd",
					},
					children = {
					{
						prop = {
							etype = "Grid",
							name = "tx11",
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
								name = "diguang4",
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
								name = "diguang9",
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
								name = "diguang10",
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
							name = "bx11",
							varName = "reward_icon11",
							posX = 0.5,
							posY = 1.702946,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 1.954402,
							sizeY = 4.994582,
							image = "shilizhanchoujiang#bx1",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an6",
							varName = "btn3",
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
							name = "kbx11",
							varName = "reward_get_icon11",
							posX = 0.4999998,
							posY = 1.702946,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.954402,
							sizeY = 4.994582,
							image = "shilizhanchoujiang#bx2",
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "qianlz4",
							sizeXAB = 179.4823,
							sizeYAB = 66.16152,
							posXAB = 140.4886,
							posYAB = 67.50371,
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
						etype = "Label",
						name = "text3",
						varName = "times",
						posX = 0.5,
						posY = 0.09418523,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.1146898,
						text = "剩余次数：5",
						color = "FFC93034",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.028279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3507079,
					sizeY = 0.1181818,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5151514,
						sizeY = 0.4807693,
						image = "shilizhanchoujiang#top",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9628772,
					posY = 1.00928,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07040726,
					sizeY = 0.1204545,
					image = "feisheng#gb",
					imageNormal = "feisheng#gb",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb1",
					varName = "scroll",
					posX = 0.3468154,
					posY = 0.7541256,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4602576,
					sizeY = 0.1724389,
					horizontal = true,
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
	diguang5 = {
		diguang5 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang2 = {
		diguang2 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang6 = {
		diguang6 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx9 = {
		bx9 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang7 = {
		diguang7 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang3 = {
		diguang3 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang8 = {
		diguang8 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx10 = {
		bx10 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang9 = {
		diguang9 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang4 = {
		diguang4 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang10 = {
		diguang10 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx11 = {
		bx11 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
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
	gy113 = {
	},
	gy114 = {
	},
	gy115 = {
	},
	gy116 = {
	},
	gy117 = {
	},
	gy118 = {
	},
	gy119 = {
	},
	gy120 = {
	},
	gy121 = {
	},
	gy122 = {
	},
	gy123 = {
	},
	gy124 = {
	},
	gy125 = {
	},
	gy126 = {
	},
	gy127 = {
	},
	gy128 = {
	},
	gy129 = {
	},
	gy130 = {
	},
	gy131 = {
	},
	gy132 = {
	},
	gy133 = {
	},
	gy134 = {
	},
	gy135 = {
	},
	gy136 = {
	},
	gy137 = {
	},
	gy138 = {
	},
	gy139 = {
	},
	gy140 = {
	},
	gy141 = {
	},
	gy142 = {
	},
	gy143 = {
	},
	gy144 = {
	},
	gy145 = {
	},
	gy146 = {
	},
	gy147 = {
	},
	gy148 = {
	},
	gy149 = {
	},
	gy150 = {
	},
	gy151 = {
	},
	gy152 = {
	},
	gy153 = {
	},
	gy154 = {
	},
	gy155 = {
	},
	gy156 = {
	},
	gy157 = {
	},
	gy158 = {
	},
	gy159 = {
	},
	gy160 = {
	},
	gy161 = {
	},
	gy162 = {
	},
	gy163 = {
	},
	gy164 = {
	},
	gy165 = {
	},
	gy166 = {
	},
	gy167 = {
	},
	gy168 = {
	},
	gy169 = {
	},
	gy170 = {
	},
	gy171 = {
	},
	gy172 = {
	},
	gy173 = {
	},
	gy174 = {
	},
	gy175 = {
	},
	gy176 = {
	},
	gy177 = {
	},
	gy178 = {
	},
	gy179 = {
	},
	gy180 = {
	},
	gy181 = {
	},
	gy182 = {
	},
	gy183 = {
	},
	gy184 = {
	},
	gy185 = {
	},
	gy186 = {
	},
	gy187 = {
	},
	gy188 = {
	},
	gy189 = {
	},
	gy190 = {
	},
	gy191 = {
	},
	gy192 = {
	},
	gy193 = {
	},
	gy194 = {
	},
	gy195 = {
	},
	gy196 = {
	},
	gy197 = {
	},
	gy198 = {
	},
	gy199 = {
	},
	gy200 = {
	},
	gy201 = {
	},
	gy202 = {
	},
	gy203 = {
	},
	gy204 = {
	},
	gy205 = {
	},
	gy206 = {
	},
	gy207 = {
	},
	gy208 = {
	},
	gy209 = {
	},
	gy210 = {
	},
	gy211 = {
	},
	gy212 = {
	},
	gy213 = {
	},
	gy214 = {
	},
	gy215 = {
	},
	gy216 = {
	},
	gy217 = {
	},
	gy218 = {
	},
	gy219 = {
	},
	gy220 = {
	},
	gy221 = {
	},
	gy222 = {
	},
	gy223 = {
	},
	gy224 = {
	},
	gy225 = {
	},
	gy226 = {
	},
	gy227 = {
	},
	gy228 = {
	},
	gy229 = {
	},
	gy230 = {
	},
	gy231 = {
	},
	gy232 = {
	},
	gy233 = {
	},
	gy234 = {
	},
	gy235 = {
	},
	gy236 = {
	},
	gy237 = {
	},
	gy238 = {
	},
	gy239 = {
	},
	gy240 = {
	},
	gy241 = {
	},
	gy242 = {
	},
	gy243 = {
	},
	gy244 = {
	},
	gy245 = {
	},
	gy246 = {
	},
	gy247 = {
	},
	gy248 = {
	},
	gy249 = {
	},
	gy250 = {
	},
	gy251 = {
	},
	gy252 = {
	},
	gy253 = {
	},
	gy254 = {
	},
	gy255 = {
	},
	gy256 = {
	},
	gy257 = {
	},
	gy258 = {
	},
	gy259 = {
	},
	gy260 = {
	},
	gy261 = {
	},
	gy262 = {
	},
	gy263 = {
	},
	gy264 = {
	},
	gy265 = {
	},
	gy266 = {
	},
	gy267 = {
	},
	gy268 = {
	},
	gy269 = {
	},
	gy270 = {
	},
	gy271 = {
	},
	gy272 = {
	},
	gy273 = {
	},
	gy274 = {
	},
	gy275 = {
	},
	gy276 = {
	},
	gy277 = {
	},
	gy278 = {
	},
	gy279 = {
	},
	gy280 = {
	},
	gy281 = {
	},
	gy282 = {
	},
	gy283 = {
	},
	gy284 = {
	},
	gy285 = {
	},
	gy286 = {
	},
	gy287 = {
	},
	gy288 = {
	},
	gy289 = {
	},
	gy290 = {
	},
	gy291 = {
	},
	gy292 = {
	},
	gy293 = {
	},
	gy294 = {
	},
	gy295 = {
	},
	gy296 = {
	},
	gy297 = {
	},
	gy298 = {
	},
	gy299 = {
	},
	gy300 = {
	},
	gy301 = {
	},
	gy302 = {
	},
	gy303 = {
	},
	gy304 = {
	},
	gy305 = {
	},
	gy306 = {
	},
	gy307 = {
	},
	gy308 = {
	},
	gy309 = {
	},
	gy310 = {
	},
	gy311 = {
	},
	gy312 = {
	},
	gy313 = {
	},
	gy314 = {
	},
	gy315 = {
	},
	gy316 = {
	},
	gy317 = {
	},
	gy318 = {
	},
	gy319 = {
	},
	gy320 = {
	},
	gy321 = {
	},
	gy322 = {
	},
	gy323 = {
	},
	gy324 = {
	},
	gy325 = {
	},
	gy326 = {
	},
	gy327 = {
	},
	gy328 = {
	},
	gy329 = {
	},
	gy330 = {
	},
	gy331 = {
	},
	gy332 = {
	},
	gy333 = {
	},
	gy334 = {
	},
	gy335 = {
	},
	gy336 = {
	},
	gy337 = {
	},
	gy338 = {
	},
	gy339 = {
	},
	gy340 = {
	},
	gy341 = {
	},
	gy342 = {
	},
	gy343 = {
	},
	gy344 = {
	},
	gy345 = {
	},
	gy346 = {
	},
	gy347 = {
	},
	gy348 = {
	},
	gy349 = {
	},
	gy350 = {
	},
	gy351 = {
	},
	gy352 = {
	},
	gy353 = {
	},
	gy354 = {
	},
	gy355 = {
	},
	gy356 = {
	},
	gy357 = {
	},
	gy358 = {
	},
	gy359 = {
	},
	gy360 = {
	},
	gy361 = {
	},
	gy362 = {
	},
	gy363 = {
	},
	gy364 = {
	},
	gy365 = {
	},
	gy366 = {
	},
	gy367 = {
	},
	gy368 = {
	},
	gy369 = {
	},
	gy370 = {
	},
	gy371 = {
	},
	gy372 = {
	},
	gy373 = {
	},
	gy374 = {
	},
	gy375 = {
	},
	gy376 = {
	},
	gy377 = {
	},
	gy378 = {
	},
	gy379 = {
	},
	gy380 = {
	},
	gy381 = {
	},
	gy382 = {
	},
	gy383 = {
	},
	gy384 = {
	},
	gy385 = {
	},
	gy386 = {
	},
	gy387 = {
	},
	gy388 = {
	},
	gy389 = {
	},
	gy390 = {
	},
	gy391 = {
	},
	gy392 = {
	},
	gy393 = {
	},
	gy394 = {
	},
	gy395 = {
	},
	gy396 = {
	},
	gy397 = {
	},
	gy398 = {
	},
	gy399 = {
	},
	gy400 = {
	},
	gy401 = {
	},
	gy402 = {
	},
	gy403 = {
	},
	gy404 = {
	},
	gy405 = {
	},
	gy406 = {
	},
	gy407 = {
	},
	gy408 = {
	},
	gy409 = {
	},
	gy410 = {
	},
	gy411 = {
	},
	gy412 = {
	},
	gy413 = {
	},
	gy414 = {
	},
	gy415 = {
	},
	gy416 = {
	},
	gy417 = {
	},
	gy418 = {
	},
	gy419 = {
	},
	gy420 = {
	},
	gy421 = {
	},
	gy422 = {
	},
	gy423 = {
	},
	gy424 = {
	},
	gy425 = {
	},
	gy426 = {
	},
	gy427 = {
	},
	gy428 = {
	},
	gy429 = {
	},
	gy430 = {
	},
	gy431 = {
	},
	gy432 = {
	},
	gy433 = {
	},
	gy434 = {
	},
	gy435 = {
	},
	gy436 = {
	},
	gy437 = {
	},
	gy438 = {
	},
	gy439 = {
	},
	gy440 = {
	},
	gy441 = {
	},
	gy442 = {
	},
	gy443 = {
	},
	gy444 = {
	},
	gy445 = {
	},
	gy446 = {
	},
	gy447 = {
	},
	gy448 = {
	},
	gy449 = {
	},
	gy450 = {
	},
	gy451 = {
	},
	gy452 = {
	},
	gy453 = {
	},
	gy454 = {
	},
	gy455 = {
	},
	gy456 = {
	},
	gy457 = {
	},
	gy458 = {
	},
	gy459 = {
	},
	gy460 = {
	},
	gy461 = {
	},
	gy462 = {
	},
	gy463 = {
	},
	gy464 = {
	},
	gy465 = {
	},
	gy466 = {
	},
	gy467 = {
	},
	gy468 = {
	},
	gy469 = {
	},
	gy470 = {
	},
	gy471 = {
	},
	gy472 = {
	},
	gy473 = {
	},
	gy474 = {
	},
	gy475 = {
	},
	gy476 = {
	},
	gy477 = {
	},
	gy478 = {
	},
	gy479 = {
	},
	gy480 = {
	},
	gy481 = {
	},
	gy482 = {
	},
	gy483 = {
	},
	gy484 = {
	},
	gy485 = {
	},
	gy486 = {
	},
	gy487 = {
	},
	gy488 = {
	},
	gy489 = {
	},
	gy490 = {
	},
	gy491 = {
	},
	gy492 = {
	},
	gy493 = {
	},
	gy494 = {
	},
	gy495 = {
	},
	gy496 = {
	},
	gy497 = {
	},
	gy498 = {
	},
	gy499 = {
	},
	gy500 = {
	},
	gy501 = {
	},
	gy502 = {
	},
	gy503 = {
	},
	gy504 = {
	},
	gy505 = {
	},
	gy506 = {
	},
	gy507 = {
	},
	gy508 = {
	},
	gy509 = {
	},
	gy510 = {
	},
	gy511 = {
	},
	gy512 = {
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_bx9 = {
		{0,"diguang5", -1, 0},
		{0,"diguang2", -1, 0},
		{0,"diguang6", -1, 0},
		{0,"bx9", -1, 0},
		{2,"qianlz2", 1, 0},
	},
	c_bx10 = {
		{0,"diguang7", -1, 0},
		{0,"diguang3", -1, 0},
		{0,"diguang8", -1, 0},
		{0,"bx10", -1, 0},
		{2,"qianlz3", 1, 0},
	},
	c_bx11 = {
		{0,"diguang9", -1, 0},
		{0,"diguang4", -1, 0},
		{0,"diguang10", -1, 0},
		{0,"bx11", -1, 0},
		{2,"qianlz4", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
