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
			sizeY = 0.127582,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "task_btn",
				posX = 0.3741981,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7663796,
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
				posX = 0.5120153,
				posY = 0.8022403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9821232,
				sizeY = 0.3147482,
				text = "限时名字",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs",
				varName = "time_label",
				posX = 0.498707,
				posY = 0.4990912,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9555068,
				sizeY = 0.3147482,
				text = "5:45",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z3",
				varName = "des2",
				posX = 0.5061647,
				posY = 0.1959422,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9704218,
				sizeY = 0.3147482,
				text = "限时：",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "itembg",
				posX = 0.8744696,
				posY = 0.6412324,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2421875,
				sizeY = 0.6749471,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "itemIcon",
					posX = 0.5027909,
					posY = 0.5142337,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8310239,
					sizeY = 0.8334405,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ss",
					varName = "overIcon",
					posX = 0.7738361,
					posY = 0.7576369,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.4032258,
					sizeY = 0.4032258,
					image = "chu1#ss",
				},
			},
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 246.5942,
				sizeYAB = 82.08465,
				posXAB = 125.5033,
				posYAB = 45.92952,
				varName = "effect1",
				posX = 0.4902473,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
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
