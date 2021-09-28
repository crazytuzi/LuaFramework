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
			name = "jie2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6292948,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db2",
				posX = 0.4940625,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9388021,
				sizeY = 0.9599999,
				image = "b#xpd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc7",
				varName = "nameLabel",
				posX = 0.1485638,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "名字",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc8",
				varName = "killLabel",
				posX = 0.2933294,
				posY = 0.4999996,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "击杀",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc9",
				varName = "deadLabel",
				posX = 0.4380951,
				posY = 0.4999996,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "死亡",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc10",
				varName = "teamScoreLabel",
				posX = 0.5828605,
				posY = 0.4999996,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "灵能",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc11",
				varName = "honorLabel",
				posX = 0.7276263,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "荣耀",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc12",
				varName = "coinLabel",
				posX = 0.8723918,
				posY = 0.4999996,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "会武币",
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
