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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6539247,
			sizeY = 0.1414337,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "di",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dy",
				varName = "titleIcon",
				posX = 0.1064377,
				posY = 0.5196003,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1517281,
				sizeY = 0.5990243,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dw2",
				posX = 0.9008535,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.1732328,
				sizeY = 0.5401039,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zdz2",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8393403,
					sizeY = 0.7905699,
					text = "领取",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pmz",
				varName = "tilteText",
				posX = 0.1067226,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1377842,
				sizeY = 0.6838266,
				text = "4",
				color = "FF966856",
				fontSize = 26,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scroll",
				posX = 0.4844934,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6416988,
				sizeY = 0.8584492,
				horizontal = true,
				showScrollBar = false,
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
