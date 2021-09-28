--version = 1
local l_fileType = "node"

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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1523438,
			sizeY = 0.1736111,
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
				sizeX = 0.9846151,
				sizeY = 0.96,
				image = "lxsy#kuang",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zp",
				varName = "icon",
				posX = 0.5,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9449126,
				sizeY = 0.896,
				image = "zhaopian1#zhaopian1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gx",
				posX = 0.8960654,
				posY = 0.1281673,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1538461,
				sizeY = 0.24,
				image = "chu1#gxd",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "gxan",
					varName = "markBtn",
					posX = 0.333486,
					posY = 0.6458241,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.464917,
					sizeY = 1.289724,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gxt",
					varName = "mark",
					posX = 0.5333333,
					posY = 0.5333333,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.266666,
					sizeY = 1.133333,
					image = "chu1#dj",
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
