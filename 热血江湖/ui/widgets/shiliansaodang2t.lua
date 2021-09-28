--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6859821,
			sizeY = 0.09722222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "di",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#ff1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "mc1",
				varName = "name",
				posX = 0.2937183,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5126203,
				sizeY = 0.8381116,
				text = "试炼名称【难度1】",
				color = "FF7F4920",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk2",
				posX = 0.6238487,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2562476,
				sizeY = 0.6857144,
				image = "zqqz2#dk",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "sweepCount",
					posX = 0.4144011,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7660341,
					sizeY = 1.145833,
					text = "全部扫荡",
					color = "FF7F4920",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xzan2",
					posX = 0.8965912,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2068177,
					sizeY = 1,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "djbza2",
						varName = "selectTimesBtn",
						posX = 0.4946082,
						posY = 0.4791965,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						image = "zqqz2#jt",
						imageNormal = "zqqz2#jt",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gxd2",
				posX = 0.8126267,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03416634,
				sizeY = 0.4285715,
				image = "chu1#gxd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj2",
					varName = "flag",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.266667,
					sizeY = 1.133333,
					image = "chu1#dj",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gxan2",
					varName = "extra_btn",
					posX = 2.097115,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 4.526355,
					sizeY = 1.555168,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gxz2",
					posX = 4.409981,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 6.023885,
					sizeY = 1.788127,
					text = "额外翻牌",
					color = "FFBB7C4E",
					fontSize = 22,
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
