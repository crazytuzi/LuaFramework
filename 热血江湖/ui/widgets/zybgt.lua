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
			sizeX = 0.183435,
			sizeY = 0.1274245,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wpk8",
				varName = "item_bg",
				posX = 0.1876338,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3620152,
				sizeY = 0.9264746,
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
				name = "wpm2",
				varName = "itemName_label",
				posX = 0.801564,
				posY = 0.7175814,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8390683,
				sizeY = 0.4998762,
				text = "伏魔花灵剑碎片",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl8",
				varName = "count",
				posX = 0.7001227,
				posY = 0.2690644,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6276677,
				sizeY = 0.4998762,
				text = "1/1000",
				color = "FF966856",
				fontOutlineColor = "FF27221D",
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
