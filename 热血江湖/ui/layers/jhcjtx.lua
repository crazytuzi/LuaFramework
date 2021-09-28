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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 768,
				sizeYAB = 328.6079,
				posXAB = 1025.367,
				posYAB = 691.8812,
				posX = 0.8010677,
				posY = 0.9609461,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.4563999,
				angle = -90,
				angleVariance = 30,
				blendFuncDestination = 771,
				emitterType = 0,
				rotationStartVariance = 80,
				finishParticleSize = 0,
				startParticleSize = 60,
				startParticleSizeVariance = 20,
				maxParticles = 10,
				particleLifespan = 3,
				particleLifespanVariance = 1,
				sourcePositionVariancex = 600,
				sourcePositionVariancey = 200,
				speed = 100,
				speedVariance = 50,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/fk1.png",
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi2",
				sizeXAB = 768,
				sizeYAB = 328.6079,
				posXAB = 1025.367,
				posYAB = 699.8685,
				posX = 0.8010677,
				posY = 0.9720396,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.4563999,
				angle = -90,
				angleVariance = 30,
				blendFuncDestination = 771,
				emitterType = 0,
				rotationStartVariance = 80,
				finishParticleSize = 0,
				startParticleSize = 60,
				startParticleSizeVariance = 20,
				maxParticles = 10,
				particleLifespan = 3,
				particleLifespanVariance = 1,
				sourcePositionVariancex = 600,
				sourcePositionVariancey = 200,
				speed = 100,
				speedVariance = 50,
				startColorBlue = 1,
				startColorGreen = 1,
				startColorRed = 1,
				textureFileName = "uieffect/fk2.png",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
