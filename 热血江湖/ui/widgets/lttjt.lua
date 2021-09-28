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
			sizeX = 0.1068539,
			sizeY = 0.2606366,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bqt",
				varName = "image",
				posX = 0.5438684,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8467168,
				sizeY = 0.9597228,
				image = "tujian#zhongli",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "a",
					varName = "btn",
					posX = 0.448237,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.120796,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tjk",
					varName = "back",
					posX = 0.44819,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.172411,
					sizeY = 1.032103,
					image = "tujian3#zi4",
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
