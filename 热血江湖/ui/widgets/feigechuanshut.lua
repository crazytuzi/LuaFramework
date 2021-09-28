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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2257757,
			sizeY = 0.1194545,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "postBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "b#scd1",
				imagePressed = "b#scd2",
				imageDisable = "b#scd1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bgIcon",
				posX = 0.1752694,
				posY = 0.4883731,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2768235,
				sizeY = 0.9301543,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "postIcon",
					posX = 0.4997493,
					posY = 0.5188347,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8241158,
					sizeY = 0.8363144,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sj5",
				varName = "name",
				posX = 0.6569417,
				posY = 0.7386907,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6050767,
				sizeY = 0.5933304,
				text = "信纸名称",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lhb2",
				varName = "currencyIcon",
				posX = 0.4149706,
				posY = 0.2986529,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1384117,
				sizeY = 0.4650771,
				image = "items4#longhunbi",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sj6",
				varName = "count",
				posX = 0.6501746,
				posY = 0.3091115,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3076016,
				sizeY = 0.5933304,
				text = "x500",
				color = "FF966856",
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
