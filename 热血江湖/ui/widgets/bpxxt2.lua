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
			sizeX = 0.8226563,
			sizeY = 0.07924275,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpxxt2",
				varName = "rootVar",
				posX = 0.1473286,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2640076,
				sizeY = 0.5608645,
				image = "cl2#dw2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sj",
					varName = "time_label",
					posX = 0.4759056,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7815316,
					sizeY = 1.287002,
					text = "2015-07-31",
					color = "FF634624",
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
