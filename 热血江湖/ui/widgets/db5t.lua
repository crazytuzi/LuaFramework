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
			name = "an1",
			varName = "select1_btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1901682,
			sizeY = 0.08611111,
			alphaCascade = true,
			propagateToChildren = true,
			soundEffectClick = "audio/rxjh/UI/anniu.ogg",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fk",
				varName = "xinfaBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2987131,
				sizeY = 0.429646,
				image = "ty#fhan",
				alphaCascade = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "das",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9695365,
				sizeY = 1.151814,
				image = "ty#fhan",
				imageNormal = "ty#fhan",
				disableClick = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gl1",
				varName = "name",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6624605,
				sizeY = 0.944493,
				color = "FFD8FFF3",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF055444",
				hTextAlign = 1,
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
