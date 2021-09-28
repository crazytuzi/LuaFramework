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
			etype = "Grid",
			name = "renwu",
			varName = "taskRoot",
			posX = 0.09440771,
			posY = 0.6298472,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.180874,
			sizeY = 0.259625,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "smd",
				varName = "tag_root",
				posX = 0.5,
				posY = 0.7423059,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.480805,
				image = "b#rwd",
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
					name = "mb",
					varName = "target",
					posX = 0.434875,
					posY = 0.7919281,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7924786,
					sizeY = 0.4860668,
					text = "当前目标",
					color = "FFFFF554",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z2",
					varName = "tag_desc",
					posX = 0.5,
					posY = 0.3424144,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.949082,
					sizeY = 0.6259289,
					text = "小描述一大推",
					vTextAlign = 1,
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd",
			posX = 0.4992189,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "desc_root",
				posX = 0.3906294,
				posY = 0.2845861,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3275872,
				sizeY = 0.1423214,
				image = "b#dtd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "as2",
					varName = "desc",
					posX = 0.5,
					posY = 0.4797288,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9614388,
					sizeY = 0.8735207,
					text = "求援",
					color = "FFFFF554",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
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
	gy2 = {
	},
	gy3 = {
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
