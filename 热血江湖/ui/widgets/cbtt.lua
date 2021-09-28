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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07734375,
			sizeY = 0.1430556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dj1",
				varName = "btn",
				posX = 0.530303,
				posY = 0.4514565,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "gradeIcon",
				posX = 0.530303,
				posY = 0.4320391,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.959596,
				sizeY = 0.9320385,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "icon",
					posX = 0.4894737,
					posY = 0.5521522,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "items#items_gaojijinengshu.png",
				},
			},
			{
				prop = {
					etype = "FrameAni",
					name = "sd3",
					sizeXAB = 80.00001,
					sizeYAB = 80,
					posXAB = 47.69242,
					posYAB = 52.7608,
					varName = "an11",
					posX = 0.5020255,
					posY = 0.5495917,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8421053,
					sizeY = 0.8333334,
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zbt",
				varName = "mountImg",
				posX = 0.4898431,
				posY = 0.4999746,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9982477,
				sizeY = 0.949789,
				image = "hd#zb",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hs",
				varName = "darkImg",
				posX = 0.5302622,
				posY = 0.4709156,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9023483,
				sizeY = 0.8890587,
				image = "b#bp",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "s1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.844067,
					sizeY = 0.7489799,
					text = "未揭示",
					color = "FFF1E9D7",
					fontSize = 22,
					fontOutlineColor = "FFA47848",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selectImg",
				posX = 0.5403482,
				posY = 0.4731225,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9292929,
				sizeY = 0.9029124,
				image = "hd#hd_xzk.png",
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
