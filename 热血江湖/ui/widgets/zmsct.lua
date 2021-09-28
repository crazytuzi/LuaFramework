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
			etype = "Button",
			name = "dj1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07890625,
			sizeY = 0.1402778,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "grade_icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9405941,
				sizeY = 0.9504949,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5209021,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "items#items_gaojijinengshu.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hs",
					varName = "hideimg",
					posX = 0.5,
					posY = 0.5312501,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.8421053,
					sizeY = 0.8333333,
					image = "ty#hong",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "item_count",
					posX = 0.5052092,
					posY = 0.2087089,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7881778,
					sizeY = 0.3327803,
					text = "x22",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "item_lock",
					posX = 0.1950916,
					posY = 0.2190415,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3157895,
					sizeY = 0.3125,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_up",
				posX = 0.7767999,
				posY = 0.7866316,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2970297,
				sizeY = 0.2970296,
				image = "chu1#ss",
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
