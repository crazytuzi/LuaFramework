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
			name = "xjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.09408806,
			sizeY = 0.1440567,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wpk3",
				varName = "itemBg",
				posX = 0.5,
				posY = 0.5674891,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7057883,
				sizeY = 0.8195077,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp5",
					varName = "itemIcon",
					posX = 0.4947425,
					posY = 0.5252965,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "itemBtn",
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
					etype = "Label",
					name = "mz12",
					varName = "itemCount",
					posX = 0.5,
					posY = -0.06898572,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.560193,
					sizeY = 0.3912227,
					text = "100",
					color = "FF966856",
					hTextAlign = 1,
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
