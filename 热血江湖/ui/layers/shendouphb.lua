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
						posX = 0.7646949,
						posY = 0.5056129,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3110309,
						sizeY = 0.8476912,
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
							sizeX = 0.8837606,
							sizeY = 0.1016961,
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
								sizeY = 0.6400001,
								image = "tong#zl",
							},
						},
						{
							prop = {
								etype = "Label",
								name = "zlz",
								varName = "battle_power",
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
							posY = 0.4550743,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.893911,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xt",
					posX = 0.2644265,
					posY = 0.5060668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4750808,
					sizeY = 0.8933589,
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
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#tsxx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd2",
				posX = 0.4992187,
				posY = 0.4785077,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7830886,
				sizeY = 0.7889817,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "z1",
					posX = 0.3164567,
					posY = 0.507288,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5205038,
					sizeY = 0.9184284,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pan",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.091667,
						sizeY = 0.9366667,
						image = "shendou#bj",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "jt",
							posX = 0.4954304,
							posY = 0.2797155,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.05343509,
							sizeY = 0.106955,
							image = "shendou#jiantou",
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "dh1",
						posX = 0.5016118,
						posY = 0.4991679,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.09154,
						sizeY = 0.9384586,
					},
					children = {
					{
						prop = {
							etype = "Particle",
							name = "tx_23",
							sizeXAB = 566.0148,
							sizeYAB = 488.7525,
							posXAB = 286.4796,
							posYAB = 243.5079,
							posX = 0.5030477,
							posY = 0.4973398,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9939015,
							sizeY = 0.9982267,
							angleVariance = 180,
							emitterType = 0,
							emissionRate = 60,
							finishColorAlpha = 0,
							middleColorAlpha = 1,
							middleColorBlue = 1,
							middleColorGreen = 1,
							middleColorRed = 1,
							startParticleSize = 15,
							startParticleSizeVariance = 8,
							middleParticleSize = 22,
							middleParticleSizeVariance = 5,
							maxParticles = 22,
							particleLifespan = 2,
							particleLifespanVariance = 0.5,
							particleLifeMiddle = 0.3,
							radialAccelVariance = 5,
							radialAcceleration = -5,
							sourcePositionVariancex = 280,
							sourcePositionVariancey = 280,
							sourcePositionx = 280,
							sourcePositiony = 280,
							speed = 18,
							speedVariance = 8,
							textureFileName = "uieffect/8111.png",
							useMiddleFrame = true,
							playOnInit = true,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "tx001",
							posX = 0.7585357,
							posY = 0.9078004,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.07634474,
							sizeY = 0.08879808,
							image = "uieffect/flare043.png",
							alpha = 0,
							rotation = 45,
							blendFunc = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "tx002",
							posX = 0.1137169,
							posY = 0.1768626,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.04580684,
							sizeY = 0.05327885,
							image = "uieffect/lizi041611.png",
							alpha = 0,
							blendFunc = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "tx3",
							posX = 0.7615814,
							posY = 0.5013317,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.05344132,
							sizeY = 0.06215866,
							image = "uieffect/flare043.png",
							alpha = 0,
							blendFunc = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "tx4",
							posX = 0.2128009,
							posY = 0.6573603,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.05344132,
							sizeY = 0.06215866,
							image = "uieffect/flare043.png",
							alpha = 0,
							blendFunc = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian1",
						varName = "line26",
						posX = 0.938495,
						posY = 0.5232916,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04833334,
						sizeY = 0.075,
						image = "shendou#jt1",
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.3,
						scale9Bottom = 0.45,
						rotation = -165,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian2",
						varName = "line15",
						posX = 0.05137075,
						posY = 0.5232916,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04833334,
						sizeY = 0.075,
						image = "shendou#jt1",
						scale9Left = 0.3,
						scale9Right = 0.3,
						rotation = 165,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian3",
						varName = "line46",
						posX = 0.8577412,
						posY = 0.3426576,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04833333,
						sizeY = 0.075,
						image = "shendou#jt1",
						scale9Left = 0.3,
						scale9Right = 0.3,
						rotation = 30,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian4",
						varName = "line35",
						posX = 0.1240252,
						posY = 0.3426576,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04833334,
						sizeY = 0.075,
						image = "shendou#jt1",
						scale9Left = 0.3,
						scale9Right = 0.3,
						rotation = -30,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian5",
						varName = "line47",
						posX = 0.6306736,
						posY = 0.1372995,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04833333,
						sizeY = 0.1366667,
						image = "shendou#jt2",
						scale9Left = 0.3,
						scale9Right = 0.3,
						rotation = -110,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian6",
						varName = "line37",
						posX = 0.3468945,
						posY = 0.1389662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04833334,
						sizeY = 0.1366667,
						image = "shendou#jt2",
						scale9Left = 0.3,
						scale9Right = 0.3,
						rotation = 110,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bjt",
						varName = "bg",
						posX = 0.4949744,
						posY = 0.5599087,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3983333,
						sizeY = 0.3966667,
						image = "shendou#1",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "jie",
						varName = "rank",
						posX = 0.4933332,
						posY = 0.2176488,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3449265,
						sizeY = 0.1524556,
						text = "一阶",
						color = "FF523095",
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFFFFF",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnd",
						varName = "skillRoot1",
						posX = 0.03575855,
						posY = 0.631452,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.15,
						sizeY = 0.15,
						image = "shendou#jnk",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jnan",
							varName = "skillBtn1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.94529,
							sizeY = 0.8372397,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnt",
							varName = "skillIcon1",
							posX = 0.4941321,
							posY = 0.5120448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8319655,
							sizeY = 0.8338652,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnhd",
							varName = "skillRed1",
							posX = 0.8409153,
							posY = 0.8530773,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3,
							sizeY = 0.3111111,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jndj",
							varName = "skillLvl1",
							posX = 0.8369919,
							posY = 0.1576698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7626691,
							sizeY = 0.5937452,
							text = "1",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnd2",
						varName = "skillRoot2",
						posX = 0.9713326,
						posY = 0.631452,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.15,
						sizeY = 0.15,
						image = "shendou#jnk",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jnan2",
							varName = "skillBtn2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.94529,
							sizeY = 0.8372397,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnt2",
							varName = "skillIcon2",
							posX = 0.4941321,
							posY = 0.5120448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8319655,
							sizeY = 0.8338652,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnhd2",
							varName = "skillRed2",
							posX = 0.8409153,
							posY = 0.8530773,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3,
							sizeY = 0.3111111,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jndj2",
							varName = "skillLvl2",
							posX = 0.8369919,
							posY = 0.1576698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7626691,
							sizeY = 0.5937452,
							text = "1",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnd3",
						varName = "skillRoot3",
						posX = 0.2221854,
						posY = 0.2242944,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.15,
						sizeY = 0.15,
						image = "shendou#jnk",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jnan3",
							varName = "skillBtn3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.94529,
							sizeY = 0.8372397,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnt3",
							varName = "skillIcon3",
							posX = 0.4941321,
							posY = 0.5120448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8319655,
							sizeY = 0.8338652,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnhd3",
							varName = "skillRed3",
							posX = 0.8409153,
							posY = 0.8530773,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3,
							sizeY = 0.3111111,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jndj3",
							varName = "skillLvl3",
							posX = 0.8369919,
							posY = 0.1576698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7626691,
							sizeY = 0.5937452,
							text = "1",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnd4",
						varName = "skillRoot4",
						posX = 0.7580011,
						posY = 0.2242944,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.15,
						sizeY = 0.15,
						image = "shendou#jnk",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jnan4",
							varName = "skillBtn4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.94529,
							sizeY = 0.8372397,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnt4",
							varName = "skillIcon4",
							posX = 0.4941321,
							posY = 0.5120448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8319655,
							sizeY = 0.8338652,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnhd4",
							varName = "skillRed4",
							posX = 0.8409153,
							posY = 0.8530773,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3,
							sizeY = 0.3111111,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jndj4",
							varName = "skillLvl4",
							posX = 0.8369919,
							posY = 0.1576698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7626691,
							sizeY = 0.5937452,
							text = "1",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jies",
						varName = "pointRoot",
						posX = 0.4949744,
						posY = 0.5599087,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3983333,
						sizeY = 0.3966667,
					},
					children = {
					{
						prop = {
							etype = "Grid",
							name = "q1",
							posX = 0.5,
							posY = 0,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws1",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb1",
								varName = "point1",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q2",
							posX = 0.25,
							posY = 0.0669873,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws2",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb2",
								varName = "point2",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q3",
							posX = 0.0669873,
							posY = 0.25,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws3",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb3",
								varName = "point3",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q4",
							posX = 0,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws4",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb4",
								varName = "point4",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q5",
							posX = 0.0669873,
							posY = 0.75,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws5",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb5",
								varName = "point5",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q6",
							posX = 0.25,
							posY = 0.9330127,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws6",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb6",
								varName = "point6",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q7",
							posX = 0.5,
							posY = 1,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws7",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb7",
								varName = "point7",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q8",
							posX = 0.75,
							posY = 0.9330127,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws8",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb8",
								varName = "point8",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q9",
							posX = 0.9330127,
							posY = 0.75,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws9",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb9",
								varName = "point9",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q10",
							posX = 1,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws10",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb10",
								varName = "point10",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q11",
							posX = 0.9330127,
							posY = 0.25,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws11",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb11",
								varName = "point11",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "q12",
							posX = 0.75,
							posY = 0.0669873,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.209205,
							sizeY = 0.210084,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dws12",
								posX = 0.54,
								posY = 0.46,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9400002,
								sizeY = 0.98,
								image = "shendou#diank",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tb12",
								varName = "point12",
								posX = 0.5,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7200001,
								sizeY = 0.68,
								image = "shendou#zi",
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnd5",
						varName = "skillRoot5",
						posX = 0.08909144,
						posY = 0.43658,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1,
						sizeY = 0.1,
						image = "shendou#jnk",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jnan5",
							varName = "skillBtn5",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.94529,
							sizeY = 0.8372397,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnt5",
							varName = "skillIcon5",
							posX = 0.4941321,
							posY = 0.5120448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8319655,
							sizeY = 0.8338652,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnhd5",
							varName = "skillRed5",
							posX = 0.8409153,
							posY = 0.8530773,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.45,
							sizeY = 0.4666667,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jndj5",
							varName = "skillLvl5",
							posX = 0.8369919,
							posY = 0.1576698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7626691,
							sizeY = 0.5937452,
							text = "1",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnd6",
						varName = "skillRoot6",
						posX = 0.8916672,
						posY = 0.43658,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09999999,
						sizeY = 0.1,
						image = "shendou#jnk",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jnan6",
							varName = "skillBtn6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.94529,
							sizeY = 0.8372397,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnt6",
							varName = "skillIcon6",
							posX = 0.4941321,
							posY = 0.5120448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8319655,
							sizeY = 0.8338652,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnhd6",
							varName = "skillRed6",
							posX = 0.8409153,
							posY = 0.8530773,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4500001,
							sizeY = 0.4666667,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jndj6",
							varName = "skillLvl6",
							posX = 0.8369919,
							posY = 0.1576698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7626691,
							sizeY = 0.5937452,
							text = "1",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnd7",
						varName = "skillRoot7",
						posX = 0.4900164,
						posY = 0.104965,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09999999,
						sizeY = 0.1,
						image = "shendou#jnk",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jnan7",
							varName = "skillBtn7",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.94529,
							sizeY = 0.8372397,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnt7",
							varName = "skillIcon7",
							posX = 0.4941321,
							posY = 0.5120448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8319655,
							sizeY = 0.8338652,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jnhd7",
							varName = "skillRed7",
							posX = 0.8409153,
							posY = 0.8530773,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4500001,
							sizeY = 0.4666667,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jndj7",
							varName = "skillLvl7",
							posX = 0.8369919,
							posY = 0.1576698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7626691,
							sizeY = 0.5937452,
							text = "1",
							fontOutlineEnable = true,
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
	gy513 = {
	},
	gy514 = {
	},
	gy515 = {
	},
	gy516 = {
	},
	gy517 = {
	},
	gy518 = {
	},
	gy519 = {
	},
	gy520 = {
	},
	gy521 = {
	},
	gy522 = {
	},
	gy523 = {
	},
	gy524 = {
	},
	gy525 = {
	},
	gy526 = {
	},
	gy527 = {
	},
	gy528 = {
	},
	gy529 = {
	},
	gy530 = {
	},
	gy531 = {
	},
	gy532 = {
	},
	gy533 = {
	},
	gy534 = {
	},
	gy535 = {
	},
	gy536 = {
	},
	gy537 = {
	},
	gy538 = {
	},
	gy539 = {
	},
	gy540 = {
	},
	gy541 = {
	},
	gy542 = {
	},
	gy543 = {
	},
	gy544 = {
	},
	gy545 = {
	},
	gy546 = {
	},
	gy547 = {
	},
	gy548 = {
	},
	gy549 = {
	},
	gy550 = {
	},
	gy551 = {
	},
	gy552 = {
	},
	gy553 = {
	},
	gy554 = {
	},
	gy555 = {
	},
	gy556 = {
	},
	gy557 = {
	},
	gy558 = {
	},
	gy559 = {
	},
	gy560 = {
	},
	gy561 = {
	},
	gy562 = {
	},
	gy563 = {
	},
	gy564 = {
	},
	gy565 = {
	},
	gy566 = {
	},
	gy567 = {
	},
	gy568 = {
	},
	gy569 = {
	},
	gy570 = {
	},
	gy571 = {
	},
	gy572 = {
	},
	gy573 = {
	},
	gy574 = {
	},
	gy575 = {
	},
	gy576 = {
	},
	gy577 = {
	},
	gy578 = {
	},
	gy579 = {
	},
	gy580 = {
	},
	gy581 = {
	},
	gy582 = {
	},
	gy583 = {
	},
	gy584 = {
	},
	gy585 = {
	},
	gy586 = {
	},
	gy587 = {
	},
	gy588 = {
	},
	gy589 = {
	},
	gy590 = {
	},
	gy591 = {
	},
	gy592 = {
	},
	gy593 = {
	},
	gy594 = {
	},
	gy595 = {
	},
	gy596 = {
	},
	gy597 = {
	},
	gy598 = {
	},
	gy599 = {
	},
	gy600 = {
	},
	gy601 = {
	},
	gy602 = {
	},
	gy603 = {
	},
	gy604 = {
	},
	gy605 = {
	},
	gy606 = {
	},
	gy607 = {
	},
	gy608 = {
	},
	gy609 = {
	},
	gy610 = {
	},
	gy611 = {
	},
	gy612 = {
	},
	gy613 = {
	},
	gy614 = {
	},
	gy615 = {
	},
	gy616 = {
	},
	gy617 = {
	},
	gy618 = {
	},
	gy619 = {
	},
	gy620 = {
	},
	gy621 = {
	},
	gy622 = {
	},
	gy623 = {
	},
	gy624 = {
	},
	gy625 = {
	},
	gy626 = {
	},
	gy627 = {
	},
	gy628 = {
	},
	gy629 = {
	},
	gy630 = {
	},
	gy631 = {
	},
	gy632 = {
	},
	gy633 = {
	},
	gy634 = {
	},
	gy635 = {
	},
	gy636 = {
	},
	gy637 = {
	},
	gy638 = {
	},
	gy639 = {
	},
	gy640 = {
	},
	gy641 = {
	},
	gy642 = {
	},
	gy643 = {
	},
	gy644 = {
	},
	dh11 = {
		tx001 = {
			alpha = {{0, {0}}, {100, {0}}, {400, {1}}, {500, {1}}, {1000, {0}}, {1800, {0}}, },
		},
		tx3 = {
			alpha = {{0, {0}}, {500, {0}}, {900, {1}}, {1400, {0}}, {1800, {0}}, },
		},
	},
	dh12 = {
		tx002 = {
			alpha = {{0, {0}}, {200, {0}}, {500, {1}}, {800, {1}}, {1300, {0}}, {1800, {0}}, },
		},
		tx4 = {
			alpha = {{0, {0}}, {500, {0}}, {900, {1}}, {1400, {1}}, {1800, {0}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_2 = {
		{0,"dh11", -1, 0},
		{0,"dh12", -1, 500},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
