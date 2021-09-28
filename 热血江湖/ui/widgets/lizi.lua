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
			name = "lizi10",
			sizeXAB = 114.5697,
			sizeYAB = 96.19762,
			posXAB = 697.7102,
			posYAB = 408.6084,
			posX = 0.5450861,
			posY = 0.5675116,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08950762,
			sizeY = 0.1336078,
			angle = 90,
			angleVariance = 360,
			finishParticleSize = 0,
			startParticleSize = 80,
			startParticleSizeVariance = 20,
			maxParticles = 15,
			minRadius = 20,
			minRadiusVariance = 10,
			particleLifespan = 1,
			particleLifespanVariance = 0.4,
			startColorBlue = 1,
			startColorGreen = 1,
			startColorRed = 1,
			textureFileName = "uieffect/067lizi.png",
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
