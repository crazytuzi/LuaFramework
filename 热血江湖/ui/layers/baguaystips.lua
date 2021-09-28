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
			scale9 = true,
			scale9Left = 0.1,
			scale9Right = 0.1,
			scale9Top = 0.1,
			scale9Bottom = 0.1,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "close_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
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
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "gb",
				posX = 0.4998818,
				posY = 0.6198444,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6101692,
				sizeY = 0.3090211,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.6187045,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.295923,
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
					name = "d9",
					posX = 0.5,
					posY = 0.4260221,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9149534,
					sizeY = 0.6849514,
					image = "b#d5",
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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.95,
						sizeY = 0.9499999,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "bzlb",
						varName = "desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.95,
						sizeY = 0.95,
						color = "FF966856",
						fontSize = 22,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top3",
					posX = 0.5,
					posY = 0.8702203,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4312314,
					sizeY = 0.1501892,
					image = "chu1#top3",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "taz3",
						varName = "title",
						posX = 0.5000002,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7293959,
						sizeY = 2.314495,
						text = "类型与专精",
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
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	dk = {
		ysjm = {
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
