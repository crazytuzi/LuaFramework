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
			sizeX = 0.3445933,
			sizeY = 0.05277778,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "xzj6",
				varName = "name",
				posX = 0.6098258,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6000001,
				sizeY = 2.098543,
				text = "攻击：",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xzj7",
				varName = "value",
				posX = 0.7617622,
				posY = 0.4473684,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4457656,
				sizeY = 2.098543,
				text = "3000",
				color = "FFF1E9D7",
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
