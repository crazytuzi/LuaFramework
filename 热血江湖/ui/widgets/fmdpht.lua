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
			sizeX = 0.6511089,
			sizeY = 0.1,
		},
		children = {
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
				posX = 0.07335207,
				posY = 0.5139253,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1523843,
				sizeY = 0.8472222,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "rankLabel",
				posX = 0.07455199,
				posY = 0.493062,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1482045,
				sizeY = 0.6239706,
				text = "4.",
				color = "FFFFE612",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF856343",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj",
				varName = "lvlLabel",
				posX = 0.5158067,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1114538,
				sizeY = 0.6205857,
				text = "Lv.40",
				color = "FF008000",
				fontSize = 24,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.2890345,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 0.6205857,
				text = "你是一个大大草包",
				color = "FF43261D",
				fontSize = 24,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj2",
				varName = "killedNum",
				posX = 0.9029495,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1114538,
				sizeY = 0.6205857,
				text = "Lv.40",
				color = "FF911D02",
				fontSize = 24,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj3",
				varName = "killNum",
				posX = 0.7051786,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1114538,
				sizeY = 0.6205857,
				text = "Lv.40",
				color = "FF008000",
				fontSize = 24,
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
