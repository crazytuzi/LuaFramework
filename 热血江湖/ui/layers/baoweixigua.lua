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
			alpha = 0.4,
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
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jjd",
			varName = "parent",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "posRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "jd",
					varName = "bgContent",
					posX = 0.5,
					posY = 0.4369546,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.8633093,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bt",
					posX = 0.5,
					posY = 0.8369265,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2875,
					sizeY = 0.1958333,
					image = "bwxg#top",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djs2",
					posX = 0.75,
					posY = 0.823069,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1796875,
					sizeY = 0.05555556,
					image = "bwxg#di",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs2",
						varName = "timesLabel",
						posX = 0.5,
						posY = 0.45,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.455338,
						sizeY = 1.722176,
						text = "倒计时：00:00:00",
						color = "FFFF0539",
						fontOutlineEnable = true,
						fontOutlineColor = "FF66EDFF",
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
					name = "djs1",
					posX = 0.25,
					posY = 0.823069,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1587826,
					sizeY = 0.05555556,
					image = "bwxg#di",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs1",
						varName = "remaintimes",
						posX = 0.5,
						posY = 0.45,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9018632,
						sizeY = 1.722176,
						text = "剩余次数：3次",
						color = "FF2A48CA",
						fontOutlineEnable = true,
						fontOutlineColor = "FF66EDFF",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx1",
					varName = "model",
					posX = 0.07218545,
					posY = 0.3269385,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05381681,
					sizeY = 0.1307216,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "npcScroll",
					posX = 0.1659274,
					posY = 0.5201405,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.331197,
					sizeY = 1.031388,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.9424418,
					posY = 0.905828,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0578125,
					sizeY = 0.1013889,
					image = "bwxg#gb",
					imageNormal = "bwxg#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "pos1",
				varName = "pos1",
				posX = 0.07647568,
				posY = 0.5596146,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07175691,
				sizeY = 0.1192292,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "pos2",
				varName = "pos2",
				posX = 0.07539062,
				posY = 0.3367706,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07109375,
				sizeY = 0.1179856,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "pos3",
				varName = "pos3",
				posX = 0.07539063,
				posY = 0.1423261,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07109375,
				sizeY = 0.1179856,
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
