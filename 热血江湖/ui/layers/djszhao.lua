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
		closeAfterOpenAni = true,
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "dd",
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
			alpha = 0,
		},
	},
	{
		prop = {
			etype = "Button",
			name = "zz",
			varName = "tip_btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "kaizhan",
			posX = 0.5,
			posY = 0.3785667,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.6,
			sizeY = 0.4286669,
			alpha = 0,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "mo",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3333333,
				sizeY = 0.8294449,
				image = "uieffect/0.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "damo",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3333333,
				sizeY = 0.8294449,
				image = "uieffect/go-0.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "san",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1666667,
				sizeY = 0.4147224,
				image = "uieffect/3.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "er",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1666667,
				sizeY = 0.4147224,
				image = "uieffect/2.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yi",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1666667,
				sizeY = 0.4147224,
				image = "uieffect/1.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bao",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3333333,
				sizeY = 0.8294449,
				image = "uieffect/Flash111-lw.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "x",
				sizeXAB = 460.8,
				sizeYAB = 77.16004,
				posXAB = 609.6294,
				posYAB = 199.246,
				posX = 0.7937883,
				posY = 0.6455607,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				angle = 0,
				angleVariance = 360,
				duration = 0.4,
				emitterType = 0,
				emissionRate = 1000,
				rotationStartVariance = 360,
				finishParticleSize = 0,
				startParticleSize = 200,
				startParticleSizeVariance = 50,
				maxParticles = 10,
				particleLifespan = 0.4,
				particleLifeMiddle = 0.5,
				speed = 300,
				speedVariance = 100,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/lizi041161121.png",
				useMiddleFrame = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "go",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3333333,
				sizeY = 0.8294449,
				image = "uieffect/go.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zi",
				varName = "findMooncake",
				posX = 0.5,
				posY = 1.069306,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8736979,
				sizeY = 0.174961,
				image = "ggy#zi",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zi2",
				varName = "memoryCardTips",
				posX = 0.5,
				posY = 1.069306,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8736979,
				sizeY = 0.174961,
				image = "ggy#zzz2",
				alpha = 0,
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
	san = {
		san = {
			scale = {{0, {20, 20, 1}}, {100, {0.8, 0.8, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {200, {1}}, {350, {0}}, },
			move = {{0, {384, -200, 0}}, {100, {384,154.3201,0}}, },
		},
	},
	xiaomo = {
		mo = {
			alpha = {{0, {1}}, {200, {1}}, {350, {0}}, },
		},
	},
	er = {
		er = {
			scale = {{0, {20, 20, 1}}, {100, {0.8, 0.8, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {200, {1}}, {350, {0}}, },
			move = {{0, {384, -200, 0}}, {100, {384,154.3201,0}}, },
		},
	},
	yi = {
		yi = {
			scale = {{0, {20, 20, 1}}, {100, {0.8, 0.8, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {200, {1}}, {350, {0}}, },
			move = {{0, {384, -200, 0}}, {100, {384,154.3201,0}}, },
		},
	},
	go = {
		go = {
			scale = {{0, {30, 30, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {250, {1}}, {400, {0}}, },
			move = {{0, {384, -200, 0}}, {100, {384,154.3201,0}}, },
		},
	},
	damo = {
		damo = {
			alpha = {{0, {1}}, {250, {1}}, {550, {0}}, },
		},
	},
	bao = {
		bao = {
			alpha = {{0, {1}}, {50, {1}}, {150, {0}}, },
			scale = {{0, {1,1,1}}, {100, {4.5, 4.5, 1}}, },
		},
	},
	gy = {
	},
	dd = {
		zi = {
			alpha = {{0, {1}}, {1000, {1}}, {3000, {1}}, {4000, {0}}, },
		},
		zi2 = {
			alpha = {{0, {1}}, {1000, {1}}, {3000, {1}}, {4000, {0}}, },
		},
	},
	c_dakai = {
		{0,"san", 1, 0},
		{0,"er", 1, 1000},
		{0,"xiaomo", 1, 1000},
		{0,"yi", 1, 2000},
		{0,"xiaomo", 1, 2000},
		{0,"go", 1, 2900},
		{0,"damo", 1, 2900},
		{0,"xiaomo", 1, 50},
		{0,"bao", 1, 3000},
		{2,"x", 1, 2950},
		{0,"dd", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
