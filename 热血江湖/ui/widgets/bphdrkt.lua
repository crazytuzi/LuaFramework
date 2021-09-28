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
			posY = 0.5216348,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1801726,
			sizeY = 0.3982429,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "rk5",
				varName = "icon",
				posX = 0.4900147,
				posY = 0.4792552,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9799629,
				sizeY = 1.042775,
				image = "gnrk#bpfl",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an5",
					varName = "btn",
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
					name = "dian4",
					varName = "redPoint",
					posX = 0.8939725,
					posY = 0.7262067,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.119469,
					sizeY = 0.09364548,
					image = "zdte#hd",
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
