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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2640625,
			sizeY = 0.6291667,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "gz",
				varName = "enterBtn",
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
				etype = "Image",
				name = "dw",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.002959,
				sizeY = 0.9999999,
				image = "qds#gzd",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb1",
					varName = "leaderName1",
					posX = 0.5,
					posY = 0.7188293,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8780514,
					sizeY = 0.1687337,
					text = "名字六七个字队伍",
					color = "FFFFE5C4",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF281B1A",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "leaderName2",
					posX = 0.5,
					posY = 0.2662862,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8780514,
					sizeY = 0.1687337,
					text = "名字六七个字队伍",
					color = "FFFFE5C4",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF281B1A",
					fontOutlineSize = 2,
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
