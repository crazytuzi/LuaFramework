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
			posY = 0.7454293,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "slg2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.46174,
				sizeY = 0.8208712,
				image = "uieffect/slg2.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "slc",
				posX = 0.4967325,
				posY = 0.4964767,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9502563,
				sizeY = 0.5283551,
				image = "uieffect/slc.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "slg",
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
				name = "sl",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/cg.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 768,
				sizeYAB = 180,
				posXAB = 1021.372,
				posYAB = 431.8735,
				posX = 0.7979469,
				posY = 0.5998243,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				duration = 999999,
				emitterType = 0,
				rotationStartVariance = 50,
				finishParticleSize = 0,
				startParticleSize = 100,
				startParticleSizeVariance = 30,
				gravityy = 80,
				maxParticles = 8,
				particleLifespan = 1,
				particleLifespanVariance = 0.3,
				sourcePositionVariancex = 150,
				sourcePositionVariancey = 80,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/lizi041161121.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sl2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/cg.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pjc",
				posX = 0.5010071,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5065268,
				sizeY = 0.3555556,
				image = "uieffect/pjc.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pjq",
				posX = 0.4992262,
				posY = 0.4986034,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/pjq.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/pj.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pj2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/pj.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sb",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/sb.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sb2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/sb.png",
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
	slg = {
		slg = {
			rotate = {{0, {0}}, {6000, {180}}, {9000, {270}}, {12000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	sl = {
		sl = {
			scale = {{0, {10, 10, 1}}, {150, {0.8, 0.8, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	slg2 = {
		slg2 = {
			alpha = {{0, {1}}, },
			scale = {{0, {0, 0, 1}}, {200, {1,1,1}}, },
		},
	},
	slc = {
		slc = {
			alpha = {{0, {1}}, },
			scale = {{0, {1, 0, 1}}, {100, {1,1,1}}, },
		},
	},
	sl2 = {
		sl2 = {
			alpha = {{0, {1}}, {300, {0}}, },
			scale = {{0, {1,1,1}}, {300, {2, 2, 1}}, },
		},
	},
	pj = {
		pj = {
			scale = {{0, {10, 10, 1}}, {150, {0.8, 0.8, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	pjc = {
		pjc = {
			alpha = {{0, {1}}, },
			scale = {{0, {1, 0, 1}}, {100, {1,1,1}}, },
		},
	},
	pjg = {
		pjq = {
			alpha = {{0, {1}}, },
		},
	},
	pj2 = {
		pj2 = {
			alpha = {{0, {1}}, {250, {0}}, },
			scale = {{0, {1,1,1}}, {250, {1.5, 1.5, 1}}, },
		},
	},
	sb = {
		sb = {
			scale = {{0, {10, 10, 1}}, {150, {0.8, 0.8, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	sb2 = {
		sb2 = {
			alpha = {{0, {1}}, {250, {0}}, },
			scale = {{0, {1,1,1}}, {250, {1.5, 1.5, 1}}, },
		},
	},
	c_sl = {
		{0,"slg", 1, 100},
		{0,"slg2", 1, 50},
		{0,"slc", 1, 100},
		{0,"sl", 1, 0},
		{2,"lizi", 1, 150},
		{0,"sl2", 1, 150},
	},
	c_pj = {
		{0,"pjc", 1, 100},
		{0,"pjg", 1, 100},
		{0,"pj", 1, 0},
		{0,"pj2", 1, 150},
	},
	c_sb = {
		{0,"sb", 1, 0},
		{0,"sb2", 1, 150},
		{0,"pjc", 1, 100},
		{0,"pjg", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
