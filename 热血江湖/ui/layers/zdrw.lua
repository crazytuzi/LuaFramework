--version = 1
local l_fileType = "layer"

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
			name = "renwu",
			varName = "taskRoot",
			posX = 0.9180776,
			posY = 0.8835866,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1576897,
			sizeY = 0.2263464,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "gg",
				posX = 0.2753555,
				posY = 0.7587463,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8818743,
				sizeY = 0.3743034,
				image = "zdte#dtdw",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "hxa",
				varName = "worldline_btn",
				posX = 0.2995812,
				posY = 0.7809604,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7963354,
				sizeY = 0.4472066,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "zban",
				varName = "toMapBtn",
				posX = 0.7842771,
				posY = 0.7634655,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4359828,
				sizeY = 0.5399786,
				image = "zdte#sjdt",
				imageNormal = "zdte#sjdt",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zb",
				varName = "worldCoord",
				posX = 0.3536808,
				posY = 0.6481269,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6433821,
				sizeY = 0.2428182,
				text = "座标",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dtmc",
				varName = "mapName",
				posX = 0.3239549,
				posY = 0.8288953,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.014888,
				sizeY = 0.3591983,
				text = "地图名称",
				color = "FF634624",
				fontSize = 18,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
