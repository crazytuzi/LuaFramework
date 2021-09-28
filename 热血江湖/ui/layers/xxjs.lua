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
			etype = "Image",
			name = "sdw3",
			posX = 0.02578524,
			posY = 0.4789957,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0671875,
			sizeY = 1.172222,
			image = "dl#dk",
			flippedY = true,
		},
	},
	{
		prop = {
			etype = "Image",
			name = "dt",
			posX = 0.8721038,
			posY = 0.5000213,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2567893,
			sizeY = 0.9999999,
			image = "dl#dt",
			scale9 = true,
			scale9Left = 0.4,
			scale9Right = 0.4,
			scale9Top = 0.4,
			scale9Bottom = 0.4,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "z1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "sdw2",
				posX = 0.4594458,
				posY = 0.1254551,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4382813,
				sizeY = 0.09722222,
				image = "dl#dw",
				flippedY = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "da1",
				varName = "base_form",
				posX = 0.2668284,
				posY = 0.131031,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.065625,
				sizeY = 0.1263889,
				image = "dl#cj1",
				imageNormal = "dl#cj1",
				imagePressed = "dl#cj2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "da2",
				varName = "fash_form",
				posX = 0.3947478,
				posY = 0.131031,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.065625,
				sizeY = 0.1263889,
				image = "dl#sz1",
				imageNormal = "dl#sz1",
				imagePressed = "dl#sz2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "da3",
				varName = "full_form",
				posX = 0.5226673,
				posY = 0.131031,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.065625,
				sizeY = 0.1263889,
				image = "dl#zp1",
				imageNormal = "dl#zp1",
				imagePressed = "dl#zp2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "da4",
				varName = "xie_form",
				posX = 0.6505867,
				posY = 0.131031,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.065625,
				sizeY = 0.1263889,
				image = "dl#xp1",
				imageNormal = "dl#xp1",
				imagePressed = "dl#xp2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "yx",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "k2",
				varName = "nameNode",
				posX = 0.8786094,
				posY = 0.3202616,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3514776,
				sizeY = 0.2898,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "mzd",
					posX = 0.5,
					posY = 0.2857029,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5379077,
					sizeY = 0.2731769,
					image = "dl#mzd",
					scale9Left = 0.5,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "EditBox",
						name = "mz2",
						sizeXAB = 262.569,
						sizeYAB = 58.34549,
						posXAB = 137.105,
						posYAB = 28.49999,
						varName = "editName",
						posX = 0.5665497,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.084996,
						sizeY = 1.023605,
						fontSize = 24,
						vTextAlign = 1,
						inputHeight = 50,
						phText = "请输入角色名称",
						phFontSize = 24,
						autoWrap = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sj",
					varName = "rndName",
					posX = 0.7342298,
					posY = 0.2892556,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1711524,
					sizeY = 0.3642359,
					image = "dl#dl_sz.png",
					imageNormal = "dl#dl_sz.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a6",
				varName = "btnPlay",
				posX = 0.8786094,
				posY = 0.1238643,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1796875,
				sizeY = 0.1055556,
				image = "dl#jrjh",
				imageNormal = "dl#jrjh",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "txjd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8310683,
					sizeY = 0.8298624,
				},
				children = {
				{
					prop = {
						etype = "FrameAni",
						name = "bowen",
						sizeXAB = 221.3613,
						sizeYAB = 73.84223,
						posXAB = 95.11647,
						posYAB = 32.02992,
						posX = 0.4976124,
						posY = 0.5078506,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.158076,
						sizeY = 1.170806,
						frameEnd = 16,
						frameName = "uieffect/xulie507_l1lf.png",
						delay = 0.15,
						column = 4,
						blendFunc = 1,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "dl1",
						sizeXAB = 195.8548,
						sizeYAB = 66.4576,
						posXAB = 191.6783,
						posYAB = 64.33525,
						posX = 1.002786,
						posY = 1.020068,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.024636,
						sizeY = 1.053719,
						angle = 0,
						angleVariance = 360,
						emitterType = 0,
						sourceSpeed = 100,
						middleColorAlpha = 1,
						middleColorBlue = 1,
						middleColorGreen = 1,
						middleColorRed = 1,
						finishParticleSize = 0,
						startParticleSize = 100,
						startParticleSizeVariance = 30,
						maxParticles = 5,
						particleLifespan = 2,
						particleLifespanVariance = 1,
						particleLifeMiddle = 0.8,
						sourcePositionVariancex = 95,
						sourcePositionVariancey = 25,
						speed = 3,
						speedVariance = 1,
						textureFileName = "uieffect/lizi0411611211.png",
						useMiddleFrame = true,
						playOnInit = true,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "dl2",
						sizeXAB = 249.5539,
						sizeYAB = 234.5217,
						posXAB = 218.5736,
						posYAB = 178.7486,
						posX = 1.143492,
						posY = 2.83415,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.305569,
						sizeY = 3.718461,
						angle = 90,
						emitterType = 0,
						finishParticleSize = 0,
						startParticleSize = 40,
						startParticleSizeVariance = 10,
						maxParticles = 10,
						particleLifespan = 1,
						particleLifespanVariance = 0.5,
						sourcePositionVariancex = 100,
						speed = 10,
						speedVariance = 5,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/lizi041161121.png",
						playOnInit = true,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "dl3",
						sizeXAB = 249.5539,
						sizeYAB = 234.5217,
						posXAB = 218.5736,
						posYAB = 119.5783,
						posX = 1.143492,
						posY = 1.895974,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.305569,
						sizeY = 3.718461,
						angle = 90,
						emitterType = 0,
						finishParticleSize = 0,
						startParticleSize = 40,
						startParticleSizeVariance = 10,
						maxParticles = 10,
						particleLifespan = 1,
						particleLifespanVariance = 0.5,
						sourcePositionVariancex = 100,
						speed = -10,
						speedVariance = -5,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/lizi041161121.png",
						playOnInit = true,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "dl4",
						sizeXAB = 249.5539,
						sizeYAB = 234.5217,
						posXAB = 312.3932,
						posYAB = 148.1902,
						posX = 1.63432,
						posY = 2.349631,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.305569,
						sizeY = 3.718461,
						emitterType = 0,
						finishParticleSize = 0,
						startParticleSize = 40,
						startParticleSizeVariance = 10,
						maxParticles = 5,
						particleLifespan = 1,
						particleLifespanVariance = 0.5,
						sourcePositionVariancey = 35,
						speed = -10,
						speedVariance = -5,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/lizi041161121.png",
						playOnInit = true,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "dl5",
						sizeXAB = 249.5539,
						sizeYAB = 234.5217,
						posXAB = 126.5603,
						posYAB = 148.1889,
						posX = 0.6621143,
						posY = 2.34961,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.305569,
						sizeY = 3.718461,
						emitterType = 0,
						finishParticleSize = 0,
						startParticleSize = 40,
						startParticleSizeVariance = 10,
						maxParticles = 5,
						particleLifespan = 1,
						particleLifespanVariance = 0.5,
						sourcePositionVariancey = 35,
						speed = 10,
						speedVariance = 5,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/lizi041161121.png",
						playOnInit = true,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "nan2",
				varName = "btnFemale",
				posX = 0.933304,
				posY = 0.404463,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.06640625,
				sizeY = 0.1205409,
				image = "dl#nv4",
				imageNormal = "dl#nv4",
				imagePressed = "dl#nv2",
				imageDisable = "dl#nv4",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "nan",
				varName = "btnMale",
				posX = 0.8208333,
				posY = 0.404463,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06640625,
				sizeY = 0.1205409,
				image = "dl#nan4",
				imageNormal = "dl#nan4",
				imagePressed = "dl#nan2",
				imageDisable = "dl#nan4",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "jsms",
				varName = "outboundDesc",
				posX = 0.8722903,
				posY = 0.2088017,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2454019,
				sizeY = 0.25,
				text = "xx级以上角色",
				color = "FFFFFFC0",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			varName = "commonNode",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 4,
			layoutTypeW = 4,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "sda",
				varName = "normalClass",
				posX = 0.5,
				posY = 0.935086,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.1277778,
				layoutType = 8,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "daokeIcon",
					posX = 0.09434754,
					posY = -0.3019009,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1828125,
					sizeY = 1.043478,
					image = "dl#dk4",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp2",
					varName = "jianshiIcon",
					posX = 0.1029416,
					posY = -1.268019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1828125,
					sizeY = 1.043478,
					image = "dl#jk4",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp3",
					varName = "qianghaoIcon",
					posX = 0.1107545,
					posY = -2.234137,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1828125,
					sizeY = 1.043478,
					image = "dl#qk4",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp4",
					varName = "gongshouIcon",
					posX = 0.1177859,
					posY = -3.200254,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1828125,
					sizeY = 1.043478,
					image = "dl#gs4",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp5",
					varName = "yishiIcon",
					posX = 0.1107545,
					posY = -4.166372,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1828125,
					sizeY = 1.043478,
					image = "dl#yz4",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "btnPlayer1",
					posX = 0.09434754,
					posY = -0.301901,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1786178,
					sizeY = 0.9114168,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "btnPlayer2",
					posX = 0.1029416,
					posY = -1.268019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1786178,
					sizeY = 0.9114168,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a3",
					varName = "btnPlayer3",
					posX = 0.1107545,
					posY = -2.234137,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1786178,
					sizeY = 0.9114168,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a4",
					varName = "btnPlayer4",
					posX = 0.1177859,
					posY = -3.200254,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1786178,
					sizeY = 0.9114168,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a5",
					varName = "btnPlayer5",
					posX = 0.1107545,
					posY = -4.166372,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1786178,
					sizeY = 0.9114168,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp6",
					varName = "cikeIcon",
					posX = 0.1029416,
					posY = -5.13249,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1828125,
					sizeY = 1.043478,
					image = "dl#ci4",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a7",
					varName = "btnPlayer6",
					posX = 0.1029416,
					posY = -5.13249,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1786178,
					sizeY = 0.9114168,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp7",
					varName = "fushiIcon",
					posX = 0.09434754,
					posY = -6.098608,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1828125,
					sizeY = 1.043478,
					image = "dl#fu4",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a8",
					varName = "btnPlayer7",
					posX = 0.09434754,
					posY = -6.098608,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1786178,
					sizeY = 0.9114168,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "wz",
				varName = "outClass",
				posX = 0.1179592,
				posY = 0.4619706,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2399414,
				sizeY = 0.919528,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp8",
					varName = "fistIcon",
					posX = 0.401594,
					posY = 0.9030875,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7619047,
					sizeY = 0.1450019,
					image = "dl#qs2",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a9",
					varName = "btnPlayer8",
					posX = 0.401594,
					posY = 0.9030875,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7444226,
					sizeY = 0.1266507,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd",
			posX = 0.4999999,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zz",
				posX = 0.07803541,
				posY = 0.928167,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.153125,
				sizeY = 0.1430556,
				image = "zjm3#fhd",
				scale9Left = 0.45,
				scale9Right = 0.45,
				alphaCascade = true,
				layoutType = 8,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "ht",
					varName = "btnReturn",
					posX = 0.4833455,
					posY = 0.6924155,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9400069,
					sizeY = 0.5939342,
					layoutType = 1,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "hta",
						posX = 0.2344714,
						posY = 0.5815728,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3419428,
						sizeY = 0.8336706,
						image = "zjm3#jt",
						imageNormal = "zjm3#jt",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ys",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "mz",
				varName = "imgDesc",
				posX = 0.8832119,
				posY = 0.7358041,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1632812,
				sizeY = 0.5569444,
				image = "dl1#daoke1",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zsj",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "qh6",
				varName = "commonCareer",
				posX = 0.402842,
				posY = 0.9584861,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1507812,
				sizeY = 0.07916667,
				image = "chu1#xyq1",
				imageNormal = "chu1#xyq1",
				imagePressed = "chu1#xyq2",
				imageDisable = "chu1#xyq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz3",
					posX = 0.5,
					posY = 0.5877194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8544021,
					sizeY = 0.7393813,
					text = "常规职业",
					color = "FFFFC898",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA06448",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh7",
				varName = "extraCareer",
				posX = 0.5572759,
				posY = 0.9584861,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1507812,
				sizeY = 0.07916667,
				image = "chu1#xyq1",
				imageNormal = "chu1#xyq1",
				imagePressed = "chu1#xyq2",
				imageDisable = "chu1#xyq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz4",
					posX = 0.5,
					posY = 0.5877194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8544021,
					sizeY = 0.7393813,
					text = "外传职业",
					color = "FFFFC898",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA06448",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
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
	niao4 = {
	},
	xx = {
	},
	zz = {
		zz = {
			move = {{0, {640, 800, 0}}, {250, {640, 667.262, 0}}, {350, {640,677.262,0}}, },
			alpha = {{0, {1}}, },
		},
	},
	zz1 = {
		zz = {
			move = {{0, {640,677.262,0}}, {200, {640, 800, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"niao4", 1, 0},
	},
	c_guanbi = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
