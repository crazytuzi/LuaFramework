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
			varName = "closeBtn",
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
			posX = 0.4992208,
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
				posX = 0.5,
				posY = 0.4880403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2734375,
				sizeY = 0.7283161,
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
					posY = 0.4936861,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.9873723,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.5,
					posY = 0.9400828,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8254014,
					sizeY = 0.06102356,
					image = "chu1#top3",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz",
						varName = "title",
						posX = 0.5,
						posY = 0.5,
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
					posX = 0.5000002,
					posY = 0.4650171,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8971428,
					sizeY = 0.8567354,
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
						posX = 0.4999999,
						posY = 0.4447863,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9812501,
						sizeY = 0.8570946,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zhan",
						posX = 0.3347105,
						posY = 0.9377972,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.111465,
						sizeY = 0.07122801,
						image = "tong#zl",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zhan1",
						varName = "power",
						posX = 0.6796578,
						posY = 0.9355713,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5245687,
						sizeY = 0.08903502,
						text = "10000",
						color = "FFFFD97F",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF895F30",
						fontOutlineSize = 2,
						vTextAlign = 1,
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
