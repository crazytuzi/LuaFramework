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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2664062,
			sizeY = 0.1730625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "suicongBg",
				posX = 0.4912024,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.95,
				sizeY = 0.9707102,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				posX = 0.1965321,
				posY = 0.4949602,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2756599,
				sizeY = 0.7543839,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.5008871,
					posY = 0.5181838,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8231949,
					sizeY = 0.8204635,
					image = "tx#xiaoxiangf",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.5975748,
				posY = 0.6836845,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4698477,
				sizeY = 0.4292258,
				text = "暗器名称",
				color = "FF7C4E3A",
				fontSize = 24,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.4736959,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9614763,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj2",
				varName = "attribute",
				posX = 0.5560541,
				posY = 0.2991753,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3868063,
				sizeY = 0.4292258,
				text = "品阶",
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF001D14",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj3",
				varName = "level",
				posX = 0.7026824,
				posY = 0.2996803,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3868063,
				sizeY = 0.4292258,
				text = "Lv15",
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF001D14",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp",
				varName = "rank_icon",
				posX = 0.4912064,
				posY = 0.2996804,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2521994,
				sizeY = 0.288913,
				image = "anqi#jipin",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_show",
				posX = 0.4903747,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9502553,
				sizeY = 0.96,
				image = "h#xzk",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jtt",
					posX = 0.9963862,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06789348,
					sizeY = 0.267512,
					image = "ty#xzkjt",
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
