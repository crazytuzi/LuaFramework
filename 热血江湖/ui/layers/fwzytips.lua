--version = 1
local l_fileType = "layer"

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
			etype = "Button",
			name = "aa",
			varName = "close_btn",
			posX = 0.4992199,
			posY = 0.5013869,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "bgRoot",
				posX = 0.4018139,
				posY = 0.4369091,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2509686,
				sizeY = 0.6586401,
				image = "b#db5",
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
					name = "smd",
					posX = 0.5000001,
					posY = 0.4485997,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.89752,
					sizeY = 0.808022,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.4475572,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8777733,
					sizeY = 0.8059368,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zldd",
					posX = 0.5,
					posY = 0.92397,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.86851,
					sizeY = 0.1054361,
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
