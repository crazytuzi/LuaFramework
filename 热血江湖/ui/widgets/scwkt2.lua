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
			name = "tp2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2414062,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "bt",
				varName = "btn",
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
				name = "fg2",
				varName = "select",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9482202,
				sizeY = 0.8666667,
				image = "sui#mr",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tpk2",
				posX = 0.2408683,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2491912,
				sizeY = 0.8555555,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tpt2",
					varName = "icon",
					posX = 0.500992,
					posY = 0.5175112,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8230051,
					sizeY = 0.8294317,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpz3",
				varName = "name",
				posX = 0.7339987,
				posY = 0.6794178,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.598536,
				sizeY = 0.5180486,
				text = "伤害加深",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpz4",
				varName = "level",
				posX = 0.6767445,
				posY = 0.3505066,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4840277,
				sizeY = 0.4553001,
				text = "Lv.5",
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpz5",
				varName = "name2",
				posX = 0.7339987,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.598536,
				sizeY = 0.5180486,
				text = "伤害加深",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zg",
				varName = "isHave",
				posX = 0.5,
				posY = 0.5222222,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9223303,
				sizeY = 0.7777778,
				image = "sui#zdt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "redPoint",
				posX = 0.1285111,
				posY = 0.777342,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.08737866,
				sizeY = 0.3111111,
				image = "zdte#hd",
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
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
