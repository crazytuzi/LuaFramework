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
			etype = "Image",
			name = "ndd",
			varName = "bgIcon",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1224533,
			sizeY = 0.2,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "nd1",
				varName = "difficultyBtn",
				posX = 0.5,
				posY = 0.4166665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8230178,
				sizeY = 0.8333333,
				image = "nd#nd11",
				imageNormal = "nd#nd11",
				imagePressed = "nd#nd12",
				imageDisable = "nd#nd13",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4031008,
					sizeY = 0.4333333,
					image = "ty#suo2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "isSelect",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.759218,
				sizeY = 0.9930556,
				image = "nd#xzk",
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
