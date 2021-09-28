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
			etype = "Image",
			name = "kk2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1953125,
			sizeY = 0.4166667,
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "buyBtn",
				posX = 0.5,
				posY = 0.2003498,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5610954,
				sizeY = 0.1850803,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "f2",
					varName = "no_name2",
					posX = 0.5,
					posY = 0.5468748,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8313926,
					sizeY = 0.9422305,
					text = "购买",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd4",
				posX = 0.5,
				posY = 0.4378218,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3676144,
				sizeY = 0.3196842,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj4",
					varName = "bgIcon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.979287,
					sizeY = 0.9384261,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt4",
						varName = "icon",
						posX = 0.4999901,
						posY = 0.5226914,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7714558,
						sizeY = 0.7714563,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "bj4",
						varName = "bt",
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
						etype = "Label",
						name = "sl4",
						varName = "count",
						posX = 0.5145302,
						posY = 0.1937359,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7878309,
						sizeY = 0.4313136,
						text = "x41",
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
						varName = "suo",
						posX = 0.1846533,
						posY = 0.2284948,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3157895,
						sizeY = 0.3225807,
						image = "tb#suo",
					},
				},
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
