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
			name = "lbjd",
			varName = "sb_root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.221875,
			sizeY = 0.1730625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_show",
				posX = 0.2530911,
				posY = 0.7117211,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5009697,
				sizeY = 0.558745,
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
				name = "a",
				varName = "btn",
				posX = 0.4879065,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9614763,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "selectBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "bg",
				posX = 0.2202635,
				posY = 0.4789095,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3873239,
				sizeY = 0.8827896,
				image = "shls#txk1",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.5006827,
					posY = 0.501199,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7169997,
					sizeY = 0.698855,
					image = "items#items_gaojijinengshu.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.6902993,
				posY = 0.6836845,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5615096,
				sizeY = 0.4292258,
				text = "心法名字六字",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "lvl_icon",
				posX = 0.6304414,
				posY = 0.3344994,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4632706,
				sizeY = 0.3420324,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "lvl_txt",
					posX = 0.5365473,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.039973,
					sizeY = 1.729675,
					text = "Lv.22",
					color = "FF65944D",
					fontOutlineColor = "FF975E1F",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "isBattling",
				posX = 0.1480932,
				posY = 0.7833586,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2746479,
				sizeY = 0.3852173,
				image = "shen#zb",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red_point",
				posX = 0.9419041,
				posY = 0.863471,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09507042,
				sizeY = 0.2247101,
				image = "zdte#hd",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp",
				varName = "lock",
				posX = 0.5632474,
				posY = 0.331601,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3028169,
				sizeY = 0.288913,
				image = "anqi#weijiesuo",
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
