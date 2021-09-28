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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.140625,
			sizeY = 0.2884407,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.6407381,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5222222,
				sizeY = 0.4526253,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "item_icon",
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
					name = "bj1",
					varName = "btn",
					posX = 0.5,
					posY = 0.3569169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.286166,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "num",
					posX = 0.514614,
					posY = 0.1854194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7779253,
					sizeY = 0.4330077,
					text = "x16",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "duo",
					varName = "lock",
					posX = 0.181314,
					posY = 0.2132565,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2978723,
					sizeY = 0.2978723,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "x",
				varName = "point",
				posX = 0.5,
				posY = 0.237813,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.858825,
				sizeY = 0.3140883,
				text = "x点/个",
				color = "FF6ACE33",
				fontOutlineColor = "FFFFFFFF",
				fontOutlineSize = 2,
				hTextAlign = 1,
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
	gy = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
