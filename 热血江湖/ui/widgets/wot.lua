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
			etype = "Button",
			name = "dj1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1257813,
			sizeY = 0.3513889,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "bg2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.94578,
				image = "hy#db1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "bg1",
				posX = 0.4999998,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.94578,
				image = "hy#db1",
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xzt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9063249,
					sizeY = 0.8943409,
					image = "hy#xzt",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "grade_icon",
				posX = 0.5,
				posY = 0.334168,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9130432,
				sizeY = 0.4664031,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "item_icon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
					image = "jstx2#gongnan",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "s1",
				varName = "item_count",
				posX = 0.5,
				posY = 0.8256651,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.3041658,
				text = "条件",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
				colorTL = "FFFCFFB3",
				colorTR = "FFFCFFB3",
				colorBR = "FFFFCF4D",
				colorBL = "FFFFCF4D",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.5,
				posY = 0.6920949,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.01185771,
				image = "b#xian",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hd",
				varName = "red",
				posX = 0.8968637,
				posY = 0.9182863,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1677018,
				sizeY = 0.1106719,
				image = "zdte#hd",
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
