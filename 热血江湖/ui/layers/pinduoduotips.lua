--version = 1
local l_fileType = "layer"

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
			etype = "Button",
			name = "zz",
			varName = "closeBtn",
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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bp",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3600571,
				sizeY = 0.4064824,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bp2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#bp",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
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
					etype = "Label",
					name = "rs",
					varName = "label1",
					posX = 0.4648097,
					posY = 0.9257578,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8068983,
					sizeY = 0.2102791,
					text = "当前参团人数：100",
					color = "FF80FF80",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rs2",
					varName = "label2",
					posX = 0.5178819,
					posY = 0.7226728,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9130424,
					sizeY = 0.2884307,
					text = "团购价格分为几档，达到多少就会发生变化。注意查看档位",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5092176,
					posY = 0.3629434,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8957141,
					sizeY = 0.6332791,
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
	c_box = {
		{2,"gy", 1, 0},
		{2,"gy2", 1, 0},
		{2,"liz", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
