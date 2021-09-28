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
				varName = "img10",
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
				varName = "img9",
				posX = 0.4004716,
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
				varName = "img8",
				posX = 0.2918282,
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
				name = "sj4",
				varName = "img7",
				posX = 0.2918282,
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
				varName = "img6",
				posX = 0.2918282,
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
				name = "sj6",
				varName = "img5",
				posX = 0.2918282,
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
				varName = "img4",
				posX = 0.1839622,
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
				varName = "img2",
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
				name = "sj9",
				varName = "img1",
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
				name = "sj10",
				varName = "img20",
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
				varName = "img19",
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
				varName = "img18",
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
				varName = "img17",
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
				varName = "img16",
				posX = 0.7247134,
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
				name = "sj15",
				varName = "img15",
				posX = 0.7247134,
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
				name = "sj16",
				varName = "img14",
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
				name = "sj17",
				varName = "img13",
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
				name = "sj18",
				varName = "img3",
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
				name = "sj19",
				varName = "img12",
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
				varName = "img11",
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
