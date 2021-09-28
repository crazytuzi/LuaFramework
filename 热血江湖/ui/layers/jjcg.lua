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
				name = "an",
				varName = "close_btn",
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
				name = "gc",
				posX = 0.5008153,
				posY = 0.4997839,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.042022,
				sizeY = 0.8517242,
				image = "uieffect/gcc.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gw",
				posX = 0.5,
				posY = 0.4930555,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4804593,
				sizeY = 0.85415,
				image = "uieffect/slg2.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gw3",
				posX = 0.5,
				posY = 0.4930555,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2917073,
				sizeY = 0.5185909,
				image = "uieffect/slg2.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gw2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4,
				sizeY = 0.7111111,
				image = "uieffect/slg.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gxjj2",
				posX = 0.5007802,
				posY = 0.4916823,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2164063,
				sizeY = 0.1152778,
				image = "uieffect/gxjj.png",
				alpha = 0,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jqtx",
			posX = 0.5,
			posY = 0.7829809,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.8,
			sizeY = 0.8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bao3",
				posX = 0.497961,
				posY = 0.1336463,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3355635,
				sizeY = 0.5356842,
				image = "uieffect/shanguang_00058.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bao4",
				posX = 0.4999103,
				posY = 0.1319487,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3706622,
				sizeY = 0.5917147,
				image = "uieffect/004guangyun.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bao6",
				posX = 0.4990249,
				posY = 0.1308135,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3392845,
				sizeY = 0.5416242,
				image = "uieffect/028_guangyun.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 614.4,
				sizeYAB = 144,
				posXAB = 820.0402,
				posYAB = 149.6748,
				posX = 0.8008205,
				posY = 0.2598521,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				angle = 0,
				angleVariance = 360,
				duration = 0.5,
				emissionRate = 1000,
				finishParticleSize = 0,
				startParticleSize = 200,
				startParticleSizeVariance = 30,
				maxParticles = 10,
				maxRadius = 40,
				maxRadiusVariance = 40,
				minRadius = 150,
				minRadiusVariance = 100,
				particleLifespan = 0.5,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/lizi041161121.png",
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
	gxjj = {
		gxjj2 = {
			alpha = {{0, {1}}, {1400, {1}}, {2000, {0}}, },
			scale = {{0, {10, 10, 1}}, {200, {0.9, 0.9, 1}}, {250, {1,1,1}}, },
			move = {{0, {640.9987,354.0113,0}}, {1300, {640.9987,354.0113,0}}, {3000, {640.9987, 500, 0}}, },
		},
	},
	gw2 = {
		gw2 = {
			alpha = {{0, {1}}, {900, {0}}, {1400, {0}}, },
			rotate = {{0, {0}}, {5000, {180}}, {7500, {270}}, {10000, {0}}, },
		},
	},
	gw3 = {
		gw3 = {
			alpha = {{0, {1}}, {800, {1}}, {1400, {0}}, },
		},
	},
	gw = {
		gw = {
			alpha = {{0, {1}}, {800, {1}}, {1400, {0}}, },
		},
	},
	gc = {
		gc = {
			scale = {{0, {0, 1, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {1000, {1}}, {1400, {0}}, },
		},
	},
	bao = {
		bao3 = {
			scale = {{0, {1, 1, 1}}, {150, {2, 2, 1}}, },
			alpha = {{0, {1}}, {500, {0}}, },
		},
	},
	bao2 = {
		bao4 = {
			scale = {{0, {1, 1, 1}}, {200, {8, 8, 1}}, },
			alpha = {{50, {1}}, {200, {0}}, },
		},
	},
	bao4 = {
		bao6 = {
			alpha = {{0, {1}}, {500, {0}}, },
			scale = {{0, {0, 0, 1}}, {50, {1, 1, 1}}, {500, {1.5, 1.5, 1}}, },
		},
	},
	c_dakai = {
		{0,"gxjj", 1, 0},
		{0,"gw2", 1, 200},
		{0,"gw3", 1, 200},
		{0,"gw", 1, 200},
		{0,"gc", 1, 200},
		{0,"bao", 1, 200},
		{0,"bao4", 1, 200},
		{2,"lizi", 1, 200},
		{0,"bao2", 1, 150},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
