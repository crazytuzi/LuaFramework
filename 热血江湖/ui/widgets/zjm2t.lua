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
			name = "an6",
			varName = "btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.078125,
			sizeY = 0.1388889,
			image = "tb2#bp",
			imageNormal = "tb2#bp",
			soundEffectClick = "audio/rxjh/UI/anniu.ogg",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xhd7",
				varName = "point",
				posX = 0.7869394,
				posY = 0.8092637,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.27,
				sizeY = 0.28,
				image = "zdte#hd",
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
