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
			name = "hdlbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1938232,
			sizeY = 0.09782898,
		},
		children = {
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
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "bt",
				posX = 0.584849,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7577782,
				sizeY = 0.9228122,
				image = "czhd#ancg",
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "czhd#ancg",
				imagePressed = "czhd#andl",
				imageDisable = "czhd#ancg",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "btIcon1",
					posX = 0.1720446,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2553191,
					sizeY = 0.7384616,
					image = "czhd#djlb",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb2",
					varName = "btIcon2",
					posX = -0.1577425,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2553191,
					sizeY = 0.7384616,
					image = "czhd#djlb",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzt",
				varName = "select_icon",
				posX = 0.5045428,
				posY = 0.5490361,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.016245,
				sizeY = 1.081064,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red_point",
				posX = 0.9422727,
				posY = 0.8505247,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09297958,
				sizeY = 0.3265336,
				image = "czhd#hd",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z",
				varName = "TitleName",
				posX = 0.6838242,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5176515,
				sizeY = 0.8042339,
				text = "一级列表",
				color = "FF914A15",
				fontSize = 22,
				fontOutlineColor = "FFFFEFC8",
				fontOutlineSize = 2,
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
