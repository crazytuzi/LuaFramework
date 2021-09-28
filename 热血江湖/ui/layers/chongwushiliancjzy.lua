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
				sizeX = 0.5743697,
				sizeY = 0.5523341,
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
					posY = 0.5033069,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 1.02,
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
						name = "d5",
						posX = 0.5000001,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8923045,
						sizeY = 0.7155942,
						image = "b#d5",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.7025239,
						posY = 0.3565551,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6640911,
						sizeY = 0.6828814,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 1.014267,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3590893,
						sizeY = 0.1307582,
						image = "chu1#top",
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tt",
							posX = 0.5,
							posY = 0.5174515,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.4976233,
							sizeY = 0.4713425,
							image = "biaoti#caijizhiyin",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5009434,
					posY = 0.503801,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8874467,
					sizeY = 0.7004956,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					posX = 0.4945654,
					posY = 0.07543022,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7725673,
					sizeY = 0.25,
					text = "点击查看采集物资讯，并可进行寻路\n采集物级别越高，所需技能等级越高，收益也越高",
					color = "FF966856",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "cjz",
					varName = "des",
					posX = 0.5,
					posY = 0.9117017,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "本次活动最多采集矿物",
					color = "FF966856",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz2",
					varName = "count",
					posX = 0.5,
					posY = 0.9114346,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7725673,
					sizeY = 0.25,
					text = "采集次数",
					color = "FF65944D",
					hTextAlign = 1,
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
				posX = 0.7698274,
				posY = 0.7439533,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
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
