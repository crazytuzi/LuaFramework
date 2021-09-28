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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.86875,
			sizeY = 0.08333334,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpxxt2",
				posX = 0.1507546,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2059353,
				sizeY = 0.6166666,
				image = "w#w_mojidi.png",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sj",
					varName = "time_label",
					posX = 0.4615172,
					posY = 0.5274744,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7815317,
					sizeY = 0.959078,
					text = "2015-07-31",
					color = "FFB8E1D9",
					fontSize = 24,
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
