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
			name = "zmsjt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2320313,
			sizeY = 0.1319444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xzt",
				varName = "selectImg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8571879,
				sizeY = 0.7181849,
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
				name = "tdt",
				varName = "icon",
				posX = 0.4850188,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.93,
				sizeY = 0.9752069,
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
				name = "an",
				varName = "btn",
				posX = 0.4850188,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9661015,
				sizeY = 0.9789477,
				image = "h#c4",
				imageNormal = "h#c4",
				imagePressed = "h#c2",
				imageDisable = "h#c4",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz",
				varName = "nameLabel",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6900336,
				sizeY = 0.4715427,
				text = "活动名字",
				color = "FF745226",
				fontSize = 26,
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red",
				posX = 0.04954278,
				posY = 0.8362961,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.09090907,
				sizeY = 0.294737,
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
