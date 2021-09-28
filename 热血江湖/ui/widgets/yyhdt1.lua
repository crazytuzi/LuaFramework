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
				etype = "Grid",
				name = "hyxxwx2",
				varName = "rootWidget",
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
					name = "db3",
					posX = 0.5,
					posY = 0.4921793,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7421875,
					sizeY = 0.7722222,
					image = "b#db3",
					scale9 = true,
					scale9Left = 0.47,
					scale9Right = 0.47,
					alpha = 0.2,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian2",
					posX = 0.3132794,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03125,
					sizeY = 0.6944444,
					image = "hyxx#tiao",
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
