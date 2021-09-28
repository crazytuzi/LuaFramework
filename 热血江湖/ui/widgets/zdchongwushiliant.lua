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
			name = "d",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2,
			sizeY = 0.1082084,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "task_btn",
				posX = 0.4910083,
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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#rwd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z1",
				varName = "taskName",
				posX = 0.5120159,
				posY = 0.7266938,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9821232,
				sizeY = 0.5620952,
				text = "主线 名字",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z2",
				varName = "taskDesc",
				posX = 0.5120158,
				posY = 0.3118058,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9821232,
				sizeY = 0.580274,
				text = "小描述",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 246.5942,
				sizeYAB = 69.61992,
				posXAB = 125.5033,
				posYAB = 38.95502,
				varName = "effect1",
				posX = 0.4902473,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9632587,
				sizeY = 0.8935936,
				angle = 0,
				emitterType = 2,
				emissionRate = 300,
				positionType = 1,
				cwRectangle = true,
				sourceSpeed = 180,
				widthRectangle = 260,
				heightRectangle = 50,
				finishColorAlpha = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				middleColorVarianceAlpha = 1,
				rotationStartVariance = 30,
				finishParticleSize = 0,
				finishParticleSizeVariance = 8,
				startParticleSize = 28,
				startParticleSizeVariance = 10,
				middleParticleSize = 10,
				middleParticleSizeVariance = 15,
				maxParticles = 300,
				particleLifespan = 0.7,
				particleLifespanVariance = 0.3,
				particleLifeMiddle = 0.4,
				speed = 100,
				speedVariance = 20,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/124lizi1.png",
				useMiddleFrame = true,
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs",
				varName = "time_label",
				posX = 0.7359369,
				posY = 0.3006951,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4250822,
				sizeY = 0.580274,
				text = "5:45",
				fontSize = 22,
				hTextAlign = 2,
				vTextAlign = 1,
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
	c_dakai = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
