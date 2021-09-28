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
			sizeX = 0.22,
			sizeY = 0.1634502,
		},
		children = {
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
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z1",
				varName = "taskName",
				posX = 0.5088253,
				posY = 0.8436124,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9750316,
				sizeY = 0.3720074,
				text = "主线 名字",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z2",
				varName = "taskDesc",
				posX = 0.5088252,
				posY = 0.4874578,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9750315,
				sizeY = 0.5348861,
				text = "小描述一大推",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "task_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.98,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z3",
				varName = "taskDesc2",
				posX = 0.5088253,
				posY = 0.1469259,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9750317,
				sizeY = 0.3720074,
				text = "小描述一大推",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z4",
				varName = "chessValue",
				posX = 0.5088253,
				posY = 0.1469259,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9750317,
				sizeY = 0.3720074,
				text = "小描述一大推",
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
