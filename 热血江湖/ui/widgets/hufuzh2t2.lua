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
			sizeX = 0.15625,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select_btn",
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
				name = "dk",
				varName = "itemBg",
				posX = 0.2101625,
				posY = 0.4789095,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4250002,
				sizeY = 0.9444444,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "itemIcon",
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
				posX = 0.9390074,
				posY = 0.6836845,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.018926,
				sizeY = 0.4292258,
				text = "心法名字六字",
				color = "FF966856",
				fontSize = 18,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "itemCount",
				posX = 0.9390074,
				posY = 0.3200336,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.018926,
				sizeY = 0.4292258,
				text = "shuliang",
				color = "FFC93034",
				fontSize = 18,
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
