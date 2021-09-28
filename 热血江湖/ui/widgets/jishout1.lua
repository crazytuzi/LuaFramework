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
			etype = "Button",
			name = "dj1",
			varName = "btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.075,
			sizeY = 0.1330646,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "grade_icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9895834,
				sizeY = 0.9707065,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5317645,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "1",
				},
			},
			{
				prop = {
					etype = "FrameAni",
					name = "sd3",
					sizeXAB = 93.5015,
					sizeYAB = 88.18851,
					posXAB = 48.35934,
					posYAB = 49.87898,
					varName = "orangeTX",
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
					repeatLastFrame = 35,
				},
			},
			{
				prop = {
					etype = "FrameAni",
					name = "sd4",
					sizeXAB = 93.5015,
					sizeYAB = 88.18851,
					posXAB = 48.35934,
					posYAB = 49.87898,
					varName = "purpleTX",
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
					repeatLastFrame = 35,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "s1",
				varName = "item_count",
				posX = 0.5191829,
				posY = 0.2218447,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.755787,
				sizeY = 0.4377611,
				text = "x22",
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 2,
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
