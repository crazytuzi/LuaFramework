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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.7620704,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tiao4",
				posX = 0.5007812,
				posY = 0.4972283,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/hg.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tiao5",
				posX = 0.5015613,
				posY = 0.4972283,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1809493,
				sizeY = 0.3216877,
				image = "uieffect/34d5bb3a1.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tiao",
				posX = 0.477383,
				posY = 0.5554544,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4,
				sizeY = 0.1777778,
				image = "uieffect/lsxgc.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tiao2",
				posX = 0.5499212,
				posY = 0.4403812,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4,
				sizeY = 0.1777778,
				image = "uieffect/lsxgc.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zi",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.1777778,
				image = "uieffect/lsxg.png",
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
						posXAB = 455.2694,
						posYAB = 363.9297,
						posX = 0.7999682,
						posY = 0.5966061,
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
						posX = 0.5035164,
						posY = 0.498376,
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
						posX = 0.4982358,
						posY = 0.4983625,
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
						posX = 0.4982619,
						posY = 0.5000063,
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
						posX = 0.4982014,
						posY = 0.4950977,
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
						etype = "Image",
						name = "bao7",
						posX = 0.496469,
						posY = 0.5000129,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.16141,
						sizeY = 0.1505902,
						image = "uieffect/ctx_binxinqingshen02.png",
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
						posXAB = 451.2804,
						posYAB = 378.8809,
						posX = 0.792959,
						posY = 0.6211163,
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
						posX = 0.4982259,
						posY = 0.501641,
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
	zi = {
		zi = {
			scale = {{0, {10, 10, 1}}, {150, {0.9, 0.9, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, {1000, {1}}, {1500, {0}}, },
		},
	},
	tiao4 = {
		tiao4 = {
			scale = {{0, {0, 0, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {800, {0}}, {1200, {0}}, },
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
		},
	},
	tiao5 = {
		tiao5 = {
			scale = {{0, {0, 0, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {800, {1}}, {1200, {0}}, },
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
		},
	},
	tiao = {
		tiao = {
			move = {{0, {500, 399.9272, 0}}, {200, {611.0502,399.9272,0}}, },
			alpha = {{0, {0}}, {200, {1}}, },
			scale = {{0, {1,1,1}}, {500, {1,1,1}}, {1200, {1, 0, 1}}, },
		},
	},
	tiao2 = {
		tiao2 = {
			alpha = {{0, {0}}, {200, {1}}, },
			move = {{0, {814, 317.0745, 0}}, {200, {703.8992,317.0745,0}}, },
			scale = {{0, {1,1,1}}, {500, {1,1,1}}, {1200, {1, 0, 1}}, },
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
	bao7 = {
		bao7 = {
			scale = {{0, {1,1,1}}, {100, {8, 8, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
	},
	bao8 = {
		bao8 = {
			scale = {{0, {1, 1, 1}}, {400, {3, 3, 1}}, },
			alpha = {{0, {1}}, {400, {0}}, },
		},
	},
	c_dakai = {
		{0,"zi", 1, 150},
		{0,"tiao4", 1, 200},
		{0,"tiao5", 1, 200},
		{0,"tiao", 1, 0},
		{0,"tiao2", 1, 0},
		{0,"bao", 1, 200},
		{0,"bao8", 1, 200},
		{0,"bao1", 1, 250},
		{0,"bao5", 1, 250},
		{2,"lz3", 1, 200},
		{2,"lz43", 1, 200},
	},
	c_zdqh = {
		{0,"bao", 1, 150},
		{0,"bao1", 1, 200},
		{0,"bao5", 1, 200},
		{0,"bao8", 1, 150},
		{2,"lz43", 1, 0},
		{2,"lz3", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
