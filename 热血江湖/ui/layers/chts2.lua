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
				varName = "ok",
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
			posY = 0.6247941,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "juxing",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4,
				sizeY = 0.1777778,
				image = "uieffect/juxing.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gy",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/hg.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gh",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1606717,
				sizeY = 0.2856386,
				image = "uieffect/34d5bb3a1.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ch1",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4,
				sizeY = 0.1777778,
				image = "ch/chuchukeren",
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ch2",
					varName = "icon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.25,
					sizeY = 0.4999999,
					image = "ch/wuhuang",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "jumpBtn",
				posX = 0.5,
				posY = 0.276756,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1015625,
				sizeY = 0.07083333,
				image = "chu1#an3",
				alpha = 0,
				alphaCascade = true,
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8941077,
					sizeY = 0.8113689,
					text = "查 看",
					fontSize = 24,
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
				etype = "Image",
				name = "hdch",
				posX = 0.4992199,
				posY = 0.6095433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.1777778,
				image = "uieffect/hdch.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z2",
				varName = "qh_view",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4446167,
				sizeY = 0.8472222,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "zbqh",
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
						etype = "Particle",
						name = "lz3",
						sizeXAB = 341.4656,
						sizeYAB = 152.5,
						posXAB = 454.272,
						posYAB = 365.9268,
						posX = 0.7982156,
						posY = 0.5998801,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						angle = 0,
						angleVariance = 360,
						duration = 0.8,
						emitterType = 0,
						finishParticleSize = 0,
						startParticleSize = 50,
						gravityy = 150,
						maxParticles = 10,
						particleLifespan = 0.6,
						rotatePerSecond = 500,
						sourcePositionVariancex = 100,
						sourcePositionVariancey = 30,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/lizi041161121.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bao",
						posX = 0.5017619,
						posY = 0.4885541,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4498257,
						sizeY = 0.4196721,
						image = "uieffect/fangsheguang001911.png",
						alpha = 0,
						blendFunc = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bao2",
						posX = 0.5052561,
						posY = 0.4819964,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4498257,
						sizeY = 0.4196721,
						image = "uieffect/001guangyun.png",
						alpha = 0,
						blendFunc = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bao3",
						posX = 0.5087852,
						posY = 0.4885494,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4498257,
						sizeY = 0.4196721,
						image = "uieffect/001guangyun.png",
						alpha = 0,
						blendFunc = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bao6",
						posX = 0.5034654,
						posY = 0.4983717,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1508594,
						sizeY = 0.1407467,
						image = "uieffect/028_guangyun.png",
						alpha = 0,
						blendFunc = 1,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "lz43",
						sizeXAB = 341.4656,
						sizeYAB = 152.5,
						posXAB = 453.2763,
						posYAB = 380.8758,
						posX = 0.7964661,
						posY = 0.6243865,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						angle = 0,
						angleVariance = 360,
						duration = 0.8,
						emitterType = 0,
						emissionRate = 1000,
						finishParticleSize = 0,
						startParticleSize = 110,
						startParticleSizeVariance = 50,
						maxParticles = 10,
						particleLifespan = 0.8,
						speed = 150,
						speedVariance = 150,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/FX_light_032.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bao8",
						posX = 0.4982279,
						posY = 0.490186,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4498256,
						sizeY = 0.4196721,
						image = "uieffect/shanguang_00058.png",
						alpha = 0,
						blendFunc = 1,
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
	ch1 = {
		ch1 = {
			scale = {{0, {10, 10, 1}}, {150, {0.9, 0.9, 1}}, {200, {1, 1, 1}}, },
			alpha = {{0, {1}}, },
		},
	},
	gy = {
		gy = {
			alpha = {{0, {1}}, },
			scale = {{0, {0, 0, 1}}, {100, {1,1,1}}, },
			rotate = {{0, {0}}, {3000, {-180}}, {4500, {-270}}, {6000, {0}}, },
		},
	},
	juxing = {
		juxing = {
			scale = {{0, {1, 0, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	gh = {
		gh = {
			alpha = {{0, {1}}, },
			rotate = {{0, {0}}, {5000, {180}}, {7500, {270}}, {10000, {0}}, },
			scale = {{0, {0, 0, 1}}, {100, {1,1,1}}, },
		},
	},
	hdch = {
		hdch = {
			scale = {{0, {0, 0, 1}}, {150, {1.2, 1.2, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	zdbd = {
		bd3 = {
			scale = {{0, {1,1,1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {1}}, {50, {1}}, {100, {0}}, },
		},
	},
	zdbk = {
		bk2 = {
			alpha = {{0, {1}}, {400, {1}}, {1000, {0}}, },
		},
		bk7 = {
			alpha = {{0, {1}}, {500, {1}}, {1000, {0}}, },
		},
	},
	zdk = {
		bk8 = {
			scale = {{0, {5, 5, 1}}, {50, {3, 3, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {150, {1}}, {200, {0}}, },
		},
	},
	zdsztx = {
		bd4 = {
			scale = {{0, {1,1,1}}, {50, {1, 0.7, 1}}, {300, {0.8, 0.4, 1}}, },
			alpha = {{0, {1}}, {150, {1}}, {500, {0}}, },
		},
		ld4 = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.5, 1.5, 1}}, },
			alpha = {{0, {1}}, {50, {1}}, {200, {0}}, },
		},
	},
	bao = {
		bao = {
			scale = {{0, {3, 3, 1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
	},
	bao1 = {
		bao3 = {
			scale = {{0, {3, 3, 1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {0}}, {500, {0}}, },
		},
	},
	bao5 = {
		bao6 = {
			scale = {{0, {3, 3, 1}}, {500, {5, 5, 1}}, },
			alpha = {{0, {1}}, {500, {0}}, },
		},
	},
	bao8 = {
		bao8 = {
			scale = {{0, {1, 1, 1}}, {400, {3, 3, 1}}, },
			alpha = {{0, {1}}, {400, {0}}, },
		},
	},
	xian = {
		an1 = {
			alpha = {{0, {0}}, {800, {1}}, },
		},
	},
	c_dakai = {
		{0,"ch1", 1, 0},
		{0,"gy", -1, 100},
		{0,"juxing", 1, 100},
		{0,"gh", -1, 100},
		{0,"hdch", 1, 100},
		{0,"bao", 1, 100},
		{0,"bao8", 1, 100},
		{0,"bao1", 1, 150},
		{0,"bao5", 1, 150},
		{2,"lz3", 1, 150},
		{2,"lz43", 1, 150},
		{0,"xian", 1, 0},
	},
	c_zdqh = {
		{0,"bao", 1, 150},
		{0,"bao1", 1, 200},
		{0,"bao5", 1, 200},
		{0,"bao8", 1, 150},
		{2,"lz3", 1, 200},
		{2,"lz43", 1, 150},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
