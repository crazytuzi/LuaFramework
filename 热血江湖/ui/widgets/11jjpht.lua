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
			sizeX = 0.5789062,
			sizeY = 0.1,
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
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tdt",
				varName = "sharder",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "d#tyd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tpm1",
				varName = "rankImg",
				posX = 0.08367081,
				posY = 0.5139253,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.17139,
				sizeY = 0.8472222,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "rankLabel",
				posX = 0.08637415,
				posY = 0.493062,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1482045,
				sizeY = 0.6239706,
				text = "4.",
				color = "FF966856",
				fontSize = 26,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ttxk",
				varName = "occupation",
				posX = 0.5200686,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06072875,
				sizeY = 0.6315786,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj",
				varName = "lvlLabel",
				posX = 0.6530762,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1114538,
				sizeY = 0.6205857,
				text = "Lv.40",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.3067838,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 0.6205857,
				text = "你是一个大大草包",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl",
				varName = "power",
				posX = 0.8556235,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 0.6205857,
				text = "9999999",
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
