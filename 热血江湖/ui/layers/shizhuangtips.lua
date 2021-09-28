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
			posX = 0.5,
			posY = 0.5708339,
			anchorX = 0.5,
			anchorY = 0,
			sizeX = 0.3125,
			sizeY = 0.1676621,
			layoutType = 5,
			layoutTypeW = 5,
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
					varName = "title",
					posX = 0.5,
					posY = 0.7957249,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.2524493,
					image = "bgchu#chuanshuo",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw",
					posX = 0.5,
					posY = 0.3768651,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.901262,
					sizeY = 0.5395266,
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
						etype = "RichText",
						name = "z1",
						varName = "desc",
						posX = 0.5062964,
						posY = 0.4470981,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9874072,
						sizeY = 0.8941963,
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
