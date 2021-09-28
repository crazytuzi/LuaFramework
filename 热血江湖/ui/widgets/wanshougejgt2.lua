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
			sizeX = 0.3632813,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xian",
				varName = "bottom",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.015054,
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
				varName = "rankTxt",
				posX = 0.1543352,
				posY = 0.5000007,
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
				posX = 0.7285872,
				posY = 0.5000005,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7826072,
				sizeY = 1.854458,
				text = "玩家名称",
				color = "FFA15031",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pm12",
				varName = "score",
				posX = 0.8656518,
				posY = 0.5000005,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.346572,
				sizeY = 1.854458,
				text = "1000积分",
				color = "FFA15031",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pm",
				varName = "rankImg",
				posX = 0.1543352,
				posY = 0.5221639,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2149127,
				sizeY = 1.066667,
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
