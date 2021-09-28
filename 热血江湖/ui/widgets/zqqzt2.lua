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
			name = "jd2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08269729,
			sizeY = 0.1422548,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djt4",
				varName = "item_BgIcon",
				posX = 0.5,
				posY = 0.5781065,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7746627,
				sizeY = 0.8005979,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "syn4",
					varName = "item_btn",
					posX = 0.5021638,
					posY = 0.4064182,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8512329,
					sizeY = 1.133552,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "das4",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5416668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl7",
					varName = "item_count",
					posX = 0.5,
					posY = -0.08090152,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.441235,
					sizeY = 0.4679778,
					text = "x200",
					color = "FF966856",
					fontSize = 18,
					fontOutlineColor = "FF102E21",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
