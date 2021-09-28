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
			etype = "Grid",
			name = "ysjm",
			posX = 0.7410105,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.5225798,
			sizeY = 0.5225798,
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
				sizeX = 0.2581564,
				sizeY = 0.6245723,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kpd",
					varName = "cover",
					posX = 0.5,
					posY = 0.5040184,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.270521,
					sizeY = 1.058344,
					image = "smkp#baoxiang",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu",
					varName = "image",
					posX = 0.5,
					posY = 0.5118732,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.270521,
					sizeY = 1.058344,
					image = "smkp#qiapian2",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text1",
					varName = "name",
					posX = 0.4999998,
					posY = 0.9546466,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9764271,
					sizeY = 0.1972202,
					text = "卡",
					color = "FF410B0B",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xz1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 3.098898,
					sizeY = 2.277115,
					image = "uieffect/35ba0e68_0.png",
					alpha = 0,
					blendFunc = 1,
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
				sizeXAB = 373.8335,
				sizeYAB = 390.7893,
				posXAB = 331.6777,
				posYAB = 191.2974,
				posX = 0.4958539,
				posY = 0.5084216,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5588762,
				sizeY = 1.038622,
				alpha = 0,
				alphaCascade = true,
				frameStart = 0,
				frameEnd = 9,
				frameName = "uieffect/xuanzhuan_8.png",
				delay = 0.03,
				frameWidth = 171,
				frameHeight = 171,
				column = 3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "boom1",
				posX = 0.4992523,
				posY = 0.5066326,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3955211,
				sizeY = 0.8464333,
				image = "uieffect/kuai03.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lz01",
				sizeXAB = 401.3413,
				sizeYAB = 94.06436,
				posXAB = 532.7053,
				posYAB = 233.5186,
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
		text1 = {
			alpha = {{0, {0}}, {1500, {0}}, {1600, {1}}, },
		},
	},
	tx = {
		boom1 = {
			alpha = {},
		},
	},
	xiaoshi = {
		ka = {
			scale = {{0, {1,1,1}}, {100, {1.1, 1.1, 1}}, {600, {0.6, 0.6, 1}}, {750, {0.4, 0.4, 1}}, {800, {0, 0, 1}}, },
			rotate = {{0, {0}}, {250, {180}}, {500, {360}}, {650, {540}}, {800, {720}}, },
			moveP = {{0, {0.5,0.5,0}}, {800, {0.5298497,1.349087,0}}, },
		},
		kpd = {
			alpha = {{0, {0}}, },
		},
		tu = {
			alpha = {{0, {1}}, },
		},
		xz1 = {
			alpha = {{0, {0}}, {200, {1}}, {600, {1}}, {800, {0}}, },
		},
	},
	c_dakai = {
		{0,"xuanzhuan2", 1, 0},
		{2,"lz01", 1, 1300},
		{0,"xiaoshi", 1, 2500},
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
