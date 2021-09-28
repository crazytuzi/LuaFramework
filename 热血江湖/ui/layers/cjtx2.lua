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
			etype = "Particle",
			name = "guang",
			sizeXAB = 768,
			sizeYAB = 180,
			posXAB = 542.1586,
			posYAB = 742.369,
			posX = 0.4235614,
			posY = 1.031068,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.25,
			duration = 999999,
			emitterType = 0,
			finishColorBlue = 0,
			finishColorGreen = 0,
			finishColorRed = 0,
			middleColorAlpha = 1,
			middleColorBlue = 0.5019608,
			middleColorGreen = 0.5019608,
			middleColorRed = 0.5019608,
			finishParticleSize = 900,
			finishParticleSizeVariance = 300,
			startParticleSize = 700,
			startParticleSizeVariance = 150,
			maxParticles = 6,
			particleLifespanVariance = 0.3,
			particleLifeMiddle = 0.3,
			sourcePositionVariancex = 120,
			textureFileName = "uieffect/E_fangsheguang_152.png",
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
