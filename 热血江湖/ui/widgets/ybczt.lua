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
			lockHV = true,
			sizeX = 0.15,
			sizeY = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "play_btn",
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
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.027295,
				sizeY = 1.04,
				image = "dw#d3",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx1",
				posX = 0.5,
				posY = 0.6206711,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5823632,
				sizeY = 0.5231051,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt1",
					varName = "pet_icon",
					posX = 0.5,
					posY = 0.5451064,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.83,
					sizeY = 0.83,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.4580873,
					posY = 0.5515568,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9368423,
					sizeY = 0.8749999,
					image = "cl#sck",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx1",
					varName = "start_icon",
					posX = 0.490506,
					posY = 0.1518916,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0233,
					sizeY = 0.2099268,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl1",
				varName = "name",
				posX = 0.5,
				posY = 0.2720221,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8037888,
				sizeY = 0.2095369,
				text = "888888",
				color = "FF43261D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xtd",
				posX = 0.5114832,
				posY = 0.8466578,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4583333,
				sizeY = 0.05092592,
				image = "zd#ybxd",
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "xl",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9639086,
					sizeY = 0.8,
					image = "zd#ybx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xtd2",
				posX = 0.5107583,
				posY = 0.7957322,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4568838,
				sizeY = 0.04166666,
				image = "zd#ybnld",
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "xl2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.95,
					sizeY = 0.7,
					image = "zd#ybnl",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd",
				posX = 0.2428912,
				posY = 0.8235939,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1822917,
				sizeY = 0.162037,
				image = "dw#djd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj1",
					varName = "level_label",
					posX = 0.5,
					posY = 0.530303,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					text = "99",
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd2",
				posX = 0.2688596,
				posY = 0.1210047,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.285492,
				sizeY = 0.2537706,
				image = "tb#tb_tongqian.png",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj2",
					varName = "level_label2",
					posX = 1.957111,
					posY = 0.5374421,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.837796,
					sizeY = 0.6578556,
					text = "234568",
					color = "FFFEDB45",
					fontSize = 22,
					fontOutlineEnable = true,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "isSelect",
				posX = 0.5,
				posY = 0.506414,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9744633,
				sizeY = 1.004945,
				image = "h#xzt",
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
					name = "dj",
					varName = "select_icon",
					posX = 0.2596948,
					posY = 0.8300243,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4382754,
					sizeY = 0.2810178,
					image = "ty#xzjt",
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
