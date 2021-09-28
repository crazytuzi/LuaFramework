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
			etype = "Button",
			name = "dj1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.07828281,
			sizeY = 0.1388889,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "grade_icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.98,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5119049,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "1",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "s1",
				varName = "item_count",
				posX = 0.5191829,
				posY = 0.2231578,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.755787,
				sizeY = 0.4377611,
				text = "x22",
				fontOutlineEnable = true,
				fontOutlineColor = "FF102E21",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "is_select",
				posX = 0.5,
				posY = 0.5313188,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.9474936,
				sizeY = 0.9389747,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kuang",
					posX = 0.5051912,
					posY = 0.450704,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.272491,
					sizeY = 1.4141,
					image = "uieffect/fangguanghuang1hong.png",
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lizi",
					sizeXAB = 85.38879,
					sizeYAB = 84.86016,
					posXAB = 46.70649,
					posYAB = 47.31096,
					posX = 0.4919541,
					posY = 0.5038576,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8993903,
					sizeY = 0.9037534,
					emitterType = 2,
					sourceSpeed = 70,
					finishParticleSize = 0,
					startParticleSize = 30,
					startParticleSizeVariance = 10,
					maxParticles = 20,
					particleLifespan = 1.5,
					particleLifespanVariance = 0.5,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/068lizi.png",
					playOnInit = true,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lizi2",
					sizeXAB = 85.38879,
					sizeYAB = 84.86016,
					posXAB = 46.70649,
					posYAB = 47.31096,
					posX = 0.4919541,
					posY = 0.5038576,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8993903,
					sizeY = 0.9037534,
					emitterType = 2,
					sourceSpeed = 70,
					rectangleStartIndex = 2,
					finishParticleSize = 0,
					startParticleSize = 30,
					startParticleSizeVariance = 10,
					maxParticles = 20,
					particleLifespan = 1.5,
					particleLifespanVariance = 0.5,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/068lizi.png",
					playOnInit = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "suo",
				posX = 0.1973507,
				posY = 0.2609761,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2993952,
				sizeY = 0.3,
				image = "tb#suo",
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
