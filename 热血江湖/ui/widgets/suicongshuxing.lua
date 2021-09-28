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
			name = "shuxing",
			varName = "attributeRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2882813,
			sizeY = 0.8388889,
			scale9 = true,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "qmd2",
				varName = "bg",
				posX = 0.5,
				posY = 0.8543634,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6314362,
				sizeY = 0.04139073,
				image = "cl#jdtk",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "qmdt2",
					varName = "attFriend_slider",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9976744,
					sizeY = 1,
					image = "ty#jdd",
					scale9Left = 0.3,
					scale9Right = 0.3,
					percent = 60,
					imageHead = "ty#guang",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qmdz2",
					varName = "attFriend_value",
					posX = 0.5,
					posY = 0.54,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7862087,
					sizeY = 1.581225,
					text = "12/666",
					color = "FFC2F9E8",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qmz2",
					varName = "attFriend_title",
					posX = 0.4999999,
					posY = 0.5400008,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7862087,
					sizeY = 1.581225,
					text = "与芙蓉的亲密度：",
					color = "FF4AE3CE",
					fontSize = 26,
					fontOutlineEnable = true,
					fontOutlineColor = "FF071913",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qmms",
					varName = "lab",
					posX = 0.5000001,
					posY = 0.5400003,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7862087,
					sizeY = 1.581225,
					text = "亲密度可提升武功级别",
					color = "FF57A08F",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF082C2A",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "qmjh2",
					varName = "attFriend_btn",
					posX = 0.8675979,
					posY = 0.8493299,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1513825,
					sizeY = 0.0956262,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tsf2",
					varName = "bg2",
					posX = 0.141087,
					posY = 0.7734633,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09214091,
					sizeY = 0.05298013,
					image = "sui#tsf",
				},
			},
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb3",
				varName = "attribute_scroll",
				posX = 0.4992841,
				posY = 0.4942141,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.982372,
				sizeY = 0.940506,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cdd",
				posX = 0.5,
				posY = 0.980132,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9485093,
				sizeY = 0.003311258,
				image = "d2#fgx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cdd2",
				posX = 0.5,
				posY = 0.008278146,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9485093,
				sizeY = 0.003311258,
				image = "d2#fgx",
				flippedY = true,
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
