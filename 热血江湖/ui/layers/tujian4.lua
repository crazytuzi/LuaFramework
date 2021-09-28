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
				varName = "close",
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
				etype = "Grid",
				name = "ka",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.272988,
				sizeY = 0.6604555,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tu",
					varName = "image",
					posX = 0.5457891,
					posY = 0.4957997,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8041792,
					sizeY = 0.9189785,
					image = "tujian#huolong",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kpd",
					varName = "cover",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9615808,
					sizeY = 0.9673458,
					image = "tujian2#cheng3",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "kaibei",
				varName = "back",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3835938,
				sizeY = 0.6402778,
				image = "tujian2#chengb",
			},
		},
		{
			prop = {
				etype = "FrameAni",
				name = "xz",
				sizeXAB = 561.7056,
				sizeYAB = 587.1821,
				posXAB = 634.693,
				posYAB = 366.0635,
				posX = 0.4958539,
				posY = 0.5084216,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4388325,
				sizeY = 0.8155307,
				alpha = 0,
				alphaCascade = true,
				frameStart = 0,
				frameEnd = 9,
				frameName = "uieffect/xuanzhuan_5.png",
				delay = 0.04,
				frameWidth = 171,
				frameHeight = 171,
				column = 3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "boom1",
				posX = 0.4988291,
				posY = 0.5020791,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3502053,
				sizeY = 0.8749511,
				image = "uieffect/kuai03.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lz01",
				sizeXAB = 768,
				sizeYAB = 180,
				posXAB = 1019.376,
				posYAB = 446.8574,
				posX = 0.7963876,
				posY = 0.6206353,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				angle = 360,
				angleVariance = 180,
				duration = 0.2,
				emitterType = 0,
				emissionRate = 100,
				rotationIsDir = true,
				finishColorAlpha = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				middleColorVarianceAlpha = 1,
				rotationStart = 5,
				rotationStartVariance = -20,
				rotationEnd = -150,
				finishParticleSize = 10,
				finishParticleSizeVariance = 20,
				startParticleSize = 4,
				startParticleSizeVariance = 10,
				middleParticleSize = 30,
				middleParticleSizeVariance = 60,
				maxParticles = 60,
				particleLifespan = 0.2,
				particleLifespanVariance = 0.4,
				particleLifeMiddle = 0.5,
				speed = 1000,
				speedVariance = 100,
				startColorAlpha = 0,
				textureFileName = "uieffect/067lizi.png",
				useMiddleFrame = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fangshe",
				posX = 0.4996092,
				posY = 0.5000013,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3720452,
				sizeY = 0.6600269,
				image = "uieffect/shanguang_00058.png",
				alpha = 0,
				blendFunc = 1,
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
		ka = {
			scale = {{0, {1,1,1}}, {200, {0, 1, 1}}, {400, {1,1,1}}, },
		},
	},
	xuanzhuan2 = {
		tu = {
			scale = {{0, {0.4, 0.4, 1}}, {1300, {0.6, 0.6, 1}}, {1500, {1,1,1}}, },
			alpha = {{0, {0}}, {1450, {0}}, {1600, {1}}, },
		},
		kpd = {
			scale = {{0, {0.4, 0.4, 1}}, {1300, {0.6, 0.6, 1}}, {1500, {1,1,1}}, },
			alpha = {{0, {0}}, {1450, {0}}, {1600, {1}}, },
		},
		xz = {
			alpha = {{0, {1}}, {1400, {1}}, {1600, {0}}, },
			scale = {{0, {0.25, 0.25, 1}}, {1300, {0.95, 0.95, 1}}, {1500, {1,1,1}}, },
		},
		boom1 = {
			alpha = {{0, {0}}, {1200, {0}}, {1450, {1}}, {1800, {0}}, },
		},
		fangshe = {
			alpha = {{0, {0}}, {1300, {0}}, {1400, {1}}, {1700, {0}}, },
			scale = {{0, {0.3, 0.3, 1}}, {1300, {0.3, 0.3, 1}}, {1400, {1.8, 1.8, 1}}, {1600, {2, 2, 1}}, },
		},
	},
	tx = {
		boom1 = {
			alpha = {},
		},
	},
	c_dakai = {
		{0,"xuanzhuan2", 1, 0},
		{2,"lz01", 1, 1300},
	},
	c_xuanzhuan = {
		{0,"xuanzhuan2", 1, 0},
		{2,"lz01", 1, 1300},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
