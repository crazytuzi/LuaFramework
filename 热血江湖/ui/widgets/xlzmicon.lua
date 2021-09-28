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
			name = "jd",
			posX = 0.5005545,
			posY = 0.5006931,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.05972671,
			sizeY = 0.1067714,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bg",
				varName = "bg",
				posX = 0.5049288,
				posY = 0.5000003,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.06362,
				sizeY = 1.04424,
				image = "djk#ktong",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bg2",
				varName = "itemIcon",
				posX = 0.5061591,
				posY = 0.5148497,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8571246,
				sizeY = 0.8143187,
				image = "icon",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "icon",
				varName = "itemBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.053763,
				sizeY = 1.04424,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bang",
				varName = "suo",
				posX = 0.2150735,
				posY = 0.2553262,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.311828,
				sizeY = 0.3196652,
				image = "tb#suo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "num",
				varName = "num",
				posX = 0.618084,
				posY = 0.2446857,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "20",
				fontOutlineEnable = true,
				hTextAlign = 2,
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
