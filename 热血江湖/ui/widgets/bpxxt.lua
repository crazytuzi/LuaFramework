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
			sizeY = 0.1041667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbdt5",
				varName = "rootVar",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.968661,
				sizeY = 0.9066664,
				image = "h#ltd",
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
					posX = 0.5511051,
					posY = 0.4848746,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8494111,
					sizeY = 0.635324,
					text = "1111",
					color = "FF634624",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sj",
					varName = "time_label",
					posX = 0.07948142,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0959323,
					sizeY = 0.5143871,
					text = "11:30",
					color = "FF634624",
					fontSize = 22,
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
