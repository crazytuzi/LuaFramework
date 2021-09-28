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
			name = "qm1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3149648,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dwt",
				varName = "propertyBg1",
				posX = 0.5,
				posY = 0.06666666,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9428571,
				sizeY = 0.04444445,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dwt2",
				varName = "propertyBg2",
				posX = 0.5,
				posY = 0.06666666,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.942857,
				sizeY = 0.04444445,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "js1",
				varName = "attr",
				posX = 0.7063199,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.617482,
				sizeY = 0.9999994,
				text = "666（+12）",
				color = "FFF1E9D7",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc1",
				varName = "name",
				posX = 0.3194684,
				posY = 0.5000006,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.342347,
				sizeY = 0.9999994,
				text = "气血：",
				color = "FF966856",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				varName = "icon",
				posX = 0.08650777,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09921744,
				sizeY = 0.8888889,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx3",
				varName = "count2",
				posX = 0.8783292,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3946688,
				sizeY = 1.25,
				text = "666",
				color = "FF65944D",
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
	sx3 = {
		sx3 = {
			alpha = {{0, {0.4}}, {700, {1}}, {1300, {0.4}}, },
		},
	},
	c_dakai = {
		{0,"sx3", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
