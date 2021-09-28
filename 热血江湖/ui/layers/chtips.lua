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
				name = "dt",
				varName = "bgRoot",
				posX = 0.704722,
				posY = 0.558986,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2265625,
				sizeY = 0.5555556,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.5033137,
					posY = 0.9151578,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9689655,
					sizeY = 0.07999999,
					image = "chu1#top3",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6836313,
						sizeY = 1.259089,
						text = "称号属性",
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
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5000001,
					posY = 0.5061179,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8975199,
					sizeY = 0.703797,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.5068305,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8777733,
					sizeY = 0.6802639,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "chgz",
					varName = "desText",
					posX = 0.4972411,
					posY = 0.09311561,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8836063,
					sizeY = 0.25,
					text = "同一个类型的称号，只有战力最高的称号属性才会生效。",
					color = "FFC93034",
					fontSize = 18,
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
