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
		soundEffectOpen = "audio/rxjh/UI/ui_shengli.ogg",
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
			scale9Left = 0.3,
			scale9Right = 0.3,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			varName = "ysjm_root",
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
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9710606,
				sizeY = 0.9415087,
				image = "a",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "d9",
					varName = "scrollImage",
					posX = 0.5,
					posY = 0.5024123,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.613054,
					sizeY = 0.3658431,
					image = "qs#juanzhdb",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Grid",
						name = "jd2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7351276,
							sizeY = 0.641129,
							horizontal = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jz1",
						posX = -0.00393692,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04986876,
						sizeY = 1.270161,
						image = "qs#juanzh",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jz2",
						posX = 1.001318,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04986876,
						sizeY = 1.270161,
						image = "qs#juanzh",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "wz",
						varName = "title",
						posX = 0.5,
						posY = 1.130503,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3123359,
						sizeY = 0.1693548,
						image = "qs#jsxjn",
						alpha = 0,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "gb",
						varName = "okBtn",
						posX = 1.003301,
						posY = 0.7700257,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07611548,
						sizeY = 0.7258064,
						image = "qs#gb",
						imageNormal = "qs#gb",
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "lizi2",
						sizeXAB = 457.2,
						sizeYAB = 62,
						posXAB = 500.0439,
						posYAB = 171.9836,
						posX = 0.6562255,
						posY = 0.6934822,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						angle = 0,
						angleVariance = 360,
						duration = 99999,
						emitterType = 0,
						rotationStartVariance = 360,
						finishParticleSize = 5,
						finishParticleSizeVariance = 10,
						startParticleSize = 60,
						startParticleSizeVariance = 30,
						middleParticleSize = 40,
						middleParticleSizeVariance = 20,
						maxParticles = 8,
						particleLifespan = 1,
						particleLifespanVariance = 0.3,
						particleLifeMiddle = 0.4,
						sourcePositionVariancex = 320,
						sourcePositionVariancey = 120,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/lizi046.png",
						useMiddleFrame = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btt",
					posX = 0.5015603,
					posY = 0.3452729,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.135252,
					sizeY = 0.0940671,
					image = "chu1#an1",
					alphaCascade = true,
					imageNormal = "chu1#an1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "bttz",
						posX = 0.5,
						posY = 0.4803922,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8529344,
						sizeY = 0.9667693,
						text = "确 定",
						fontSize = 22,
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
					etype = "Label",
					name = "sm",
					varName = "desc",
					posX = 0.5,
					posY = 0.2864464,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6,
					sizeY = 0.06756341,
					text = "说明",
					color = "FFADADAD",
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
			name = "sys",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fxt",
				varName = "fxt",
				posX = 0.5982625,
				posY = 0.8183339,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.06740379,
				sizeY = 0.1111111,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "sys2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fxt2",
				varName = "fxt2",
				posX = 0.5,
				posY = 0.4550492,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1111111,
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
	fei1 = {
		fxt = {
			moveP = {{0, {0.5,0.4550493,0}}, {500, {0.06399813, 0.9043109, 0}}, },
			alpha = {{0, {1}}, {500, {1}}, {800, {0}}, },
		},
	},
	fei2 = {
		fxt = {
			moveP = {{0, {0.5,0.4550493,0}}, {300, {0.5982625,0.8183339,0}}, },
			alpha = {{0, {1}}, {300, {1}}, {650, {0}}, },
		},
	},
	fei3 = {
		fxt2 = {
			moveP = {{0, {0.5,0.4550493,0}}, {400, {0.1, 0.4550492, 0}}, },
			alpha = {{0, {1}}, {350, {1}}, {650, {0}}, },
		},
	},
	juanzhou1 = {
		d9 = {
			scale = {{0, {0, 0.85, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
		wz = {
			alpha = {{0, {0}}, {150, {0}}, {200, {1}}, },
		},
	},
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
	c_fei1 = {
		{0,"fei1", 1, 0},
	},
	c_fei2 = {
		{0,"fei2", 1, 0},
	},
	c_fei3 = {
		{0,"fei3", 1, 0},
	},
	c_juanzhou = {
		{0,"juanzhou1", 1, 0},
		{2,"lizi2", 1, 200},
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
