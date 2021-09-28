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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.221875,
			sizeY = 0.1572485,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_show",
				posX = 0.486456,
				posY = 0.502962,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.94,
				sizeY = 0.96,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "suicongBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.024564,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "iconBg",
				posX = 0.2273057,
				posY = 0.4869348,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3309859,
				sizeY = 0.83025,
				image = "sui#scbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.4903608,
					posY = 0.5184126,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8231949,
					sizeY = 0.8204635,
					image = "tx#xiaoxiangf",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sk",
					posX = 0.4900022,
					posY = 0.5302802,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9468085,
					sizeY = 0.893617,
					image = "cl#sck",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.6444684,
				posY = 0.6836845,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4698477,
				sizeY = 0.4292258,
				text = "宠物名字",
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
				varName = "qlvl_icon1",
				posX = 0.1225254,
				posY = 0.2941348,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1690141,
				sizeY = 0.4239574,
				image = "suic#djk",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "qlvl",
				posX = 0.1170679,
				posY = 0.2810639,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2403405,
				sizeY = 0.2743226,
				text = "15",
				color = "FFFFE7AF",
				fontOutlineEnable = true,
				fontOutlineColor = "FF975E1F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "desc",
				posX = 0.6832694,
				posY = 0.3200336,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5474496,
				sizeY = 0.4292258,
				text = "尚未获得青睐",
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF002120",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj2",
				varName = "attribute",
				posX = 0.863829,
				posY = 0.6836845,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1443847,
				sizeY = 0.4292258,
				text = "1转",
				color = "FFC76F34",
				fontOutlineColor = "FF001D14",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx",
				varName = "slvl",
				posX = 0.6661478,
				posY = 0.3294362,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5176056,
				sizeY = 0.2561409,
				image = "scxx#scxx0",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "is_select",
				posX = 0.06725983,
				posY = 0.7913379,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1408451,
				sizeY = 0.4504547,
				image = "sui#cz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red_point",
				posX = 0.938383,
				posY = 0.8393949,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09507042,
				sizeY = 0.2473085,
				image = "zdte#hd",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.67958,
				posY = 0.5264974,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5035211,
				sizeY = 0.1236542,
				image = "d2#fgt",
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
