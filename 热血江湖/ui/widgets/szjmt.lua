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
			posX = 0.4992188,
			posY = 0.5777524,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6926122,
			sizeY = 0.0944953,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8,
				image = "d#bt",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "nr1",
				varName = "name",
				posX = 0.1100656,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2210257,
				sizeY = 0.8078567,
				text = "活动名称",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "nr2",
				varName = "days",
				posX = 0.3544355,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.281994,
				sizeY = 0.8078567,
				text = "每天",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "nr3",
				varName = "time",
				posX = 0.6326427,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3304028,
				sizeY = 0.8078567,
				text = "时间",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dja",
				varName = "onBtn",
				posX = 0.8770233,
				posY = 0.4665807,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1127976,
				sizeY = 0.6173147,
				image = "chu1#zt1",
				imageNormal = "chu1#zt1",
				imagePressed = "chu1#zt2",
				imageDisable = "chu1#zt1",
				disablePressScale = true,
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
