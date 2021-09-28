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
				posY = 0.500693,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.7279713,
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
					sizeX = 0.07093596,
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
					sizeX = 0.07093596,
					sizeY = 1.156191,
					image = "jz#jz1",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					varName = "rootView",
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
						varName = "g1",
						posX = 0.1678636,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2974681,
						sizeY = 0.9427781,
						image = "b#d2",
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
							name = "lb1",
							varName = "ActivitiesList",
							posX = 0.4960493,
							posY = 0.4977398,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9685037,
							sizeY = 0.9784861,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "ls",
						varName = "RightView",
						posX = 0.6565312,
						posY = 0.5021309,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6694875,
						sizeY = 0.957207,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8790902,
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
					name = "tz",
					posX = 0.5,
					posY = 0.4911858,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4485049,
					sizeY = 0.4807692,
					image = "biaoti#fuli",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.9079092,
				posY = 0.7908329,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0484375,
				sizeY = 0.2222222,
				image = "jz#gb2",
				imageNormal = "jz#gb2",
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
