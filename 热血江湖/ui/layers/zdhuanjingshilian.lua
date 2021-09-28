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
			name = "ys",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bo",
				posX = 0.8455256,
				posY = 0.777685,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.296875,
				sizeY = 0.4183484,
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
					etype = "Label",
					name = "slz",
					posX = 0.3132418,
					posY = 0.8359175,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5096875,
					sizeY = 0.6677624,
					text = "副本竞速时间：",
					color = "FF47C8E8",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz3",
					varName = "time",
					posX = 0.6790342,
					posY = 0.8359175,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5096875,
					sizeY = 0.6677624,
					text = "副本竞速时间：",
					color = "FF47C8E8",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5209069,
					posY = 0.3811654,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9250177,
					sizeY = 0.6960435,
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
	jn6 = {
	},
	bj = {
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
	jn7 = {
	},
	bj2 = {
	},
	c_hld = {
	},
	c_hld2 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
