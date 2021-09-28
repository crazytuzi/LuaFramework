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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.659375,
			sizeY = 0.1165446,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
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
				name = "dib2",
				varName = "tShow",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "jh5#db2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				effect = "tHide",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sjd",
				varName = "time",
				posX = 0.1769445,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.320563,
				sizeY = 0.8679304,
				text = "时间段",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz1",
				varName = "mName",
				posX = 0.6563526,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2353658,
				sizeY = 1.06265,
				text = "名字已七个字",
				color = "FF966856",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "gName",
				posX = 0.9421566,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2353658,
				sizeY = 1.06265,
				text = "名字已七个字",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txa",
				posX = 0.7980874,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0326624,
				sizeY = 0.2920206,
				image = "rw#tx",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sjd2",
				varName = "line",
				posX = 0.4745665,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.320563,
				sizeY = 0.8679304,
				text = "几线",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
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
