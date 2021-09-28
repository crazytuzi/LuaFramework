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
			name = "buffj",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0390625,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djk2",
					varName = "icon",
					posX = 0.5099561,
					posY = 0.5099679,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8186572,
					sizeY = 0.8186567,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zz",
					varName = "grayImg",
					posX = 0.5099561,
					posY = 0.5099686,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.8186572,
					sizeY = 0.8186567,
					image = "b#dd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.5,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "djan",
				varName = "btn",
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
				name = "zbqh",
				posX = 1.957556,
				posY = -1.476724,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 5.550835,
				sizeY = 5.940368,
			},
			children = {
			{
				prop = {
					etype = "Particle",
					name = "lz3",
					sizeXAB = 0,
					sizeYAB = 0,
					posXAB = 0,
					posYAB = 0,
					posX = 0.5385876,
					posY = 0.9583071,
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
					sourcePositionVariancex = 40,
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
					posX = 0.2386247,
					posY = 0.8322521,
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
					name = "bao3",
					posX = 0.2386318,
					posY = 0.8322473,
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
					name = "bao4",
					posX = 0.2386052,
					posY = 0.8371702,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1508594,
					sizeY = 0.1407467,
					image = "uieffect/0juhuang.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao5",
					posX = 0.2385736,
					posY = 0.837175,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1508594,
					sizeY = 0.1407467,
					image = "uieffect/png_10218waihuanguangquan.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao6",
					posX = 0.2385736,
					posY = 0.8371587,
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
					sizeXAB = 0,
					sizeYAB = 0,
					posXAB = 0,
					posYAB = 0,
					posX = 0.5385929,
					posY = 0.9549924,
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
					textureFileName = "uieffect/c1.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao8",
					posX = 0.2385981,
					posY = 0.8322451,
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
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
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
		bao4 = {
			alpha = {{0, {1}}, {100, {1}}, {800, {0}}, },
		},
	},
	bao5 = {
		bao5 = {
			scale = {{0, {1,1,1}}, {150, {10, 10, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
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
