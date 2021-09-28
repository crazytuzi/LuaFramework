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
			etype = "Grid",
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
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
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "dd",
					varName = "close_btn",
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
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fj1",
				posX = 0.5,
				posY = 0.2319423,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9507808,
				sizeY = 0.06944445,
				image = "zyt#dz",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tbw",
				varName = "text",
				posX = 0.3393272,
				posY = 0.06114018,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2651861,
				sizeY = 0.1040019,
				color = "FFFD5E18",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scroll",
				posX = 0.547208,
				posY = 0.4817503,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7870286,
				sizeY = 0.530131,
				horizontal = true,
				showScrollBar = false,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dl1",
				posX = 0.04919395,
				posY = 0.3128167,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09296875,
				sizeY = 0.1944444,
				image = "zyt#dl",
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx2",
				varName = "model",
				posX = 0.1091513,
				posY = 0.2517819,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1125365,
				sizeY = 0.6600285,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dl2",
				posX = 0.9539391,
				posY = 0.3114278,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09296875,
				sizeY = 0.1944444,
				image = "zyt#dl",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tis",
				posX = 0.5,
				posY = 0.1769194,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "点击空白区域关闭",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zz",
				posX = 0.3494667,
				posY = 0.7898017,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.378125,
				sizeY = 0.06666667,
				image = "zyt#top",
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
