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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6673955,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jfd",
				varName = "mbrCnt",
				posX = 0.2517929,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2232685,
				sizeY = 0.8016629,
				text = "15",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jfd2",
				varName = "order",
				posX = 0.1088504,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2232685,
				sizeY = 0.8016629,
				text = "1",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jfd3",
				varName = "mapLvl",
				posX = 0.3947354,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2232685,
				sizeY = 0.8016629,
				text = "70",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jfd4",
				varName = "killed",
				posX = 0.5376779,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2232685,
				sizeY = 0.8016629,
				text = "否",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jfd5",
				varName = "time",
				posX = 0.7208114,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2232685,
				sizeY = 0.8016629,
				text = "时间",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "detail",
				posX = 0.889168,
				posY = 0.4777778,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1439832,
				sizeY = 0.6444445,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8438206,
					sizeY = 0.9856026,
					text = "查 看",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
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
