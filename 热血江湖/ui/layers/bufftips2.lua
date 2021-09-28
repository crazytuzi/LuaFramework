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
				posX = 0.3695607,
				posY = 0.6818631,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2218803,
				sizeY = 0.2583461,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hw",
					posX = 0.5,
					posY = 0.8837118,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.2323792,
					image = "ty#hw",
					alpha = 0.5,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "name",
					posX = 0.5,
					posY = 0.8879207,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7807794,
					sizeY = 0.3013824,
					text = "buff名字",
					color = "FFFFE792",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "fwb",
					varName = "desc",
					posX = 0.5140841,
					posY = 0.3900609,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.950793,
					sizeY = 0.7334491,
					text = "buff描述",
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
