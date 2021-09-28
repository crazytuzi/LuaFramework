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
			sizeX = 0.7390625,
			sizeY = 0.1041667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbdt5",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9968287,
				sizeY = 0.9866664,
				image = "g#zbd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "lbtz9",
					varName = "desc_label",
					posX = 0.5007545,
					posY = 0.4955013,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9501122,
					sizeY = 0.6565779,
					text = "1111",
					color = "FF8FFFE3",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF1C4034",
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
