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
				name = "dd",
				varName = "ok",
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
			name = "ysjm",
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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.43125,
				sizeY = 0.4791667,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "close_btn",
					posX = 0.9922445,
					posY = 1.010239,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1627604,
					sizeY = 0.2604166,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9275362,
					sizeY = 1.484058,
					image = "uieffect/fzquan.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.16113,
					sizeY = 1.857805,
					image = "uieffect/png_10218waihuanguangquan11.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9275362,
					sizeY = 1.484058,
					image = "uieffect/fzquan.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "tp3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6474815,
					sizeY = 0.2982801,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "fg3",
						posX = 0.5,
						posY = 0.5000001,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7890103,
						sizeY = 3.245661,
						image = "sui#db1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xxf",
							posX = 0.5,
							posY = 0.105461,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3439716,
							sizeY = 0.1047904,
							image = "sui#xxf",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tpk3",
						posX = 0.5097079,
						posY = 1.344095,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2658013,
						sizeY = 0.9037318,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tpt3",
							varName = "icon",
							posX = 0.4894888,
							posY = 0.5214617,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8243297,
							sizeY = 0.8343828,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz5",
						varName = "name",
						posX = 0.5,
						posY = 0.7802793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4840277,
						sizeY = 0.3855711,
						text = "伤害加深",
						color = "FFA05C21",
						fontSize = 24,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz6",
						varName = "level",
						posX = 0.5,
						posY = 0.4971825,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4840277,
						sizeY = 0.3855711,
						text = "Lv.5",
						color = "FFA05C21",
						fontSize = 22,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "msz",
						varName = "desc",
						posX = 0.5,
						posY = -0.08307799,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6206309,
						sizeY = 1.086572,
						text = "受到伤害时，有<c=green>18%</c>几率使攻击者的中毒5秒，每秒损失<c=green>[292]</c>气血（效果可叠加）",
						color = "FF634624",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lizi",
					sizeXAB = 331.2,
					sizeYAB = 86.25,
					posXAB = 442.7246,
					posYAB = 223.416,
					posX = 0.8020374,
					posY = 0.6475827,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					angle = 0,
					angleVariance = 360,
					duration = 999999,
					rotationEndVariance = 360,
					finishParticleSize = 0,
					startParticleSize = 100,
					startParticleSizeVariance = 30,
					maxParticles = 40,
					maxRadius = 210,
					maxRadiusVariance = 20,
					minRadius = 260,
					minRadiusVariance = 20,
					particleLifespan = 0.8,
					particleLifespanVariance = 0.3,
					speed = 100,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/lizi041161121.png",
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lz",
					sizeXAB = 82.86309,
					sizeYAB = 83.05675,
					posXAB = 279.4935,
					posYAB = 261.9482,
					posX = 0.5063289,
					posY = 0.7592703,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1501143,
					sizeY = 0.2407442,
					duration = 999999,
					emitterType = 2,
					sourceSpeed = 120,
					rectangleStartIndex = 1,
					rotationStartVariance = 30,
					finishParticleSize = 0,
					startParticleSize = 35,
					startParticleSizeVariance = 15,
					maxParticles = 30,
					particleLifespan = 1,
					particleLifespanVariance = 0.3,
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
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	dk = {
		ysjm = {
			scale = {{0, {0, 0, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	xz = {
		xz = {
			rotate = {{0, {0}}, {6000, {180}}, {9000, {270}}, {12000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	fz = {
		fz = {
			alpha = {{0, {0.5}}, },
		},
	},
	fz2 = {
		fz2 = {
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
		{2,"lz", 1, 0},
		{2,"lizi", 1, 0},
		{0,"xz", -1, 0},
		{0,"fz", 1, 0},
		{0,"fz2", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
