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
			name = "jie",
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.111202,
			sizeY = 0.2083333,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.1938368,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.018698,
				sizeY = 0.2933334,
				image = "bagua#zhuo3",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djt2",
				varName = "grade_icon",
				posX = 0.515733,
				posY = 0.5273969,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5971678,
				sizeY = 0.5666668,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djts2",
					varName = "item_icon",
					posX = 0.503991,
					posY = 0.5095298,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8204181,
					sizeY = 0.8257036,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1992327,
					posY = 0.2353428,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3373493,
					sizeY = 0.3373493,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gxd",
				posX = 0.694423,
				posY = 0.7089165,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1756376,
				sizeY = 0.1666667,
				image = "chu1#gxd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "select",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.266666,
					sizeY = 1.133333,
					image = "chu1#dj",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "bt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8882467,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.5,
				posY = 0.1765572,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.031428,
				sizeY = 0.3709734,
				text = "装备名字",
				color = "FFFFD43D",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF84251B",
				fontOutlineSize = 2,
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
