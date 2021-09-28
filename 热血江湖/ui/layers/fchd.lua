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
				posY = 0.500693,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.7279713,
				image = "b#jzd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9770473,
					sizeY = 0.8940562,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "g1",
						posX = 0.1678636,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2974681,
						sizeY = 0.9427781,
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
							name = "lb1",
							varName = "scroll",
							posX = 0.5159985,
							posY = 0.4977398,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.008402,
							sizeY = 0.9784862,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "ls",
						varName = "rightWidget",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.290709,
						sizeY = 1.536459,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					posX = 0.5,
					posY = -0.03321243,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1697642,
					text = "同一帐号只能完成一次",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsx",
					posX = 0.68,
					posY = -0.03523868,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1123153,
					sizeY = 0.01717101,
					image = "tong#zsx2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsx2",
					posX = 0.32,
					posY = -0.03523868,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1123153,
					sizeY = 0.01717101,
					image = "tong#zsx2",
					flippedX = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8874236,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.38125,
				sizeY = 0.1083333,
				image = "jz#top3",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2602459,
					sizeY = 0.371795,
					image = "jz#fchd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jzz",
				posX = 0.08906271,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.8291667,
				image = "jz#jz1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jzz2",
				posX = 0.881509,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09296875,
				sizeY = 0.8291667,
				image = "jz#jz2",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.904012,
				posY = 0.8406967,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04453125,
				sizeY = 0.1069444,
				image = "ty#gb2",
				imageNormal = "ty#gb2",
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
