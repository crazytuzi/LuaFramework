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
			name = "jie2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2367187,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bt7",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "d#bt",
					alpha = 0.5,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jsfc22",
					varName = "propertyName",
					posX = 0.3888392,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3740263,
					sizeY = 1.375,
					text = "属性1：",
					color = "FF966856",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jsfc23",
					varName = "propertyValue",
					posX = 0.7058838,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3740263,
					sizeY = 1.375,
					text = "50",
					color = "FFF1E9D7",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jsfc24",
					varName = "max",
					posX = 0.9507958,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3740263,
					sizeY = 1.375,
					text = "MAX",
					color = "FFC93034",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zt",
					varName = "propIcon",
					posX = 0.1145121,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1650165,
					sizeY = 1.25,
					image = "zt#qixue",
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
