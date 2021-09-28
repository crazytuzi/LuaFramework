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
			sizeX = 0.1054688,
			sizeY = 0.1572485,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "selectBtn",
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
				posX = 0.5,
				posY = 0.4869348,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.696296,
				sizeY = 0.83025,
				image = "djk#ktong",
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selectImg",
				posX = 0.4925926,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8444441,
				sizeY = 1.006899,
				image = "djk#xz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "levelIcon",
				posX = 0.1965994,
				posY = 0.2323076,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2962962,
				sizeY = 0.3532979,
				image = "suic#djk",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "level",
				posX = 0.1965995,
				posY = 0.2234752,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4439302,
				sizeY = 0.4208496,
				text = "15",
				color = "FFFFE7AF",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF975E1F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red_point",
				posX = 0.8866977,
				posY = 0.8835822,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1999999,
				sizeY = 0.2473085,
				image = "zdte#hd",
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
