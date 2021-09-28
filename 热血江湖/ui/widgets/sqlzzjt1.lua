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
			name = "jie1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6292948,
			sizeY = 0.08532766,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				varName = "bgIcon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9733117,
				sizeY = 1.041736,
				image = "sblz#wo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc1",
				posX = 0.1485638,
				posY = 0.4862241,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "名字",
				color = "FFF7FFDE",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				posX = 0.2933294,
				posY = 0.4862239,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "击杀",
				color = "FFF7FFDE",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc3",
				posX = 0.4380951,
				posY = 0.4862239,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "死亡",
				color = "FFF7FFDE",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc4",
				posX = 0.5828605,
				posY = 0.4862239,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "灵能",
				color = "FFF7FFDE",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc5",
				posX = 0.7276263,
				posY = 0.4862238,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "荣耀",
				color = "FFF7FFDE",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc6",
				posX = 0.8723918,
				posY = 0.4862239,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2069592,
				sizeY = 1.551512,
				text = "会武币",
				color = "FFF7FFDE",
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
