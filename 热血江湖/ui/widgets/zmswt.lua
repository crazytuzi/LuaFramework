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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1791667,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dj1",
				varName = "bt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dk",
					varName = "grade_icon",
					posX = 0.5,
					posY = 0.5763735,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.95,
					sizeY = 0.7441859,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tp1",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5417355,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
						image = "items#items_gaojijinengshu.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "s1",
						varName = "item_count",
						posX = 0.5159578,
						posY = 0.2241789,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8087566,
						sizeY = 0.4263349,
						text = "+1000",
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "s2",
					varName = "args_count",
					posX = 0.5,
					posY = 0.1390014,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.2585237,
					text = "x200",
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gy",
				posX = 0.4999907,
				posY = 0.5812622,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.198041,
				sizeY = 1.044797,
				image = "uieffect/fangguanghuang1lv.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 60,
				sizeYAB = 32.25001,
				posXAB = 78.95239,
				posYAB = 53.51937,
				posX = 0.7895239,
				posY = 0.4148788,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				angle = 90,
				duration = 0.35,
				emitterType = 0,
				emissionRate = 100,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 0,
				startParticleSize = 50,
				startParticleSizeVariance = 20,
				maxParticles = 20,
				particleLifespan = 0.35,
				particleLifeMiddle = 0.5,
				sourcePositionVariancex = 43,
				speed = 250,
				speedVariance = 30,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/lizi0416121.png",
				useMiddleFrame = true,
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
	gy = {
		gy = {
			alpha = {{0, {1}}, {200, {1}}, {500, {0}}, },
		},
	},
	c_shiyong = {
		{0,"gy", 1, 0},
		{2,"lizi", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
