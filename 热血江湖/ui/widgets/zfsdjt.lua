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
			posX = 0.5023395,
			posY = 0.4993966,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.07487612,
			sizeY = 0.1468007,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "gradeIcon",
				posX = 0.5,
				posY = 0.5792567,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9583483,
				sizeY = 0.8689934,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djk",
					varName = "itemIcon",
					posX = 0.5026884,
					posY = 0.5212724,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8402775,
					sizeY = 0.8416974,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "itemCount",
					posX = 0.5000007,
					posY = -0.07266201,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.14402,
					sizeY = 0.7851637,
					text = "55555",
					color = "FF966856",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btns",
				varName = "itemBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
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
