--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.671875,
			sizeY = 0.1580882,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "rcht1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.88,
				scale9 = true,
				scale9Left = 0.1,
				scale9Right = 0.1,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wwcd",
					varName = "noFinish",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.13,
					image = "chongyangjie#dk",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ywcd",
					varName = "complete",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1,
					sizeY = 1.13,
					image = "chongyangjie#dk",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "icok",
					varName = "taskIcon",
					posX = 0.07569498,
					posY = 0.4734227,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.0943332,
					sizeY = 0.8184572,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ico",
						varName = "taskicon",
						posX = 0.4976835,
						posY = 0.5135133,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwmc",
					varName = "taskName",
					posX = 0.2996887,
					posY = 0.7247594,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2361973,
					sizeY = 0.6185881,
					text = "任务名称",
					color = "FF2F8E86",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwtj3",
					varName = "count1",
					posX = 0.049002,
					posY = 0.2155562,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1296221,
					sizeY = 0.9571317,
					text = "×30",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "qw",
					varName = "btn",
					posX = 0.8350163,
					posY = 0.4864227,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2923063,
					sizeY = 0.879311,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aas",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5728301,
						sizeY = 0.6358151,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						disableClick = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "az",
						varName = "goLabel",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.953678,
						sizeY = 0.8150085,
						text = "立即前往",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "tj",
					varName = "condition",
					posX = 0.4034929,
					posY = 0.2818501,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4438057,
					sizeY = 0.6374199,
					text = "任务描述",
					color = "FF995D3C",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fdz",
					varName = "notCanJump",
					posX = 0.8372239,
					posY = 0.5249466,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1769231,
					sizeY = 0.9057609,
					image = "huigui#ywc",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "tj2",
					varName = "des",
					posX = 0.5861213,
					posY = 0.7247595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2578176,
					sizeY = 0.6374199,
					text = "进度：0/1",
					color = "FF995D3C",
					vTextAlign = 1,
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
