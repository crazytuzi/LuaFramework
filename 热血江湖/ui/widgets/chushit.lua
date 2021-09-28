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
			name = "tj1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4008791,
			sizeY = 0.07222223,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zt",
				varName = "imgScore",
				posX = 0.07728372,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1422655,
				sizeY = 0.576923,
				image = "baishi#a",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jdd",
				posX = 0.6925462,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6263549,
				sizeY = 0.7115384,
				image = "baishi#c",
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jdt",
					varName = "progCond",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "baishi#d",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ms1",
				varName = "txtDescpt",
				posX = 0.4742122,
				posY = 0.4807686,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6295888,
				sizeY = 0.7800522,
				text = "条件五个字",
				color = "FF914A15",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ms2",
				varName = "txtScore",
				posX = 0.07338604,
				posY = 0.4999996,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1303594,
				sizeY = 0.7800522,
				text = "20分",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "imgSuccess",
				posX = 0.97673,
				posY = 0.5384616,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07405599,
				sizeY = 0.6538461,
				image = "baishi#dd",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ms3",
				varName = "txtProgress",
				posX = 0.6653786,
				posY = 0.480768,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5019753,
				sizeY = 0.7800522,
				text = "200/300",
				color = "FF914A15",
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
