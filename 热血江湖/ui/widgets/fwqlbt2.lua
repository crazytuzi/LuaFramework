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
			name = "zdj3",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3726563,
			sizeY = 0.1469795,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "f3",
				posX = 0.5,
				posY = 0.4811011,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9798384,
				sizeY = 0.9449542,
				image = "fwq#dw",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn3",
					varName = "selectBtn",
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
					name = "ztt3",
					varName = "state",
					posX = 0.1026919,
					posY = 0.51,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08130379,
					sizeY = 0.39,
					image = "fwq#baoman",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jnm14",
					varName = "serverName",
					posX = 0.5161428,
					posY = 0.56,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5274109,
					sizeY = 1,
					text = "01服",
					color = "FF745226",
					fontSize = 26,
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tjm3",
					varName = "tag",
					posX = 0.965661,
					posY = 0.6197748,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05990805,
					sizeY = 0.7,
					image = "fwq#dq",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xft",
					varName = "isNewServer",
					posX = 0.738701,
					posY = 0.5325536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1989803,
					sizeY = 0.38,
					image = "fwq#xin",
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
