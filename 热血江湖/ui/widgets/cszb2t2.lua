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
				etype = "Label",
				name = "slz",
				posX = 0.524331,
				posY = 0.2029946,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7682752,
				sizeY = 0.2847376,
				text = "x500",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
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
