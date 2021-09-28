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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bj2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 1.333333,
				image = "dhbj2#dhbj2",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 1.333333,
				image = "dhbj#dhbj1",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.4992199,
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
			name = "zi",
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
				name = "huoxing2",
				sizeXAB = 768,
				sizeYAB = 180,
				posXAB = 954.4827,
				posYAB = 89.44488,
				posX = 0.7456896,
				posY = 0.124229,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				angle = 55,
				angleVariance = 15,
				duration = 999999,
				emitterType = 0,
				rotationStartVariance = 15,
				finishParticleSize = 0,
				startParticleSize = 80,
				startParticleSizeVariance = 30,
				maxParticles = 8,
				particleLifespan = 1.5,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.3,
				sourcePositionVariancex = 600,
				sourcePositionVariancey = 200,
				speed = 200,
				speedVariance = 50,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/068lizi.png",
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "huoxing",
				sizeXAB = 768,
				sizeYAB = 180,
				posXAB = 954.4827,
				posYAB = 89.44488,
				posX = 0.7456896,
				posY = 0.124229,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				angle = 55,
				angleVariance = 15,
				duration = 999999,
				emitterType = 0,
				rotationStartVariance = 15,
				finishParticleSize = 0,
				startParticleSize = 80,
				startParticleSizeVariance = 30,
				maxParticles = 15,
				particleLifespan = 1.5,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.3,
				sourcePositionVariancex = 600,
				sourcePositionVariancey = 200,
				speed = 200,
				speedVariance = 50,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/067liz.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yi",
				posX = 0.824468,
				posY = 0.6288886,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/001.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "er",
				posX = 0.7580593,
				posY = 0.6191663,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/002.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "san",
				posX = 0.6955572,
				posY = 0.6163885,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/003.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "si",
				posX = 0.6283671,
				posY = 0.5497213,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/004.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wu",
				posX = 0.5541458,
				posY = 0.5024987,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/005.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "liu",
				posX = 0.4823833,
				posY = 0.6120499,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/006.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "qi",
				posX = 0.4214483,
				posY = 0.6064943,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/007.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ba",
				posX = 0.3519202,
				posY = 0.6051054,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/008.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jiu",
				posX = 0.2737983,
				posY = 0.5939942,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/009.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shi",
				posX = 0.1987974,
				posY = 0.5939942,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.7111111,
				image = "uieffect/010.png",
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
	yi = {
		yi = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	er = {
		er = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	san = {
		san = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	si = {
		si = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	wu = {
		wu = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	liu = {
		liu = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	qi = {
		qi = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	ba = {
		ba = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	jiu = {
		jiu = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	shi = {
		shi = {
			alpha = {{0, {0}}, {3000, {1}}, },
		},
	},
	c_dakai = {
		{0,"yi", 1, 0},
		{0,"er", 1, 1000},
		{0,"san", 1, 2000},
		{0,"si", 1, 3000},
		{0,"wu", 1, 4000},
		{0,"liu", 1, 5000},
		{0,"qi", 1, 6000},
		{0,"ba", 1, 7000},
		{0,"jiu", 1, 8000},
		{0,"shi", 1, 9000},
		{2,"huoxing", 1, 0},
		{2,"huoxing2", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
