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
			etype = "FrameAni",
			name = "ws",
			sizeXAB = 768,
			sizeYAB = 180,
			posXAB = 733.8461,
			posYAB = 228.2169,
			posX = 0.5733173,
			posY = 0.3169679,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.25,
			frameEnd = 16,
			frameName = "14861878770340649617.png",
			packFile = "chuizi.plist",
			delay = 0.1,
			column = 4,
		},
	},
	{
		prop = {
			etype = "FrameAni",
			name = "fdg",
			sizeXAB = 768,
			sizeYAB = 180,
			posXAB = 649.9832,
			posYAB = 364.9917,
			posX = 0.5077994,
			posY = 0.5069329,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.25,
			frameEnd = 6,
			frameName = "baozha.png",
			packFile = "baozha.plist",
			delay = 0.1,
			playTimes = 0,
			frameWidth = 95,
			frameHeight = 115,
		},
	},
	{
		prop = {
			etype = "Image",
			name = "ddd",
			posX = 0.2466539,
			posY = 0.7268131,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2165423,
			sizeY = 0.2789144,
			image = "farm.jpg",
			rotationY = -10,
		},
	},
	{
		prop = {
			etype = "Particle",
			name = "pp1",
			sizeXAB = 768,
			sizeYAB = 180,
			posXAB = 523.1907,
			posYAB = 459.8362,
			posX = 0.4087427,
			posY = 0.6386614,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.25,
			blendFuncDestination = 771,
			blendFuncSource = 770,
			emitterType = 2,
			positionType = 1,
			rectangleStartIndex = 2,
			startParticleSize = 100,
			speed = 111,
			textureFileName = "uieffect/006guangyun.png",
			playOnInit = true,
		},
	},
	{
		prop = {
			etype = "Image",
			name = "ddd2",
			posX = 0.7606539,
			posY = 0.7268131,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2165423,
			sizeY = 0.2789144,
			image = "farm.jpg",
			rotationY = 10,
		},
	},
	{
		prop = {
			etype = "Image",
			name = "ddd3",
			posX = 0.5106722,
			posY = 0.7337459,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2329222,
			sizeY = 0.3177376,
		},
	},
	{
		prop = {
			etype = "Button",
			name = "bbb",
			varName = "bbb",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.25,
			soundEffectClick = "audio/rxjh/skill/baozha.ogg",
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	ff1 = {
		ddd = {
			scale = {{0, {1,1,1}}, {500, {0.5, 0.5, 1}}, {1000, {1,1,1}}, },
			rotate = {{0, {0}}, {1000, {180}}, {2000, {360}}, {2050, {180}}, },
		},
	},
	pp1 = {
		pp1 = {
			circle = {{0, {523.1907,459.8362,0}}, {2000, {323.1907, 459.8362, 0}}, },
		},
	},
	c_chuizi = {
		{0,"ff1", -1, 0},
		{0,"pp1", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
