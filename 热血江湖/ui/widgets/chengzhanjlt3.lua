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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.065625,
			sizeY = 0.117512,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "icon",
					posX = 0.4985621,
					posY = 0.5211978,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.834821,
					sizeY = 0.8447802,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.1909601,
					posY = 0.2167703,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3333333,
					sizeY = 0.3309354,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "count",
					posX = 0.5698743,
					posY = 0.1789405,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7159726,
					sizeY = 0.7739957,
					text = "x40",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btns",
					varName = "Item",
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
