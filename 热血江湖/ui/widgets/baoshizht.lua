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
			etype = "Button",
			name = "dj1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.09765625,
			sizeY = 0.1611111,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.6120691,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.68,
				sizeY = 0.7327587,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "item_icon",
					posX = 0.5099798,
					posY = 0.52,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.788,
					sizeY = 0.788,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "s1",
					varName = "item_count",
					posX = 0.5316577,
					posY = 0.1781046,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.755787,
					sizeY = 0.6875001,
					text = "x22",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF102E21",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc",
					varName = "name",
					posX = 0.4999993,
					posY = -0.0953607,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.55674,
					sizeY = 0.5715842,
					text = "mingc",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "isUp",
				posX = 0.2997638,
				posY = 0.7994691,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3619048,
				sizeY = 0.2931035,
				image = "chu1#dj",
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
