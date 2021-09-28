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
			name = "fw",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07421875,
			sizeY = 0.1291667,
			image = "djk#ktong",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fwtp",
				posX = 0.5002338,
				posY = 0.5266665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.924799,
				sizeY = 0.9017505,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				posX = 0.2056455,
				posY = 0.2207463,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2842105,
				sizeY = 0.2903225,
				image = "tb#suo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl",
				posX = 0.581723,
				posY = 0.2199056,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6257671,
				sizeY = 0.3341615,
				text = "x5",
				fontOutlineEnable = true,
				fontOutlineColor = "FF102E21",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				posX = 0.5054887,
				posY = 0.5159361,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9142873,
				sizeY = 0.9446878,
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
