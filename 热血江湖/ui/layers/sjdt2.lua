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
				name = "dt2",
				posX = 0.5,
				posY = 0.4743039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8439232,
				sizeY = 0.8611111,
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
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
					sizeX = 0.9997948,
					sizeY = 0.951942,
					scale9 = true,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dw1",
						posX = 0.5,
						posY = 0,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.06486825,
						image = "d2#jzd2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dw2",
						posX = 0.5,
						posY = 0.9942763,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.06486825,
						image = "d2#jzd2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						flippedY = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "das",
						posX = 0.5,
						posY = 0.480921,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.01,
						sizeY = 1.013089,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jzz3",
						posX = 0.9988484,
						posY = 0.5019051,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06666667,
						sizeY = 1.156191,
						image = "jz#jz1",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jzz2",
						posX = 0.002463773,
						posY = 0.5019051,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06666667,
						sizeY = 1.156191,
						image = "jz#jz1",
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "scroll",
					posX = 0.5009257,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9451764,
					sizeY = 0.8967742,
					horizontal = true,
					showScrollBar = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb2",
				varName = "closeBtn",
				posX = 0.932061,
				posY = 0.8115689,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0484375,
				sizeY = 0.2222222,
				image = "jz#gb2",
				imageNormal = "jz#gb2",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8987937,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2351563,
				sizeY = 0.07222223,
				image = "jz#top3",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4418603,
					sizeY = 0.4807692,
					image = "biaoti#sjdt",
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
