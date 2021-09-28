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
			name = "xl1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2109375,
			sizeY = 0.3069444,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "xz1",
				varName = "path_btn",
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
				name = "yt1",
				varName = "path_icon",
				posX = 0.5,
				posY = 0.5950229,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.962963,
				sizeY = 0.7013575,
				image = "lx#xl11",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzk",
				varName = "select_bg",
				posX = 0.5,
				posY = 0.6131225,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.7873304,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "cdd",
					posX = 0.4963015,
					posY = -0.1559735,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9178571,
					sizeY = 0.1182926,
					image = "d#cdd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "path_name",
				posX = 0.5,
				posY = 0.1957134,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.7051455,
				sizeY = 0.2011472,
				text = "玄渤古道",
				color = "FFFFF554",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz2",
				varName = "path_pos",
				posX = 0.5,
				posY = 0.1588553,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.308945,
				sizeY = 0.2011472,
				text = "玄渤竹林至三邪圣地",
				color = "FF43261D",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
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
