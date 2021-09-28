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
			sizeX = 0.6648437,
			sizeY = 0.1470653,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ssd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.6988581,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "wt1",
					varName = "title",
					posX = 0.5,
					posY = 0.5055426,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.91903,
					sizeY = 1.417788,
					text = "1，调查内容：温泉打法风娃娃发噶发我刚发我发我付完费泉打法风娃娃发噶发我刚发我发我付完费\n",
					color = "FF43261D",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
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
