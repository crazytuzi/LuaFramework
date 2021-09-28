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
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "closeBtn",
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
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3793512,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.4942205,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7009373,
				sizeY = 0.7510809,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.03,
					sizeY = 0.8519225,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk1",
					posX = 0.5,
					posY = 0.3353876,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9073173,
					sizeY = 0.3938464,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mz9",
						varName = "extra_text",
						posX = 0.5,
						posY = 0.8595651,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.69427,
						sizeY = 0.546695,
						text = "并额外必然获得",
						color = "FFC93034",
						fontSize = 22,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tyd",
						posX = 0.5,
						posY = 0.3732163,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.6839605,
						image = "d#tyd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz8",
					varName = "itemName_label",
					posX = 0.6400357,
					posY = 0.2802095,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5823583,
					sizeY = 0.2097309,
					text = "名字写六七个zi",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zbd2",
					varName = "item_bg",
					posX = 0.2144011,
					posY = 0.2755414,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2425924,
					sizeY = 0.2571491,
					image = "djk#kzi",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zbt2",
						varName = "item_icon",
						posX = 0.4894737,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8241493,
						sizeY = 0.8155648,
						image = "ls#ls_jinggangtoukui.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z3",
					varName = "itemDesc_label",
					posX = 0.5,
					posY = 0.7292053,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8684277,
					sizeY = 0.2645611,
					text = "wwadadsad",
					color = "FF966856",
					fontSize = 22,
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
