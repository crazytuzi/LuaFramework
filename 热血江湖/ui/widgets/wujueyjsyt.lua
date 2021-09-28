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
			posX = 0.5007801,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0859375,
			sizeY = 0.1644427,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "cover",
				posX = 0.5,
				posY = 0.6097988,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8181818,
				sizeY = 0.7601432,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5052876,
					posY = 0.5180072,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8324518,
					sizeY = 0.8351824,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.2004517,
					posY = 0.2226258,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3333333,
					sizeY = 0.3333333,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "count",
					posX = 0.4052787,
					posY = 0.1851641,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.032126,
					sizeY = 0.6576992,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btns",
				varName = "Item",
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
				name = "dw",
				varName = "value",
				posX = 0.5,
				posY = 0.1703832,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.026069,
				sizeY = 0.4538546,
				text = "5000",
				color = "FF966856",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
