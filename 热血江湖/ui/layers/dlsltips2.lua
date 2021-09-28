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
				varName = "globel_bt",
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
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.796847,
					sizeY = 1.183653,
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
						posY = 0.9180486,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.459478,
						sizeY = 0.08332112,
						image = "chu1#top3",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mz9",
							varName = "itemGrade_lable",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7423119,
							sizeY = 1.690796,
							text = "必得奖励",
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
						etype = "Label",
						name = "mss",
						varName = "condition",
						posX = 0.5,
						posY = 0.05719937,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "随机奖励只能获得其中的一种",
						color = "FFC93034",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsx2",
						posX = 0.5,
						posY = 0.4780078,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.459478,
						sizeY = 0.08332112,
						image = "chu1#top3",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mz10",
							varName = "itemGrade_lable2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7423119,
							sizeY = 1.690796,
							text = "随机奖励",
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
			{
				prop = {
					etype = "Image",
					name = "dk1",
					posX = 0.5,
					posY = 0.7350416,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.64751,
					sizeY = 0.3892349,
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
						varName = "listView",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9779047,
						sizeY = 0.9695086,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk2",
					posX = 0.5,
					posY = 0.2172662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.64751,
					sizeY = 0.3892349,
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
						name = "lb2",
						varName = "listView2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9779047,
						sizeY = 0.9695086,
						horizontal = true,
						showScrollBar = false,
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
