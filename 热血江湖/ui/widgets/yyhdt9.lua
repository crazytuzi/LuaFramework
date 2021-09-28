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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7101563,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "shouchong",
				varName = "ShouChong",
				posX = 0.5000001,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9988998,
				sizeY = 0.8625783,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sct",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 1.345503,
					image = "shouchongsonglibanner#shouchongsonglibanner",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dr2",
					posX = 0.2690767,
					posY = 0.1128073,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3716364,
					sizeY = 0.4234791,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj1",
						varName = "item_bg",
						posX = 0.1994346,
						posY = 0.8140938,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2370751,
						sizeY = 0.4768869,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt1",
							varName = "item_icon",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an1",
							varName = "Btn1",
							posX = 0.5,
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
							name = "sld",
							varName = "count_bg",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8617022,
							sizeY = 0.2765957,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo7",
							varName = "Item_suo",
							posX = 0.1936149,
							posY = 0.2402985,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3723404,
							sizeY = 0.3723404,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl",
							varName = "item_count",
							posX = 0.5257913,
							posY = 0.2213165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj2",
						varName = "item_bg2",
						posX = 0.5123966,
						posY = 0.8140938,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2370751,
						sizeY = 0.4768869,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt2",
							varName = "item_icon2",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an3",
							varName = "Btn2",
							posX = 0.5,
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
							name = "sld2",
							varName = "count_bg2",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8617021,
							sizeY = 0.2765957,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo6",
							varName = "Item_suo2",
							posX = 0.1936149,
							posY = 0.2402985,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3723404,
							sizeY = 0.3723404,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl2",
							varName = "item_count2",
							posX = 0.5257913,
							posY = 0.2213165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj3",
						varName = "item_bg3",
						posX = 0.8253586,
						posY = 0.8140938,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2370751,
						sizeY = 0.4768869,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt3",
							varName = "item_icon3",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an4",
							varName = "Btn3",
							posX = 0.4873505,
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
							name = "sld3",
							varName = "count_bg3",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8617021,
							sizeY = 0.2765957,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo5",
							varName = "Item_suo3",
							posX = 0.1936149,
							posY = 0.2402985,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3723404,
							sizeY = 0.3723404,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl3",
							varName = "item_count3",
							posX = 0.5257913,
							posY = 0.2213165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj4",
						varName = "item_bg4",
						posX = 0.1994346,
						posY = 0.25067,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2370751,
						sizeY = 0.4768869,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt4",
							varName = "item_icon4",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an5",
							varName = "Btn4",
							posX = 0.5,
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
							name = "sld4",
							varName = "count_bg4",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8617021,
							sizeY = 0.2765957,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo4",
							varName = "Item_suo4",
							posX = 0.1936149,
							posY = 0.2402985,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3684211,
							sizeY = 0.3645834,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl4",
							varName = "item_count4",
							posX = 0.5257913,
							posY = 0.2213165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj5",
						varName = "item_bg5",
						posX = 0.5123966,
						posY = 0.25067,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2370751,
						sizeY = 0.4768869,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt5",
							varName = "item_icon5",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an6",
							varName = "Btn5",
							posX = 0.5,
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
							name = "sld5",
							varName = "count_bg5",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8617021,
							sizeY = 0.2765957,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo3",
							varName = "Item_suo5",
							posX = 0.1936149,
							posY = 0.2402985,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3723404,
							sizeY = 0.3723404,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl5",
							varName = "item_count5",
							posX = 0.5257913,
							posY = 0.2213165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj6",
						varName = "item_bg6",
						posX = 0.8253586,
						posY = 0.25067,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2370751,
						sizeY = 0.4768869,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt6",
							varName = "item_icon6",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an9",
							varName = "Btn6",
							posX = 0.5126495,
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
							name = "sld6",
							varName = "count_bg6",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8526314,
							sizeY = 0.2708333,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo2",
							varName = "Item_suo6",
							posX = 0.1767491,
							posY = 0.2361246,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3723404,
							sizeY = 0.3723404,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl6",
							varName = "item_count6",
							posX = 0.5257913,
							posY = 0.2213165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj8",
						varName = "ExItem_bg",
						posX = 0.4941193,
						posY = 1.840784,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2370751,
						sizeY = 0.4768869,
						image = "djk#kcheng",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt8",
							varName = "ExItem_icon",
							posX = 0.5105412,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
							image = "equip#daojie50",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an10",
							varName = "ExBtn",
							posX = 0.5,
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
							name = "sld8",
							varName = "Excount_bg",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8617021,
							sizeY = 0.2765957,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo2",
							varName = "ExItem_suo",
							posX = 0.1767491,
							posY = 0.2361246,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3162367,
							sizeY = 0.3130636,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl8",
							varName = "Exitem_count",
							posX = 0.5257913,
							posY = 0.2213165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dg2",
							posX = 0.4947215,
							posY = 0.5011336,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.257181,
							sizeY = 1.377948,
							image = "uieffect/kuang.png",
							blendFunc = 1,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "rlz2",
							sizeXAB = 71.56345,
							sizeYAB = 70.0107,
							posXAB = 39.77077,
							posYAB = 43.31499,
							posX = 0.4971345,
							posY = 0.5414374,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8945429,
							sizeY = 0.8751337,
							angle = 0,
							emitterType = 2,
							sourceSpeed = 150,
							middleColorAlpha = 1,
							finishParticleSize = 0,
							startParticleSize = 50,
							startParticleSizeVariance = 10,
							maxParticles = 15,
							particleLifespan = 1,
							particleLifespanVariance = 0.3,
							sourcePositionVariancex = 1,
							sourcePositionVariancey = 1,
							speed = 15,
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
							name = "rlz4",
							sizeXAB = 71.56345,
							sizeYAB = 70.0107,
							posXAB = 40.61188,
							posYAB = 42.48033,
							posX = 0.5076484,
							posY = 0.5310041,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8945429,
							sizeY = 0.8751337,
							angle = 0,
							emitterType = 2,
							sourceSpeed = 150,
							middleColorAlpha = 1,
							finishParticleSize = 0,
							startParticleSize = 50,
							maxParticles = 5,
							particleLifespan = 1.2,
							particleLifespanVariance = 0.3,
							sourcePositionVariancex = 7,
							sourcePositionVariancey = 7,
							speed = 15,
							speedVariance = 5,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/067lizi.png",
							playOnInit = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "s3",
							sizeXAB = 48.00001,
							sizeYAB = 54.15488,
							posXAB = 66.09972,
							posYAB = 71.24525,
							posX = 0.8262463,
							posY = 0.8905656,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.6769359,
							angle = 0,
							angleVariance = 360,
							rotationEndVariance = 100,
							finishParticleSize = 0,
							startParticleSize = 25,
							startParticleSizeVariance = 5,
							maxParticles = 8,
							maxRadius = 40,
							minRadius = 65,
							particleLifespan = 0.5,
							particleLifespanVariance = 0.3,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/0351.png",
							playOnInit = true,
						},
					},
					{
						prop = {
							etype = "Particle",
							name = "s4",
							sizeXAB = 48.00001,
							sizeYAB = 54.15488,
							posXAB = 66.09972,
							posYAB = 71.24525,
							posX = 0.8262463,
							posY = 0.8905656,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.6769359,
							angle = 0,
							angleVariance = 360,
							rotationEndVariance = 100,
							finishParticleSize = 0,
							startParticleSize = 25,
							startParticleSizeVariance = 5,
							maxParticles = 8,
							maxRadius = 40,
							minRadius = 65,
							particleLifespan = 0.5,
							particleLifespanVariance = 0.3,
							startColorBlue = 1,
							startColorGreen = 1,
							startColorRed = 1,
							textureFileName = "uieffect/0352.png",
							playOnInit = true,
						},
					},
					{
						prop = {
							etype = "FrameAni",
							name = "sd3",
							sizeXAB = 78.73812,
							sizeYAB = 75.86109,
							posXAB = 40.72367,
							posYAB = 42.90665,
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xl_003.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "weiyi2",
							posX = 0.6683648,
							posY = 0.7708703,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5425532,
							sizeY = 0.3510638,
							image = "djk#weiyi",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.3289897,
						posY = 1.102707,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3425555,
						sizeY = 0.1887754,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mz",
							varName = "ExItem_name",
							posX = 0.5769964,
							posY = 0.7973741,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.7500203,
							sizeY = 1.079304,
							text = "芙蓉的香囊",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz2",
							posX = 1.016834,
							posY = 1.40742,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.592514,
							sizeY = 1.436338,
							text = "羽华凌云刃碎片",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA3432F",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d",
					posX = 0.7298819,
					posY = -0.03858143,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5385945,
					sizeY = 0.2636133,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "topup",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3557963,
						sizeY = 0.6320246,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "z5",
							varName = "CreditBtnText2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.016411,
							sizeY = 0.8880838,
							text = "充  值",
							fontSize = 26,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
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
						name = "an11",
						varName = "GetBtn",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3557963,
						sizeY = 0.6320246,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "z6",
							varName = "GetBtnText",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.016411,
							sizeY = 1.019074,
							text = "领 取",
							fontSize = 26,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
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
		},
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	jn6 = {
	},
	bj = {
	},
	jn7 = {
	},
	bj2 = {
	},
	jn8 = {
	},
	bj3 = {
	},
	jn9 = {
	},
	bj4 = {
	},
	jn10 = {
	},
	bj5 = {
	},
	jn11 = {
	},
	bj6 = {
	},
	jn12 = {
	},
	bj7 = {
	},
	jn13 = {
	},
	bj8 = {
	},
	jn14 = {
	},
	bj9 = {
	},
	jn15 = {
	},
	bj10 = {
	},
	jn16 = {
	},
	bj11 = {
	},
	jn17 = {
	},
	bj12 = {
	},
	jn18 = {
	},
	bj13 = {
	},
	jn19 = {
	},
	bj14 = {
	},
	jn20 = {
	},
	bj15 = {
	},
	jn21 = {
	},
	bj16 = {
	},
	jn22 = {
	},
	bj17 = {
	},
	jn23 = {
	},
	bj18 = {
	},
	jn24 = {
	},
	bj19 = {
	},
	jn25 = {
	},
	bj20 = {
	},
	jn26 = {
	},
	bj21 = {
	},
	jn27 = {
	},
	bj22 = {
	},
	jn28 = {
	},
	bj23 = {
	},
	jn29 = {
	},
	bj24 = {
	},
	jn30 = {
	},
	bj25 = {
	},
	jn31 = {
	},
	bj26 = {
	},
	jn32 = {
	},
	bj27 = {
	},
	jn33 = {
	},
	bj28 = {
	},
	jn34 = {
	},
	bj29 = {
	},
	jn35 = {
	},
	bj30 = {
	},
	jn36 = {
	},
	bj31 = {
	},
	jn37 = {
	},
	bj32 = {
	},
	jn38 = {
	},
	bj33 = {
	},
	jn39 = {
	},
	bj34 = {
	},
	jn40 = {
	},
	bj35 = {
	},
	jn41 = {
	},
	bj36 = {
	},
	jn42 = {
	},
	bj37 = {
	},
	jn43 = {
	},
	bj38 = {
	},
	jn44 = {
	},
	bj39 = {
	},
	jn45 = {
	},
	bj40 = {
	},
	jn46 = {
	},
	bj41 = {
	},
	jn47 = {
	},
	bj42 = {
	},
	jn48 = {
	},
	bj43 = {
	},
	jn49 = {
	},
	bj44 = {
	},
	jn50 = {
	},
	bj45 = {
	},
	jn51 = {
	},
	bj46 = {
	},
	jn52 = {
	},
	bj47 = {
	},
	jn53 = {
	},
	bj48 = {
	},
	jn54 = {
	},
	bj49 = {
	},
	jn55 = {
	},
	bj50 = {
	},
	jn56 = {
	},
	bj51 = {
	},
	jn57 = {
	},
	bj52 = {
	},
	jn58 = {
	},
	bj53 = {
	},
	jn59 = {
	},
	bj54 = {
	},
	jn60 = {
	},
	bj55 = {
	},
	jn61 = {
	},
	bj56 = {
	},
	jn62 = {
	},
	bj57 = {
	},
	jn63 = {
	},
	bj58 = {
	},
	jn64 = {
	},
	bj59 = {
	},
	jn65 = {
	},
	bj60 = {
	},
	c_hld = {
	},
	c_hld2 = {
	},
	c_hld3 = {
	},
	c_hld4 = {
	},
	c_hld5 = {
	},
	c_hld6 = {
	},
	c_hld7 = {
	},
	c_hld8 = {
	},
	c_hld9 = {
	},
	c_hld10 = {
	},
	c_hld11 = {
	},
	c_hld12 = {
	},
	c_hld13 = {
	},
	c_hld14 = {
	},
	c_hld15 = {
	},
	c_hld16 = {
	},
	c_hld17 = {
	},
	c_hld18 = {
	},
	c_hld19 = {
	},
	c_hld20 = {
	},
	c_hld21 = {
	},
	c_hld22 = {
	},
	c_hld23 = {
	},
	c_hld24 = {
	},
	c_hld25 = {
	},
	c_hld26 = {
	},
	c_hld27 = {
	},
	c_hld28 = {
	},
	c_hld29 = {
	},
	c_hld30 = {
	},
	c_hld31 = {
	},
	c_hld32 = {
	},
	c_hld33 = {
	},
	c_hld34 = {
	},
	c_hld35 = {
	},
	c_hld36 = {
	},
	c_hld37 = {
	},
	c_hld38 = {
	},
	c_hld39 = {
	},
	c_hld40 = {
	},
	c_hld41 = {
	},
	c_hld42 = {
	},
	c_hld43 = {
	},
	c_hld44 = {
	},
	c_hld45 = {
	},
	c_hld46 = {
	},
	c_hld47 = {
	},
	c_hld48 = {
	},
	c_hld49 = {
	},
	c_hld50 = {
	},
	c_hld51 = {
	},
	c_hld52 = {
	},
	c_hld53 = {
	},
	c_hld54 = {
	},
	c_hld55 = {
	},
	c_hld56 = {
	},
	c_hld57 = {
	},
	c_hld58 = {
	},
	c_hld59 = {
	},
	c_hld60 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
