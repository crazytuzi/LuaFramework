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
			name = "xjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "sj1",
				varName = "img34",
				posX = 0.5088952,
				posY = 0.6748433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj2",
				varName = "img21",
				posX = 0.1839622,
				posY = 0.6748434,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj3",
				varName = "img26",
				posX = 0.184192,
				posY = 0.1133039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj4",
				varName = "img22",
				posX = 0.1839622,
				posY = 0.4876635,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj5",
				varName = "img23",
				posX = 0.07605226,
				posY = 0.4876635,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj6",
				varName = "img29",
				posX = 0.5088952,
				posY = 0.1133039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj7",
				varName = "img28",
				posX = 0.4004716,
				posY = 0.1133039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj8",
				varName = "img25",
				posX = 0.07605226,
				posY = 0.1133039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj9",
				varName = "img24",
				posX = 0.07605226,
				posY = 0.3004837,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj10",
				varName = "img40",
				posX = 0.9400291,
				posY = 0.6748433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj11",
				varName = "img39",
				posX = 0.9400291,
				posY = 0.4876635,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj12",
				varName = "img38",
				posX = 0.8323712,
				posY = 0.4876635,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj13",
				varName = "img37",
				posX = 0.7247134,
				posY = 0.4876635,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj14",
				varName = "img36",
				posX = 0.7247134,
				posY = 0.6748433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj15",
				varName = "img35",
				posX = 0.6168044,
				posY = 0.6748433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj16",
				varName = "img31",
				posX = 0.6168044,
				posY = 0.3004837,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj17",
				varName = "img30",
				posX = 0.6168044,
				posY = 0.1133039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj18",
				varName = "img27",
				posX = 0.2923318,
				posY = 0.1133039,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj19",
				varName = "img32",
				posX = 0.5088952,
				posY = 0.3004837,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sj20",
				varName = "img33",
				posX = 0.5088952,
				posY = 0.4876635,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.25,
				image = "dfwdj2#tu",
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
