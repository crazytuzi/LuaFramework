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
			name = "hdlbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.234375,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.89,
				sizeY = 0.9899999,
				image = "jjc#jjd2",
				imageNormal = "jjc#jjd2",
				imagePressed = "jjc#jjd3",
				imageDisable = "jjc#jjd2",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t",
				varName = "icon",
				posX = 0.6499985,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.56,
				sizeY = 0.8799999,
				image = "jjc2#sl",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z",
				varName = "name",
				posX = 0.5461211,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6513256,
				sizeY = 0.8042339,
				text = "图鉴",
				color = "FF745226",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FFF1E9D7",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "lock",
				posX = 0.8326806,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1366667,
				sizeY = 0.42,
				image = "ty#suo",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hd",
				varName = "red",
				posX = 0.9026752,
				posY = 0.8594263,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.09,
				sizeY = 0.28,
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
