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
			name = "dj1",
			varName = "item_bg",
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
				etype = "Button",
				name = "djan",
				varName = "item_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djtb",
				varName = "item_icon",
				posX = 0.5,
				posY = 0.5215054,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8,
				sizeY = 0.8,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djsl",
				varName = "item_count",
				posX = 0.5075889,
				posY = 0.2029539,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8464606,
				sizeY = 0.3716368,
				text = "x66",
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
				posX = 0.1847393,
				posY = 0.2316197,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3157895,
				sizeY = 0.3225805,
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
	gy = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
