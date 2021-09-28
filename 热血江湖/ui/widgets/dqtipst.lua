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
			name = "bbb2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1274245,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wpk8",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8999999,
				sizeY = 0.9809731,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp8",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5427376,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "items#items_zhongjijinengshu.png",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "dj2",
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
					name = "suo2",
					varName = "lockImg",
					posX = 0.2007675,
					posY = 0.2201097,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3329284,
					sizeY = 0.3233335,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl8",
				varName = "count",
				posX = 0.2026728,
				posY = 0.2145659,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.362567,
				sizeY = 0.4998762,
				text = "x10",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 2,
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
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
