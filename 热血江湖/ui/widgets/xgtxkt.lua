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
			varName = "frame_btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1171875,
			sizeY = 0.2708333,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.036182,
				sizeY = 1,
				image = "hy#db1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "hy#db1",
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xzt",
					varName = "select_bg",
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
				varName = "frame_icon",
				posX = 0.5,
				posY = 0.4316038,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.6051282,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "head_icon",
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
				varName = "condition",
				posX = 0.5,
				posY = 0.8847973,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.2166706,
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
				posY = 0.7946589,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.01185771,
				image = "b#xian",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "s2",
				varName = "effect_time",
				posX = 0.5,
				posY = 0.1128206,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.2166706,
				text = "时效：",
				color = "FFC93034",
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
				colorTL = "FFFCFFB3",
				colorTR = "FFFCFFB3",
				colorBR = "FFFFCF4D",
				colorBL = "FFFFCF4D",
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
