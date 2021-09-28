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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2414062,
			sizeY = 0.06146124,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt3",
				varName = "diwen",
				posX = 0.4428912,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5812194,
				sizeY = 0.8359586,
				image = "d2#xhd",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.1210986,
				posY = 0.4826389,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1391586,
				sizeY = 0.9717054,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "propertyIcon",
					posX = 0.4836753,
					posY = 0.5394987,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7855316,
					sizeY = 0.7780383,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "propertyName",
				posX = 0.4162329,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4324658,
				sizeY = 0.919449,
				text = "气血:",
				color = "FFF45481",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "propertyValue",
				posX = 0.7931941,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3430338,
				sizeY = 0.919449,
				text = "123123",
				color = "FF1F9400",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				posX = 0.5814565,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04530745,
				sizeY = 0.338967,
				image = "chu1#jt",
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
