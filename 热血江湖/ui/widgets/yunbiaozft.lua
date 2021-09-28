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
			sizeX = 0.3845237,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xian",
				varName = "bottom",
				posX = 0.4978506,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.052031,
				sizeY = 0.9777778,
				image = "gzcj#1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pm10",
				varName = "rankLabel",
				posX = 0.09030142,
				posY = 0.5000014,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6904109,
				sizeY = 1.854458,
				text = "第一名",
				color = "FFA15031",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pm11",
				varName = "name",
				posX = 0.3334025,
				posY = 0.5443844,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7826072,
				sizeY = 1.854458,
				text = "玩家名称",
				color = "FFA15031",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pm12",
				varName = "postion",
				posX = 0.6140292,
				posY = 0.5000024,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.346572,
				sizeY = 1.854458,
				text = "副帮主",
				color = "FFA15031",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pm13",
				varName = "times",
				posX = 0.8877562,
				posY = 0.5000009,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.346572,
				sizeY = 1.854458,
				text = "17",
				color = "FFA15031",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pm",
				varName = "rankImg",
				posX = 0.09305274,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1942628,
				sizeY = 1.020555,
				image = "cl3#1st",
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
