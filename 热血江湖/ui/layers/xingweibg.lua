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
				posY = 0.4979201,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6820313,
				sizeY = 0.9625,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5560358,
					sizeY = 0.9055387,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
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
						etype = "Grid",
						name = "jie",
						varName = "partRoot",
						posX = 0.499332,
						posY = 0.7095071,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1751608,
						sizeY = 0.2206571,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kk3",
						varName = "items",
						posX = 0.4999988,
						posY = 0.3725043,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.475736,
						sizeY = 0.3342273,
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
							etype = "Image",
							name = "top3",
							posX = 0.5,
							posY = 0.9967328,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.4478501,
							sizeY = 0.1554273,
							image = "chu1#top2",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "taz3",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7293959,
								sizeY = 0.9861619,
								text = "消耗道具",
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
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.5000001,
							posY = 0.4633656,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9683297,
							sizeY = 0.8836171,
							horizontal = true,
							showScrollBar = false,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "plcs2",
						varName = "ok",
						posX = 0.5,
						posY = 0.147464,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1811934,
						sizeY = 0.08658009,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
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
				{
					prop = {
						etype = "Image",
						name = "top4",
						posX = 0.4977123,
						posY = 0.8924002,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3195876,
						sizeY = 0.07215007,
						image = "xingpan#zld",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "taz4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							text = "强制变更形状",
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
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.7340496,
					posY = 0.9096563,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0744559,
					sizeY = 0.09090909,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
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
