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
			name = "k2",
			posX = 0.4999999,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08515625,
			sizeY = 0.1505783,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk1",
				varName = "effectBg",
				posX = 0.5,
				posY = 0.4925237,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9357798,
				sizeY = 0.9408171,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "icon",
					posX = 0.5,
					posY = 0.5105124,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8155609,
					sizeY = 0.8033884,
					image = "yj#xin1",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sm1",
				varName = "lockText",
				posX = 0.5,
				posY = 0.2115732,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.022524,
				sizeY = 0.4538373,
				text = "未解锁",
				color = "FFC93034",
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sm2",
				varName = "name",
				posX = 0.6555354,
				posY = 0.6857417,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6165432,
				sizeY = 0.4538373,
				text = "名字",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF183935",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzk",
				varName = "chooseIcon",
				posX = 0.5,
				posY = 0.5184474,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.9891927,
				sizeY = 0.9945176,
				image = "djk#xz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "syz",
				varName = "usingIcon",
				posX = 0.3525924,
				posY = 0.8038794,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7247707,
				sizeY = 0.3505005,
				image = "zqqz2#yzb",
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
