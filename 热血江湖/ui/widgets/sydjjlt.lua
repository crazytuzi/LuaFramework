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
			name = "jl1",
			varName = "award",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2109375,
			sizeY = 0.2083333,
			alphaCascade = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wp1",
				varName = "item_bg",
				posX = 0.2225385,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3518519,
				sizeY = 0.6200001,
				image = "djk#ktong",
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5303082,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8196225,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.2057058,
					posY = 0.2298236,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3157894,
					sizeY = 0.3125,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "item_btn",
					posX = 1.012269,
					posY = 0.5053019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.065906,
					sizeY = 0.9673693,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "item_name",
				posX = 0.7213451,
				posY = 0.6507158,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5924335,
				sizeY = 0.25,
				text = "什么道具",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "item_count",
				posX = 0.7213451,
				posY = 0.3907171,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5924335,
				sizeY = 0.25,
				text = "x15",
				color = "FF634624",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
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
