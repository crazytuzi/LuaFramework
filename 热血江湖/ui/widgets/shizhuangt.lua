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
			name = "k1",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.09671412,
			sizeY = 0.2192937,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "das",
				varName = "is_select",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "state",
				posX = 0.5080567,
				posY = 0.4971654,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 0.25,
				color = "FF029133",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "item_btn",
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
				etype = "Image",
				name = "bpsdt",
				varName = "item_root",
				posX = 0.5007961,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.945118,
				sizeY = 0.9120189,
				image = "bg2#szd",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "item_bg",
					posX = 0.5,
					posY = 0.6309454,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6837607,
					sizeY = 0.5555556,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zt",
					varName = "activation",
					posX = 0.3554593,
					posY = 0.789676,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6752137,
					sizeY = 0.4027778,
					image = "bg2#yzb",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zt2",
				varName = "no_have",
				posX = 0.3641883,
				posY = 0.7641902,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6381566,
				sizeY = 0.367341,
				image = "bg2#kjh",
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 74.27644,
				sizeYAB = 39.47287,
				posXAB = 97.90655,
				posYAB = 112.9482,
				varName = "lizi",
				posX = 0.7908824,
				posY = 0.7153535,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				duration = 999999,
				emitterType = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 0,
				startParticleSize = 30,
				startParticleSizeVariance = 10,
				middleParticleSize = 20,
				middleParticleSizeVariance = 10,
				maxParticles = 10,
				particleLifespan = 1.5,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.3,
				sourcePositionVariancex = 35,
				sourcePositionVariancey = 10,
				textureFileName = "uieffect/lizi0416121.png",
				useMiddleFrame = true,
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "item_name",
				posX = 0.5,
				posY = 0.2045677,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.412174,
				sizeY = 0.25,
				text = "名字最长七个字",
				color = "FF404040",
				fontSize = 18,
				fontOutlineColor = "FF614A31",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yc",
				varName = "have_spinning",
				posX = 0.3640427,
				posY = 0.7579024,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6381566,
				sizeY = 0.367341,
				image = "bg2#yichu",
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
	zt2 = {
		zt2 = {
			scale = {{0, {1,1,1}}, {500, {1.1, 1.1, 1}}, {1000, {1,1,1}}, },
		},
	},
	c_dakai = {
		{2,"lizi", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
