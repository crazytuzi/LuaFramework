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
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.07828281,
			sizeY = 0.1388889,
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
				sizeX = 0.938105,
				sizeY = 0.9399999,
				image = "djk#ktong",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp1",
				varName = "item_icon",
				posX = 0.5099798,
				posY = 0.52,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.788,
				sizeY = 0.788,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd3",
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
					name = "sd7",
					sizeXAB = 98.62144,
					sizeYAB = 94.82636,
					posXAB = 51.0074,
					posYAB = 53.63331,
					varName = "an11",
					posX = 0.5090457,
					posY = 0.5363331,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
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
					etype = "FrameAni",
					name = "sd8",
					sizeXAB = 98.62144,
					sizeYAB = 94.82636,
					posXAB = 51.0074,
					posYAB = 53.63331,
					varName = "an12",
					posX = 0.5090457,
					posY = 0.5363331,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
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
				etype = "Image",
				name = "hs",
				varName = "is_show",
				posX = 0.4999999,
				posY = 0.5113188,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.7914576,
				sizeY = 0.7930564,
				image = "ty#hong",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "suo",
				posX = 0.1973507,
				posY = 0.2209761,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2993952,
				sizeY = 0.3,
				image = "tb#suo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sla",
				varName = "countLabel",
				posX = 0.574146,
				posY = 0.2380705,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6088505,
				sizeY = 0.2747519,
				text = "x555",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selectedImg",
				posX = 0.5,
				posY = 0.52,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1.037903,
				sizeY = 1.04,
				image = "djk#zbxz",
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
