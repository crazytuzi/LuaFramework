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
			name = "jn1",
			posX = 0.4964897,
			posY = 0.4823206,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1193356,
			sizeY = 0.2197779,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jnk1",
				varName = "borderIcon",
				posX = 0.5,
				posY = 0.5821534,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8510662,
				sizeY = 0.7583414,
				image = "qs#jndc",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnt1",
				varName = "icon",
				posX = 0.5,
				posY = 0.5821534,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5237331,
				sizeY = 0.5055609,
				image = "skillquan#bailichongquan",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "js",
				varName = "title",
				posX = 0.5,
				posY = 0.8866481,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1.031739,
				sizeY = 0.3317811,
				text = "解锁",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "js2",
				varName = "name",
				posX = 0.5,
				posY = 0.1038929,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9523774,
				sizeY = 0.337973,
				text = "技能名称",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "fydjtx",
				varName = "equipAni",
				posX = 0.5059211,
				posY = 0.5630635,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4582664,
				sizeY = 0.4423658,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ring",
					posX = 0.490469,
					posY = 0.4795184,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4.036408,
					sizeY = 3.663274,
					image = "uieffect/fangsheguang01.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "glow1",
					posX = 0.5236626,
					posY = 0.5261328,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4.036408,
					sizeY = 3.663274,
					image = "uieffect/xinjia019.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ring2",
					posX = 0.470217,
					posY = 0.4856417,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4.036408,
					sizeY = 3.663274,
					image = "uieffect/waves32.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "shan",
					sizeXAB = 0,
					sizeYAB = 0,
					posXAB = 0,
					posYAB = 0,
					posX = 0.3351667,
					posY = 0.3625004,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = -0.4482242,
					sizeY = -0.4750153,
					angle = 270,
					angleVariance = 180,
					duration = 0.15,
					emitterType = 0,
					emissionRate = 300,
					rotationIsDir = true,
					finishParticleSize = 10,
					startParticleSize = 50,
					maxParticles = 30,
					particleLifespan = 0.2,
					particleLifespanVariance = 0.15,
					radialAccelVariance = 30,
					radialAcceleration = 15,
					speed = 400,
					speedVariance = 200,
					tangentialAccelVariance = 30,
					tangentialAcceleration = 15,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/lizi0416111.png",
					preAlpha = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "glow02",
					posX = 0.5670813,
					posY = 0.4857395,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 7.477143,
					sizeY = 1.571481,
					image = "uieffect/81111.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "glow3",
					posX = 0.5198662,
					posY = 0.4857402,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 7.477143,
					sizeY = 1.571481,
					image = "uieffect/guangyun030.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "glow2",
					posX = 0.4922116,
					posY = 0.4832829,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4.036408,
					sizeY = 3.663274,
					image = "uieffect/016fangshe.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
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
	fydjtx = {
		ring = {
			scale = {{0, {0.1, 0.1, 1}}, {150, {1, 1, 1}}, {400, {1.4, 1.4, 1}}, },
			alpha = {{0, {1}}, {150, {1}}, {400, {0}}, },
		},
		glow1 = {
			scale = {{0, {1.5, 1.5, 1}}, {100, {1, 1, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
		ring2 = {
			scale = {{0, {0.2, 0.2, 1}}, {400, {1.5, 1.5, 1}}, },
			alpha = {{0, {1}}, {200, {1}}, {350, {0}}, },
		},
		glow02 = {
			scale = {{0, {0, 0, 1}}, {50, {0.1, 0.1, 1}}, {100, {0.6, 1, 1}}, {350, {1.4, 0, 1}}, },
		},
		glow3 = {
			scale = {{0, {0, 0, 1}}, {50, {0.1, 0.1, 1}}, {150, {0.6, 1, 1}}, {300, {1.4, 0, 1}}, },
		},
		glow2 = {
			scale = {{0, {1.5, 1.5, 1}}, {100, {1, 1, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
	},
	c_jztx = {
		{2,"shan", 1, 0},
		{0,"fydjtx", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
