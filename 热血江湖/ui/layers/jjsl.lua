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
		soundEffectOpen = "audio/rxjh/UI/ui_win.ogg",
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
			scale9Left = 0.3,
			scale9Right = 0.3,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "exitBtn",
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
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9710606,
				sizeY = 0.9415087,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "scczt",
					posX = 0.2763326,
					posY = 0.4473791,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4779105,
					sizeY = 0.3393674,
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "txd",
						posX = 0.6228883,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9427253,
						sizeY = 0.6694124,
						image = "jjc#jjc_sld.png",
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "cdd",
							posX = 0.4253779,
							posY = 0.1045588,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7802601,
							sizeY = 0.2012987,
							image = "d#cdd",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zmd",
							posX = 0.4174993,
							posY = 0.14343,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8365649,
							sizeY = 0.2402597,
							image = "d#tyd",
							alpha = 0.6,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tx1",
						posX = 0.3857146,
						posY = 0.6206712,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3040889,
						sizeY = 0.6302909,
						image = "zdtx#txd.png",
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txt1",
							varName = "winnerIcon",
							posX = 0.5054789,
							posY = 0.6925332,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7210885,
							sizeY = 1.110169,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "djd",
							posX = 0.7925571,
							posY = 0.2645361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2325123,
							sizeY = 0.2965517,
							image = "zdte#djd2",
							alphaCascade = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "dj1",
								varName = "winnerLvl",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
								text = "99",
								fontSize = 22,
								fontOutlineEnable = true,
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
						name = "zl2",
						posX = 0.610087,
						posY = 0.6089414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1783347,
						sizeY = 0.2095369,
						text = "排名:",
						color = "FF4FDCFF",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jt1",
						posX = 0.05878676,
						posY = 0.4908403,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1212075,
						sizeY = 0.4042555,
						image = "jjc#jjc_ss.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz1",
						varName = "winnerName",
						posX = 0.3924367,
						posY = 0.2655098,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4649296,
						sizeY = 0.25,
						text = "我的名字七个字",
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz1",
						varName = "mww",
						posX = 0.7353004,
						posY = 0.5909798,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz2",
						varName = "mqw",
						posX = 0.7869633,
						posY = 0.5909798,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz3",
						varName = "mbw",
						posX = 0.8386263,
						posY = 0.5909798,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz4",
						varName = "msw",
						posX = 0.8902892,
						posY = 0.5909798,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz5",
						varName = "mgw",
						posX = 0.9419521,
						posY = 0.5909798,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zl3",
						posX = 0.610087,
						posY = 0.2655098,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1783347,
						sizeY = 0.2095369,
						text = "战力:",
						color = "FF4FDCFF",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zl5",
						varName = "winnerPower",
						posX = 0.8217907,
						posY = 0.2655098,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1983206,
						sizeY = 0.2095368,
						text = "12345",
						color = "FF4FDCFF",
						fontSize = 24,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "scczt2",
					posX = 0.7159122,
					posY = 0.3367391,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4779105,
					sizeY = 0.3393674,
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "txd2",
						posX = 0.392261,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9427253,
						sizeY = 0.6694124,
						image = "jjc#jjc_sld.png",
						alphaCascade = true,
						flippedX = true,
						flippedY = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "cdd2",
							posX = 0.4994773,
							posY = 0.1045588,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.949916,
							sizeY = 0.2012987,
							image = "d#cdd",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zmd2",
							posX = 0.5051574,
							posY = 0.14343,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9791033,
							sizeY = 0.2402597,
							image = "d#tyd",
							alpha = 0.6,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cdd3",
							posX = 0.5887699,
							posY = 0.8256927,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8111684,
							sizeY = 0.3291345,
							image = "d#cdd",
							flippedY = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tx2",
						posX = 0.6126323,
						posY = 0.620738,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3040889,
						sizeY = 0.6302909,
						image = "zdtx#txd.png",
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txt2",
							varName = "loserIcon",
							posX = 0.5054789,
							posY = 0.6925332,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7210885,
							sizeY = 1.110169,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "djd2",
							posX = 0.7925571,
							posY = 0.2645361,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2325123,
							sizeY = 0.2965517,
							image = "zdte#djd2",
							alphaCascade = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "dj2",
								varName = "loserLvl",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
								text = "99",
								fontOutlineEnable = true,
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
						name = "zl4",
						posX = 0.09855025,
						posY = 0.5872487,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2016806,
						sizeY = 0.2095371,
						text = "排名:",
						color = "FF4FDCFF",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jt2",
						posX = 0.9663434,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1212075,
						sizeY = 0.4042555,
						image = "jjc#jjc_xj.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz2",
						varName = "loserName",
						posX = 0.6126323,
						posY = 0.2654169,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4649296,
						sizeY = 0.25,
						text = "我的名字七个字",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz6",
						varName = "eww",
						posX = 0.2428539,
						posY = 0.5649414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz7",
						varName = "eqw",
						posX = 0.2978959,
						posY = 0.5649414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz8",
						varName = "ebw",
						posX = 0.3529378,
						posY = 0.5649414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz9",
						varName = "esw",
						posX = 0.4079798,
						posY = 0.5649414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz10",
						varName = "egw",
						posX = 0.4630218,
						posY = 0.5649414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07407127,
						sizeY = 0.26081,
						image = "jjc#jjc_9.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zl6",
						posX = 0.09855025,
						posY = 0.2654168,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2016806,
						sizeY = 0.2095371,
						text = "战力:",
						color = "FF4FDCFF",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zl7",
						varName = "loserPower",
						posX = 0.3220803,
						posY = 0.2654168,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2016806,
						sizeY = 0.2095371,
						text = "123456",
						color = "FF4FDCFF",
						fontSize = 24,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fgx",
					posX = 0.5028335,
					posY = 0.3998596,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.01937832,
					sizeY = 0.7656151,
					image = "jjc#jjc_g.png",
					alpha = 0,
					rotation = 32,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tit11",
				varName = "coolTimeLabel",
				posX = 0.4291623,
				posY = 0.04782565,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04016649,
				sizeY = 0.08113909,
				text = "120",
				color = "FFC872FF",
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tit12",
				posX = 0.5,
				posY = 0.09504794,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2112233,
				sizeY = 0.08113909,
				text = "点击空白区域退出",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tit13",
				posX = 0.5531721,
				posY = 0.04921454,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2112233,
				sizeY = 0.08113909,
				text = "秒后强制传出副本",
				color = "FF91FFD2",
				vTextAlign = 1,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zs1",
				posX = 0.3791042,
				posY = 0.09510905,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "tong#zsx2",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zs2",
				posX = 0.6263472,
				posY = 0.09510905,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "tong#zsx2",
				alpha = 0,
				flippedX = true,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "shengli",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xian3",
					posX = 0.5012987,
					posY = 1.348608,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1666667,
					sizeY = 0.7111111,
					image = "uieffect/guang2.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian4",
					posX = 0.4999984,
					posY = 1.437356,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1666667,
					sizeY = 0.7111111,
					image = "uieffect/Gameart8.com1014.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian2",
					posX = 0.4999984,
					posY = 1.437356,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1666667,
					sizeY = 0.7111111,
					image = "uieffect/guang2.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.4934989,
					posY = 1.564924,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1666667,
					sizeY = 0.7111111,
					image = "uieffect/guang2.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian5",
					posX = 0.4999984,
					posY = 1.437356,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1666667,
					sizeY = 0.7111111,
					image = "uieffect/guang2.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bg",
					posX = 0.4974013,
					posY = 1.470615,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1666667,
					sizeY = 0.7111111,
					image = "uieffect/Gameart8.com1014.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gh",
					posX = 0.5012987,
					posY = 1.470629,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3333333,
					sizeY = 1.422222,
					image = "uieffect/guang.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gh2",
					posX = 0.5012987,
					posY = 1.470629,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3105391,
					sizeY = 1.324968,
					image = "uieffect/guang.png",
					alpha = 0,
					rotation = 45,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sl",
					posX = 0.4961011,
					posY = 1.459533,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3333333,
					sizeY = 1.422222,
					image = "uieffect/shengli.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lizi",
					sizeXAB = 460.8,
					sizeYAB = 45,
					posXAB = 615.0748,
					posYAB = 293.13,
					posX = 0.8008787,
					posY = 1.6285,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					angle = 0,
					angleVariance = 360,
					duration = 99999,
					emitterType = 0,
					rotationStartVariance = 360,
					finishParticleSize = 5,
					finishParticleSizeVariance = 10,
					startParticleSize = 60,
					startParticleSizeVariance = 30,
					middleParticleSize = 40,
					middleParticleSizeVariance = 20,
					maxParticles = 8,
					particleLifespan = 1,
					particleLifespanVariance = 0.3,
					particleLifeMiddle = 0.4,
					sourcePositionVariancex = 150,
					sourcePositionVariancey = 120,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/lizi046.png",
					useMiddleFrame = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "pzan2",
				varName = "ShareBtn",
				posX = 0.0625325,
				posY = 0.08397254,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.053125,
				sizeY = 0.1055556,
				image = "lt#fx2",
				alpha = 0,
				imageNormal = "lt#fx2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
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
	sl = {
		sl = {
			scale = {{0, {4, 4, 1}}, {150, {0.9, 0.9, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
		bg = {
			scale = {{0, {2, 2, 1}}, },
			alpha = {{0, {1}}, },
		},
	},
	xian = {
		xian = {
			scale = {{0, {1,1,1}}, {200, {6, 0.1, 1}}, },
			alpha = {{0, {1}}, },
		},
		xian2 = {
			scale = {{0, {1, 1, 1}}, {200, {8, 0.5, 1}}, },
			alpha = {{0, {1}}, },
		},
		xian3 = {
			scale = {{0, {1, 1, 1}}, {200, {4.5, 0.3, 1}}, },
			alpha = {{0, {1}}, },
		},
		xian4 = {
			scale = {{0, {1, 1, 1}}, {200, {8, 0.5, 1}}, },
			alpha = {{0, {1}}, {150, {1}}, {300, {0}}, },
		},
	},
	zhuan = {
		gh = {
			rotate = {{0, {0}}, {3000, {180}}, },
			alpha = {{0, {1}}, },
		},
		gh2 = {
			rotate = {{0, {0}}, {3000, {-180}}, },
			alpha = {{0, {1}}, },
		},
	},
	banzi = {
		scczt = {
			move = {{0, {343.4697, 253.2722, 0}}, {500, {343.4697,303.2722,0}}, },
			alpha = {{0, {0}}, {200, {0}}, {400, {1}}, },
		},
		scczt2 = {
			move = {{0, {889.8485, 278.2708, 0}}, {500, {889.8485,228.2708,0}}, },
			alpha = {{0, {0}}, {200, {0}}, {400, {1}}, },
		},
	},
	xt = {
		fgx = {
			scale = {{0, {0, 0, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	zi = {
		tit11 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		tit12 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		tit13 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		zs1 = {
			alpha = {{0, {0}}, {300, {0.7}}, },
		},
		zs2 = {
			alpha = {{0, {0}}, {300, {0.7}}, },
		},
		pzan2 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
	},
	c_dakai = {
		{0,"sl", 1, 0},
		{0,"xian", 1, 50},
		{0,"zhuan", -1, 0},
		{0,"banzi", 1, 0},
		{2,"lizi", 1, 0},
		{0,"xt", 1, 150},
		{0,"zi", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
