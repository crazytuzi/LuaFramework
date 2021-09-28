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
				varName = "globel_bt",
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
			sizeX = 0.3793512,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.3621211,
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
					sizeX = 0.8935674,
					sizeY = 0.9011523,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dw2",
						posX = 0.5,
						posY = 0.7477369,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8746617,
						sizeY = 0.3691381,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zbd2",
					varName = "item_bg",
					posX = 0.727775,
					posY = 0.7156088,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2791214,
					sizeY = 0.2958699,
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
					posX = 0.5030212,
					posY = 0.3215101,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7393639,
					sizeY = 0.3969202,
					text = "wwadadsad",
					color = "FF966856",
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
