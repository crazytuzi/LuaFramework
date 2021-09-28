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
			sizeX = 0.6762072,
			sizeY = 0.08333334,
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
				image = "phb#db2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tpm1",
				varName = "rankImg",
				posX = 0.1121631,
				posY = 0.5139253,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1467283,
				sizeY = 1.016667,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "rankLabel",
				posX = 0.1121631,
				posY = 0.493062,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1482045,
				sizeY = 0.6239706,
				text = "4.",
				color = "FF966856",
				fontSize = 26,
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
				posX = 0.5796494,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 1.358573,
				text = "Lv.40",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.3354405,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 1.358573,
				text = "你是一个大大草包",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj2",
				varName = "chessValue",
				posX = 0.8493631,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 1.358573,
				text = "Lv.40",
				color = "FF966856",
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
