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
			name = "xt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.408703,
			sizeY = 0.1982814,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "tex",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
			},
			children = {
			{
				prop = {
					etype = "FrameAni",
					name = "hua",
					sizeXAB = 52.50361,
					sizeYAB = 79.20224,
					posXAB = 324.7666,
					posYAB = 16.1834,
					posX = 1.034671,
					posY = 0.4534353,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1672708,
					sizeY = 2.219131,
					frameEnd = 16,
					frameName = "uieffect/t_xsakura_ani001.png",
					playTimes = 0,
					frameWidth = 64,
					frameHeight = 64,
					column = 4,
				},
			},
			{
				prop = {
					etype = "FrameAni",
					name = "hua2",
					sizeXAB = 52.50361,
					sizeYAB = 79.20224,
					posXAB = 62.77678,
					posYAB = -10.7072,
					posX = 0.2,
					posY = -0.3,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1672708,
					sizeY = 2.219131,
					frameEnd = 16,
					frameName = "uieffect/t_xsakura_ani001.png",
					playTimes = 0,
					frameWidth = 64,
					frameHeight = 64,
					column = 4,
					rotation = 90,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pd3",
				varName = "set_image",
				posX = 0.3182112,
				posY = 0.7544671,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1318959,
				sizeY = 0.1470973,
				image = "lt#xt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "nrd",
				varName = "imgUI",
				posX = 0.5965319,
				posY = 0.4062322,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8047562,
				sizeY = 0.7424913,
				image = "hybj#hua1",
				scale9Top = 0.2,
				scale9Bottom = 0.2,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "xtnr",
					varName = "b",
					posX = 0.5185801,
					posY = 0.4066608,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.924847,
					sizeY = 0.5188061,
					text = "名字绿色的人啊送名字还是绿色的999多玫瑰，巴拉巴拉巴拉巴拉",
					color = "FF0371D7",
				},
			},
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi",
				sizeXAB = 313.8839,
				sizeYAB = 35.69065,
				posXAB = 474.0649,
				posYAB = 26.62374,
				posX = 0.9061916,
				posY = 0.1864896,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				duration = 999999,
				emitterType = 0,
				positionType = 1,
				finishParticleSize = 5,
				startParticleSize = 50,
				startParticleSizeVariance = 10,
				particleLifespan = 0.4,
				particleLifespanVariance = 0.2,
				sourcePositionVariancex = 200,
				speed = 20,
				speedVariance = 10,
				textureFileName = "uieffect/068liz1i1.png",
			},
		},
		{
			prop = {
				etype = "Particle",
				name = "lizi2",
				sizeXAB = 313.8839,
				sizeYAB = 35.69065,
				posXAB = 465.904,
				posYAB = 101.0147,
				posX = 0.8905916,
				posY = 0.7075708,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				angle = 0,
				duration = 999999,
				emitterType = 0,
				positionType = 1,
				finishParticleSize = 5,
				startParticleSize = 50,
				startParticleSizeVariance = 10,
				particleLifespan = 0.4,
				particleLifespanVariance = 0.2,
				sourcePositionVariancex = 200,
				speed = 20,
				speedVariance = 10,
				textureFileName = "uieffect/068liz1i1.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txd",
				posX = 0.101445,
				posY = 0.597362,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2381319,
				sizeY = 0.7004635,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "txa",
					posX = 0.5219683,
					posY = 0.4998675,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9654359,
					sizeY = 1.009824,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xt2",
					posX = 0.4976174,
					posY = 0.5399157,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5699319,
					sizeY = 0.71,
					image = "jstx2#xt",
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
	c_hao = {
		{2,"lizi", 1, 0},
		{2,"lizi2", 1, 0},
		{1,"hua", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
