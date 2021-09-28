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
			sizeX = 0.1289063,
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bg",
				posX = 0.2375,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4751514,
				sizeY = 0.98,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5064191,
					posY = 0.5063362,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7625939,
					sizeY = 0.7614548,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ss",
					varName = "suo",
					posX = 0.2004723,
					posY = 0.2253494,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.35,
					sizeY = 0.35,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btns",
					varName = "btn",
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
					name = "sl",
					varName = "count",
					posX = 1.804639,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.611195,
					sizeY = 0.474427,
					text = "x500000",
					color = "FF966856",
					fontSize = 18,
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
