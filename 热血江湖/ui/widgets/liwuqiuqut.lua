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
			sizeX = 0.1132813,
			sizeY = 0.1805556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "item_btn",
				posX = 0.4999935,
				posY = 0.6249854,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6747606,
				sizeY = 0.8486016,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "icon_bg",
				posX = 0.5,
				posY = 0.5705127,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6482756,
				sizeY = 0.7230768,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "item_icon",
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
					varName = "item_count",
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
				posX = 0.5068963,
				posY = 0.578205,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7298252,
				sizeY = 0.814036,
				image = "djk#xz",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "item_name",
				posX = 0.4999996,
				posY = 0.1170505,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9540938,
				sizeY = 0.3246695,
				text = "道具名称",
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
