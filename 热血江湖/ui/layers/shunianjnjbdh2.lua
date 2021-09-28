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
			scale9Left = 0.4,
			scale9Right = 0.4,
			scale9Top = 0.4,
			scale9Bottom = 0.4,
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
				name = "db",
				posX = 0.5,
				posY = 0.4923596,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.853125,
				sizeY = 0.8194444,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6346154,
					sizeY = 0.640678,
					image = "shunianjnjb#duihuandiban",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bt",
						posX = 0.5,
						posY = 0.9199434,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1428571,
						sizeY = 0.08730159,
						image = "shunianjnjb#duihuanliebiaomeizhuzi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "scroll",
					posX = 0.499542,
					posY = 0.5076309,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5256922,
					sizeY = 0.4636436,
					effect = "scroll",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.734679,
				posY = 0.6257689,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0484375,
				sizeY = 0.2222222,
				image = "shunianjnjb#guanbi",
				imageNormal = "shunianjnjb#guanbi",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
