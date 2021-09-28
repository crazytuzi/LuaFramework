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
			posX = 0.5,
			posY = 0.7690032,
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
				posX = 0.5,
				posY = 0.4986111,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.08888889,
				image = "uieffect/sjfs.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1960938,
				sizeY = 0.09027778,
				image = "guiying#cg",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1960938,
				sizeY = 0.09027778,
				image = "guiying#cg",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj3",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1960938,
				sizeY = 0.09027778,
				image = "guiying#cg",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shibai",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1960938,
				sizeY = 0.09027778,
				image = "guiying#sb",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jqtx",
				posX = 0.5,
				posY = 0.4973383,
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
					posX = 0.5038109,
					posY = 0.4820316,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2530461,
					sizeY = 0.4039557,
					image = "uieffect/shanguang_00058.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao4",
					posX = 0.5008854,
					posY = 0.4855348,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2840909,
					sizeY = 0.4535147,
					image = "uieffect/004guangyun.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao6",
					posX = 0.5,
					posY = 0.4861332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2840909,
					sizeY = 0.4535147,
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
					posXAB = 818.0431,
					posYAB = 352.3419,
					posX = 0.7988702,
					posY = 0.6117046,
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
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	sj = {
		sj = {
			scale = {{0, {12, 12, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, {2200, {1}}, {3000, {0}}, },
		},
	},
	sj2 = {
		sj2 = {
			scale = {{0, {8, 8, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, {150, {1}}, {200, {0}}, },
		},
	},
	sj3 = {
		sj3 = {
			alpha = {{0, {1}}, {300, {0}}, },
			scale = {{0, {1,1,1}}, {300, {2, 2, 1}}, },
		},
	},
	gc = {
		gc = {
			scale = {{0, {1,1,1}}, {50, {3, 3, 1}}, {1200, {3.5, 3.5, 1}}, },
			alpha = {{0, {1}}, {1200, {0}}, },
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
	shibai = {
		shibai = {
			alpha = {{0, {1}}, {1200, {1}}, {1300, {0}}, },
		},
	},
	c_chenggong = {
		{0,"sj", 1, 0},
		{0,"sj2", 1, 50},
		{0,"sj3", 1, 150},
		{0,"gc", 1, 150},
		{0,"bao", 1, 150},
		{0,"bao4", 1, 150},
		{0,"bao2", 1, 200},
		{2,"lizi", 1, 200},
	},
	c_shibai = {
		{0,"shibai", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
