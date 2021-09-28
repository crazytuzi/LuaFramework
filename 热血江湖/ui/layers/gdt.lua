--version = 1
local l_fileType = "layer"

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
			posX = 0.48986,
			posY = 0.9,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7097713,
			sizeY = 0.2,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.5,
				posY = 0.8947957,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9389029,
				sizeY = 0.1805556,
				image = "d#gdt",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "gdz",
				varName = "text",
				posX = 0.5,
				posY = 0.9027752,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9941914,
				sizeY = 0.2359759,
				color = "FFFFF554",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
				autoWrap = false,
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
