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
			sizeX = 0.0703125,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "item_btn",
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
				varName = "bgIcon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "itemIcon",
					posX = 0.5052941,
					posY = 0.5125834,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7880853,
					sizeY = 0.7794854,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl1",
					varName = "count",
					posX = 0.5477648,
					posY = 0.1849172,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7476179,
					sizeY = 0.4569285,
					text = "x100",
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
					varName = "lock",
					posX = 0.1894179,
					posY = 0.2116075,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3111111,
					sizeY = 0.3111111,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "guang",
				varName = "chosenIcon",
				posX = 0.5,
				posY = 0.5222222,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 1.087094,
				sizeY = 1.087094,
				image = "djk#xz",
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
