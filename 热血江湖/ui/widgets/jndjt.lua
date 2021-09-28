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
			name = "qm1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0859375,
			sizeY = 0.1305556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "onClickBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				varName = "iconBg",
				posX = 0.5,
				posY = 0.4468085,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.770772,
				sizeY = 0.8829784,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "itemIcon",
					posX = 0.4955309,
					posY = 0.52438,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7947796,
					sizeY = 0.8281333,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lockImg",
					posX = 0.1903498,
					posY = 0.216017,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2948638,
					sizeY = 0.3012049,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sld",
				posX = 0.7179276,
				posY = 0.181357,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3,
				sizeY = 0.2234042,
				image = "zd#sld",
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "js1",
					varName = "itemCount",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.202519,
					sizeY = 1.202993,
					text = "66",
					fontSize = 18,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "LoadingBar",
				name = "cd",
				varName = "itemCD",
				posX = 0.4954529,
				posY = 0.3937918,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7169999,
				sizeY = 0.7222137,
				image = "b#dd",
				alpha = 0.7,
				barDirection = 3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mzd",
				posX = 0.5181818,
				posY = 0.8297873,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8712114,
				sizeY = 0.2664609,
				image = "zd#mzd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "itemName",
					posX = 0.4686956,
					posY = 0.5470322,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.268346,
					sizeY = 2.015424,
					text = "道具名称",
					fontSize = 18,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
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
