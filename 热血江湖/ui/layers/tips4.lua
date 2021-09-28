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
			name = "sss",
			varName = "tips_root",
			posX = 0.7126659,
			posY = 0.5708339,
			anchorX = 0.5,
			anchorY = 0,
			sizeX = 0.3125,
			sizeY = 0.1676621,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "tips_bg",
				posX = 0.5,
				posY = -0.1484881,
				anchorX = 0.5,
				anchorY = 0,
				sizeX = 1,
				sizeY = 1.148488,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.7957249,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8198454,
					sizeY = 0.2308106,
					image = "chu1#top2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "topz",
						varName = "title",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7065092,
						sizeY = 1.174276,
						text = "火系抗性[外门属性]",
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
				etype = "RichText",
				name = "z1",
				varName = "desc",
				posX = 0.5,
				posY = 0.6110653,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 0.9699315,
				sizeY = 0.688505,
				text = "造成伤害时，追加内力伤害，若自身内力大于对方内力，则内力伤害翻倍",
				color = "FF966856",
				fontOutlineColor = "FF1A3740",
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
