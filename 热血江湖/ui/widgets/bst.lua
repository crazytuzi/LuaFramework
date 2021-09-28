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
			name = "bs1",
			varName = "gemButton",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1953125,
			sizeY = 0.1569444,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.02,
				sizeY = 1.1,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				alpha = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gx",
				posX = 0.6556421,
				posY = 0.5386783,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.572,
				sizeY = 0.1238938,
				image = "d2#fgt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "bsgrade",
				posX = 0.2287359,
				posY = 0.4909536,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.38,
				sizeY = 0.8495578,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t1",
					varName = "jewelIcon",
					posX = 0.5011626,
					posY = 0.5344587,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.2057213,
					posY = 0.22962,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.3347463,
					sizeY = 0.3312594,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl1",
				varName = "jewelCount",
				posX = 0.2459787,
				posY = 0.2556275,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2661563,
				sizeY = 0.3630718,
				text = "x22",
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "aa1",
				varName = "jewelName",
				posX = 0.7114132,
				posY = 0.6906441,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.581547,
				sizeY = 0.3941214,
				text = "10级小石头",
				color = "FFEDE4D9",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "bb1",
				varName = "jewelPro",
				posX = 0.6988959,
				posY = 0.2866479,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5565127,
				sizeY = 0.3013625,
				text = "物理攻击",
				color = "FF966856",
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
