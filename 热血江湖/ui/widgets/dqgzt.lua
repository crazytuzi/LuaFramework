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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1289063,
			sizeY = 0.2763889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "bg_icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.993939,
				sizeY = 0.9999999,
				image = "bpdq#dq1",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "frame",
				varName = "frame",
				posX = 0.5155938,
				posY = 0.5026263,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9546769,
				sizeY = 0.9510641,
			},
		},
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
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj",
				varName = "factionName",
				posX = 0.513859,
				posY = 0.1052724,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.507253,
				sizeY = 0.2586875,
				text = "占领帮派名字",
				fontOutlineEnable = true,
				fontOutlineColor = "FF3D4953",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj2",
				varName = "mapName",
				posX = 0.5,
				posY = 0.3061367,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.329838,
				sizeY = 0.2409808,
				text = "地图名字",
				color = "FF966856",
				fontOutlineColor = "FF372214",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
				lineSpaceAdd = -2,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bptb",
				varName = "factionIcon",
				posX = 0.5,
				posY = 0.616178,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.65625,
				sizeY = 0.5526316,
				image = "bptb2#101",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj3",
				varName = "state",
				posX = 0.5138592,
				posY = 0.1002474,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8069463,
				sizeY = 0.6613826,
				text = "未占领",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF95959B",
				fontOutlineSize = 2,
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
