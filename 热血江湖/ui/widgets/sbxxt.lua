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
			sizeX = 0.2664062,
			sizeY = 0.1730625,
		},
		children = {
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
				posX = 0.4912024,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.9707102,
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
				etype = "Image",
				name = "dk",
				varName = "weaponBg",
				posX = 0.1965321,
				posY = 0.4949602,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2785924,
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
				posX = 0.5975748,
				posY = 0.6836845,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4698477,
				sizeY = 0.4292258,
				text = "心法名字六字",
				color = "FF7C4E3A",
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
				posX = 0.09318975,
				posY = 0.2459826,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1085044,
				sizeY = 0.2808876,
				image = "chu1#djk",
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
				sizeX = 0.9502553,
				sizeY = 0.96,
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
					name = "fff",
					posX = 0.9963862,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06789348,
					sizeY = 0.267512,
					image = "ty#xzkjt",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "qlvl",
				posX = 0.09130254,
				posY = 0.2490526,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2403405,
				sizeY = 0.2743226,
				text = "22",
				color = "FFFEDB45",
				fontOutlineEnable = true,
				fontOutlineColor = "FF00152E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx",
				varName = "slvl",
				posX = 0.5832437,
				posY = 0.3282999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4281526,
				sizeY = 0.3290398,
				image = "shen#sbx1",
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
