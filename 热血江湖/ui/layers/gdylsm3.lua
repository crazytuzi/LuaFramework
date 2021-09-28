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
			posX = 0.4994668,
			posY = 0.4998969,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "mask",
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
			sizeX = 0.9967992,
			sizeY = 0.9858795,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6230881,
				sizeY = 0.690303,
				image = "guidaoyuling2#sm",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "leftBtn",
					posX = 0.1657888,
					posY = 0.5061223,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0591195,
					sizeY = 0.122449,
					image = "guidaoyuling2#jt",
					imageNormal = "guidaoyuling2#jt",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "rightBtn",
					posX = 0.8384596,
					posY = 0.5061223,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0591195,
					sizeY = 0.122449,
					image = "guidaoyuling2#jt",
					imageNormal = "guidaoyuling2#jt",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.8835557,
					posY = 0.8300597,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06666666,
					sizeY = 0.3142857,
					image = "guidaoyuling2#gb",
					imageNormal = "guidaoyuling2#gb",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu",
					varName = "icon",
					posX = 0.5,
					posY = 0.561224,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5861635,
					sizeY = 0.6816326,
					image = "guidaoyuling2#zhandou",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wb",
					varName = "desc",
					posX = 0.5,
					posY = 0.1583662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1127745,
					text = "说明",
					color = "FF400000",
					fontSize = 22,
					fontOutlineSize = 5,
					fontUnderlineEnable = true,
					hTextAlign = 1,
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
