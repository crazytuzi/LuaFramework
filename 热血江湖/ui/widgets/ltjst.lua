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
			name = "ltjst",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.2129301,
			sizeY = 0.1198681,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "txk",
				varName = "txb_img",
				posX = 0.1900805,
				posY = 0.4652396,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3656605,
				sizeY = 0.9269448,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "icon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "name",
				varName = "name",
				posX = 0.7232779,
				posY = 0.6505532,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7402174,
				sizeY = 0.5324616,
				text = "公认热血醉人",
				color = "FF634624",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "id",
				varName = "id",
				posX = 0.6759843,
				posY = 0.2577029,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.64563,
				sizeY = 0.4063189,
				text = "id：1234",
				color = "FF911D02",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
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
