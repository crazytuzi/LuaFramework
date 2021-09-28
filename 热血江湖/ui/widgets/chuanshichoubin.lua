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
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cjsl",
				varName = "img",
				posX = 0.5,
				posY = 0.4928946,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.018377,
				sizeY = 1.018377,
				image = "chuanshichoubin#chuanshichoubin",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sj1",
				varName = "title",
				posX = 0.3119684,
				posY = 0.09023789,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "活动期限：",
				color = "FF54F9FF",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sj2",
				varName = "ActivitiesTime",
				posX = 0.6536696,
				posY = 0.09023793,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9738973,
				sizeY = 0.1317907,
				text = "10",
				color = "FF54F9FF",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "model",
				posX = 0.7971754,
				posY = -0.01479613,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3412778,
				sizeY = 0.7769898,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pao",
				posX = 0.3776875,
				posY = 0.7338504,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5932059,
				sizeY = 0.3771456,
				image = "b#pao",
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
					name = "smz",
					varName = "content",
					posX = 0.4735292,
					posY = 0.49482,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8667266,
					sizeY = 0.8541009,
					text = "说明",
					color = "FF54F9FF",
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
