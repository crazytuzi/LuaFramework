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
			etype = "Particle",
			name = "huoxing",
			sizeXAB = 0,
			sizeYAB = 0,
			posXAB = 0,
			posYAB = 0,
			posX = 0.7417906,
			posY = 0.2545705,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.25,
			angle = 45,
			angleVariance = 30,
			emitterType = 0,
			finishParticleSize = 0,
			startParticleSize = 70,
			startParticleSizeVariance = 30,
			maxParticles = 15,
			particleLifespan = 2,
			particleLifespanVariance = 1,
			particleLifeMiddle = 0.3,
			sourcePositionVariancex = 700,
			sourcePositionVariancey = 50,
			speed = 200,
			speedVariance = 50,
			startColorBlue = 1,
			startColorGreen = 1,
			startColorRed = 1,
			textureFileName = "uieffect/067lizi.png",
			useMiddleFrame = true,
			playOnInit = true,
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
