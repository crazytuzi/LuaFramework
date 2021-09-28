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
			etype = "Image",
			name = "bgt",
			posX = 0.5044184,
			posY = 1.172401,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6172566,
			sizeY = 0.1182033,
			image = "chu1#zld",
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "zl",
				varName = "battle_power",
				posX = 0.5930341,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7138616,
				sizeY = 1.061954,
				text = "455546",
				color = "FFFFE7AF",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FFB2722C",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
				colorTL = "FFFFD060",
				colorTR = "FFFFD060",
				colorBR = "FFF2441C",
				colorBL = "FFF2441C",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "role_lv",
				posX = 0.03907025,
				posY = -0.6424803,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5063323,
				sizeY = 1.169878,
				text = "LV99",
				color = "FFFFEED7",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FFB2722C",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhanz",
				posX = 0.2564197,
				posY = 0.5043473,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.125448,
				sizeY = 0.6400001,
				image = "tong#zl",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
