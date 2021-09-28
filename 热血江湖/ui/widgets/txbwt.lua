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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.721468,
			sizeY = 0.06953613,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xuan",
				posX = 0.5,
				posY = 0.05992089,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.05992089,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs1",
				varName = "rankTxt",
				posX = 0.05988622,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09600405,
				sizeY = 0.991278,
				text = "4",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs2",
				varName = "name",
				posX = 0.2635722,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1884028,
				sizeY = 0.9912785,
				text = "4",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs3",
				varName = "level",
				posX = 0.4616204,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1016626,
				sizeY = 0.9912775,
				text = "4",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs4",
				varName = "career",
				posX = 0.5978373,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1000621,
				sizeY = 0.9912775,
				text = "4",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs5",
				varName = "fighting",
				posX = 0.7372971,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1032639,
				sizeY = 0.9912785,
				text = "4",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hs6",
				varName = "awardNum",
				posX = 0.9044156,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1465846,
				sizeY = 0.991278,
				text = "4",
				color = "FF634624",
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
