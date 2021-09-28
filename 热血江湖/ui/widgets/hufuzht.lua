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
			sizeX = 0.3515625,
			sizeY = 0.1333333,
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
				varName = "xinfaBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9812891,
				sizeY = 1,
				image = "b#lfd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "equipBg",
				posX = 0.1425647,
				posY = 0.5101172,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1777778,
				sizeY = 0.8333336,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.4957812,
					posY = 0.5102026,
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
					name = "suo",
					varName = "suo",
					posX = 0.1919497,
					posY = 0.213137,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.319149,
					sizeY = 0.3191489,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.5535368,
				posY = 0.7287579,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5818501,
				sizeY = 0.4292258,
				text = "心法名字六字",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "mz2",
				varName = "power",
				posX = 0.5363366,
				posY = 0.3231356,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5474496,
				sizeY = 0.4292258,
				text = "战力：",
				color = "FFEB5513",
				fontOutlineColor = "FF002120",
				vTextAlign = 1,
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
