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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0859375,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8545455,
				sizeY = 0.9399999,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "infoBtn",
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
					etype = "Label",
					name = "sx",
					varName = "countLabel",
					posX = 0.06449927,
					posY = 0.19601,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.72392,
					sizeY = 0.454107,
					text = "x100",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5026645,
					posY = 0.5153987,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7463084,
					sizeY = 0.7594906,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.2074697,
					posY = 0.221437,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3294117,
					sizeY = 0.3294118,
					image = "tb#suo",
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
