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
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7014508,
				sizeY = 0.7216647,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.5,
					posY = 0.4745416,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9373615,
					sizeY = 0.8310064,
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
						name = "lbt",
						varName = "item_scroll",
						posX = 0.5000001,
						posY = 0.450096,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9887609,
						sizeY = 0.876412,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ds",
						posX = 0.5,
						posY = 0.9453753,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.034866,
						sizeY = 0.1277979,
						image = "phb#top4",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tsz2",
							posX = 0.1527744,
							posY = 0.4999992,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2683739,
							sizeY = 1.350368,
							text = "拍卖物品",
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tsz3",
							posX = 0.418781,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2683739,
							sizeY = 1.350368,
							text = "成交时间",
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tsz4",
							posX = 0.6226864,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2683739,
							sizeY = 1.350368,
							text = "成交价格",
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tsz5",
							posX = 0.8587909,
							posY = 0.4999989,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2683739,
							sizeY = 1.350368,
							text = "购买玩家",
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9628378,
					posY = 0.9374736,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07239459,
					sizeY = 0.1212474,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.7490781,
					posY = 0.2790364,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.554654,
					sizeY = 0.5331038,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2940335,
					sizeY = 0.1000772,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5113635,
						sizeY = 0.4807695,
						image = "biaoti#pmjg",
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
