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
				etype = "FrameAni",
				name = "bao",
				sizeXAB = 190.318,
				sizeYAB = 180,
				posXAB = 705.5758,
				posYAB = 603.5998,
				posX = 0.5512311,
				posY = 0.8383331,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1486859,
				sizeY = 0.25,
				alphaCascade = true,
				frameEnd = 8,
				frameName = "uieffect/bbao.png",
				delay = 0.05,
				playTimes = 1,
				column = 4,
				playOnInit = false,
			},
		},
		{
			prop = {
				etype = "FrameAni",
				name = "bao2",
				sizeXAB = 113.445,
				sizeYAB = 107.971,
				posXAB = 223.8682,
				posYAB = 404.0007,
				posX = 0.174897,
				posY = 0.5611121,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08862893,
				sizeY = 0.1499597,
				alphaCascade = true,
				frameEnd = 8,
				frameName = "uieffect/bbao.png",
				delay = 0.05,
				playTimes = 1,
				column = 4,
				rotationX = 180,
				playOnInit = false,
			},
		},
		{
			prop = {
				etype = "FrameAni",
				name = "bao3",
				sizeXAB = 79.49979,
				sizeYAB = 78.01992,
				posXAB = 1107.416,
				posYAB = 270.221,
				posX = 0.8651685,
				posY = 0.375307,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.06210921,
				sizeY = 0.108361,
				alphaCascade = true,
				frameEnd = 8,
				frameName = "uieffect/bbao.png",
				delay = 0.05,
				playTimes = 1,
				column = 4,
				rotationY = 180,
				playOnInit = false,
			},
		},
		{
			prop = {
				etype = "FrameAni",
				name = "bao4",
				sizeXAB = 172.3474,
				sizeYAB = 165.8758,
				posXAB = 509.8981,
				posYAB = 533.788,
				posX = 0.3983579,
				posY = 0.7413722,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1346464,
				sizeY = 0.230383,
				alphaCascade = true,
				frameEnd = 8,
				frameName = "uieffect/bbao.png",
				delay = 0.05,
				playTimes = 1,
				column = 4,
				playOnInit = false,
			},
		},
		{
			prop = {
				etype = "FrameAni",
				name = "bao5",
				sizeXAB = 120.1905,
				sizeYAB = 117.9532,
				posXAB = 910.7388,
				posYAB = 369.0587,
				posX = 0.7115147,
				posY = 0.5125816,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09389883,
				sizeY = 0.1638239,
				alphaCascade = true,
				frameEnd = 8,
				frameName = "uieffect/bbao.png",
				delay = 0.05,
				playTimes = 1,
				column = 4,
				playOnInit = false,
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
	bao = {
		bao = {
			alpha = {{0, {1}}, {400, {1}}, {500, {0}}, },
		},
	},
	bao2 = {
		bao2 = {
			alpha = {{0, {1}}, {400, {1}}, {500, {0}}, },
		},
	},
	bao3 = {
		bao3 = {
			alpha = {{0, {1}}, {400, {1}}, {500, {0}}, },
		},
	},
	bao4 = {
		bao4 = {
			alpha = {{0, {1}}, {400, {1}}, {500, {0}}, },
		},
	},
	bao5 = {
		bao5 = {
			alpha = {{0, {1}}, {400, {1}}, {500, {0}}, },
		},
	},
	c_dakai = {
		{1,"bao", 1, 0},
		{1,"bao2", 1, 250},
		{1,"bao3", 1, 100},
		{0,"bao", 1, 0},
		{0,"bao2", 1, 250},
		{0,"bao3", 1, 100},
		{0,"bao4", 1, 350},
		{1,"bao4", 1, 350},
		{0,"bao5", 1, 450},
		{1,"bao5", 1, 450},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
