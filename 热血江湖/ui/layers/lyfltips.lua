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
			name = "zz",
			varName = "close_btn",
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
				posX = 0.2633717,
				posY = 0.4992125,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2470647,
				sizeY = 0.7333354,
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
					etype = "Button",
					name = "an",
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
					name = "dw2",
					posX = 0.5033137,
					posY = 0.9340973,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8885578,
					sizeY = 0.06060589,
					image = "chu1#top3",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz",
						posX = 0.5,
						posY = 0.4375,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6836313,
						sizeY = 1.5625,
						text = "魂玉附灵",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5000001,
					posY = 0.4500194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8975199,
					sizeY = 0.7638984,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.98,
						sizeY = 0.98,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zhanz",
					posX = 0.3259859,
					posY = 0.8673789,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1106745,
					sizeY = 0.06060589,
					image = "tong#zl",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl",
					varName = "battle_power",
					posX = 0.6088448,
					posY = 0.8635911,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7138616,
					sizeY = 0.2973315,
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
