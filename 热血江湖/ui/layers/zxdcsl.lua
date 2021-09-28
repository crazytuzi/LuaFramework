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
		soundEffectOpen = "audio/rxjh/UI/ui_shengli.ogg",
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
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9710606,
				sizeY = 0.9415087,
				image = "a",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "d9",
					posX = 0.5,
					posY = 0.5024123,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8206234,
					sizeY = 0.2699194,
					image = "d#diban",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Grid",
						name = "jd2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tb1",
							varName = "icon",
							posX = 0.3261233,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.04901961,
							sizeY = 0.2732619,
							image = "ty#exp",
							alphaCascade = true,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl2",
							varName = "expLabel",
							posX = 0.5259983,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3439619,
							sizeY = 0.4587363,
							text = "+3345",
							color = "FF43261D",
							fontSize = 24,
							fontOutlineColor = "FF102E21",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl1",
							varName = "interalLabel",
							posX = 0.7254827,
							posY = 0.4999999,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3439619,
							sizeY = 0.360963,
							text = "积分+100",
							color = "FF43261D",
							fontSize = 24,
							fontOutlineColor = "FF102E21",
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
				etype = "Grid",
				name = "shengli",
				posX = 0.5,
				posY = 0.4194438,
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
					posY = 1.31513,
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
					posY = 1.470477,
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
					posY = 1.365085,
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
				etype = "Label",
				name = "tit11",
				varName = "coolTimeLabel",
				posX = 0.4291623,
				posY = 0.303383,
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
				name = "tit14",
				posX = 0.5531721,
				posY = 0.3047719,
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
				name = "zs3",
				posX = 0.6263472,
				posY = 0.3506666,
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
				etype = "Label",
				name = "tit13",
				posX = 0.5,
				posY = 0.3506055,
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
				etype = "Image",
				name = "zs4",
				posX = 0.3791042,
				posY = 0.3506666,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "tong#zsx2",
				alpha = 0,
				flippedX = true,
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
	bz = {
		db = {
			alpha = {{0, {0}}, {500, {1}}, },
		},
	},
	zi = {
		tit11 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		tit13 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		tit14 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		zs4 = {
			alpha = {{0, {0}}, {300, {0.7}}, },
		},
		zs3 = {
			alpha = {{0, {0}}, {300, {0.7}}, },
		},
	},
	c_dakai = {
		{0,"sl", 1, 0},
		{0,"xian", 1, 50},
		{0,"zhuan", -1, 0},
		{2,"lizi", 1, 0},
		{0,"bz", 1, 0},
		{0,"zi", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
