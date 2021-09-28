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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4079237,
			sizeY = 0.1261828,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "select_btn",
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
				name = "pt",
				varName = "normalBg",
				posX = 0.5,
				posY = 0.4881843,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9445186,
				sizeY = 0.9842492,
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zdfx",
				varName = "fightBg",
				posX = 0.5,
				posY = 0.4999958,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9445186,
				sizeY = 0.9842492,
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dq",
				varName = "showselect",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9445186,
				sizeY = 0.9842492,
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "lineName",
				posX = 0.407087,
				posY = 0.5263222,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3476331,
				sizeY = 0.9736063,
				text = "乱斗分线一",
				color = "FF008000",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb2",
				varName = "lineDesc",
				posX = 0.9634027,
				posY = 0.5263225,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.183713,
				sizeY = 0.8289101,
				text = "已满",
				color = "FFC93034",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jr",
				varName = "enterBtn",
				posX = 0.7441251,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2153734,
				sizeY = 0.5347068,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "jr1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8857083,
					sizeY = 0.8606678,
					text = "进 入",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF65944D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
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
