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
			sizeX = 0.1046968,
			sizeY = 0.1944444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.98,
				image = "ll#cyd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
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
				etype = "Image",
				name = "t1",
				varName = "suicongBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.9798751,
				sizeY = 1,
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
				varName = "iconBg",
				posX = 0.4586504,
				posY = 0.5574812,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8432087,
				sizeY = 0.8214288,
				image = "ll#sxd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.5434093,
					posY = 0.5136271,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7079646,
					sizeY = 0.6956522,
					image = "ll#shenfa",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_show",
				posX = 0.4929544,
				posY = 0.5632898,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.7238163,
				sizeY = 0.6928573,
				image = "ll#sxxz",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.5068949,
				posY = 0.1322057,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.163216,
				sizeY = 0.2770618,
				text = "宠物名字",
				color = "FF7C4E3A",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "desc",
				posX = 0.5074942,
				posY = 0.341442,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5843194,
				sizeY = 0.4292258,
				text = "Lv.55",
				fontSize = 22,
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "is_select",
				posX = 0.3476171,
				posY = 0.7565942,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6417341,
				sizeY = 0.4428572,
				image = "ll#xj",
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
