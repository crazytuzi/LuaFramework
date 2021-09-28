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
			sizeX = 0.15625,
			sizeY = 0.2083333,
			alphaCascade = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wp1",
				varName = "item_bg1",
				posX = 0.5,
				posY = 0.5933326,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.475,
				sizeY = 0.6200001,
				image = "djk#ktong",
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "item_icon1",
					posX = 0.5,
					posY = 0.5274574,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8069127,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					posX = 0.2057058,
					posY = 0.2278075,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3157895,
					sizeY = 0.3225806,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "item_desc1",
				posX = 0.5,
				posY = 0.1914998,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.25,
				text = "什么道具x100",
				color = "FF634624",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
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
