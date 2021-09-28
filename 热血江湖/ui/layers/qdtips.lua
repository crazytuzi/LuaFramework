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
			etype = "Grid",
			name = "k",
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
				sizeX = 0.3125,
				sizeY = 0.2777778,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.9,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "title",
					posX = 0.4353957,
					posY = 0.8036581,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4896204,
					sizeY = 0.2205351,
					text = "道具名字",
					color = "FFFFCB40",
					fontSize = 22,
					fontOutlineEnable = true,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z4",
					posX = 0.5,
					posY = 0.1302802,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7858613,
					sizeY = 0.1695843,
					text = "本月第几次签到获得此奖励",
					color = "FFB0FFD9",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "adwa",
					posX = 0.7601464,
					posY = 0.8036581,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.366073,
					sizeY = 0.2205351,
					text = "拥有数量",
					color = "FFFFCB40",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.1031573,
					posY = 0.7895242,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1484375,
					sizeY = 0.3,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj",
						posX = 0.5,
						posY = 0.5333334,
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
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.4264871,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9843016,
					sizeY = 0.325,
					image = "d#tyd",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "js",
						varName = "daw",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9134995,
						sizeY = 0.901613,
						text = "道具介绍写在这里",
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
