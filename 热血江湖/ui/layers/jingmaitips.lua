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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6836313,
						sizeY = 1.259089,
						text = "经脉总属性",
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
					posY = 0.4452794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8975198,
					sizeY = 0.784721,
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
					name = "zl",
					posX = 0.3486502,
					posY = 0.8705907,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1106745,
					sizeY = 0.06060589,
					image = "tong#zl",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zlz",
						varName = "power",
						posX = 3.335785,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 3.818434,
						sizeY = 1.199063,
						text = "6666",
						color = "FFFFE7AF",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB2722C",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
