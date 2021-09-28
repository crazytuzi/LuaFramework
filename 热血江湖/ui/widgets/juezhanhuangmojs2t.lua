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
			sizeX = 0.5640625,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbt",
				varName = "bgIcon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 1,
				image = "jzhm#liang",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z7",
				varName = "name",
				posX = 0.07700703,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2145734,
				sizeY = 1.156811,
				text = "名称",
				color = "FF7A3A3A",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z8",
				varName = "score1",
				posX = 0.2439588,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2145734,
				sizeY = 1.156811,
				text = "名称",
				color = "FF7A3A3A",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z9",
				varName = "score2",
				posX = 0.414134,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2145734,
				sizeY = 1.156811,
				text = "名称",
				color = "FF7A3A3A",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z10",
				varName = "score3",
				posX = 0.5873352,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2145734,
				sizeY = 1.156811,
				text = "名称",
				color = "FF7A3A3A",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z11",
				varName = "score4",
				posX = 0.7501016,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2145734,
				sizeY = 1.156811,
				text = "名称",
				color = "FF7A3A3A",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z12",
				varName = "totalScoreTxt",
				posX = 0.9180825,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2145734,
				sizeY = 1.156811,
				text = "名称",
				color = "FF5037A2",
				fontOutlineColor = "FF143230",
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
