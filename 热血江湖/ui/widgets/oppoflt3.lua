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
			name = "zjd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07260084,
			sizeY = 0.1151908,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "xa1",
				varName = "Btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xt1",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8644115,
				sizeY = 0.9685494,
				image = "djk#kzi",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xt2",
					varName = "item_icon",
					posX = 0.500851,
					posY = 0.5246877,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8539162,
					sizeY = 0.8539159,
					image = "items#qingtongyaoshi",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xt5",
					varName = "item_suo",
					posX = 0.2280565,
					posY = 0.2542866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3723404,
					sizeY = 0.3723403,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "item_count",
					posX = 0.2194118,
					posY = 0.2070093,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.392663,
					sizeY = 0.7831429,
					text = "50",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
