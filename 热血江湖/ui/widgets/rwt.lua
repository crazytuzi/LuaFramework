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
			sizeX = 0.3320313,
			sizeY = 0.1367891,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "xinfaBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.95,
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
				posX = 0.1342564,
				posY = 0.4689889,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2,
				sizeY = 0.8721326,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "pet_icon",
					posX = 0.5,
					posY = 0.5480618,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "items#items_gaojijinengshu.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "mz",
				varName = "pet_desc",
				posX = 0.368246,
				posY = 0.7253461,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2340694,
				sizeY = 0.4292258,
				text = "写四个字",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF404040",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "mz2",
				varName = "task_name_label",
				posX = 0.6387985,
				posY = 0.7253461,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.319034,
				sizeY = 0.4292258,
				text = "任务名字字",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF404040",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx1",
				varName = "star1",
				posX = 0.2866479,
				posY = 0.3003201,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08941175,
				sizeY = 0.3858332,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx4",
				posX = 0.374259,
				posY = 0.3003201,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08941175,
				sizeY = 0.3858332,
				image = "ty#xx",
				alpha = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx5",
				posX = 0.46187,
				posY = 0.3003201,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08941175,
				sizeY = 0.3858332,
				image = "ty#xx",
				alpha = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx2",
				varName = "star2",
				posX = 0.374259,
				posY = 0.3003201,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08941175,
				sizeY = 0.3858332,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx3",
				varName = "star3",
				posX = 0.46187,
				posY = 0.3003201,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08941175,
				sizeY = 0.3858332,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd",
				posX = 0.1353505,
				posY = 0.1669039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1788235,
				sizeY = 0.2639911,
				image = "rw#djd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "level_label",
					posX = 0.4672616,
					posY = 0.5415385,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.075019,
					sizeY = 1.238565,
					text = "Lv.15",
					color = "FFFEDB45",
					fontOutlineEnable = true,
					fontOutlineColor = "FF00152E",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ywc",
				varName = "finish_icon",
				posX = 0.7567571,
				posY = 0.4863918,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4729411,
				sizeY = 0.4162937,
				image = "rw#ywc2",
				rotation = -15,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "select_icon",
				posX = 0.4986411,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9799374,
				sizeY = 0.99,
				image = "h#xzk",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.9927967,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0720334,
					sizeY = 0.3999866,
					image = "cl2#yjt",
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
