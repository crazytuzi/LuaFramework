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
			name = "dht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2242188,
			sizeY = 0.1666667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9616723,
				sizeY = 0.8833331,
				image = "shunianjnjb#duihuanjiemiandiban",
				scale9Left = 0.2,
				scale9Right = 0.7,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wp",
				varName = "itembg",
				posX = 0.2047883,
				posY = 0.5083211,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.261324,
				sizeY = 0.6249997,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp",
					varName = "itemicon",
					posX = 0.5,
					posY = 0.538703,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zi",
					varName = "itemcount",
					posX = 0.3769934,
					posY = 0.2004468,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.080922,
					sizeY = 0.5224699,
					text = "999",
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1846533,
					posY = 0.2284948,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3157895,
					sizeY = 0.3225807,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lhb2",
				posX = 0.7840629,
				posY = 0.6692548,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5220034,
				sizeY = 0.7245798,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "needcount",
					posX = 0.5552019,
					posY = 0.1897641,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.456257,
					sizeY = 0.6023577,
					text = "999",
					color = "FFFFF600",
					fontSize = 22,
					fontOutlineColor = "FF804000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "stq2",
					varName = "needicon",
					posX = 0.2964532,
					posY = 0.2973888,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4004939,
					sizeY = 0.690055,
					image = "items8#wannenghuobi",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "cz2",
					varName = "needbtn",
					posX = 0.4655904,
					posY = 0.2262094,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6597601,
					sizeY = 0.4707785,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "sy",
				varName = "synums",
				posX = 0.7365431,
				posY = 0.2213128,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4661335,
				sizeY = 0.3295303,
				text = "剩余9999次",
				color = "FFFFF600",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
