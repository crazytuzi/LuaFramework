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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07916655,
			sizeY = 0.1478641,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tb1",
				varName = "awardItem",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8486855,
				sizeY = 0.8077989,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "itemicon",
					posX = 0.5117359,
					posY = 0.5147778,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7831926,
					sizeY = 0.7795459,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo1",
					varName = "suo1",
					posX = 0.1984068,
					posY = 0.2190548,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.319149,
					sizeY = 0.3191489,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xy2",
					varName = "count",
					posX = 0.6348865,
					posY = 0.1962906,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4991978,
					sizeY = 0.70513,
					text = "x1",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "itemDesc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
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
