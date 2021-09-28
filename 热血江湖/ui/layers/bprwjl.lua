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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
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
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "kk1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6146457,
				sizeY = 0.5914322,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz1",
					posX = 0.3270796,
					posY = 0.08447711,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2516628,
					sizeY = 0.1539883,
					text = "总计奖励：",
					color = "FF966856",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz2",
					varName = "money_count",
					posX = 0.6871889,
					posY = 0.08447711,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2516628,
					sizeY = 0.1539883,
					text = "x64634",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xep",
					varName = "money_icon",
					posX = 0.5155477,
					posY = 0.08576828,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07221916,
					sizeY = 0.1068738,
					image = "ty#exp",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "pt",
				varName = "dailyUI",
				posX = 0.5,
				posY = 0.5183716,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5816513,
				sizeY = 0.4668769,
				scale9 = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.5,
					posY = 0.489874,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9839462,
					sizeY = 0.9447243,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb1",
					varName = "item_scroll",
					posX = 0.5,
					posY = 0.4801077,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9765353,
					sizeY = 0.9251916,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.7951172,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.234375,
				sizeY = 0.07369614,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					varName = "tabName",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5113636,
					sizeY = 0.4807693,
					image = "bp#bprw",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.7909733,
				posY = 0.7477504,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05948153,
				sizeY = 0.1077097,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
	tc = {
		ysjm = {
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"tc", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
