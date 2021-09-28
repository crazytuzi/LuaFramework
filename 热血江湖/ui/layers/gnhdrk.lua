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
				sizeX = 2.544207,
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
					posX = 0.5065908,
					posY = 0.4950155,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7631323,
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
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9315468,
					posY = 0.9372505,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08815327,
					sizeY = 0.216285,
					image = "gnrk#gb",
					imageNormal = "gnrk#gb",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5074069,
					posY = 0.5396362,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7463343,
					sizeY = 0.7296054,
					horizontal = true,
					showScrollBar = false,
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
