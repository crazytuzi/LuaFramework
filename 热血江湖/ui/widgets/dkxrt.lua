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
			name = "scczt",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1138733,
			sizeY = 0.2165402,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "play_btn",
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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.027295,
				sizeY = 1.04,
				image = "dw#d3",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx1",
				posX = 0.5,
				posY = 0.4777702,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.699689,
				sizeY = 0.6610183,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt1",
					varName = "pet_icon",
					posX = 0.5,
					posY = 0.5354138,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx1",
					varName = "star_icon",
					posX = 0.490506,
					posY = 0.1518916,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0233,
					sizeY = 0.2099268,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd1",
				posX = 0.2054462,
				posY = 0.7681004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2356847,
				sizeY = 0.227225,
				image = "dw#djd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj1",
					varName = "level_label",
					posX = 0.5,
					posY = 0.560606,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.112165,
					sizeY = 0.9453558,
					text = "99",
					fontOutlineEnable = true,
					fontOutlineColor = "FF102E21",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hh",
				varName = "ingRoot",
				posX = 0.5,
				posY = 0.506414,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9744633,
				sizeY = 1.004945,
				image = "h#xzt",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sw",
					varName = "desc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8689681,
					sizeY = 0.3451324,
					text = "采矿中",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
					vTextAlign = 1,
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
