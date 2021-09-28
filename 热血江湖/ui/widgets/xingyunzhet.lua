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
			sizeX = 0.4242187,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "yx",
				posX = 0.5,
				posY = 0,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.95,
				sizeY = 0.05,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "wb1",
				varName = "des",
				posX = 0.520174,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9596519,
				sizeY = 1,
				text = "玩家xxx使用了x个加油卡为小红旗加油，大家距离奖励又近了",
				color = "FF966856",
				fontSize = 18,
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
