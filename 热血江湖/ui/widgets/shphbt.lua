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
			name = "jjpht2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7419289,
			sizeY = 0.08333334,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "queryBtn",
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
				name = "tdt2",
				varName = "sharder2",
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
				name = "tpm3",
				varName = "rankImg",
				posX = 0.1215247,
				posY = 0.5139253,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1337308,
				sizeY = 1.016667,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm4",
				varName = "rankLabel",
				posX = 0.1215247,
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
				name = "tdj4",
				varName = "lvl",
				posX = 0.551259,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1656518,
				sizeY = 0.6205857,
				text = "Lv.40",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "name",
				posX = 0.3363918,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 0.6205857,
				text = "你是一个大大草包",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj5",
				varName = "power",
				posX = 0.7051907,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1656518,
				sizeY = 0.6205857,
				text = "Lv.40",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj6",
				varName = "score",
				posX = 0.8666849,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1656518,
				sizeY = 0.6205857,
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
