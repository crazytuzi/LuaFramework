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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd2",
				varName = "close_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "d",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Particle",
				name = "lizi6",
				sizeXAB = 675.84,
				sizeYAB = 176.4,
				posXAB = 1090.334,
				posYAB = 369.7745,
				posX = 0.9679811,
				posY = 0.5240568,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				emitterType = 0,
				finishColorBlue = 0,
				finishColorGreen = 0,
				finishColorRed = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 15,
				finishParticleSizeVariance = 10,
				startParticleSize = 15,
				startParticleSizeVariance = 15,
				middleParticleSize = 15,
				middleParticleSizeVariance = 15,
				gravityx = 6,
				maxParticles = 7,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.5,
				sourcePositionVariancex = 40,
				sourcePositionVariancey = 190,
				sourcePositionx = 75,
				sourcePositiony = 70,
				startColorAlpha = 0,
				textureFileName = "uieffect/l21.png",
				useMiddleFrame = true,
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi5",
				sizeXAB = 675.84,
				sizeYAB = 176.4,
				posXAB = 547.2266,
				posYAB = 365.7802,
				posX = 0.485819,
				posY = 0.518396,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				emitterType = 0,
				finishColorBlue = 0,
				finishColorGreen = 0,
				finishColorRed = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 15,
				finishParticleSizeVariance = 10,
				startParticleSize = 15,
				startParticleSizeVariance = 15,
				middleParticleSize = 15,
				middleParticleSizeVariance = 15,
				gravityx = -6,
				maxParticles = 7,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.5,
				sourcePositionVariancex = 40,
				sourcePositionVariancey = 190,
				sourcePositionx = 75,
				sourcePositiony = 70,
				startColorAlpha = 0,
				textureFileName = "uieffect/l21.png",
				useMiddleFrame = true,
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi3",
				sizeXAB = 675.84,
				sizeYAB = 176.4,
				posXAB = 565.1959,
				posYAB = 372.7677,
				posX = 0.5017719,
				posY = 0.5282989,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				emitterType = 0,
				finishColorBlue = 0,
				finishColorGreen = 0,
				finishColorRed = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 15,
				finishParticleSizeVariance = 10,
				startParticleSize = 15,
				startParticleSizeVariance = 15,
				middleParticleSize = 15,
				middleParticleSizeVariance = 15,
				gravityx = -6,
				maxParticles = 15,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.5,
				sourcePositionVariancex = 40,
				sourcePositionVariancey = 90,
				sourcePositionx = 75,
				sourcePositiony = 70,
				startColorAlpha = 0,
				textureFileName = "uieffect/l21.png",
				useMiddleFrame = true,
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 675.84,
				sizeYAB = 176.4,
				posXAB = 565.1959,
				posYAB = 372.7677,
				posX = 0.5017719,
				posY = 0.5282989,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				emitterType = 0,
				finishColorBlue = 0,
				finishColorGreen = 0,
				finishColorRed = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 15,
				finishParticleSizeVariance = 10,
				startParticleSize = 15,
				startParticleSizeVariance = 15,
				middleParticleSize = 15,
				middleParticleSizeVariance = 15,
				gravityx = -6,
				maxParticles = 15,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.5,
				sourcePositionVariancex = 40,
				sourcePositionVariancey = 90,
				sourcePositionx = 75,
				sourcePositiony = 70,
				startColorAlpha = 0,
				textureFileName = "uieffect/l1.png",
				useMiddleFrame = true,
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi4",
				sizeXAB = 675.84,
				sizeYAB = 176.4,
				posXAB = 1081.348,
				posYAB = 370.7706,
				posX = 0.9600033,
				posY = 0.5254685,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				emitterType = 0,
				finishColorBlue = 0,
				finishColorGreen = 0,
				finishColorRed = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 15,
				finishParticleSizeVariance = 10,
				startParticleSize = 15,
				startParticleSizeVariance = 15,
				middleParticleSize = 15,
				middleParticleSizeVariance = 15,
				gravityx = 6,
				maxParticles = 15,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.5,
				sourcePositionVariancex = 40,
				sourcePositionVariancey = 90,
				sourcePositionx = 75,
				sourcePositiony = 70,
				startColorAlpha = 0,
				textureFileName = "uieffect/l21.png",
				useMiddleFrame = true,
				playOnInit = true,
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi2",
				sizeXAB = 675.84,
				sizeYAB = 176.4,
				posXAB = 1081.348,
				posYAB = 370.7706,
				posX = 0.9600033,
				posY = 0.5254685,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				emitterType = 0,
				finishColorBlue = 0,
				finishColorGreen = 0,
				finishColorRed = 0,
				middleColorAlpha = 1,
				middleColorBlue = 1,
				middleColorGreen = 1,
				middleColorRed = 1,
				finishParticleSize = 15,
				finishParticleSizeVariance = 10,
				startParticleSize = 15,
				startParticleSizeVariance = 15,
				middleParticleSize = 15,
				middleParticleSizeVariance = 15,
				gravityx = 6,
				maxParticles = 15,
				particleLifespanVariance = 0.5,
				particleLifeMiddle = 0.5,
				sourcePositionVariancex = 40,
				sourcePositionVariancey = 90,
				sourcePositionx = 75,
				sourcePositiony = 70,
				startColorAlpha = 0,
				textureFileName = "uieffect/l1.png",
				useMiddleFrame = true,
				playOnInit = true,
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
				sizeX = 0.4972848,
				sizeY = 0.5030367,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zg2",
					posX = -0.04463152,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1285389,
					sizeY = 0.9579011,
					image = "top#top_pbg.png",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zg1",
					posX = 1.044625,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1285389,
					sizeY = 0.9579011,
					image = "top#top_pbg.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bjg",
					posX = 0.5,
					posY = 0.9416658,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4266779,
					sizeY = 0.6733481,
					image = "top#dg2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.98,
					sizeY = 0.98,
					scale9 = true,
					scale9Left = 0.41,
					scale9Right = 0.37,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wk",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.02,
						sizeY = 1.02,
						image = "b#cs",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.2,
						scale9Bottom = 0.7,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4335638,
						sizeY = 0.1581169,
						image = "top#top_sldjts.png",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "mzd",
						posX = 0.5,
						posY = 0.522988,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.909181,
						sizeY = 0.7059959,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "RichText",
							name = "kf",
							varName = "desc",
							posX = 0.5,
							posY = 0.1277848,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7401254,
							sizeY = 0.3436697,
							text = "开放新参数【追】",
							color = "FFFF3D10",
							fontSize = 24,
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
					etype = "Grid",
					name = "f4",
					posX = 0.5,
					posY = 0.6635098,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9645313,
					sizeY = 0.1801456,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj4",
						posX = 0.6394269,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02591277,
						sizeY = 0.2345899,
						image = "chu1#jt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n7",
						varName = "lvl_label",
						posX = 0.3177656,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2912359,
						sizeY = 0.541536,
						text = "熟练等级：",
						color = "FF966856",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n9",
						varName = "old_lvl",
						posX = 0.5277166,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2180479,
						sizeY = 0.541536,
						text = "11",
						color = "FFF1E9D7",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n12",
						varName = "new_lvl",
						posX = 0.7790278,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1773974,
						sizeY = 0.541536,
						text = "12",
						color = "FF76D646",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian1",
						posX = 0.5,
						posY = 0.1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7,
						sizeY = 0.03127866,
						image = "b#xian",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "f5",
					posX = 0.5,
					posY = 0.534328,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9645313,
					sizeY = 0.1801456,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj5",
						posX = 0.6394269,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02591277,
						sizeY = 0.2345899,
						image = "chu1#jt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n8",
						varName = "point_label",
						posX = 0.3177656,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2912359,
						sizeY = 0.541536,
						text = "熟练等级：",
						color = "FF966856",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n10",
						varName = "old_point",
						posX = 0.5277165,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2180479,
						sizeY = 0.541536,
						text = "11",
						color = "FFF1E9D7",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n13",
						varName = "new_point",
						posX = 0.7790277,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1773974,
						sizeY = 0.541536,
						text = "12",
						color = "FF76D646",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian2",
						posX = 0.5,
						posY = 0.1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7,
						sizeY = 0.03127866,
						image = "b#xian",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "f6",
					varName = "dayCreateCount",
					posX = 0.5000001,
					posY = 0.4051455,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9645313,
					sizeY = 0.1801456,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj6",
						posX = 0.6394269,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02591277,
						sizeY = 0.2345899,
						image = "chu1#jt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n11",
						varName = "count_label",
						posX = 0.3177656,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2912359,
						sizeY = 0.541536,
						text = "熟练等级：",
						color = "FF966856",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n14",
						varName = "old_count",
						posX = 0.5277165,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2180479,
						sizeY = 0.541536,
						text = "11",
						color = "FFF1E9D7",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "n15",
						varName = "new_count",
						posX = 0.7790276,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1773974,
						sizeY = 0.541536,
						text = "12",
						color = "FF76D646",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xian3",
						posX = 0.5,
						posY = 0.1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7,
						sizeY = 0.03127866,
						image = "b#xian",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz1",
					posX = 0.5,
					posY = 0.8102784,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.12409,
					text = "各项参数可投入上限提升",
					color = "FFC93034",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz2",
					posX = 0.5,
					posY = 0.08898568,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.12409,
					text = "--点任意位置继续--",
					color = "FF966856",
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
	tc = {
		top = {
			scale = {{0, {5, 5, 1}}, {150, {4, 4, 1}}, {300, {0.8, 0.8, 1}}, {350, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	xz = {
		bjg = {
			rotate = {{0, {0}}, {2000, {180}}, },
		},
	},
	c_dakai = {
		{0,"tc", 1, 0},
		{0,"xz", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
