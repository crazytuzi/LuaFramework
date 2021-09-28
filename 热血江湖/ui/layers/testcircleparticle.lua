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
			name = "ttt",
			sizeXAB = 301.1361,
			sizeYAB = 212.7987,
			posXAB = 410.561,
			posYAB = 489.3613,
			posX = 0.3207508,
			posY = 0.6796685,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2352626,
			sizeY = 0.2955538,
			startParticleSize = 64,
			maxParticles = 200,
			maxRadius = 123,
			minRadius = 123,
			particleLifespan = 10,
			rotatePerSecond = 60,
			startColorBlue = 1,
			startColorGreen = 1,
			startColorRed = 1,
			textureFileName = "uieffect/003guangyun.png",
			playOnInit = true,
		},
	},
	{
		prop = {
			etype = "Image",
			name = "dummy",
			posX = 0.9033876,
			posY = 0.1485974,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.121387,
			sizeY = 0.1236135,
			image = "zd.png",
		},
	},
	{
		prop = {
			etype = "Label",
			name = "sdfsdf",
			posX = 0.7871713,
			posY = 0.672734,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3506975,
			sizeY = 0.3593379,
			text = "燕子",
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
