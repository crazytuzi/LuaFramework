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
			name = "aaa",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "sss",
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
			sizeX = 0.3727202,
			sizeY = 0.2842541,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.662765,
				sizeY = 1.92023,
				image = "gnrk#jz",
				scale9 = true,
				scale9Left = 0.5,
				scale9Right = 0.48,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ddd",
					posX = 0.5106632,
					posY = 0.4950155,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7185012,
					sizeY = 0.6911694,
					image = "gnrk#db",
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
					name = "rk",
					varName = "icon1",
					posX = 0.3453893,
					posY = 0.5245008,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2848949,
					sizeY = 0.7608144,
					image = "gnrk#zqxl",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "practice_btn",
						posX = 0.4984595,
						posY = 0.469496,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.013612,
						sizeY = 0.7846621,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "wkf2",
						varName = "not_open2",
						posX = 0.5,
						posY = 0.4498325,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.4424779,
						sizeY = 0.3511705,
						image = "gnrk#wkf",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "rk2",
					varName = "icon2",
					posX = 0.6663685,
					posY = 0.5245008,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2848949,
					sizeY = 0.7608144,
					image = "gnrk#zqsx",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "star_btn",
						posX = 0.4873442,
						posY = 0.469496,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.013612,
						sizeY = 0.7846621,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "wkf",
						varName = "not_open1",
						posX = 0.5,
						posY = 0.4498325,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.4424779,
						sizeY = 0.3511705,
						image = "gnrk#wkf",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9315468,
					posY = 0.9372505,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1348839,
					sizeY = 0.216285,
					image = "gnrk#gb",
					imageNormal = "gnrk#gb",
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
