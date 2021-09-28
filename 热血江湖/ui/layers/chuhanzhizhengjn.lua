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
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.69375,
				sizeY = 0.8333333,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw",
					posX = 0.5,
					posY = 0.847788,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9938613,
					sizeY = 0.2899327,
					image = "rcb#dw",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d9",
					posX = 0.5,
					posY = 0.3269506,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9149534,
					sizeY = 0.5823772,
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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9869599,
						sizeY = 0.9678738,
						horizontal = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d10",
					posX = 0.5,
					posY = 0.8003114,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9149534,
					sizeY = 0.1912857,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "ms",
						varName = "restraintDesc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9979846,
						sizeY = 0.9539854,
						color = "FF622C23",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top2",
				posX = 0.2644504,
				posY = 0.8663443,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2125,
				sizeY = 0.05555556,
				image = "sblz#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "toza2",
					posX = 0.3862254,
					posY = 0.55,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6517324,
					sizeY = 1.604067,
					text = "兵种克制",
					color = "FFFFE0B6",
					fontSize = 24,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top3",
				posX = 0.2644504,
				posY = 0.6361245,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2125,
				sizeY = 0.05555556,
				image = "sblz#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "toza3",
					posX = 0.3862254,
					posY = 0.55,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6517324,
					sizeY = 1.604067,
					text = "兵种介绍",
					color = "FFFFE0B6",
					fontSize = 24,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.8216165,
				posY = 0.873659,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
