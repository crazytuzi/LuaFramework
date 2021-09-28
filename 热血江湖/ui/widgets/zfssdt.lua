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
			name = "k",
			posX = 0.5,
			posY = 0.4969394,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3007813,
			sizeY = 0.1408608,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "gx",
				varName = "selectBtn",
				posX = 0.7274939,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5225704,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "itemBtn",
				posX = 0.1444344,
				posY = 0.5053315,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.243148,
				sizeY = 0.863965,
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
				sizeX = 0.99,
				sizeY = 0.98,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk1",
				varName = "itemBg",
				posX = 0.1382196,
				posY = 0.4786324,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2184794,
				sizeY = 0.8761758,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "itemIcon",
					posX = 0.5,
					posY = 0.5371094,
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
					name = "suo2",
					varName = "itemLock",
					posX = 0.1965968,
					posY = 0.2456336,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3566564,
					sizeY = 0.3529412,
					image = "tb#tb_suo.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "mz1",
				varName = "itemName",
				posX = 0.5541731,
				posY = 0.7175786,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5936357,
				sizeY = 0.4607697,
				text = "道具名称",
				color = "FFFF7E2D",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jz1",
				varName = "energyCount",
				posX = 0.4697083,
				posY = 0.3192155,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2472865,
				sizeY = 0.4475255,
				text = "2123",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hb1",
				varName = "energyIcon",
				posX = 0.289554,
				posY = 0.3254573,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1038961,
				sizeY = 0.412318,
				image = "tb#tongqian",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "energyLock",
					posX = 0.608169,
					posY = 0.2589015,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.55,
					sizeY = 0.55,
					image = "tb#tb_suo.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t2",
				varName = "select_icon1",
				posX = 0.8464276,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09545639,
				sizeY = 0.3702401,
				image = "ty#zyd",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "selectIcon",
				posX = 0.8759036,
				posY = 0.5676959,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1719965,
				sizeY = 0.485706,
				image = "ty#xzjt",
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
