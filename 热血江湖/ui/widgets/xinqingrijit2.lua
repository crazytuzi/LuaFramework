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
			name = "jie2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1400485,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "beiban",
				varName = "background",
				posX = 0.5000003,
				posY = 0.5793376,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8,
				sizeY = 0.7933759,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "liwu",
				varName = "bg",
				posX = 0.5,
				posY = 0.5793376,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8,
				sizeY = 0.7933759,
				image = "djk#ktong",
				scale9Left = 0.3,
				scale9Right = 0.68,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "liwu2",
					varName = "item_icon",
					posX = 0.505904,
					posY = 0.51595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8367714,
					sizeY = 0.8452584,
					scale9Left = 0.3,
					scale9Right = 0.68,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xqz2",
				varName = "count",
				posX = 0.5,
				posY = 0.0804691,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 2.243953,
				sizeY = 0.7961277,
				text = "x1000000",
				color = "FF966856",
				fontSize = 18,
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
