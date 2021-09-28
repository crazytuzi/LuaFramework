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
			name = "zbsct2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.2203125,
			sizeY = 0.144635,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "tan1",
				varName = "equipBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.00203,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "b#scd1",
				imagePressed = "b#scd2",
				imageDisable = "b#scd1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "twpk",
				varName = "equipGrade",
				posX = 0.2045466,
				posY = 0.4928736,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3333333,
				sizeY = 0.9026553,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "twp1",
					varName = "equipIcon",
					posX = 0.4946004,
					posY = 0.519456,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jzz",
					varName = "suo",
					posX = 0.1903205,
					posY = 0.2201894,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2978724,
					sizeY = 0.2978723,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "FrameAni",
					name = "sd3",
					sizeXAB = 92.51727,
					sizeYAB = 89.13677,
					posXAB = 47.85029,
					posYAB = 50.41531,
					varName = "an1",
					posX = 0.5090457,
					posY = 0.5363331,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
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
					etype = "FrameAni",
					name = "sd4",
					sizeXAB = 92.51727,
					sizeYAB = 89.13677,
					posXAB = 47.85029,
					posYAB = 50.41531,
					varName = "an2",
					posX = 0.5090457,
					posY = 0.5363331,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.9842263,
					sizeY = 0.9482635,
					frameEnd = 16,
					frameName = "uieffect/xll_001.png",
					delay = 0.05,
					frameWidth = 64,
					frameHeight = 64,
					column = 4,
					blendFunc = 1,
					repeatLastFrame = 35,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tmz1",
				varName = "equipName",
				posX = 0.7146696,
				posY = 0.6756505,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6427943,
				sizeY = 0.3484159,
				text = "装备名字",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tmz2",
				varName = "equipLvl",
				posX = 0.5284406,
				posY = 0.3229784,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2743618,
				sizeY = 0.3484159,
				text = "50级",
				color = "FF65944D",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
