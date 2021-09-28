--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "Bonuspanel",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
		soundEffectOpen = "audio/rxjh/UI/ui_lose.ogg",
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
				varName = "exitBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
				name = "mo",
				posX = 0.5,
				posY = 0.6566878,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2585937,
				sizeY = 0.3013889,
				image = "dati2#mo",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7800574,
				sizeY = 0.3027778,
				image = "d#diban",
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.05248,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2263455,
					sizeY = 0.2981651,
					image = "dati2#sb",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tcsj",
					varName = "tips",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7081413,
					sizeY = 0.6236749,
					text = "答题失败了少年，书山有路勤为径",
					color = "FFD0C4A7",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "okBtn",
					posX = 0.5,
					posY = -0.2729657,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1231881,
					sizeY = 0.266055,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "btnz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.258485,
						sizeY = 1.121219,
						text = "确 定",
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
