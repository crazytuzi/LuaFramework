--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "czsl",
				varName = "CZSL",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bj",
					varName = "sign_bg",
					posX = 0.4999849,
					posY = 0.1128796,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.002972,
					sizeY = 0.2927341,
					image = "rcb#dw",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk4",
					posX = 0.5,
					posY = 0.5701784,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.6112394,
					image = "b#d5",
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
						name = "lb4",
						varName = "scroll",
						posX = 0.4999999,
						posY = 0.5015977,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9897595,
						sizeY = 0.9809777,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp1",
					posX = 0.4984686,
					posY = 0.943769,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.015176,
					sizeY = 0.1478916,
					image = "qd#top.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp2",
					varName = "month",
					posX = 0.05503043,
					posY = 0.9460333,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07810107,
					sizeY = 0.08843537,
					image = "qd#12",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "uc",
					varName = "extraAward",
					posX = 0.7216878,
					posY = 0.953014,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6,
					sizeY = 0.1453741,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bd",
						posX = 0.5918829,
						posY = 0.4688036,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7784584,
						sizeY = 0.9202936,
						image = "qd#bd",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ew",
						posX = 0.8627722,
						posY = 0.2352695,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6236153,
						sizeY = 0.7028798,
						text = "额外奖励：",
						color = "FFDB2D20",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "item_bg",
						posX = 0.8822199,
						posY = 0.4688893,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1531394,
						sizeY = 0.9358917,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj",
							varName = "item_icon",
							posX = 0.4999906,
							posY = 0.5088163,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7647059,
							sizeY = 0.7633927,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl",
							varName = "item_desc",
							posX = 0.3057673,
							posY = 0.2503549,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.242235,
							sizeY = 0.7264093,
							text = "x18",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jiu",
						posX = 0.6452433,
						posY = 0.6712965,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1786626,
						sizeY = 0.4835441,
						image = "qd#jiuyou",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "sb1",
					varName = "bonus1",
					posX = 0.25,
					posY = 0.1341304,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4911099,
					sizeY = 0.2427223,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn1",
						varName = "month_btn",
						posX = 0.3353507,
						posY = 0.538311,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2646174,
						sizeY = 0.755481,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djk",
						varName = "month_frame",
						posX = 0.3318773,
						posY = 0.5281314,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2494584,
						sizeY = 0.7473804,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj1",
							varName = "month_icon",
							posX = 0.5035553,
							posY = 0.5162672,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8317574,
							sizeY = 0.8414497,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo1",
							varName = "month_lock",
							posX = 0.2004902,
							posY = 0.20049,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.3125,
							sizeY = 0.3125,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "slz1",
							varName = "month_count",
							posX = 0.4723757,
							posY = 0.1855234,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8941532,
							sizeY = 0.8788811,
							text = "x111",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "k3",
						posX = 0.3318772,
						posY = 0.5281316,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2494584,
						sizeY = 0.7473804,
					},
					children = {
					{
						prop = {
							etype = "Particle",
							name = "lizi",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 30,
							startParticleSizeVariance = 3,
							middleParticleSize = 20,
							middleParticleSizeVariance = 3,
							maxParticles = 30,
							particleLifespan = 0.5,
							particleLifespanVariance = 0.3,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/81111.png",
							useMiddleFrame = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "lizi2",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi2",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 50,
							startParticleSizeVariance = 5,
							middleParticleSize = 30,
							middleParticleSizeVariance = 3,
							maxParticles = 10,
							particleLifespan = 0.3,
							particleLifespanVariance = 0.1,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/068lizi.png",
							useMiddleFrame = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "lizi3",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi3",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							cwRectangle = true,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 30,
							startParticleSizeVariance = 3,
							middleParticleSize = 20,
							middleParticleSizeVariance = 3,
							maxParticles = 30,
							particleLifespan = 0.5,
							particleLifespanVariance = 0.3,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/81111.png",
							useMiddleFrame = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "lizi4",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi4",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							cwRectangle = true,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 50,
							startParticleSizeVariance = 5,
							middleParticleSize = 30,
							middleParticleSizeVariance = 3,
							maxParticles = 10,
							particleLifespan = 0.3,
							particleLifespanVariance = 0.1,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/068lizi.png",
							useMiddleFrame = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sm1",
						varName = "month_txt",
						posX = 0.685275,
						posY = 0.5280638,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3984979,
						sizeY = 0.6789376,
						text = "本月签到8次可领取",
						color = "FFFECD22",
						fontSize = 18,
						fontOutlineEnable = true,
						fontOutlineColor = "FF916439",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bq1",
						varName = "month_double",
						posX = 0.1512301,
						posY = 0.4999083,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09042867,
						sizeY = 0.9996213,
						image = "qd#yueka",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylq1",
						varName = "month_got",
						posX = 0.3381143,
						posY = 0.5466331,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2369855,
						sizeY = 0.4857973,
						image = "qd#ylq",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "sb2",
					varName = "bonus2",
					posX = 0.75,
					posY = 0.1341304,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4911099,
					sizeY = 0.2427223,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn2",
						varName = "xiaoyao_btn",
						posX = 0.3353507,
						posY = 0.538311,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2646174,
						sizeY = 0.755481,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djk2",
						varName = "xiaoyao_frame",
						posX = 0.3318773,
						posY = 0.5281314,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2494584,
						sizeY = 0.7473804,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj2",
							varName = "xiaoyao_icon",
							posX = 0.5035553,
							posY = 0.5162672,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8317574,
							sizeY = 0.8414497,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo2",
							varName = "xiaoyao_lock",
							posX = 0.2004902,
							posY = 0.20049,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.3125,
							sizeY = 0.3125,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "slz2",
							varName = "xiaoyao_count",
							posX = 0.4723757,
							posY = 0.1855234,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8941532,
							sizeY = 0.8788811,
							text = "x111",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "k4",
						posX = 0.3318774,
						posY = 0.5281316,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2494584,
						sizeY = 0.7473804,
					},
					children = {
					{
						prop = {
							etype = "Particle",
							name = "lizi5",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi5",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 30,
							startParticleSizeVariance = 3,
							middleParticleSize = 20,
							middleParticleSizeVariance = 3,
							maxParticles = 30,
							particleLifespan = 0.5,
							particleLifespanVariance = 0.3,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/81111.png",
							useMiddleFrame = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "lizi6",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi6",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 50,
							startParticleSizeVariance = 5,
							middleParticleSize = 30,
							middleParticleSizeVariance = 3,
							maxParticles = 10,
							particleLifespan = 0.3,
							particleLifespanVariance = 0.1,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/068lizi.png",
							useMiddleFrame = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "lizi7",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi7",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							cwRectangle = true,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 30,
							startParticleSizeVariance = 3,
							middleParticleSize = 20,
							middleParticleSizeVariance = 3,
							maxParticles = 30,
							particleLifespan = 0.5,
							particleLifespanVariance = 0.3,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/81111.png",
							useMiddleFrame = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "lizi8",
							sizeXAB = 65.55675,
							sizeYAB = 70.37238,
							posXAB = 39.26559,
							posYAB = 38.47136,
							varName = "lizi8",
							posX = 0.4908199,
							posY = 0.480892,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8194593,
							sizeY = 0.8796548,
							angle = 0,
							angleVariance = 360,
							emitterType = 2,
							emissionRate = 200,
							positionType = 1,
							cwRectangle = true,
							sourceSpeed = 150,
							rectangleStartIndex = 1,
							finishParticleSize = 5,
							finishParticleSizeVariance = 3,
							startParticleSize = 50,
							startParticleSizeVariance = 5,
							middleParticleSize = 30,
							middleParticleSizeVariance = 3,
							maxParticles = 10,
							particleLifespan = 0.3,
							particleLifespanVariance = 0.1,
							particleLifeMiddle = 0.4,
							sourcePositionVariancex = 0.5,
							sourcePositionVariancey = 0.5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/068lizi.png",
							useMiddleFrame = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sm2",
						varName = "xiaoyao_txt",
						posX = 0.685275,
						posY = 0.5280638,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3984979,
						sizeY = 0.6789376,
						text = "本月签到8次可领取",
						color = "FFFECD22",
						fontSize = 18,
						fontOutlineEnable = true,
						fontOutlineColor = "FF916439",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bq2",
						varName = "xiaoyao_double",
						posX = 0.1512301,
						posY = 0.4999083,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09042867,
						sizeY = 0.9996213,
						image = "qd#xiaoyaoka",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylq2",
						varName = "xiaoyao_got",
						posX = 0.3381143,
						posY = 0.5466331,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2369855,
						sizeY = 0.4857973,
						image = "qd#ylq",
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
