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
				posX = 0.4691682,
				posY = 0.3853816,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2265625,
				sizeY = 0.4310533,
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
					posY = 0.8990473,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9689655,
					sizeY = 0.1031066,
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
						text = "皮肤加成",
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
					posY = 0.4419888,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.89752,
					sizeY = 0.7694957,
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
					posY = 0.4419888,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8777733,
					sizeY = 0.7694957,
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
