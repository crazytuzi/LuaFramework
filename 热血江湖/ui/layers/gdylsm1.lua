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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "closeBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				alpha = 0.7,
			},
		},
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
			sizeX = 0.3793512,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7009373,
				sizeY = 0.7510809,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.4528368,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.796847,
					sizeY = 0.8902877,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zsx",
						posX = 0.5,
						posY = 0.8797901,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.459478,
						sizeY = 0.1107769,
						image = "chu1#top3",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mss",
						varName = "condition",
						posX = 0.5,
						posY = 0.09885994,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "积分达到多少多少可领取",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk1",
					posX = 0.5000001,
					posY = 0.3953824,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.64751,
					sizeY = 0.6215379,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.4874286,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9779048,
						sizeY = 0.9946513,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz9",
					varName = "rule",
					posX = 0.5,
					posY = 0.7841835,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6177265,
					sizeY = 0.1254289,
					text = "炼化说明",
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
