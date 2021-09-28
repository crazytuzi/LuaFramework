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
			varName = "sb_root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.221875,
			sizeY = 0.1730625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_show",
				posX = 0.2530911,
				posY = 0.7117211,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5009697,
				sizeY = 0.558745,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.4879065,
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
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "iconBg",
				posX = 0.2202635,
				posY = 0.4789095,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.334507,
				sizeY = 0.7463585,
				image = "shen#sbd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.5081546,
					posY = 0.5490907,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7566569,
					sizeY = 0.7395833,
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
				posX = 0.6902994,
				posY = 0.6836845,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5615096,
				sizeY = 0.4292258,
				text = "心法名字六字",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "qlvl_icon1",
				posX = 0.09083541,
				posY = 0.2459826,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1690141,
				sizeY = 0.3852173,
				image = "suic#djk",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "qlvl",
				posX = 0.08893847,
				posY = 0.2410272,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2403405,
				sizeY = 0.2743226,
				text = "22",
				color = "FFFFE7AF",
				fontOutlineEnable = true,
				fontOutlineColor = "FF975E1F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx",
				varName = "slvl",
				posX = 0.6825839,
				posY = 0.3122492,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5140845,
				sizeY = 0.3290398,
				image = "shen#sbx1",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "desc",
				posX = 0.6832694,
				posY = 0.3200336,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5474496,
				sizeY = 0.4292258,
				text = "尚未获得线索",
				color = "FF65944D",
				fontSize = 22,
				fontOutlineColor = "FF002120",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "is_select",
				posX = 0.1480932,
				posY = 0.7833586,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2746479,
				sizeY = 0.3852173,
				image = "shen#zb",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red_point",
				posX = 0.9419041,
				posY = 0.863471,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09507042,
				sizeY = 0.2247101,
				image = "zdte#hd",
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
