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
			name = "zy",
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "rw",
				varName = "leftRoot",
				posX = 0.3674594,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.15,
				sizeY = 0.08888889,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp",
					varName = "bgImgLeft",
					posX = 0.4999999,
					posY = 0.6875,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.372641,
					sizeY = 1.95928,
					image = "b#zyd",
					scale9 = true,
					scale9Left = 0.6,
					scale9Right = 0.35,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "tsz",
					varName = "leftText",
					posX = 0.5125577,
					posY = 0.5156255,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.138597,
					sizeY = 1.100434,
					text = "开始冒险",
					color = "FF8B7040",
					fontOutlineColor = "FF00152E",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "rw3",
				varName = "rightRoot",
				posX = 0.6341259,
				posY = 0.4986131,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.15,
				sizeY = 0.08888889,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp2",
					varName = "bgImgRight",
					posX = 0.5,
					posY = 0.7031026,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.372641,
					sizeY = 1.95928,
					image = "b#zyd",
					scale9 = true,
					scale9Left = 0.6,
					scale9Right = 0.35,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "tsz2",
					varName = "rightText",
					posX = 0.4793724,
					posY = 0.515625,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.12318,
					sizeY = 1.100434,
					text = "开始冒险",
					color = "FF8B7040",
					fontOutlineColor = "FF00152E",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "model",
				posX = 0.5,
				posY = 0.402777,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09798775,
				sizeY = 0.2040369,
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
