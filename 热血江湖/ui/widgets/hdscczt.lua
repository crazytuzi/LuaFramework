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
			name = "scczt",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1138733,
			sizeY = 0.2165402,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.027295,
				sizeY = 1.04,
				image = "dw#d3",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx1",
				varName = "iconBg",
				posX = 0.5,
				posY = 0.4777702,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.699689,
				sizeY = 0.6610183,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt1",
					varName = "icon",
					posX = 0.5,
					posY = 0.5451064,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.83,
					sizeY = 0.83,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.4580873,
					posY = 0.5515568,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9368423,
					sizeY = 0.8749999,
					image = "cl#sck",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx1",
					varName = "starIcon",
					posX = 0.490506,
					posY = 0.1518916,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0233,
					sizeY = 0.2099268,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd",
				posX = 0.2260002,
				posY = 0.7296792,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3293133,
				sizeY = 0.307872,
				image = "suic#djk",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj1",
					varName = "level",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					text = "99",
					color = "FFFFE7AF",
					fontOutlineEnable = true,
					fontOutlineColor = "FF975E1F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "isSelect",
				posX = 0.5,
				posY = 0.506414,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9744633,
				sizeY = 1.004945,
				image = "h#xzt",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					posX = 0.2296336,
					posY = 0.8512655,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4385579,
					sizeY = 0.2922405,
					image = "ty#xzjt",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ztz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.7726001,
					sizeY = 0.3770359,
					text = "开采中",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
