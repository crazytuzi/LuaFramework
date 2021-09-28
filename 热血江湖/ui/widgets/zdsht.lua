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
			name = "d",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2,
			sizeY = 0.1594872,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "task_btn",
				posX = 0.4910083,
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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#rwd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z1",
				varName = "taskName",
				posX = 0.5081154,
				posY = 0.7799219,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9821232,
				sizeY = 0.4208046,
				text = "保证NPC存活",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z2",
				varName = "taskDesc",
				posX = 0.5081154,
				posY = 0.5022593,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9821232,
				sizeY = 0.4208046,
				text = "当前波数：",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z3",
				varName = "tas",
				posX = 0.5081151,
				posY = 0.2245965,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9821232,
				sizeY = 0.4208046,
				text = "我的积分：",
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
	c_dakai = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
