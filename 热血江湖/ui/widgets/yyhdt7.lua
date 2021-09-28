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
			sizeX = 0.7101564,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "czsl",
				varName = "CZSL",
				posX = 0.5090542,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.025411,
				sizeY = 1.158424,
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
					name = "bj",
					varName = "sign_bg",
					posX = 0.3718233,
					posY = 0.09662256,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.685014,
					sizeY = 0.1894922,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "czhd",
						posX = 0.2436328,
						posY = 0.5539348,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4898574,
						sizeY = 0.9210159,
						image = "b#d5",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "czhd2",
						posX = 0.7524246,
						posY = 0.5539348,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4835986,
						sizeY = 0.9210159,
						image = "b#d5",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk4",
					posX = 0.3661825,
					posY = 0.5365235,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.681945,
					sizeY = 0.6602891,
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
					varName = "reason",
					posX = 0.5001212,
					posY = 0.9359495,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9548343,
					sizeY = 0.1221804,
					image = "qiandao#bannerxia",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "uc",
					varName = "extraAward",
					posX = 0.1197367,
					posY = 0.9417533,
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
						posX = 0.6115142,
						posY = 0.4754992,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5453642,
						sizeY = 0.8132566,
						image = "qd#bd",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ew",
						posX = 0.6771172,
						posY = 0.2610926,
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
						posX = 0.5965448,
						posY = 0.4689414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1162251,
						sizeY = 0.8404553,
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
							posY = 0.2006979,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.242235,
							sizeY = 0.5629906,
							text = "15",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "item_suo",
							posX = 0.1846533,
							posY = 0.2284948,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.3723404,
							sizeY = 0.3723403,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jiu",
						posX = 0.4292408,
						posY = 0.6325615,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1287712,
						sizeY = 0.4008325,
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
					posX = 0.1671987,
					posY = 0.09526709,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3390405,
					sizeY = 0.2427223,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn1",
						varName = "month_btn",
						posX = 0.3581028,
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
						posX = 0.3616025,
						posY = 0.5281314,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2974502,
						sizeY = 0.7279583,
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
							sizeX = 0.3723405,
							sizeY = 0.3723404,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "slz1",
							varName = "month_count",
							posX = 0.4405184,
							posY = 0.2280161,
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
						posX = 0.3666555,
						posY = 0.5281317,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.319015,
						sizeY = 0.7473803,
					},
					children = {
					{
						prop = {
							etype = "Particle",
							name = "lizi",
							sizeXAB = 82.61369,
							sizeYAB = 84.89367,
							posXAB = 49.48195,
							posYAB = 46.40989,
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
							sizeXAB = 82.61369,
							sizeYAB = 84.89367,
							posXAB = 49.48195,
							posYAB = 46.40989,
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
							sizeXAB = 82.61369,
							sizeYAB = 84.89367,
							posXAB = 49.48195,
							posYAB = 46.40989,
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
							sizeXAB = 82.61369,
							sizeYAB = 84.89367,
							posXAB = 49.48195,
							posYAB = 46.40989,
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
						posX = 0.7315142,
						posY = 0.5280638,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3984979,
						sizeY = 0.6789376,
						text = "本月签到8次可领取",
						color = "FF914A15",
						fontSize = 18,
						fontOutlineColor = "FF916439",
						fontOutlineSize = 2,
						hTextAlign = 1,
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
						sizeX = 0.09176657,
						sizeY = 0.8286334,
						image = "qd#yueka",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylq1",
						varName = "month_got",
						posX = 0.3673642,
						posY = 0.5466331,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2474195,
						sizeY = 0.4027003,
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
					posX = 0.5416327,
					posY = 0.09339051,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3510591,
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
						posX = 0.3389252,
						posY = 0.5358629,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2872669,
						sizeY = 0.7279583,
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
							sizeX = 0.3723404,
							sizeY = 0.3723404,
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
						posX = 0.3519527,
						posY = 0.5281315,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.289609,
						sizeY = 0.7473804,
					},
					children = {
					{
						prop = {
							etype = "Particle",
							name = "lizi5",
							sizeXAB = 77.65718,
							sizeYAB = 84.89368,
							posXAB = 46.51322,
							posYAB = 46.4099,
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
							sizeXAB = 77.65718,
							sizeYAB = 84.89368,
							posXAB = 46.51322,
							posYAB = 46.4099,
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
							sizeXAB = 77.65718,
							sizeYAB = 84.89368,
							posXAB = 46.51322,
							posYAB = 46.4099,
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
							sizeXAB = 77.65718,
							sizeYAB = 84.89368,
							posXAB = 46.51322,
							posYAB = 46.4099,
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
						posX = 0.6983017,
						posY = 0.5280638,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3984979,
						sizeY = 0.6789376,
						text = "本月签到8次可领取",
						color = "FF914A15",
						fontSize = 18,
						fontOutlineColor = "FF916439",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bq2",
						varName = "xiaoyao_double",
						posX = 0.1298381,
						posY = 0.4999083,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.08862491,
						sizeY = 0.8286334,
						image = "qd#xiaoyaoka",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylq2",
						varName = "xiaoyao_got",
						posX = 0.3632269,
						posY = 0.5543571,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.238949,
						sizeY = 0.4027003,
						image = "qd#ylq",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt",
					posX = 0.5847304,
					posY = 0.9342932,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.162757,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tp2",
						varName = "month",
						posX = 0.08550333,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1305298,
						sizeY = 0.612103,
						image = "qiandao#yuefenmeizhuzi5",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qd",
						posX = 0.3583915,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4559602,
						sizeY = 0.612103,
						image = "qiandao#meizhuzi-qiandao",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lh",
				posX = 0.8779981,
				posY = 0.521654,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.420242,
				sizeY = 1.208506,
				image = "czhdlh#lh4",
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
	jn6 = {
	},
	bj = {
	},
	jn7 = {
	},
	bj2 = {
	},
	jn8 = {
	},
	bj3 = {
	},
	jn9 = {
	},
	bj4 = {
	},
	jn10 = {
	},
	bj5 = {
	},
	jn11 = {
	},
	bj6 = {
	},
	jn12 = {
	},
	bj7 = {
	},
	jn13 = {
	},
	bj8 = {
	},
	jn14 = {
	},
	bj9 = {
	},
	jn15 = {
	},
	bj10 = {
	},
	jn16 = {
	},
	bj11 = {
	},
	jn17 = {
	},
	bj12 = {
	},
	jn18 = {
	},
	bj13 = {
	},
	jn19 = {
	},
	bj14 = {
	},
	jn20 = {
	},
	bj15 = {
	},
	jn21 = {
	},
	bj16 = {
	},
	jn22 = {
	},
	bj17 = {
	},
	jn23 = {
	},
	bj18 = {
	},
	jn24 = {
	},
	bj19 = {
	},
	jn25 = {
	},
	bj20 = {
	},
	jn26 = {
	},
	bj21 = {
	},
	jn27 = {
	},
	bj22 = {
	},
	jn28 = {
	},
	bj23 = {
	},
	jn29 = {
	},
	bj24 = {
	},
	jn30 = {
	},
	bj25 = {
	},
	jn31 = {
	},
	bj26 = {
	},
	jn32 = {
	},
	bj27 = {
	},
	jn33 = {
	},
	bj28 = {
	},
	jn34 = {
	},
	bj29 = {
	},
	jn35 = {
	},
	bj30 = {
	},
	jn36 = {
	},
	bj31 = {
	},
	jn37 = {
	},
	bj32 = {
	},
	jn38 = {
	},
	bj33 = {
	},
	jn39 = {
	},
	bj34 = {
	},
	jn40 = {
	},
	bj35 = {
	},
	jn41 = {
	},
	bj36 = {
	},
	jn42 = {
	},
	bj37 = {
	},
	jn43 = {
	},
	bj38 = {
	},
	jn44 = {
	},
	bj39 = {
	},
	jn45 = {
	},
	bj40 = {
	},
	jn46 = {
	},
	bj41 = {
	},
	jn47 = {
	},
	bj42 = {
	},
	jn48 = {
	},
	bj43 = {
	},
	jn49 = {
	},
	bj44 = {
	},
	jn50 = {
	},
	bj45 = {
	},
	jn51 = {
	},
	bj46 = {
	},
	jn52 = {
	},
	bj47 = {
	},
	jn53 = {
	},
	bj48 = {
	},
	jn54 = {
	},
	bj49 = {
	},
	jn55 = {
	},
	bj50 = {
	},
	jn56 = {
	},
	bj51 = {
	},
	jn57 = {
	},
	bj52 = {
	},
	jn58 = {
	},
	bj53 = {
	},
	jn59 = {
	},
	bj54 = {
	},
	jn60 = {
	},
	bj55 = {
	},
	jn61 = {
	},
	bj56 = {
	},
	jn62 = {
	},
	bj57 = {
	},
	jn63 = {
	},
	bj58 = {
	},
	jn64 = {
	},
	bj59 = {
	},
	jn65 = {
	},
	bj60 = {
	},
	c_hld = {
	},
	c_hld2 = {
	},
	c_hld3 = {
	},
	c_hld4 = {
	},
	c_hld5 = {
	},
	c_hld6 = {
	},
	c_hld7 = {
	},
	c_hld8 = {
	},
	c_hld9 = {
	},
	c_hld10 = {
	},
	c_hld11 = {
	},
	c_hld12 = {
	},
	c_hld13 = {
	},
	c_hld14 = {
	},
	c_hld15 = {
	},
	c_hld16 = {
	},
	c_hld17 = {
	},
	c_hld18 = {
	},
	c_hld19 = {
	},
	c_hld20 = {
	},
	c_hld21 = {
	},
	c_hld22 = {
	},
	c_hld23 = {
	},
	c_hld24 = {
	},
	c_hld25 = {
	},
	c_hld26 = {
	},
	c_hld27 = {
	},
	c_hld28 = {
	},
	c_hld29 = {
	},
	c_hld30 = {
	},
	c_hld31 = {
	},
	c_hld32 = {
	},
	c_hld33 = {
	},
	c_hld34 = {
	},
	c_hld35 = {
	},
	c_hld36 = {
	},
	c_hld37 = {
	},
	c_hld38 = {
	},
	c_hld39 = {
	},
	c_hld40 = {
	},
	c_hld41 = {
	},
	c_hld42 = {
	},
	c_hld43 = {
	},
	c_hld44 = {
	},
	c_hld45 = {
	},
	c_hld46 = {
	},
	c_hld47 = {
	},
	c_hld48 = {
	},
	c_hld49 = {
	},
	c_hld50 = {
	},
	c_hld51 = {
	},
	c_hld52 = {
	},
	c_hld53 = {
	},
	c_hld54 = {
	},
	c_hld55 = {
	},
	c_hld56 = {
	},
	c_hld57 = {
	},
	c_hld58 = {
	},
	c_hld59 = {
	},
	c_hld60 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
