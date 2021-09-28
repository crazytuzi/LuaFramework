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
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2234375,
			sizeY = 0.1666667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_show",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5336093,
				sizeY = 0.6905326,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
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
				sizeX = 1,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.5067748,
				posY = 0.5251628,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9778179,
				sizeY = 0.9655027,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "bg_grade",
				posX = 0.2249791,
				posY = 0.4789095,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3321678,
				sizeY = 0.7999998,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.5,
					posY = 0.5416668,
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
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.6728922,
				posY = 0.6747442,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4919913,
				sizeY = 0.4292258,
				text = "写五个字这",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "btn_icon1",
				posX = 0.8239332,
				posY = 0.2645713,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1608392,
				sizeY = 0.3916666,
				image = "ty#zyd",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "gx",
					varName = "select2_btn",
					posX = 0.7007234,
					posY = 1.120203,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.717391,
					sizeY = 2.446809,
				},
				children = {
				{
					prop = {
						etype = "Grid",
						name = "hh",
						varName = "posWidget",
						posX = 0.5,
						posY = 0.3152415,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.353151,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "btn_icon2",
				posX = 0.8683965,
				posY = 0.3174264,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2867133,
				sizeY = 0.5083333,
				image = "ty#xzjt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red_point",
				posX = 0.3617359,
				posY = 0.837999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09440559,
				sizeY = 0.2333333,
				image = "zdte#hd",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "layer_lvl",
				posX = 0.6728922,
				posY = 0.316412,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4919913,
				sizeY = 0.4292258,
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF043C40",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cjt",
				varName = "icon_desc",
				posX = 0.5593923,
				posY = 0.3003385,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3426574,
				sizeY = 0.2416666,
				image = "xf#yuanman",
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
