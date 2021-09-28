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
			sizeX = 0.5323146,
			sizeY = 0.09722222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9907141,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pm",
				varName = "rank_img",
				posX = 0.0904519,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1527797,
				sizeY = 0.7142858,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z4",
				varName = "rank",
				posX = 0.0904519,
				posY = 0.5064974,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1272963,
				sizeY = 0.7857144,
				text = "4.",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z6",
				varName = "name",
				posX = 0.3043847,
				posY = 0.5064974,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2627979,
				sizeY = 0.7857144,
				text = "4.",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z7",
				varName = "group",
				posX = 0.580542,
				posY = 0.5064974,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2935294,
				sizeY = 0.7857144,
				text = "4.",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z8",
				varName = "count",
				posX = 0.8750994,
				posY = 0.5064974,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1952896,
				sizeY = 0.7857144,
				text = "4.",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF143230",
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
