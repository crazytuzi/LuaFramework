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
			etype = "FrameAni",
			name = "sd4",
			sizeXAB = 96.45418,
			sizeYAB = 92.92982,
			posXAB = 640,
			posYAB = 360,
			varName = "an1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			visible = false,
			lockHV = true,
			sizeX = 0.07535483,
			sizeY = 0.1290692,
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
