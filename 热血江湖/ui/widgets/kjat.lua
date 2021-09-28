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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.05859375,
			sizeY = 0.1041667,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "kjat",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
			},
			children = {
			{
				prop = {
					etype = "Particle",
					name = "lizi",
					sizeXAB = 27,
					sizeYAB = 4.687501,
					posXAB = 32.5239,
					posYAB = 6.380496,
					posX = 0.7227533,
					posY = 0.340293,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					alpha = 0,
					angle = 0,
					angleVariance = 360,
					duration = 999999,
					finishColorAlpha = 0,
					middleColorAlpha = 0.6,
					middleColorBlue = 1,
					middleColorGreen = 1,
					middleColorRed = 1,
					rotationStart = 20,
					rotationStartVariance = 40,
					finishParticleSize = 180,
					finishParticleSizeVariance = 20,
					startParticleSize = 120,
					startParticleSizeVariance = 20,
					gravityy = 40,
					maxParticles = 3,
					minRadius = 0,
					particleLifespan = 1,
					particleLifespanVariance = 0.3,
					particleLifeMiddle = 0.4,
					startColorAlpha = 0,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/shousuo3.png",
					useMiddleFrame = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu4",
					posX = 0.4942002,
					posY = 0.5092058,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4,
					sizeY = 10,
					image = "uieffect/001guangyun.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu5",
					posX = 0.4942002,
					posY = 0.5092058,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.5,
					sizeY = 9,
					image = "uieffect/016fangshe.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu6",
					posX = 0.4942002,
					posY = 0.5092058,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3,
					sizeY = 8,
					image = "uieffect/shanguang_00058.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu1",
					posX = 0.4720106,
					posY = 0.5624606,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.466667,
					sizeY = 5.919998,
					image = "uieffect/023gy.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu2",
					posX = 0.471091,
					posY = 0.5089773,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.911111,
					sizeY = 6.986665,
					image = "uieffect/34d5bb3a1.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lizi2",
					sizeXAB = 27,
					sizeYAB = 4.687501,
					posXAB = 32.5239,
					posYAB = 6.380496,
					posX = 0.7227533,
					posY = 0.340293,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					alpha = 0,
					angle = 0,
					angleVariance = 360,
					duration = 999999,
					rotationStartVariance = 100,
					finishParticleSize = 0,
					startParticleSize = 40,
					startParticleSizeVariance = 10,
					gravityy = 40,
					maxParticles = 10,
					maxRadius = 30,
					maxRadiusVariance = 10,
					minRadius = 60,
					minRadiusVariance = 20,
					particleLifespan = 0.6,
					particleLifespanVariance = 0.3,
					sourcePositionVariancex = 25,
					sourcePositionVariancey = 25,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/067lizi.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bt6",
				varName = "click_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				alphaCascade = true,
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xhd3",
					varName = "red_point",
					posX = 0.8732998,
					posY = 0.8302884,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.35,
					image = "zdte#hd",
					alphaCascade = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ym",
					varName = "isFull",
					posX = 0.2370312,
					posY = 0.7593898,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5333334,
					sizeY = 0.5333332,
					image = "zdte#man",
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
	tu1 = {
		tu1 = {
			alpha = {{0, {1}}, },
			rotate = {{0, {0}}, {1500, {-180}}, {2250, {-270}}, {3000, {0}}, },
		},
	},
	tu2 = {
		tu2 = {
			alpha = {{0, {1}}, },
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
		},
	},
	tu5 = {
		tu5 = {
			alpha = {{0, {1}}, },
			rotate = {{0, {0}}, {4000, {-180}}, {6000, {-270}}, {8000, {-360}}, },
		},
	},
	tu6 = {
		tu6 = {
			alpha = {{0, {1}}, },
			rotate = {{0, {0}}, {5000, {180}}, {7500, {270}}, {10000, {360}}, },
		},
	},
	tu4 = {
		tu4 = {
			alpha = {{0, {1}}, },
			rotate = {{0, {0}}, {1500, {-180}}, {2250, {-270}}, {3000, {0}}, },
		},
	},
	c_ss = {
		{2,"lizi", 1, 0},
		{0,"tu6", -1, 0},
		{0,"tu5", -1, 0},
		{0,"tu4", -1, 0},
		{2,"lizi2", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
