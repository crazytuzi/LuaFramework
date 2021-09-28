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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.190625,
			sizeY = 0.1138889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "group",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.024564,
				image = "b#ftd1",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "name",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6821761,
					sizeY = 0.558035,
					text = "分堂一",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF00152E",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suozai",
					varName = "inGroupMark",
					posX = 0.1726757,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.147541,
					sizeY = 0.5237206,
					image = "bp#cy",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t2",
				varName = "create",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.012195,
				image = "b#ftd3",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mz2",
					varName = "name2",
					posX = 0.54918,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6821761,
					sizeY = 0.558035,
					text = "创建分堂",
					color = "FFB96146",
					fontSize = 24,
					fontOutlineColor = "FF00152E",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jia",
					posX = 0.1726699,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1188525,
					sizeY = 0.3493976,
					image = "bp#jia",
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
