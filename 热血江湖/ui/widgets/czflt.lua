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
			posX = 0.341129,
			posY = 0.3180928,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.121189,
			sizeY = 0.2164567,
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
				sizeX = 0.98,
				sizeY = 0.98,
				image = "djk#ktong",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp1",
				varName = "item_icon",
				posX = 0.5,
				posY = 0.54,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.788,
				sizeY = 0.788,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "suo",
				posX = 0.1973507,
				posY = 0.2609761,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2993952,
				sizeY = 0.3,
				image = "tb#suo",
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
