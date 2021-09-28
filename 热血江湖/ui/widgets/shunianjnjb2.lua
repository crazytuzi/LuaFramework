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
			name = "zzt",
			posX = 0.5,
			posY = 0.4908059,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.03125,
			sizeY = 0.375,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zt",
				varName = "selectBg",
				posX = 0.5,
				posY = 0.4288439,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.2,
				sizeY = 0.8476748,
				image = "shunianjnjb#xuanzhong",
				scale9Left = 0.2,
				scale9Right = 0.2,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz",
				varName = "blnum",
				posX = 0.5,
				posY = 0.9083018,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.264571,
				sizeY = 0.1009017,
				text = "999",
				color = "FFFFF600",
				fontSize = 16,
				hTextAlign = 1,
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bxdt",
					varName = "box",
					posX = 0.5,
					posY = 1.174594,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.010444,
					sizeY = 0.7341211,
					image = "rcb#bxd",
				},
				children = {
				{
					prop = {
						etype = "Grid",
						name = "tx",
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
							name = "diguang",
							posX = 0.5127509,
							posY = 1.260542,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.119283,
							sizeY = 5.415948,
							image = "uieffect/001guangyun.png",
							alpha = 0,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "diguang2",
							posX = 0.5127509,
							posY = 1.260542,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.119283,
							sizeY = 5.415948,
							image = "uieffect/016fangshe.png",
							alpha = 0,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "diguang3",
							posX = 0.5235927,
							posY = 1.232915,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.902253,
							sizeY = 4.861315,
							image = "uieffect/shanguang_00058.png",
							alpha = 0,
							blendFunc = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bx",
						varName = "bxbg",
						posX = 0.5154326,
						posY = 1.065139,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8695652,
						sizeY = 2.25,
						image = "rcb#bx1",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "boxbtn",
						posX = 0.5,
						posY = 1.13889,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.168886,
						sizeY = 2.61643,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kbx",
						varName = "kbxbg",
						posX = 0.6518981,
						posY = 1.22086,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 1.152174,
						sizeY = 2.5,
						image = "rcb#bx1k",
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "lz",
						sizeXAB = 99.71245,
						sizeYAB = 36.7564,
						posXAB = 78.04926,
						posYAB = 37.50206,
						posX = 1.52705,
						posY = 1.875103,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.950895,
						sizeY = 1.83782,
						duration = 999999,
						emitterType = 0,
						rotationStartVariance = 50,
						finishParticleSize = 0,
						startParticleSize = 60,
						startParticleSizeVariance = 20,
						gravityy = 40,
						maxParticles = 7,
						particleLifespan = 1,
						sourcePositionVariancex = 20,
						sourcePositionVariancey = 20,
						startColorBlue = 1,
						startColorGreen = 1,
						startColorRed = 1,
						textureFileName = "uieffect/lizi041161121.png",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz2",
				varName = "times",
				posX = 0.5,
				posY = 0.03282595,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.92185,
				sizeY = 0.1111127,
				text = "1月",
				color = "FFF4E0C5",
				fontSize = 16,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "LoadingBar",
				name = "jdt",
				varName = "jdt",
				posX = 0.5,
				posY = 0.4749866,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.6,
				sizeY = 0.7824195,
				image = "shunianjnjb#zhuzhuangtu",
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				barDirection = 3,
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
	diguang = {
		diguang = {
			alpha = {{0, {1}}, },
		},
	},
	diguang2 = {
		diguang2 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang3 = {
		diguang3 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx = {
		bx = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	c_bx = {
		{0,"diguang2", -1, 0},
		{0,"diguang", -1, 0},
		{0,"diguang3", -1, 0},
		{0,"bx", -1, 0},
		{2,"lz", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
