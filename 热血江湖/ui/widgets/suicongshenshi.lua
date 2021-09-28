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
			etype = "Image",
			name = "xiansuo",
			varName = "xiansuoRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2882813,
			sizeY = 0.8388889,
			scale9 = true,
			scale9Left = 0.3,
			scale9Right = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "kk2",
				posX = 0.5,
				posY = 0.4304385,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.504065,
				sizeY = 0.05960265,
				image = "chu1#top2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7186648,
					sizeY = 1.17649,
					text = "身世进度",
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
				etype = "Image",
				name = "qmd",
				posX = 0.5,
				posY = 0.2654272,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6449863,
				sizeY = 0.05298013,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "qmdt",
					varName = "friend_slider1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9411766,
					sizeY = 0.6250001,
					image = "tong#jdt2",
					scale9Left = 0.3,
					scale9Right = 0.3,
					percent = 60,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "zhh",
				varName = "call_btn",
				posX = 0.5,
				posY = 0.07299579,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4715446,
				sizeY = 0.1092715,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zhhz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9934938,
					sizeY = 1.20557,
					text = "探索身世",
					fontSize = 24,
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
				name = "smz",
				varName = "das",
				posX = 0.5,
				posY = 0.7074395,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7102119,
				sizeY = 0.3421526,
				text = "您需要探索宠物身世，之后开启喂养功能",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
